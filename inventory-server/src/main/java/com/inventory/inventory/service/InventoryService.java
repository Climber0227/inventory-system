package com.inventory.inventory.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.inventory.entity.Inventory;
import com.inventory.inventory.mapper.InventoryMapper;
import com.inventory.product.entity.Product;
import com.inventory.product.mapper.ProductMapper;
import com.inventory.system.entity.SysUser;
import com.inventory.system.mapper.SysUserMapper;
import com.inventory.warehouse.entity.Warehouse;
import com.inventory.warehouse.mapper.WarehouseMapper;
import cn.dev33.satoken.stp.StpUtil;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class InventoryService {

    private final InventoryMapper inventoryMapper;
    private final ProductMapper productMapper;
    private final WarehouseMapper warehouseMapper;
    private final SysUserMapper userMapper;

    public InventoryService(InventoryMapper inventoryMapper, ProductMapper productMapper,
                            WarehouseMapper warehouseMapper, SysUserMapper userMapper) {
        this.inventoryMapper = inventoryMapper;
        this.productMapper = productMapper;
        this.warehouseMapper = warehouseMapper;
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

    public Page<Inventory> page(Page<Inventory> page, Long productId, String productName, Long warehouseId) {
        LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<Inventory>()
                .gt(Inventory::getQuantity, 0)
                .eq(productId != null, Inventory::getProductId, productId)
                .eq(warehouseId != null, Inventory::getWarehouseId, warehouseId)
                .orderByDesc(Inventory::getCreateTime);

        // 按商品名称或编码搜索
        if (productName != null && !productName.isEmpty() && productId == null) {
            // 先尝试精确匹配编码
            List<Product> codeMatched = productMapper.selectList(
                    new LambdaQueryWrapper<Product>().eq(Product::getCode, productName));
            // 再模糊匹配名称
            List<Product> nameMatched = productMapper.selectList(
                    new LambdaQueryWrapper<Product>().like(Product::getName, productName));
            // 合并去重
            Set<Long> productIds = new LinkedHashSet<>();
            codeMatched.forEach(p -> productIds.add(p.getId()));
            nameMatched.forEach(p -> productIds.add(p.getId()));
            if (!productIds.isEmpty()) {
                wrapper.in(Inventory::getProductId, productIds);
            } else {
                return page; // 无匹配
            }
        }
        Page<Inventory> result = inventoryMapper.selectPage(page, wrapper);
        enrichNames(result.getRecords());
        if (!isAdmin()) {
            result.getRecords().forEach(i -> i.setCostPrice(null));
        }
        return result;
    }

    public List<Inventory> listAll() {
        List<Inventory> list = inventoryMapper.selectList(
                new LambdaQueryWrapper<Inventory>().orderByDesc(Inventory::getCreateTime));
        enrichNames(list);
        if (!isAdmin()) {
            list.forEach(i -> i.setCostPrice(null));
        }
        return list;
    }

    public List<Inventory> listByWarehouse(Long warehouseId) {
        List<Inventory> list = inventoryMapper.selectList(
                new LambdaQueryWrapper<Inventory>().eq(Inventory::getWarehouseId, warehouseId)
                        .orderByDesc(Inventory::getCreateTime));
        enrichNames(list);
        if (!isAdmin()) {
            list.forEach(i -> i.setCostPrice(null));
        }
        return list;
    }

    private void enrichNames(List<Inventory> list) {
        if (list == null || list.isEmpty()) return;
        // 收集所有需要查询的ID
        Set<Long> productIds = new HashSet<>();
        Set<Long> warehouseIds = new HashSet<>();
        for (Inventory inv : list) {
            if (inv.getProductId() != null) productIds.add(inv.getProductId());
            if (inv.getWarehouseId() != null) warehouseIds.add(inv.getWarehouseId());
        }
        // 批量查询（2 次 SQL 替代 2N 次）
        Map<Long, Product> productMap = productIds.isEmpty() ? Collections.emptyMap()
                : productMapper.selectBatchIdsIgnoreDeleted(productIds).stream()
                    .collect(Collectors.toMap(Product::getId, p -> p, (a, b) -> a));
        Map<Long, Warehouse> warehouseMap = warehouseIds.isEmpty() ? Collections.emptyMap()
                : warehouseMapper.selectBatchIdsIgnoreDeleted(warehouseIds).stream()
                    .collect(Collectors.toMap(Warehouse::getId, w -> w, (a, b) -> a));
        // 纯内存赋值
        for (Inventory inv : list) {
            Product p = productMap.get(inv.getProductId());
            if (p != null) {
                inv.setProductName(p.getName());
                inv.setProductCode(p.getCode());
            }
            Warehouse w = warehouseMap.get(inv.getWarehouseId());
            if (w != null) {
                inv.setWarehouseName(w.getName());
                inv.setWarehouseCode(w.getCode());
            }
        }
    }

    public List<Map<String, Object>> getAlertList() {
        List<Inventory> all = inventoryMapper.selectList(null);
        if (all.isEmpty()) return Collections.emptyList();
        // 批量加载所有关联数据
        Set<Long> productIds = all.stream().map(Inventory::getProductId)
                .filter(Objects::nonNull).collect(Collectors.toSet());
        Set<Long> warehouseIds = all.stream().map(Inventory::getWarehouseId)
                .filter(Objects::nonNull).collect(Collectors.toSet());
        Map<Long, Product> productMap = productMapper.selectBatchIdsIgnoreDeleted(productIds).stream()
                .collect(Collectors.toMap(Product::getId, p -> p, (a, b) -> a));
        Map<Long, Warehouse> warehouseMap = warehouseMapper.selectBatchIdsIgnoreDeleted(warehouseIds).stream()
                .collect(Collectors.toMap(Warehouse::getId, w -> w, (a, b) -> a));
        // 加载所有仓库用于构建父级路径
        Map<Long, Warehouse> allWhMap = warehouseMapper.selectList(null).stream()
                .collect(Collectors.toMap(Warehouse::getId, w -> w, (a, b) -> a));
        // 纯内存过滤+组装
        List<Map<String, Object>> alerts = new ArrayList<>();
        for (Inventory inv : all) {
            Product p = productMap.get(inv.getProductId());
            if (p != null && p.getMinStock() != null && inv.getQuantity() < p.getMinStock()) {
                Warehouse w = warehouseMap.get(inv.getWarehouseId());
                Map<String, Object> item = new HashMap<>();
                item.put("productName", p.getName());
                item.put("productCode", p.getCode());
                item.put("quantity", inv.getQuantity());
                item.put("minStock", p.getMinStock());
                item.put("warehouseName", w != null ? w.getName() : "");
                item.put("warehousePath", w != null ? buildWhPath(w, allWhMap) : "");
                alerts.add(item);
            }
        }
        return alerts;
    }

    private String buildWhPath(Warehouse wh, Map<Long, Warehouse> allMap) {
        java.util.List<String> parts = new java.util.ArrayList<>();
        Long cur = wh.getId();
        java.util.Set<Long> visited = new java.util.HashSet<>();
        while (cur != null && allMap.containsKey(cur) && visited.add(cur)) {
            Warehouse w = allMap.get(cur);
            parts.add(0, w.getName());
            cur = w.getParentId();
        }
        if (parts.size() > 1) parts.remove(parts.size() - 1);
        return parts.isEmpty() ? "" : String.join(" / ", parts);
    }
}
