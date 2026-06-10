package com.inventory.inventory.controller;

import cn.dev33.satoken.annotation.SaCheckRole;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.common.result.PageResult;
import com.inventory.common.result.R;
import com.inventory.common.util.ExcelUtil;
import com.inventory.inventory.entity.Inventory;
import com.inventory.inventory.entity.InventoryExportVO;
import com.inventory.inventory.entity.InventoryLog;
import com.inventory.inventory.entity.InventoryLogExportVO;
import com.inventory.inventory.service.InventoryLogService;
import com.inventory.inventory.service.InventoryService;
import com.inventory.warehouse.entity.Warehouse;
import com.inventory.warehouse.mapper.WarehouseMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Tag(name = "库存管理")
@RestController
@RequestMapping("/api/v1/inventory")
@RequiredArgsConstructor
public class InventoryController {

    private final InventoryService inventoryService;
    private final InventoryLogService inventoryLogService;
    private final WarehouseMapper warehouseMapper;

    @Operation(summary = "分页查询库存")
    @GetMapping("/page")
    public R<PageResult<Inventory>> page(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long productId,
            @RequestParam(required = false) String productName,
            @RequestParam(required = false) Long warehouseId) {
        return R.ok(PageResult.of(inventoryService.page(new Page<>(page, size), productId, productName, warehouseId)));
    }

    @Operation(summary = "分页查询库存流水")
    @GetMapping("/log/page")
    public R<PageResult<InventoryLog>> logPage(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long productId,
            @RequestParam(required = false) String productName,
            @RequestParam(required = false) Long warehouseId,
            @RequestParam(required = false) String changeType,
            @RequestParam(required = false) String refOrderNo,
            @RequestParam(required = false) String operatorName,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        LocalDateTime start = startDate != null && !startDate.isEmpty() ? LocalDateTime.parse(startDate + "T00:00:00") : null;
        LocalDateTime end = endDate != null && !endDate.isEmpty() ? LocalDateTime.parse(endDate + "T23:59:59") : null;
        return R.ok(PageResult.of(inventoryLogService.page(new Page<>(page, size), productId, productName, warehouseId, changeType, refOrderNo, operatorName, start, end)));
    }

    @SaCheckRole("role_1")
    @Operation(summary = "导出库存")
    @GetMapping("/export")
    public void export(HttpServletResponse response,
                       @RequestParam(required = false) String ids,
                       @RequestParam(required = false) Long warehouseId,
                       @RequestParam(required = false) String warehouseIds) {
        List<Inventory> list;
        if (warehouseIds != null && !warehouseIds.isEmpty()) {
            List<Long> whIds = Arrays.stream(warehouseIds.split(",")).map(Long::parseLong).collect(Collectors.toList());
            list = inventoryService.listAll().stream()
                    .filter(inv -> whIds.contains(inv.getWarehouseId())).collect(Collectors.toList());
        } else if (warehouseId != null) {
            list = inventoryService.listByWarehouse(warehouseId);
        } else {
            list = inventoryService.listAll();
        }
        if (ids != null && !ids.isEmpty()) {
            List<Long> idList = Arrays.stream(ids.split(",")).map(Long::parseLong).collect(Collectors.toList());
            list = list.stream().filter(inv -> idList.contains(inv.getId())).collect(Collectors.toList());
        }
        // 合并同一商品+仓库的不同批次记录（导出无批次列，避免展示重复行）
        log.debug("导出库存 - 合并前记录数: {}", list.size());
        Map<String, Inventory> mergedMap = new LinkedHashMap<>();
        for (Inventory inv : list) {
            String key = inv.getProductId() + "_" + inv.getWarehouseId();
            Inventory m = mergedMap.get(key);
            if (m != null) {
                int oldQty = m.getQuantity() != null ? m.getQuantity() : 0;
                int addQty = inv.getQuantity() != null ? inv.getQuantity() : 0;
                int newQty = oldQty + addQty;
                m.setQuantity(newQty);
                if (inv.getCostPrice() != null && m.getCostPrice() != null && newQty > 0) {
                    BigDecimal oldValue = m.getCostPrice().multiply(BigDecimal.valueOf(oldQty));
                    BigDecimal addValue = inv.getCostPrice().multiply(BigDecimal.valueOf(addQty));
                    m.setCostPrice(oldValue.add(addValue).divide(BigDecimal.valueOf(newQty), 4, RoundingMode.HALF_UP));
                } else if (inv.getCostPrice() != null) {
                    m.setCostPrice(inv.getCostPrice());
                }
            } else {
                mergedMap.put(key, inv);
            }
        }
        list = new ArrayList<>(mergedMap.values());
        log.debug("导出库存 - 实体合并后记录数: {}", list.size());
        // 加载所有仓库，构建层级映射
        List<Warehouse> allWarehouses = warehouseMapper.selectList(null);
        Map<Long, Warehouse> whMap = allWarehouses.stream().collect(Collectors.toMap(Warehouse::getId, w -> w));
        List<InventoryExportVO> voList = list.stream().map(inv -> {
            InventoryExportVO vo = new InventoryExportVO();
            vo.setProductCode(inv.getProductCode());
            vo.setProductName(inv.getProductName());
            vo.setQuantity(inv.getQuantity());
            vo.setCostPrice("¥" + String.format("%.2f", inv.getCostPrice() != null ? inv.getCostPrice().doubleValue() : 0.0));
            vo.setAmount("¥" + String.format("%.2f",
                    (inv.getCostPrice() != null ? inv.getCostPrice().doubleValue() : 0.0) * (inv.getQuantity() != null ? inv.getQuantity() : 0)));
            // 填充仓库层级
            if (inv.getWarehouseId() != null) {
                Warehouse w = whMap.get(inv.getWarehouseId());
                if (w != null) {
                    switch (w.getLevel() != null ? w.getLevel() : 1) {
                        case 4: vo.setLevel4Name(w.getName());
                            Warehouse p3 = whMap.get(w.getParentId());
                            if (p3 != null) {
                                vo.setLevel3Name(p3.getName());
                                Warehouse p2 = whMap.get(p3.getParentId());
                                if (p2 != null) {
                                    vo.setLevel2Name(p2.getName());
                                    Warehouse p1 = whMap.get(p2.getParentId());
                                    if (p1 != null) vo.setLevel1Name(p1.getName());
                                }
                            }
                            break;
                        case 3: vo.setLevel3Name(w.getName());
                            Warehouse p2 = whMap.get(w.getParentId());
                            if (p2 != null) {
                                vo.setLevel2Name(p2.getName());
                                Warehouse p1 = whMap.get(p2.getParentId());
                                if (p1 != null) vo.setLevel1Name(p1.getName());
                            }
                            break;
                        case 2: vo.setLevel2Name(w.getName());
                            Warehouse p1 = whMap.get(w.getParentId());
                            if (p1 != null) vo.setLevel1Name(p1.getName());
                            break;
                        default: vo.setLevel1Name(w.getName()); break;
                    }
                }
            }
            return vo;
        }).collect(Collectors.toList());
        // 二次去重：按导出可见字段去重，合并数量与金额
        log.debug("导出库存 - VO映射后记录数: {}", voList.size());
        Map<String, InventoryExportVO> voMerged = new LinkedHashMap<>();
        for (InventoryExportVO vo : voList) {
            String key = String.join("|",
                    vo.getProductCode() != null ? vo.getProductCode() : "",
                    vo.getProductName() != null ? vo.getProductName() : "",
                    vo.getLevel1Name() != null ? vo.getLevel1Name() : "",
                    vo.getLevel2Name() != null ? vo.getLevel2Name() : "",
                    vo.getLevel3Name() != null ? vo.getLevel3Name() : "",
                    vo.getLevel4Name() != null ? vo.getLevel4Name() : "");
            InventoryExportVO existing = voMerged.get(key);
            if (existing != null) {
                log.warn("导出库存 - 发现重复行已合并: code={}, name={}, warehouse={}/{}/{}/{}, qty1={}, qty2={}",
                        vo.getProductCode(), vo.getProductName(),
                        vo.getLevel1Name(), vo.getLevel2Name(), vo.getLevel3Name(), vo.getLevel4Name(),
                        existing.getQuantity(), vo.getQuantity());
                existing.setQuantity((existing.getQuantity() != null ? existing.getQuantity() : 0)
                        + (vo.getQuantity() != null ? vo.getQuantity() : 0));
                // 重新计算金额（取均价近似）
                String cp = existing.getCostPrice();
                if (cp != null && cp.startsWith("¥")) {
                    try {
                        BigDecimal price = new BigDecimal(cp.substring(1));
                        existing.setAmount("¥" + String.format("%.2f",
                                price.multiply(BigDecimal.valueOf(existing.getQuantity())).doubleValue()));
                    } catch (NumberFormatException ignored) {}
                }
            } else {
                voMerged.put(key, vo);
            }
        }
        voList = new ArrayList<>(voMerged.values());
        // 按仓库层级 + 商品编码排序，确保同一仓库的数据连续
        voList.sort(Comparator
                .comparing(InventoryExportVO::getLevel1Name, Comparator.nullsLast(String::compareTo))
                .thenComparing(InventoryExportVO::getLevel2Name, Comparator.nullsLast(String::compareTo))
                .thenComparing(InventoryExportVO::getLevel3Name, Comparator.nullsLast(String::compareTo))
                .thenComparing(InventoryExportVO::getLevel4Name, Comparator.nullsLast(String::compareTo))
                .thenComparing(InventoryExportVO::getProductCode, Comparator.nullsLast(String::compareTo)));
        log.debug("导出库存 - 最终导出记录数: {}", voList.size());
        ExcelUtil.export(response, voList, "库存列表", InventoryExportVO.class);
    }

    @Operation(summary = "导出库存流水")
    @GetMapping("/log/export")
    public void exportLog(HttpServletResponse response,
                          @RequestParam(required = false) String ids) {
        List<InventoryLog> list = inventoryLogService.listAll();
        if (ids != null && !ids.isEmpty()) {
            List<Long> idList = Arrays.stream(ids.split(",")).map(Long::parseLong).collect(Collectors.toList());
            list = list.stream().filter(log -> idList.contains(log.getId())).collect(Collectors.toList());
        }
        List<InventoryLogExportVO> voList = list.stream().map(log -> {
            InventoryLogExportVO vo = new InventoryLogExportVO();
            vo.setProductName(log.getProductName());
            vo.setWarehouseName(log.getWarehouseName());
            // 操作类型转中文
            String type = log.getChangeType();
            if (type != null) {
                switch (type) {
                    case "PURCHASE_IN": type = "采购入库"; break;
                    case "SALES_OUT": type = "销售出库"; break;
                    case "TRANSFER_IN": type = "调拨入库"; break;
                    case "TRANSFER_OUT": type = "调拨出库"; break;
                    case "PURCHASE_CANCEL": type = "取消入库"; break;
                    case "SALES_CANCEL": type = "取消出库"; break;
                    case "STOCKTAKE": type = "盘点调整"; break;
                }
            }
            vo.setChangeType(type);
            vo.setChangeQty(log.getChangeQty());
            vo.setBeforeQty(log.getBeforeQty());
            vo.setAfterQty(log.getAfterQty());
            vo.setRefOrderNo(log.getRefOrderNo());
            vo.setOperatorName(log.getOperatorName());
            if (log.getCreateTime() != null) vo.setCreateTime(log.getCreateTime());
            return vo;
        }).collect(Collectors.toList());
        ExcelUtil.export(response, voList, "库存流水", InventoryLogExportVO.class);
    }
}
