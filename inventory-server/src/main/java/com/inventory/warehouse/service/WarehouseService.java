package com.inventory.warehouse.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.common.exception.BusinessException;
import com.inventory.inventory.entity.Inventory;
import com.inventory.inventory.mapper.InventoryMapper;
import com.inventory.product.entity.Product;
import com.inventory.product.mapper.ProductMapper;
import com.inventory.purchase.entity.PurchaseOrder;
import com.inventory.purchase.mapper.PurchaseOrderMapper;
import com.inventory.sales.entity.SalesOrder;
import com.inventory.sales.mapper.SalesOrderMapper;
import com.inventory.transfer.entity.InventoryTransfer;
import com.inventory.transfer.mapper.InventoryTransferMapper;
import com.inventory.warehouse.entity.Warehouse;
import com.inventory.warehouse.mapper.WarehouseMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.inventory.warehouse.entity.WarehouseImportVO;
import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;
import cn.hutool.core.date.DateUtil;
import org.apache.ibatis.session.ExecutorType;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import java.util.Date;

@Service
public class WarehouseService {

    private final WarehouseMapper warehouseMapper;
    private final InventoryMapper inventoryMapper;
    private final PurchaseOrderMapper purchaseOrderMapper;
    private final SalesOrderMapper salesOrderMapper;
    private final InventoryTransferMapper transferMapper;
    private final ProductMapper productMapper;
    private final SqlSessionFactory sqlSessionFactory;

    public WarehouseService(WarehouseMapper warehouseMapper, InventoryMapper inventoryMapper,
                            PurchaseOrderMapper purchaseOrderMapper, SalesOrderMapper salesOrderMapper,
                            InventoryTransferMapper transferMapper,
                            ProductMapper productMapper,
                            SqlSessionFactory sqlSessionFactory) {
        this.warehouseMapper = warehouseMapper;
        this.inventoryMapper = inventoryMapper;
        this.purchaseOrderMapper = purchaseOrderMapper;
        this.salesOrderMapper = salesOrderMapper;
        this.transferMapper = transferMapper;
        this.productMapper = productMapper;
        this.sqlSessionFactory = sqlSessionFactory;
    }

    /** 仓库统计上下文：SQL 聚合 + 内存计算，避免加载全量库存（144 万 → 1.2 万行） */
    private static class StatsContext {
        final Map<Long, List<Long>> childMap;          // parentId → childIds
        final Map<Long, Set<Long>> leafDescendants;     // nodeId → 所有叶子后代ID集合
        final Map<Long, Integer> qtyByWh;               // warehouseId → 总数量
        final Map<Long, BigDecimal> amtByWh;            // warehouseId → 总金额
        final Map<Long, Warehouse> whMap;               // id → warehouse

        StatsContext(Map<Long, List<Long>> childMap, Map<Long, Set<Long>> leafDescendants,
                    Map<Long, Integer> qtyByWh, Map<Long, BigDecimal> amtByWh,
                    Map<Long, Warehouse> whMap) {
            this.childMap = childMap; this.leafDescendants = leafDescendants;
            this.qtyByWh = qtyByWh; this.amtByWh = amtByWh; this.whMap = whMap;
        }

        StatsContext(WarehouseService svc) {
            // 1. 全量加载仓库（1 次 SQL）
            List<Warehouse> all = svc.warehouseMapper.selectList(
                    new LambdaQueryWrapper<Warehouse>().eq(Warehouse::getDeleted, 0));
            whMap = all.stream().collect(Collectors.toMap(Warehouse::getId, w -> w, (a, b) -> a));

            // 2. 构建 childMap（纯内存）
            childMap = new HashMap<>();
            for (Warehouse w : all) {
                if (w.getParentId() != null) {
                    childMap.computeIfAbsent(w.getParentId(), k -> new ArrayList<>()).add(w.getId());
                }
            }

            // 3. SQL 聚合库存统计（1 次 SQL，返回 ~12K 行而非 144 万行）
            qtyByWh = new HashMap<>();
            amtByWh = new HashMap<>();
            for (Map<String, Object> row : svc.inventoryMapper.selectWarehouseStats()) {
                Long whId = toLong(row.get("warehouse_id"));
                if (whId != null) {
                    qtyByWh.put(whId, toInt(row.get("total_qty")));
                    Object amt = row.get("total_amt");
                    amtByWh.put(whId, amt != null ? new BigDecimal(amt.toString()) : BigDecimal.ZERO);
                }
            }

            // 4. 自底向上计算每个节点的叶子后代集合（纯内存）
            leafDescendants = new HashMap<>();
            List<Warehouse> sorted = new ArrayList<>(all);
            sorted.sort((a, b) -> Integer.compare(
                    b.getLevel() != null ? b.getLevel() : 0,
                    a.getLevel() != null ? a.getLevel() : 0));
            for (Warehouse w : sorted) {
                List<Long> children = childMap.get(w.getId());
                if (children == null || children.isEmpty()) {
                    Set<Long> s = new HashSet<>();
                    s.add(w.getId());
                    leafDescendants.put(w.getId(), s);
                } else {
                    Set<Long> s = new HashSet<>();
                    for (Long cid : children) {
                        Set<Long> childLeaves = leafDescendants.get(cid);
                        if (childLeaves != null) s.addAll(childLeaves);
                    }
                    leafDescendants.put(w.getId(), s);
                }
            }
        }

        private static Long toLong(Object v) {
            if (v instanceof Long) return (Long) v;
            if (v instanceof Number) return ((Number) v).longValue();
            return null;
        }
        private static int toInt(Object v) {
            if (v instanceof Number) return ((Number) v).intValue();
            return 0;
        }
    }

    private StatsContext loadStatsContext() {
        return new StatsContext(this);
    }

    /** 纯内存 enrich，用预聚合数据，0 次 SQL */
    private void enrichStats(Warehouse w, StatsContext ctx) {
        Set<Long> leafIds = ctx.leafDescendants.get(w.getId());
        if (leafIds == null || leafIds.isEmpty()) {
            w.setProductCount(0);
            w.setTotalAmount(BigDecimal.ZERO);
            w.setHasChildren(false);
            return;
        }
        w.setHasChildren(ctx.childMap.containsKey(w.getId())
                && !ctx.childMap.get(w.getId()).isEmpty());

        int totalQty = 0;
        BigDecimal totalAmt = BigDecimal.ZERO;
        for (Long leafId : leafIds) {
            totalQty += ctx.qtyByWh.getOrDefault(leafId, 0);
            totalAmt = totalAmt.add(ctx.amtByWh.getOrDefault(leafId, BigDecimal.ZERO));
        }
        w.setProductCount(totalQty);
        w.setTotalAmount(totalAmt);
    }

    public Warehouse getById(Long id) {
        Warehouse w = warehouseMapper.selectById(id);
        if (w != null) w.setHasChildren(hasChildren(w.getId()));
        return w;
    }

    public List<Warehouse> tree() { return tree(true); }

    public List<Warehouse> tree(boolean enrichStats) {
        StatsContext ctx = enrichStats ? loadStatsContext() : loadTreeOnly();
        List<Warehouse> all = new ArrayList<>(ctx.whMap.values());
        all.sort(Comparator.comparing(Warehouse::getId));
        if (enrichStats) {
            for (Warehouse w : all) enrichStats(w, ctx);
        } else {
            for (Warehouse w : all) w.setHasChildren(ctx.childMap.containsKey(w.getId())
                    && !ctx.childMap.get(w.getId()).isEmpty());
        }
        List<Warehouse> roots = new ArrayList<>();
        for (Warehouse w : all) {
            if (w.getParentId() == null) {
                roots.add(w);
            } else {
                Warehouse parent = ctx.whMap.get(w.getParentId());
                if (parent != null) {
                    if (parent.getChildren() == null) parent.setChildren(new ArrayList<>());
                    parent.getChildren().add(w);
                }
            }
        }
        return roots;
    }

    /** 仅加载树结构，不加载库存聚合（用于筛选下拉框场景） */
    private StatsContext loadTreeOnly() {
        List<Warehouse> all = warehouseMapper.selectList(
                new LambdaQueryWrapper<Warehouse>().eq(Warehouse::getDeleted, 0));
        Map<Long, Warehouse> whMap = all.stream()
                .collect(Collectors.toMap(Warehouse::getId, w -> w, (a, b) -> a));
        Map<Long, List<Long>> childMap = new HashMap<>();
        for (Warehouse w : all) {
            if (w.getParentId() != null) {
                childMap.computeIfAbsent(w.getParentId(), k -> new ArrayList<>()).add(w.getId());
            }
        }
        return new StatsContext(childMap, Collections.emptyMap(), Collections.emptyMap(),
                Collections.emptyMap(), whMap);
    }

    public List<Warehouse> children(Long parentId) {
        return warehouseMapper.selectList(new LambdaQueryWrapper<Warehouse>()
                .eq(Warehouse::getParentId, parentId)
                .eq(Warehouse::getStatus, 1)
                .orderByAsc(Warehouse::getId));
    }

    public List<Warehouse> search(String keyword, Integer level, Integer status) {
        StatsContext ctx = loadStatsContext();
        return ctx.whMap.values().stream()
                .filter(w -> status == null ? w.getStatus() != null && w.getStatus() == 1
                        : w.getStatus() != null && w.getStatus().equals(status))
                .filter(w -> level == null || w.getLevel() != null && w.getLevel().equals(level))
                .filter(w -> keyword == null || keyword.isEmpty()
                        || (w.getName() != null && w.getName().contains(keyword))
                        || (w.getCode() != null && w.getCode().contains(keyword)))
                .sorted(Comparator.comparing(Warehouse::getId))
                .peek(w -> enrichStats(w, ctx))
                .collect(Collectors.toList());
    }

    public List<Warehouse> listAll() {
        StatsContext ctx = loadStatsContext();
        // 叶子节点（无子级）用于单据选择
        Set<Long> parentIds = new HashSet<>(ctx.childMap.keySet());
        return ctx.whMap.values().stream()
                .filter(w -> w.getStatus() != null && w.getStatus() == 1)
                .filter(w -> !parentIds.contains(w.getId()))  // 排除非叶子
                .peek(w -> enrichStats(w, ctx))
                .collect(Collectors.toList());
    }

    public List<Warehouse> exportAll() {
        // 导出全部仓库（按层级显示）
        return warehouseMapper.selectList(new LambdaQueryWrapper<Warehouse>()
                .orderByAsc(Warehouse::getLevel, Warehouse::getId));
    }

    public List<Warehouse> roots(Integer status) {
        StatsContext ctx = loadStatsContext();
        return ctx.whMap.values().stream()
                .filter(w -> w.getLevel() != null && w.getLevel() == 1)
                .filter(w -> status == null || w.getStatus() != null && w.getStatus().equals(status))
                .sorted(Comparator.comparing(Warehouse::getId))
                .peek(w -> enrichStats(w, ctx))
                .collect(Collectors.toList());
    }

    public List<Warehouse> childrenAll(Long parentId, Integer status) {
        StatsContext ctx = loadStatsContext();
        List<Long> childIds = ctx.childMap.getOrDefault(parentId, Collections.emptyList());
        return childIds.stream()
                .map(ctx.whMap::get)
                .filter(Objects::nonNull)
                .filter(w -> status == null || w.getStatus() != null && w.getStatus().equals(status))
                .peek(w -> enrichStats(w, ctx))
                .collect(Collectors.toList());
    }

    public Page<Warehouse> page(Page<Warehouse> page, String name, String contact, String phone,
                                String address, Integer status, Integer level, Long parentId) {
        LambdaQueryWrapper<Warehouse> wrapper = new LambdaQueryWrapper<Warehouse>()
                .like(name != null, Warehouse::getName, name)
                .like(contact != null, Warehouse::getContact, contact)
                .like(phone != null, Warehouse::getPhone, phone)
                .like(address != null, Warehouse::getAddress, address)
                .eq(status != null, Warehouse::getStatus, status)
                .eq(level != null, Warehouse::getLevel, level)
                .eq(parentId != null, Warehouse::getParentId, parentId)
                .orderByDesc(Warehouse::getId);
        Page<Warehouse> result = warehouseMapper.selectPage(page, wrapper);
        StatsContext ctx = loadStatsContext();
        for (Warehouse w : result.getRecords()) {
            enrichStats(w, ctx);
            if (w.getParentId() != null) {
                Warehouse parent = ctx.whMap.get(w.getParentId());
                if (parent != null) w.setParentName(parent.getName());
            }
        }
        return result;
    }

    private boolean hasChildren(Long id) {
        return warehouseMapper.selectCount(
                new LambdaQueryWrapper<Warehouse>().eq(Warehouse::getParentId, id)) > 0;
    }

    @Transactional(rollbackFor = Exception.class)
    public void save(Warehouse warehouse) {
        warehouse.setCode(generateWarehouseCode());
        // 校验层级连续性：子级层级 = 父级层级 + 1
        if (warehouse.getParentId() != null) {
            Warehouse parent = warehouseMapper.selectById(warehouse.getParentId());
            if (parent != null && warehouse.getLevel() != null) {
                if (parent.getLevel() == null || warehouse.getLevel() != parent.getLevel() + 1) {
                    throw new BusinessException("仓库层级不连续，子级层级必须为父级层级+1");
                }
                // 有库存的仓库不可再建子级（库存归属会混乱）
                long invCount = inventoryMapper.selectCount(
                        new LambdaQueryWrapper<Inventory>().eq(Inventory::getWarehouseId, warehouse.getParentId()));
                if (invCount > 0) {
                    throw new BusinessException("该仓库存在库存记录，不可新建子级仓库，请先清空库存");
                }
            }
        }
        warehouseMapper.insert(warehouse);
    }

    private synchronized String generateWarehouseCode() {
        String prefix = "WH";
        String dateStr = DateUtil.format(new Date(), "yyyyMMdd");
        String likePrefix = prefix + dateStr;

        String maxCode = warehouseMapper.selectMaxCodeByPrefix(likePrefix);
        int seq = 1;
        if (maxCode != null) {
            seq = Integer.parseInt(maxCode.substring(maxCode.length() - 6)) + 1;
        }

        String code = likePrefix + String.format("%06d", seq);
        while (warehouseMapper.countAllByCode(code) > 0) {
            seq++;
            code = likePrefix + String.format("%06d", seq);
        }
        return code;
    }

    @Transactional
    public void update(Warehouse warehouse) {
        Warehouse existing = warehouseMapper.selectById(warehouse.getId());
        if (existing == null) throw new BusinessException("仓库不存在");

        // 禁止修改层级
        if (warehouse.getLevel() != null && !warehouse.getLevel().equals(existing.getLevel())) {
            throw new BusinessException("层级不可修改");
        }

        // 禁止修改有库存仓库的上级（防止库存归属混乱）
        if (warehouse.getParentId() != null && !warehouse.getParentId().equals(existing.getParentId())) {
            long invCount = inventoryMapper.selectCount(
                    new LambdaQueryWrapper<Inventory>().eq(Inventory::getWarehouseId, warehouse.getId()));
            if (invCount > 0) {
                throw new BusinessException("该仓库存在库存记录，无法调整上级");
            }
            long childCount = warehouseMapper.selectCount(
                    new LambdaQueryWrapper<Warehouse>().eq(Warehouse::getParentId, warehouse.getId()));
            if (childCount > 0) {
                throw new BusinessException("该仓库存在子级仓库，无法调整上级");
            }
        }

        warehouseMapper.updateById(warehouse);
    }

    @Transactional
    public void delete(Long id) {
        Warehouse w = warehouseMapper.selectById(id);
        if (w == null) throw new BusinessException("仓库不存在");

        // 父节点：检查是否有子仓库
        if (hasChildren(id)) {
            throw new BusinessException("该仓库存在子级仓库，请先删除子级仓库");
        }

        // 检查库存
        long invCount = inventoryMapper.selectCount(
                new LambdaQueryWrapper<Inventory>().eq(Inventory::getWarehouseId, id));
        if (invCount > 0) throw new BusinessException("该仓库存在库存记录，无法删除，请先清空库存");

        // 检查采购入库单引用（包含所有状态）
        long purchaseCount = purchaseOrderMapper.selectCount(
                new LambdaQueryWrapper<PurchaseOrder>().eq(PurchaseOrder::getWarehouseId, id));
        if (purchaseCount > 0) throw new BusinessException("该仓库已被采购入库单引用，无法删除");

        // 检查销售出库单引用（包含所有状态）
        long salesCount = salesOrderMapper.selectCount(
                new LambdaQueryWrapper<SalesOrder>().eq(SalesOrder::getWarehouseId, id));
        if (salesCount > 0) throw new BusinessException("该仓库已被销售出库单引用，无法删除");

        // 检查调拨单引用（包含所有状态）
        long transferCount = transferMapper.selectCount(
                new LambdaQueryWrapper<InventoryTransfer>()
                        .eq(InventoryTransfer::getFromWarehouseId, id)
                        .or()
                        .eq(InventoryTransfer::getToWarehouseId, id));
        if (transferCount > 0) throw new BusinessException("该仓库已被调拨单引用，无法删除");

        warehouseMapper.deleteById(id);
    }

    @Transactional
    public void restore(Long id) {
        Warehouse w = warehouseMapper.selectById(id);
        if (w == null) throw new BusinessException("仓库不存在");
        w.setDeleted(0);
        warehouseMapper.updateById(w);
    }

    public int importExcel(List<WarehouseImportVO> rows) {
        // 1. 加载已有仓库到缓存（name:parentId → id）
        Map<String, Long> cache = new HashMap<>();
        // 已占用的编码（来自数据库）
        Set<String> takenCodes = new HashSet<>();
        for (Warehouse w : warehouseMapper.selectList(
                new LambdaQueryWrapper<Warehouse>().eq(Warehouse::getDeleted, 0))) {
            cache.put(w.getName() + ":" + (w.getParentId() == null ? 0 : w.getParentId()), w.getId());
            if (w.getCode() != null) takenCodes.add(w.getCode());
        }

        // 2. 逐级处理（1级→2级→3级→4级）
        //    每级去重后 BATCH 插入，避免同一名称重复创建
        int created = 0;
        for (int level = 1; level <= 4; level++) {
            // key=cacheKey → Warehouse，自动去重
            Map<String, Warehouse> newWhMap = new LinkedHashMap<>();

            for (WarehouseImportVO row : rows) {
                String[] names = { row.getLevel1Name(), row.getLevel2Name(),
                                   row.getLevel3Name(), row.getLevel4Name() };
                String name = names[level - 1];
                if (name == null || name.trim().isEmpty()) continue;
                name = name.trim();

                // 计算 parentId: 从缓存取前一级的 ID
                Long parentId = null;
                for (int p = 0; p < level - 1; p++) {
                    String pn = names[p];
                    if (pn == null || pn.trim().isEmpty()) continue;
                    String ck = pn.trim() + ":" + (parentId == null ? 0 : parentId);
                    parentId = cache.get(ck);
                    if (parentId == null) break;
                }
                if (parentId == null && level > 1) continue;

                String cacheKey = name + ":" + (parentId == null ? 0 : parentId);
                if (cache.containsKey(cacheKey)) continue;
                if (newWhMap.containsKey(cacheKey)) continue; // 同一批次已加入，去重

                boolean isLast = (level == 4)
                        || (level < 4 && (names[level] == null || names[level].trim().isEmpty()));

                Warehouse w = new Warehouse();
                w.setName(name);
                w.setParentId(parentId);
                w.setLevel(level);
                if (isLast) {
                    w.setStatus("停用".equals(row.getStatus()) ? 0 : 1);
                    w.setContact(row.getContact());
                    w.setPhone(row.getPhone());
                    w.setAddress(row.getAddress());
                } else {
                    w.setStatus(1);
                }
                String customCode = row.getCode();
                if (isLast && customCode != null && !customCode.trim().isEmpty()
                        && !takenCodes.contains(customCode.trim())) {
                    w.setCode(customCode.trim());
                    takenCodes.add(customCode.trim());
                }
                newWhMap.put(cacheKey, w);
            }

            if (newWhMap.isEmpty()) continue;
            List<Warehouse> newWh = new ArrayList<>(newWhMap.values());

            if (level == 4) {
                // Level 4：BATCH 插入，编码池统一赋值，已被 takenCodes 过滤
                List<String> pool = generateWarehouseCodes(newWh.size());
                int poolIdx = 0;
                for (Warehouse w : newWh) {
                    if (w.getCode() == null || w.getCode().isEmpty()) {
                        String code = pool.get(Math.min(poolIdx++, pool.size() - 1));
                        // 确保不跟 takenCodes 冲突
                        while (takenCodes.contains(code) && poolIdx < pool.size()) {
                            code = pool.get(Math.min(poolIdx++, pool.size() - 1));
                        }
                        w.setCode(code);
                        takenCodes.add(code);
                    }
                }
                try (SqlSession session = sqlSessionFactory.openSession(ExecutorType.BATCH)) {
                    WarehouseMapper batchMapper = session.getMapper(WarehouseMapper.class);
                    for (Warehouse w : newWh) batchMapper.insert(w);
                    session.commit();
                }
                created += newWh.size();
            } else {
                // Level 1-3：逐条插入，需要返回 ID
                for (Warehouse w : newWh) {
                    if (w.getCode() == null || w.getCode().isEmpty()) {
                        w.setCode(generateWarehouseCode());
                    }
                    takenCodes.add(w.getCode());
                    warehouseMapper.insert(w);
                    cache.put(w.getName() + ":" + (w.getParentId() == null ? 0 : w.getParentId()), w.getId());
                    created++;
                }
            }
        }
        return created;
    }

    /** 批量预生成编码 */
    private synchronized List<String> generateWarehouseCodes(int count) {
        List<String> codes = new ArrayList<>(count);
        String prefix = "WH";
        String dateStr = DateUtil.format(new Date(), "yyyyMMdd");
        String likePrefix = prefix + dateStr;
        String maxCode = warehouseMapper.selectMaxCodeByPrefix(likePrefix);
        int seq = 1;
        if (maxCode != null) {
            seq = Integer.parseInt(maxCode.substring(maxCode.length() - 6)) + 1;
        }
        for (int i = 0; i < count; i++) {
            codes.add(likePrefix + String.format("%06d", seq + i));
        }
        return codes;
    }
}
