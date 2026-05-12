package com.inventory.inventory.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.inventory.entity.Inventory;
import com.inventory.inventory.mapper.InventoryMapper;
import com.inventory.product.entity.Product;
import com.inventory.product.mapper.ProductMapper;
import com.inventory.warehouse.entity.Warehouse;
import com.inventory.warehouse.mapper.WarehouseMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class InventoryService {

    private final InventoryMapper inventoryMapper;
    private final ProductMapper productMapper;
    private final WarehouseMapper warehouseMapper;

    public InventoryService(InventoryMapper inventoryMapper, ProductMapper productMapper,
                            WarehouseMapper warehouseMapper) {
        this.inventoryMapper = inventoryMapper;
        this.productMapper = productMapper;
        this.warehouseMapper = warehouseMapper;
    }

    public Page<Inventory> page(Page<Inventory> page, Long productId, String productName, Long warehouseId) {
        LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<Inventory>()
                .eq(productId != null, Inventory::getProductId, productId)
                .eq(warehouseId != null, Inventory::getWarehouseId, warehouseId)
                .orderByDesc(Inventory::getId);

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
        // 填充名称
        for (Inventory inv : result.getRecords()) {
            if (inv.getProductId() != null) {
                Product p = productMapper.selectById(inv.getProductId());
                if (p != null) { inv.setProductName(p.getName()); inv.setProductCode(p.getCode()); }
            }
            if (inv.getWarehouseId() != null) {
                Warehouse w = warehouseMapper.selectById(inv.getWarehouseId());
                if (w != null) { inv.setWarehouseName(w.getName()); inv.setWarehouseCode(w.getCode()); }
            }
        }
        return result;
    }

    public List<Inventory> listAll() {
        List<Inventory> list = inventoryMapper.selectList(null);
        for (Inventory inv : list) {
            if (inv.getProductId() != null) {
                Product p = productMapper.selectById(inv.getProductId());
                if (p != null) {
                    inv.setProductName(p.getName());
                    inv.setProductCode(p.getCode());
                }
            }
            if (inv.getWarehouseId() != null) {
                Warehouse w = warehouseMapper.selectById(inv.getWarehouseId());
                if (w != null) { inv.setWarehouseName(w.getName()); inv.setWarehouseCode(w.getCode()); }
            }
        }
        return list;
    }

    public List<Map<String, Object>> getAlertList() {
        List<Inventory> all = inventoryMapper.selectList(null);
        Map<Long, Product> productCache = new HashMap<>();
        List<Map<String, Object>> alerts = new ArrayList<>();
        for (Inventory inv : all) {
            Product p = productCache.computeIfAbsent(inv.getProductId(), id -> productMapper.selectById(id));
            if (p != null && p.getMinStock() != null && inv.getQuantity() < p.getMinStock()) {
                Map<String, Object> item = new HashMap<>();
                item.put("productName", p.getName());
                item.put("productCode", p.getCode());
                item.put("quantity", inv.getQuantity());
                item.put("minStock", p.getMinStock());
                Warehouse w = warehouseMapper.selectById(inv.getWarehouseId());
                item.put("warehouseName", w != null ? w.getName() : "");
                alerts.add(item);
            }
        }
        return alerts;
    }
}
