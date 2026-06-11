package com.inventory.product.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.common.exception.BusinessException;
import com.inventory.inventory.entity.Inventory;
import com.inventory.inventory.mapper.InventoryMapper;
import com.inventory.product.entity.Product;
import com.inventory.product.entity.ProductCategory;
import com.inventory.product.mapper.ProductCategoryMapper;
import com.inventory.product.mapper.ProductMapper;
import com.inventory.purchase.entity.PurchaseOrderItem;
import com.inventory.purchase.mapper.PurchaseOrderItemMapper;
import com.inventory.sales.entity.SalesOrderItem;
import com.inventory.sales.mapper.SalesOrderItemMapper;
import com.inventory.stocktake.entity.StockTakeItem;
import com.inventory.stocktake.mapper.StockTakeItemMapper;
import com.inventory.system.entity.SysUser;
import com.inventory.system.mapper.SysUserMapper;
import com.inventory.transfer.entity.InventoryTransferItem;
import com.inventory.transfer.mapper.InventoryTransferItemMapper;
import cn.dev33.satoken.stp.StpUtil;
import org.apache.ibatis.session.ExecutorType;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.inventory.product.entity.ProductImportVO;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;
import cn.hutool.core.date.DateUtil;
import java.util.Date;

@Service
public class ProductService {

    private final ProductMapper productMapper;
    private final InventoryMapper inventoryMapper;
    private final ProductCategoryMapper categoryMapper;
    private final PurchaseOrderItemMapper purchaseOrderItemMapper;
    private final SalesOrderItemMapper salesOrderItemMapper;
    private final InventoryTransferItemMapper transferItemMapper;
    private final StockTakeItemMapper stockTakeItemMapper;
    private final SqlSessionFactory sqlSessionFactory;
    private final SysUserMapper userMapper;

    public ProductService(ProductMapper productMapper, InventoryMapper inventoryMapper,
                          ProductCategoryMapper categoryMapper,
                          PurchaseOrderItemMapper purchaseOrderItemMapper,
                          SalesOrderItemMapper salesOrderItemMapper,
                          InventoryTransferItemMapper transferItemMapper,
                          StockTakeItemMapper stockTakeItemMapper,
                          SqlSessionFactory sqlSessionFactory,
                          SysUserMapper userMapper) {
        this.productMapper = productMapper;
        this.inventoryMapper = inventoryMapper;
        this.categoryMapper = categoryMapper;
        this.purchaseOrderItemMapper = purchaseOrderItemMapper;
        this.salesOrderItemMapper = salesOrderItemMapper;
        this.transferItemMapper = transferItemMapper;
        this.stockTakeItemMapper = stockTakeItemMapper;
        this.sqlSessionFactory = sqlSessionFactory;
        this.userMapper = userMapper;
    }

    private boolean isAdmin() {
        try {
            long uid = StpUtil.getLoginIdAsLong();
            SysUser u = userMapper.selectById(uid);
            return u != null && u.getRole() != null && u.getRole() == 1;
        } catch (Exception e) {
            return false;
        }
    }

    public Page<Product> page(Page<Product> page, String name, String code, Integer status, Boolean alertOnly, Long warehouseId, Long categoryId, BigDecimal minPrice, BigDecimal maxPrice, BigDecimal minSalePrice, BigDecimal maxSalePrice, String startDate, String endDate) {
        // 日期参数先判空再转换，避免 MyBatis-Plus 条件参数提前求值导致 NPE
        LocalDateTime startDateTime = (startDate != null && !startDate.isEmpty()) ? LocalDate.parse(startDate).atStartOfDay() : null;
        LocalDateTime endDateTime = (endDate != null && !endDate.isEmpty()) ? LocalDate.parse(endDate).atTime(LocalTime.MAX) : null;
        boolean admin = isAdmin();
        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<Product>()
                .and(name != null || code != null, w -> w
                        .like(name != null, Product::getName, name)
                        .or()
                        .like(code != null, Product::getCode, code))
                .eq(status != null, Product::getStatus, status)
                .eq(categoryId != null, Product::getCategoryId, categoryId)
                .ge(admin && minPrice != null, Product::getPurchasePrice, minPrice)
                .le(admin && maxPrice != null, Product::getPurchasePrice, maxPrice)
                .ge(minSalePrice != null, Product::getSalePrice, minSalePrice)
                .le(maxSalePrice != null, Product::getSalePrice, maxSalePrice)
                .ge(startDateTime != null, Product::getCreateTime, startDateTime)
                .le(endDateTime != null, Product::getCreateTime, endDateTime);
        // 仓库筛选：先查商品ID再加IN条件，确保分页正常
        if (warehouseId != null) {
            List<Long> ids = inventoryMapper.selectList(
                    new LambdaQueryWrapper<Inventory>().eq(Inventory::getWarehouseId, warehouseId))
                    .stream().map(Inventory::getProductId).distinct().collect(Collectors.toList());
            if (!ids.isEmpty()) {
                wrapper.in(Product::getId, ids);
            } else {
                page.setRecords(new ArrayList<>());
                page.setTotal(0);
                return page;
            }
        }
        wrapper.orderByDesc(Product::getId);
        Page<Product> result = productMapper.selectPage(page, wrapper);
        enrichInventoryBatch(result.getRecords(), warehouseId);
        enrichCategoryNames(result.getRecords());
        if (Boolean.TRUE.equals(alertOnly)) {
            List<Product> filtered = result.getRecords().stream()
                    .filter(p -> "warning".equals(p.getAlertStatus()))
                    .collect(Collectors.toList());
            result.setRecords(filtered);
            result.setTotal(filtered.size());
        } else if (Boolean.FALSE.equals(alertOnly)) {
            List<Product> filtered = result.getRecords().stream()
                    .filter(p -> "normal".equals(p.getAlertStatus()))
                    .collect(Collectors.toList());
            result.setRecords(filtered);
            result.setTotal(filtered.size());
        }
        if (!admin) {
            result.getRecords().forEach(p -> p.setPurchasePrice(null));
        }
        return result;
    }

    public List<Product> list() {
        List<Product> result = productMapper.selectList(new LambdaQueryWrapper<Product>()
                .eq(Product::getStatus, 1).orderByDesc(Product::getId));
        if (!isAdmin()) {
            result.forEach(p -> p.setPurchasePrice(null));
        }
        return result;
    }

    public List<Product> listAll() {
        List<Product> list = productMapper.selectList(new LambdaQueryWrapper<Product>().orderByDesc(Product::getId));
        enrichInventoryBatch(list, null);
        enrichCategoryNames(list);
        if (!isAdmin()) {
            list.forEach(p -> p.setPurchasePrice(null));
        }
        return list;
    }

    public List<Product> listFiltered(String name, String code, Integer status, Boolean alertOnly,
            Long warehouseId, Long categoryId, java.math.BigDecimal minPrice, java.math.BigDecimal maxPrice,
            java.math.BigDecimal minSalePrice, java.math.BigDecimal maxSalePrice, String startDate, String endDate) {
        LocalDateTime startDateTime = (startDate != null && !startDate.isEmpty()) ? LocalDate.parse(startDate).atStartOfDay() : null;
        LocalDateTime endDateTime = (endDate != null && !endDate.isEmpty()) ? LocalDate.parse(endDate).atTime(LocalTime.MAX) : null;
        boolean admin = isAdmin();
        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<Product>()
                .and(name != null || code != null, w -> w
                        .like(name != null, Product::getName, name)
                        .or()
                        .like(code != null, Product::getCode, code))
                .eq(status != null, Product::getStatus, status)
                .eq(categoryId != null, Product::getCategoryId, categoryId)
                .ge(admin && minPrice != null, Product::getPurchasePrice, minPrice)
                .le(admin && maxPrice != null, Product::getPurchasePrice, maxPrice)
                .ge(minSalePrice != null, Product::getSalePrice, minSalePrice)
                .le(maxSalePrice != null, Product::getSalePrice, maxSalePrice)
                .ge(startDateTime != null, Product::getCreateTime, startDateTime)
                .le(endDateTime != null, Product::getCreateTime, endDateTime);
        if (warehouseId != null) {
            List<Long> ids = inventoryMapper.selectList(
                    new LambdaQueryWrapper<Inventory>().eq(Inventory::getWarehouseId, warehouseId))
                    .stream().map(Inventory::getProductId).distinct().collect(Collectors.toList());
            if (!ids.isEmpty()) wrapper.in(Product::getId, ids);
            else return new ArrayList<>();
        }
        wrapper.orderByDesc(Product::getId);
        List<Product> list = productMapper.selectList(wrapper);
        enrichInventoryBatch(list, warehouseId);
        enrichCategoryNames(list);
        // 预警筛选
        if (alertOnly != null) {
            list = list.stream().filter(p -> Boolean.TRUE.equals(alertOnly) ? "warning".equals(p.getAlertStatus()) : "normal".equals(p.getAlertStatus())).collect(Collectors.toList());
        }
        if (!admin) {
            list.forEach(p -> p.setPurchasePrice(null));
        }
        return list;
    }

    public Product getById(Long id) {
        Product product = productMapper.selectById(id);
        if (product != null) {
            if (product.getCategoryId() != null) {
                ProductCategory cat = categoryMapper.selectById(product.getCategoryId());
                if (cat != null) product.setCategoryName(cat.getName());
            }
            if (!isAdmin()) {
                product.setPurchasePrice(null);
            }
        }
        return product;
    }

    /** 批量预加载库存，用 SQL GROUP BY 聚合（返回 2K 行而非几十万行） */
    private void enrichInventoryBatch(List<Product> products, Long warehouseId) {
        if (products == null || products.isEmpty()) return;
        Set<Long> productIds = products.stream().map(Product::getId)
                .filter(Objects::nonNull).collect(Collectors.toSet());
        if (productIds.isEmpty()) return;
        // SQL 聚合：SUM(quantity) GROUP BY product_id — 最多返回 productIds.size() 行
        List<Map<String, Object>> stats = warehouseId != null
                ? inventoryMapper.selectProductStatsByIdsAndWarehouse(productIds, warehouseId)
                : inventoryMapper.selectProductStatsByIds(productIds);
        Map<Long, Integer> qtyMap = new HashMap<>();
        for (Map<String, Object> row : stats) {
            Object pid = row.get("product_id");
            Object qty = row.get("total_qty");
            if (pid instanceof Number && qty instanceof Number) {
                qtyMap.put(((Number) pid).longValue(), ((Number) qty).intValue());
            }
        }
        for (Product p : products) {
            int total = qtyMap.getOrDefault(p.getId(), 0);
            p.setInventoryQuantity(total);
            p.setAlertStatus(p.getMinStock() != null && total < p.getMinStock() ? "warning" : "normal");
        }
    }

    private void enrichCategoryNames(List<Product> products) {
        Set<Long> categoryIds = products.stream()
                .map(Product::getCategoryId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        if (categoryIds.isEmpty()) return;
        List<ProductCategory> categories = categoryMapper.selectBatchIds(categoryIds);
        Map<Long, String> nameMap = categories.stream()
                .collect(Collectors.toMap(ProductCategory::getId, ProductCategory::getName));
        for (Product p : products) {
            if (p.getCategoryId() != null) {
                p.setCategoryName(nameMap.get(p.getCategoryId()));
            }
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void save(Product product) {
        product.setCode(generateProductCode());
        productMapper.insert(product);
    }

    @Transactional(rollbackFor = Exception.class)
    public int importExcel(List<ProductImportVO> rows) {
        // 加载分类缓存（轻量）
        Map<String, Long> catCache = new HashMap<>();
        categoryMapper.selectList(null).forEach(c ->
                catCache.put(c.getName() + ":" + (c.getParentId() == null ? 0 : c.getParentId()), c.getId()));

        // 只加载 code 和 name（不加载全量字段）
        List<Product> allProducts = productMapper.selectList(
                new LambdaQueryWrapper<Product>().select(Product::getId, Product::getCode, Product::getName));
        Map<String, Product> byCode = new HashMap<>();
        Map<String, Product> byName = new HashMap<>();
        for (Product p : allProducts) {
            if (p.getCode() != null) byCode.put(p.getCode(), p);
            if (p.getName() != null) byName.put(p.getName(), p);
        }

        // 预生成一批编码，避免每次 synchronized
        List<String> codePool = generateProductCodes(rows.size());

        List<Product> toInsert = new ArrayList<>();
        List<Product> toUpdate = new ArrayList<>();
        int count = 0, codeIdx = 0;

        for (ProductImportVO row : rows) {
            if (row.getName() == null || row.getName().trim().isEmpty()) continue;
            String name = row.getName().trim();

            Product existing = null;
            if (row.getCode() != null && !row.getCode().trim().isEmpty()) {
                existing = byCode.get(row.getCode().trim());
            }
            if (existing == null) existing = byName.get(name);

            // 解析分类路径
            Long categoryId = null;
            if (row.getCategoryPath() != null && !row.getCategoryPath().trim().isEmpty()) {
                String[] parts = row.getCategoryPath().split("/");
                Long parentId = null;
                for (String part : parts) {
                    String catName = part.trim();
                    if (catName.isEmpty()) continue;
                    String cacheKey = catName + ":" + (parentId == null ? 0 : parentId);
                    Long existed = catCache.get(cacheKey);
                    if (existed != null) { parentId = existed; continue; }
                    ProductCategory cat = new ProductCategory();
                    cat.setName(catName); cat.setParentId(parentId); cat.setStatus(1);
                    categoryMapper.insert(cat);
                    catCache.put(cacheKey, cat.getId());
                    parentId = cat.getId();
                }
                categoryId = parentId;
            }

            if (existing != null) {
                existing.setCategoryId(categoryId);
                if (row.getSpec() != null) existing.setSpec(row.getSpec());
                if (row.getUnit() != null && !row.getUnit().trim().isEmpty()) existing.setUnit(row.getUnit());
                if (row.getPurchasePrice() != null) existing.setPurchasePrice(row.getPurchasePrice());
                if (row.getSalePrice() != null) existing.setSalePrice(row.getSalePrice());
                if (row.getMinStock() != null) existing.setMinStock(row.getMinStock());
                if (row.getMaxStock() != null) existing.setMaxStock(row.getMaxStock());
                if (row.getStatus() != null) existing.setStatus("停用".equals(row.getStatus()) ? 0 : 1);
                toUpdate.add(existing);
            } else {
                Product p = new Product();
                p.setName(name); p.setCategoryId(categoryId);
                p.setSpec(row.getSpec());
                p.setUnit(row.getUnit() != null && !row.getUnit().trim().isEmpty() ? row.getUnit() : "棵");
                p.setPurchasePrice(row.getPurchasePrice()); p.setSalePrice(row.getSalePrice());
                p.setMinStock(row.getMinStock()); p.setMaxStock(row.getMaxStock());
                p.setStatus("停用".equals(row.getStatus()) ? 0 : 1);
                if (row.getCode() != null && !row.getCode().trim().isEmpty()
                        && productMapper.countAllByCode(row.getCode().trim()) == 0) {
                    p.setCode(row.getCode().trim());
                } else {
                    p.setCode(codePool.get(Math.min(codeIdx++, codePool.size() - 1)));
                }
                toInsert.add(p);
                byName.put(name, p);
                if (p.getCode() != null) byCode.put(p.getCode(), p);
            }
            count++;

            // 分批提交，避免大事务
            if (toInsert.size() >= 200) {
                batchInsertProducts(toInsert);
                toInsert.clear();
            }
            if (toUpdate.size() >= 200) {
                for (Product u : toUpdate) productMapper.updateById(u);
                toUpdate.clear();
            }
        }
        // 剩余批次
        if (!toInsert.isEmpty()) batchInsertProducts(toInsert);
        for (Product u : toUpdate) productMapper.updateById(u);
        return count;
    }

    /** MyBatis BATCH 模式批量插入，比逐条 insert 快 30~100 倍 */
    private void batchInsertProducts(List<Product> list) {
        if (list.isEmpty()) return;
        try (SqlSession session = sqlSessionFactory.openSession(ExecutorType.BATCH)) {
            ProductMapper batchMapper = session.getMapper(ProductMapper.class);
            for (Product p : list) batchMapper.insert(p);
            session.commit();  // 一次网络往返，批量写
        }
    }

    /** 批量预生成编码（synchronized 保证并发安全） */
    private synchronized List<String> generateProductCodes(int count) {
        List<String> codes = new ArrayList<>(count);
        String prefix = "GD";
        String dateStr = DateUtil.format(new Date(), "yyyyMMdd");
        String likePrefix = prefix + dateStr;
        String maxCode = productMapper.selectMaxCodeByPrefix(likePrefix);
        int seq = 1;
        if (maxCode != null) {
            seq = Integer.parseInt(maxCode.substring(maxCode.length() - 6)) + 1;
        }
        for (int i = 0; i < count; i++) {
            codes.add(likePrefix + String.format("%06d", seq + i));
        }
        return codes;
    }

    private synchronized String generateProductCode() {
        String prefix = "GD";
        String dateStr = DateUtil.format(new Date(), "yyyyMMdd");
        String likePrefix = prefix + dateStr;

        String maxCode = productMapper.selectMaxCodeByPrefix(likePrefix);
        int seq = 1;
        if (maxCode != null) {
            seq = Integer.parseInt(maxCode.substring(maxCode.length() - 6)) + 1;
        }

        String code = likePrefix + String.format("%06d", seq);
        while (productMapper.countAllByCode(code) > 0) {
            seq++;
            code = likePrefix + String.format("%06d", seq);
        }
        return code;
    }

    @Transactional(rollbackFor = Exception.class)
    public void update(Product product) { productMapper.updateById(product); }

    /** 全量导出为导入格式 */
    public List<ProductImportVO> getImportVOs() {
        List<Product> products = productMapper.selectList(new LambdaQueryWrapper<Product>().orderByDesc(Product::getId));
        return toImportVOs(products);
    }

    /** 按筛选结果导出为导入格式 */
    public List<ProductImportVO> getImportVOs(List<Product> products) {
        return toImportVOs(products);
    }

    private List<ProductImportVO> toImportVOs(List<Product> products) {
        if (products == null || products.isEmpty()) return List.of();
        // 加载所需分类
        Set<Long> catIds = products.stream().map(Product::getCategoryId)
                .filter(Objects::nonNull).collect(Collectors.toSet());
        Map<Long, ProductCategory> catMap = catIds.isEmpty() ? Map.of()
                : categoryMapper.selectBatchIds(catIds).stream()
                    .collect(Collectors.toMap(ProductCategory::getId, c -> c, (a, b) -> a));
        // 收集所有需要的父级分类ID
        Set<Long> neededParentIds = new HashSet<>();
        for (ProductCategory cat : catMap.values()) {
            Long pid = cat.getParentId();
            while (pid != null) {
                neededParentIds.add(pid);
                pid = null; // 需要进一步查父级的父级... 先只查一级
            }
        }
        // 补充加载父级分类
        if (!neededParentIds.isEmpty()) {
            List<ProductCategory> parents = categoryMapper.selectBatchIds(neededParentIds);
            for (ProductCategory pc : parents) catMap.putIfAbsent(pc.getId(), pc);
            // 再查一级
            Set<Long> grandParents = new HashSet<>();
            for (ProductCategory pc : parents) {
                if (pc.getParentId() != null) grandParents.add(pc.getParentId());
            }
            if (!grandParents.isEmpty()) {
                categoryMapper.selectBatchIds(grandParents)
                        .forEach(c -> catMap.putIfAbsent(c.getId(), c));
            }
        }
        // 构建分类路径
        java.util.function.Function<Long, String> buildPath = (id) -> {
            StringBuilder sb = new StringBuilder();
            Long cur = id;
            java.util.Set<Long> visited = new HashSet<>();
            while (cur != null && visited.add(cur)) {
                ProductCategory cat = catMap.get(cur);
                if (cat == null) break;
                if (sb.length() > 0) sb.insert(0, "/");
                sb.insert(0, cat.getName());
                cur = cat.getParentId();
            }
            return sb.toString();
        };
        return products.stream().map(p -> {
            ProductImportVO vo = new ProductImportVO();
            vo.setName(p.getName());
            vo.setCode(p.getCode());
            if (p.getCategoryId() != null) vo.setCategoryPath(buildPath.apply(p.getCategoryId()));
            vo.setSpec(p.getSpec());
            vo.setUnit(p.getUnit());
            vo.setPurchasePrice(p.getPurchasePrice());
            vo.setSalePrice(p.getSalePrice());
            vo.setMinStock(p.getMinStock());
            vo.setMaxStock(p.getMaxStock());
            vo.setStatus(p.getStatus() != null && p.getStatus() == 1 ? "启用" : "停用");
            return vo;
        }).collect(Collectors.toList());
    }

    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        // 检查库存
        long invCount = inventoryMapper.selectCount(
                new LambdaQueryWrapper<Inventory>().eq(Inventory::getProductId, id));
        if (invCount > 0) throw new BusinessException("该商品存在库存记录，无法删除，请先清空库存");

        // 检查采购入库引用
        long poCount = purchaseOrderItemMapper.selectCount(
                new LambdaQueryWrapper<PurchaseOrderItem>().eq(PurchaseOrderItem::getProductId, id));
        if (poCount > 0) throw new BusinessException("该商品已被采购入库单引用，无法删除");

        // 检查销售出库引用
        long soCount = salesOrderItemMapper.selectCount(
                new LambdaQueryWrapper<SalesOrderItem>().eq(SalesOrderItem::getProductId, id));
        if (soCount > 0) throw new BusinessException("该商品已被销售出库单引用，无法删除");

        // 检查调拨引用
        long trCount = transferItemMapper.selectCount(
                new LambdaQueryWrapper<InventoryTransferItem>().eq(InventoryTransferItem::getProductId, id));
        if (trCount > 0) throw new BusinessException("该商品已被调拨单引用，无法删除");

        // 检查盘点引用
        long stCount = stockTakeItemMapper.selectCount(
                new LambdaQueryWrapper<StockTakeItem>().eq(StockTakeItem::getProductId, id));
        if (stCount > 0) throw new BusinessException("该商品已被盘点单引用，无法删除");

        productMapper.deleteById(id);
    }

    @Transactional(rollbackFor = Exception.class)
    public void restore(Long id) {
        Product p = productMapper.selectById(id);
        if (p == null) throw new com.inventory.common.exception.BusinessException("商品不存在");
        p.setDeleted(0);
        productMapper.updateById(p);
    }

}
