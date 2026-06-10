package com.inventory.stocktake.service;

import cn.hutool.core.date.DateUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.common.constant.OrderStatus;
import com.inventory.common.exception.BusinessException;
import com.inventory.inventory.entity.Inventory;
import com.inventory.inventory.entity.InventoryLog;
import com.inventory.inventory.mapper.InventoryLogMapper;
import com.inventory.inventory.mapper.InventoryMapper;
import com.inventory.stocktake.entity.StockTake;
import com.inventory.stocktake.entity.StockTakeDetailExportVO;
import com.inventory.stocktake.entity.StockTakeItem;
import com.inventory.stocktake.mapper.StockTakeItemMapper;
import com.inventory.stocktake.mapper.StockTakeMapper;
import com.inventory.system.entity.SysUser;
import com.inventory.system.mapper.SysUserMapper;
import com.inventory.product.entity.Product;
import com.inventory.product.mapper.ProductMapper;
import com.inventory.warehouse.entity.Warehouse;
import com.inventory.warehouse.mapper.WarehouseMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class StockTakeService {

    private final StockTakeMapper stockTakeMapper;
    private final StockTakeItemMapper stockTakeItemMapper;
    private final InventoryMapper inventoryMapper;
    private final InventoryLogMapper inventoryLogMapper;
    private final WarehouseMapper warehouseMapper;
    private final SysUserMapper sysUserMapper;
    private final ProductMapper productMapper;

    public StockTakeService(StockTakeMapper stockTakeMapper,
                            StockTakeItemMapper stockTakeItemMapper,
                            InventoryMapper inventoryMapper,
                            InventoryLogMapper inventoryLogMapper,
                            WarehouseMapper warehouseMapper,
                            SysUserMapper sysUserMapper,
                            ProductMapper productMapper) {
        this.stockTakeMapper = stockTakeMapper;
        this.stockTakeItemMapper = stockTakeItemMapper;
        this.inventoryMapper = inventoryMapper;
        this.inventoryLogMapper = inventoryLogMapper;
        this.warehouseMapper = warehouseMapper;
        this.sysUserMapper = sysUserMapper;
        this.productMapper = productMapper;
    }

    public Page<StockTake> page(Page<StockTake> page, String orderNo, Long warehouseId, Integer takeType,
                                Integer minTotalItems, Integer maxTotalItems, Integer minDiffItems, Integer maxDiffItems,
                                String operatorName, String approverName, Integer status) {
        LambdaQueryWrapper<StockTake> wrapper = new LambdaQueryWrapper<StockTake>()
                .like(orderNo != null, StockTake::getOrderNo, orderNo)
                .eq(warehouseId != null, StockTake::getWarehouseId, warehouseId)
                .eq(takeType != null, StockTake::getTakeType, takeType)
                .ge(minTotalItems != null, StockTake::getTotalItems, minTotalItems)
                .le(maxTotalItems != null, StockTake::getTotalItems, maxTotalItems)
                .ge(minDiffItems != null, StockTake::getDiffItems, minDiffItems)
                .le(maxDiffItems != null, StockTake::getDiffItems, maxDiffItems)
                .eq(status != null, StockTake::getStatus, status)
                .ne(StockTake::getStatus, OrderStatus.VOIDED)
                .orderByDesc(StockTake::getId);
        Page<StockTake> result = stockTakeMapper.selectPage(page, wrapper);
        enrichStockTakesBatch(result.getRecords());

        if (operatorName != null && !operatorName.isEmpty()) {
            List<StockTake> filtered = result.getRecords().stream()
                    .filter(t -> t.getOperatorName() != null && t.getOperatorName().contains(operatorName))
                    .collect(Collectors.toList());
            result.setRecords(filtered);
            result.setTotal(filtered.size());
        }
        if (approverName != null && !approverName.isEmpty()) {
            List<StockTake> filtered = result.getRecords().stream()
                    .filter(t -> t.getApproverName() != null && t.getApproverName().contains(approverName))
                    .collect(Collectors.toList());
            result.setRecords(filtered);
            result.setTotal(filtered.size());
        }
        return result;
    }

    public List<StockTakeDetailExportVO> getExportDetailList(List<StockTake> stocktakes) {
        // 批量预加载所有关联数据
        enrichStockTakesBatch(stocktakes);
        List<StockTakeDetailExportVO> result = new ArrayList<>();
        for (StockTake s : stocktakes) {
            List<StockTakeItem> items = s.getItems() != null ? s.getItems() : List.of();
            for (StockTakeItem item : items) {
                StockTakeDetailExportVO vo = new StockTakeDetailExportVO();
                vo.setOrderNo(s.getOrderNo());
                vo.setWarehouseName(s.getWarehouseName());
                vo.setTakeType(s.getTakeType() != null && s.getTakeType() == 0 ? "全盘" : "抽盘");
                if (s.getStatus() != null) {
                    switch (s.getStatus()) {
                        case 0: vo.setStatus("盘点中"); break;
                        case 1: vo.setStatus("已审核"); break;
                        case 2: vo.setStatus("已调整"); break;
                        default: vo.setStatus("未知"); break;
                    }
                }
                if (s.getOrderDate() != null) vo.setOrderDate(s.getOrderDate());
                if (s.getOperatorName() != null) vo.setOperatorName(s.getOperatorName());
                vo.setProductName(item.getProductName());
                vo.setProductCode(item.getProductCode());
                vo.setBatchNo(item.getBatchNo());
                vo.setBookQty(item.getBookQty());
                vo.setActualQty(item.getActualQty());
                vo.setDiffQty(item.getDiffQty());
                vo.setDiffReason(item.getDiffReason());
                result.add(vo);
            }
            if (items.isEmpty()) {
                StockTakeDetailExportVO vo = new StockTakeDetailExportVO();
                vo.setOrderNo(s.getOrderNo());
                vo.setWarehouseName(s.getWarehouseName());
                vo.setTakeType(s.getTakeType() != null && s.getTakeType() == 0 ? "全盘" : "抽盘");
                vo.setStatus(s.getStatus() != null ? (s.getStatus() == 0 ? "盘点中" : s.getStatus() == 1 ? "已审核" : "已调整") : "未知");
                if (s.getOrderDate() != null) vo.setOrderDate(s.getOrderDate());
                if (s.getOperatorName() != null) vo.setOperatorName(s.getOperatorName());
                result.add(vo);
            }
        }
        return result;
    }

    private void enrichStockTakesBatch(List<StockTake> list) {
        if (list == null || list.isEmpty()) return;
        Set<Long> stockTakeIds = new HashSet<>();
        Set<Long> warehouseIds = new HashSet<>();
        Set<Long> userIds = new HashSet<>();
        for (StockTake t : list) {
            stockTakeIds.add(t.getId());
            if (t.getWarehouseId() != null) warehouseIds.add(t.getWarehouseId());
            if (t.getOperatorId() != null) userIds.add(t.getOperatorId());
            if (t.getApproverId() != null) userIds.add(t.getApproverId());
        }
        // 批量加载明细
        List<StockTakeItem> allItems = stockTakeIds.isEmpty() ? List.of()
                : stockTakeItemMapper.selectList(
                    new LambdaQueryWrapper<StockTakeItem>().in(StockTakeItem::getStockTakeId, stockTakeIds));
        Map<Long, List<StockTakeItem>> itemMap = allItems.stream()
                .collect(Collectors.groupingBy(StockTakeItem::getStockTakeId));
        Set<Long> productIds = allItems.stream().map(StockTakeItem::getProductId)
                .filter(Objects::nonNull).collect(Collectors.toSet());
        // 批量加载关联实体
        Map<Long, Warehouse> warehouseMap = warehouseIds.isEmpty() ? new HashMap<>()
                : warehouseMapper.selectBatchIds(warehouseIds).stream()
                    .collect(Collectors.toMap(Warehouse::getId, w -> w, (a, b) -> a));
        Map<Long, SysUser> userMap = userIds.isEmpty() ? new HashMap<>()
                : sysUserMapper.selectBatchIds(userIds).stream()
                    .collect(Collectors.toMap(SysUser::getId, u -> u, (a, b) -> a));
        Map<Long, Product> productMap = productIds.isEmpty() ? new HashMap<>()
                : productMapper.selectBatchIds(productIds).stream()
                    .collect(Collectors.toMap(Product::getId, p -> p, (a, b) -> a));
        // 纯内存组装
        for (StockTake t : list) {
            Warehouse w = warehouseMap.get(t.getWarehouseId());
            if (w != null) t.setWarehouseName(w.getName());
            SysUser op = userMap.get(t.getOperatorId());
            if (op != null) t.setOperatorName(op.getRealName());
            SysUser ap = userMap.get(t.getApproverId());
            if (ap != null) t.setApproverName(ap.getRealName());
            List<StockTakeItem> items = itemMap.getOrDefault(t.getId(), List.of());
            for (StockTakeItem item : items) {
                Product p = productMap.get(item.getProductId());
                if (p != null) { item.setProductName(p.getName()); item.setProductCode(p.getCode()); }
            }
            t.setItems(items);
        }
    }

    public List<StockTake> listAll() {
        List<StockTake> list = stockTakeMapper.selectList(
                new LambdaQueryWrapper<StockTake>().orderByDesc(StockTake::getId));
        enrichStockTakesBatch(list);
        return list;
    }

    public StockTake getDetail(Long id) {
        StockTake stockTake = stockTakeMapper.selectById(id);
        if (stockTake != null) {
            List<StockTakeItem> items = stockTakeItemMapper.selectList(
                    new LambdaQueryWrapper<StockTakeItem>()
                            .eq(StockTakeItem::getStockTakeId, id));
            stockTake.setItems(items);
            enrichStockTakesBatch(List.of(stockTake));
        }
        return stockTake;
    }

    @Transactional(rollbackFor = Exception.class)
    public Long create(StockTake stockTake) {
        stockTake.setOrderNo(generateOrderNo());
        stockTake.setStatus(OrderStatus.STOCKTAKE_IN_PROGRESS);
        if (stockTake.getOrderDate() == null) {
            stockTake.setOrderDate(LocalDate.now());
        }
        stockTake.setTotalItems(0);
        stockTake.setDiffItems(0);
        stockTakeMapper.insert(stockTake);

        // 全盘：自动加载该仓库所有库存批次，每个批次独立一行
        if (stockTake.getTakeType() != null && stockTake.getTakeType() == 0) {
            List<Inventory> invList = inventoryMapper.selectList(
                    new LambdaQueryWrapper<Inventory>()
                            .eq(Inventory::getWarehouseId, stockTake.getWarehouseId())
                            .gt(Inventory::getQuantity, 0));
            for (Inventory inv : invList) {
                StockTakeItem item = new StockTakeItem();
                item.setStockTakeId(stockTake.getId());
                item.setProductId(inv.getProductId());
                item.setBatchNo(inv.getBatchNo());
                item.setBookQty(inv.getQuantity());
                item.setActualQty(inv.getQuantity());
                item.setDiffQty(0);
                stockTakeItemMapper.insert(item);
            }
            stockTake.setTotalItems(invList.size());
            stockTake.setDiffItems(0);
            stockTakeMapper.updateById(stockTake);
        }

        return stockTake.getId();
    }

    @Transactional(rollbackFor = Exception.class)
    public void addItem(StockTakeItem item) {
        // Verify stock take exists and is in progress
        StockTake stockTake = stockTakeMapper.selectById(item.getStockTakeId());
        if (stockTake == null) {
            throw new BusinessException("盘点单不存在");
        }
        if (stockTake.getStatus() != OrderStatus.STOCKTAKE_IN_PROGRESS) {
            throw new BusinessException("当前状态不可添加盘点项");
        }

        // 按批次获取账面数量
        int bookQty;
        if (item.getBatchNo() != null && !item.getBatchNo().isEmpty()) {
            Inventory inv = inventoryMapper.selectOne(
                    new LambdaQueryWrapper<Inventory>()
                            .eq(Inventory::getProductId, item.getProductId())
                            .eq(Inventory::getWarehouseId, stockTake.getWarehouseId())
                            .eq(Inventory::getBatchNo, item.getBatchNo()));
            bookQty = inv != null ? inv.getQuantity() : 0;
        } else {
            List<Inventory> invList = inventoryMapper.selectList(
                    new LambdaQueryWrapper<Inventory>()
                            .eq(Inventory::getProductId, item.getProductId())
                            .eq(Inventory::getWarehouseId, stockTake.getWarehouseId()));
            bookQty = invList.stream().mapToInt(Inventory::getQuantity).sum();
        }
        item.setBookQty(bookQty);
        int actualQty = item.getActualQty() != null ? item.getActualQty() : bookQty;
        item.setActualQty(actualQty);
        item.setDiffQty(actualQty - bookQty);

        stockTakeItemMapper.insert(item);

        // Update stock take totals
        stockTake.setTotalItems(stockTake.getTotalItems() + 1);
        if (item.getDiffQty() != 0) {
            stockTake.setDiffItems(stockTake.getDiffItems() + 1);
        }
        stockTakeMapper.updateById(stockTake);
    }

    @Transactional(rollbackFor = Exception.class)
    public void approve(Long id, Long approverId) {
        StockTake stockTake = stockTakeMapper.selectById(id);
        if (stockTake == null) {
            throw new BusinessException("盘点单不存在");
        }
        if (stockTake.getStatus() != OrderStatus.STOCKTAKE_IN_PROGRESS) {
            throw new BusinessException("当前状态不可审核");
        }
        stockTake.setStatus(OrderStatus.STOCKTAKE_APPROVED);
        stockTake.setApproverId(approverId);
        stockTakeMapper.updateById(stockTake);
    }

    @Transactional(rollbackFor = Exception.class)
    public void adjust(Long id) {
        StockTake stockTake = stockTakeMapper.selectById(id);
        if (stockTake == null) {
            throw new BusinessException("盘点单不存在");
        }
        if (stockTake.getStatus() != OrderStatus.STOCKTAKE_APPROVED) {
            throw new BusinessException("当前状态不可调整，请先审核");
        }

        List<StockTakeItem> items = stockTakeItemMapper.selectList(
                new LambdaQueryWrapper<StockTakeItem>()
                        .eq(StockTakeItem::getStockTakeId, id));

        for (StockTakeItem item : items) {
            if (item.getDiffQty() == 0) {
                continue;
            }

            // 使用审批时保存的差异值
            int diff = item.getDiffQty();
            if (diff == 0) continue;

            // 定位该批次对应的库存行
            Inventory target = null;
            if (item.getBatchNo() != null && !item.getBatchNo().isEmpty()) {
                target = inventoryMapper.selectOne(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getProductId, item.getProductId())
                                .eq(Inventory::getWarehouseId, stockTake.getWarehouseId())
                                .eq(Inventory::getBatchNo, item.getBatchNo()));
            }
            if (target == null) {
                // 未匹配到批次，取该商品第一个库存行
                List<Inventory> list = inventoryMapper.selectList(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getProductId, item.getProductId())
                                .eq(Inventory::getWarehouseId, stockTake.getWarehouseId())
                                .last("LIMIT 1"));
                target = list.isEmpty() ? null : list.get(0);
            }
            int beforeQty = target != null ? target.getQuantity() : 0;
            int afterQty = beforeQty + diff;

            if (target != null) {
                target.setQuantity(afterQty);
                if (target.getQuantity() < 0) target.setQuantity(0);
                inventoryMapper.updateById(target);
            } else if (diff > 0) {
                Inventory newInv = new Inventory();
                newInv.setProductId(item.getProductId());
                newInv.setWarehouseId(stockTake.getWarehouseId());
                newInv.setQuantity(diff);
                newInv.setLockedQty(0);
                inventoryMapper.insert(newInv);
            }

            InventoryLog log = new InventoryLog();
            log.setProductId(item.getProductId());
            log.setWarehouseId(stockTake.getWarehouseId());
            log.setBatchNo(item.getBatchNo());
            log.setChangeType(OrderStatus.STOCKTAKE_ADJUST);
            log.setChangeQty(diff);
            log.setBeforeQty(beforeQty);
            log.setAfterQty(Math.max(0, afterQty));
            log.setRefOrderNo(stockTake.getOrderNo());
            log.setOperatorId(stockTake.getOperatorId());
            log.setRemark(item.getDiffReason() != null ? item.getDiffReason() : "盘点调整");
            inventoryLogMapper.insert(log);
        }

        stockTake.setStatus(OrderStatus.STOCKTAKE_ADJUSTED);
        stockTakeMapper.updateById(stockTake);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateItem(StockTakeItem item) {
        StockTakeItem existing = stockTakeItemMapper.selectById(item.getId());
        if (existing == null) throw new BusinessException("盘点明细不存在");

        // 只更新实盘数和差异原因
        if (item.getActualQty() != null) {
            existing.setActualQty(item.getActualQty());
            existing.setDiffQty(item.getActualQty() - existing.getBookQty());
        }
        if (item.getDiffReason() != null) {
            existing.setDiffReason(item.getDiffReason());
        }
        stockTakeItemMapper.updateById(existing);

        // 重新统计差异数
        StockTake stockTake = stockTakeMapper.selectById(existing.getStockTakeId());
        if (stockTake != null) {
            List<StockTakeItem> allItems = stockTakeItemMapper.selectList(
                    new LambdaQueryWrapper<StockTakeItem>().eq(StockTakeItem::getStockTakeId, stockTake.getId()));
            long diffCount = allItems.stream().filter(i -> i.getDiffQty() != 0).count();
            stockTake.setDiffItems((int) diffCount);
            stockTakeMapper.updateById(stockTake);
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteItem(Long itemId) {
        StockTakeItem item = stockTakeItemMapper.selectById(itemId);
        if (item == null) throw new BusinessException("盘点明细不存在");
        StockTake stockTake = stockTakeMapper.selectById(item.getStockTakeId());
        stockTakeItemMapper.deleteById(itemId);
        if (stockTake != null) {
            stockTake.setTotalItems(Math.max(0, stockTake.getTotalItems() - 1));
            if (item.getDiffQty() != 0) {
                stockTake.setDiffItems(Math.max(0, stockTake.getDiffItems() - 1));
            }
            stockTakeMapper.updateById(stockTake);
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        StockTake order = stockTakeMapper.selectById(id);
        if (order == null) throw new BusinessException("盘点单不存在");
        order.setStatus(OrderStatus.VOIDED);
        stockTakeMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void batchDelete(List<Long> ids) {
        for (Long id : ids) {
            StockTake order = stockTakeMapper.selectById(id);
            if (order != null) {
                order.setStatus(OrderStatus.VOIDED);
                stockTakeMapper.updateById(order);
            }
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void voidOrder(Long id, String reason) {
        StockTake order = stockTakeMapper.selectById(id);
        if (order == null) throw new BusinessException("盘点单不存在");
        if (order.getStatus() == OrderStatus.STOCKTAKE_ADJUSTED) throw new BusinessException("已调整的盘点单不可作废");
        order.setStatus(OrderStatus.VOIDED);
        order.setRemark((order.getRemark() != null ? order.getRemark() + " | " : "") + "作废原因: " + (reason != null ? reason : ""));
        order.setUpdateTime(LocalDateTime.now());
        stockTakeMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void batchVoid(List<Long> ids, String reason) {
        for (Long id : ids) {
            voidOrder(id, reason);
        }
    }

    private synchronized String generateOrderNo() {
        String prefix = "ST";
        String dateStr = DateUtil.format(new Date(), "yyyyMMdd");
        String likePrefix = prefix + dateStr;

        LambdaQueryWrapper<StockTake> wrapper = new LambdaQueryWrapper<StockTake>()
                .likeRight(StockTake::getOrderNo, likePrefix)
                .orderByDesc(StockTake::getOrderNo);
        Page<StockTake> page = stockTakeMapper.selectPage(new Page<>(1, 1), wrapper);

        int seq = 1;
        if (!page.getRecords().isEmpty()) {
            String lastNo = page.getRecords().get(0).getOrderNo();
            seq = Integer.parseInt(lastNo.substring(lastNo.length() - 4)) + 1;
        }
        // 防止重复：如果生成的单号已存在则自增
        String orderNo = likePrefix + String.format("%04d", seq);
        while (stockTakeMapper.selectCount(new LambdaQueryWrapper<StockTake>().eq(StockTake::getOrderNo, orderNo)) > 0) {
            seq++;
            orderNo = likePrefix + String.format("%04d", seq);
        }
        return orderNo;
    }
}
