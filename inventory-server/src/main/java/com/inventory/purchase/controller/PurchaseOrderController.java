package com.inventory.purchase.controller;

import cn.dev33.satoken.annotation.SaCheckRole;
import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.common.constant.OrderStatus;
import com.inventory.common.result.PageResult;
import com.inventory.common.result.R;
import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.write.metadata.WriteSheet;
import com.inventory.common.util.ExcelUtil;
import com.inventory.purchase.entity.PurchaseOrder;
import com.inventory.purchase.entity.PurchaseOrderDetailExportVO;
import com.inventory.purchase.entity.PurchaseOrderExportVO;
import com.inventory.purchase.service.PurchaseOrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

import java.io.IOException;
import java.net.URLEncoder;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Tag(name = "采购订单管理")
@RestController
@RequestMapping("/api/v1/purchase-order")
@RequiredArgsConstructor
public class PurchaseOrderController {

    private final PurchaseOrderService purchaseOrderService;

    @SaCheckRole("role_1")
    @Operation(summary = "分页查询采购订单")
    @GetMapping("/page")
    public R<PageResult<PurchaseOrder>> page(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String orderNo,
            @RequestParam(required = false) Long supplierId,
            @RequestParam(required = false) Long warehouseId,
            @RequestParam(required = false) Integer minQuantity,
            @RequestParam(required = false) Integer maxQuantity,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) {
        return R.ok(PageResult.of(purchaseOrderService.page(new Page<>(page, size), orderNo, supplierId, warehouseId, minQuantity, maxQuantity, status, startDate, endDate)));
    }

    @SaCheckRole("role_1")
    @Operation(summary = "获取采购订单详情")
    @GetMapping("/{id}")
    public R<PurchaseOrder> getById(@PathVariable Long id) {
        return R.ok(purchaseOrderService.getDetail(id));
    }

    @SaCheckRole("role_1")
    @Operation(summary = "新增采购订单")
    @PostMapping
    public R<Long> create(@RequestBody PurchaseOrder order) {
        order.setOperatorId(StpUtil.getLoginIdAsLong());
        return R.ok(purchaseOrderService.create(order));
    }

    @SaCheckRole("role_1")
    @Operation(summary = "提交采购订单")
    @PutMapping("/{id}/submit")
    public R<Void> submit(@PathVariable Long id) {
        purchaseOrderService.submit(id);
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "审核通过采购订单")
    @PutMapping("/{id}/approve")
    public R<Void> approve(@PathVariable Long id) {
        purchaseOrderService.approve(id);
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "驳回采购订单")
    @PutMapping("/{id}/reject")
    public R<Void> reject(@PathVariable Long id, @RequestBody Map<String, String> body) {
        purchaseOrderService.reject(id, body.getOrDefault("reason", ""));
        return R.ok();
    }

    @Operation(summary = "取消采购订单")
    @PutMapping("/{id}/cancel")
    public R<Void> cancel(@PathVariable Long id) {
        purchaseOrderService.cancel(id);
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "导出采购订单")
    @GetMapping("/export")
    public void export(HttpServletResponse response,
                       @RequestParam(required = false) String ids) {
        List<PurchaseOrder> allList = purchaseOrderService.listAll();
        List<PurchaseOrder> list = allList.stream()
                .filter(o -> o.getStatus() != null && o.getStatus() != 3)
                .collect(Collectors.toList());
        if (ids != null && !ids.isEmpty()) {
            List<Long> idList = Arrays.stream(ids.split(",")).map(Long::parseLong).collect(Collectors.toList());
            list = list.stream().filter(o -> idList.contains(o.getId())).collect(Collectors.toList());
        }
        List<PurchaseOrderExportVO> voList = list.stream()
                .map(order -> {
            PurchaseOrderExportVO vo = new PurchaseOrderExportVO();
            vo.setOrderNo(order.getOrderNo());
            vo.setSupplierName(order.getSupplierName());
            vo.setWarehouseName(order.getWarehouseName());
            vo.setWarehousePath(order.getWarehousePath());
            vo.setTotalQuantity(order.getTotalQuantity());
            vo.setTotalAmount(order.getTotalAmount());
            vo.setOperatorName(order.getOperatorName());
            vo.setOrderDate(order.getOrderDate());
            if (order.getCreateTime() != null) vo.setCreateTime(order.getCreateTime());
            String statusText;
            if (order.getStatus() == OrderStatus.DRAFT) {
                statusText = "草稿";
            } else if (order.getStatus() == OrderStatus.CONFIRMED) {
                statusText = "已入库";
            } else if (order.getStatus() == OrderStatus.CANCELED) {
                statusText = "已取消";
            } else if (order.getStatus() == OrderStatus.PENDING) {
                statusText = "待审批";
            } else {
                statusText = "未知";
            }
            vo.setStatus(statusText);
            return vo;
        }).collect(Collectors.toList());
        ExcelUtil.export(response, voList, "采购订单列表", PurchaseOrderExportVO.class);
    }

    @SaCheckRole("role_1")
    @Operation(summary = "导出采购订单明细")
    @GetMapping("/export-detail")
    public void exportDetail(HttpServletResponse response,
                             @RequestParam(required = false) String ids) throws IOException {
        List<PurchaseOrder> allList = purchaseOrderService.listAll();
        List<PurchaseOrder> list = allList.stream()
                .filter(o -> o.getStatus() != null && o.getStatus() != 3)
                .collect(Collectors.toList());
        if (ids != null && !ids.isEmpty()) {
            List<Long> idList = Arrays.stream(ids.split(",")).map(Long::parseLong).collect(Collectors.toList());
            list = list.stream().filter(o -> idList.contains(o.getId())).collect(Collectors.toList());
        }
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("采购订单明细", "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");
        var excelWriter = EasyExcel.write(response.getOutputStream()).build();

        // 第一个 sheet：汇总
        List<List<Object>> summaryData = new ArrayList<>();
        summaryData.add(Arrays.asList("订单编号", "供应商", "仓库", "仓库路径", "总数量", "总金额", "日期", "操作人", "状态"));
        for (PurchaseOrder o : list) {
            String statusText = switch (o.getStatus()) {
                case 0 -> "草稿"; case 1 -> "已入库"; case 2 -> "已取消"; case 4 -> "待审批";
                default -> "未知";
            };
            List<Object> row = new ArrayList<>();
            row.add(o.getOrderNo());
            row.add(o.getSupplierName() != null ? o.getSupplierName() : "");
            row.add(o.getWarehouseName() != null ? o.getWarehouseName() : "");
            row.add(o.getWarehousePath() != null ? o.getWarehousePath() : "");
            row.add(o.getTotalQuantity() != null ? o.getTotalQuantity() : 0);
            row.add(o.getTotalAmount() != null ? o.getTotalAmount() : "");
            row.add(o.getOrderDate() != null ? o.getOrderDate().toString() : "");
            row.add(o.getOperatorName() != null ? o.getOperatorName() : "");
            row.add(statusText);
            summaryData.add(row);
        }
        WriteSheet summarySheet = EasyExcel.writerSheet("汇总").build();
        excelWriter.write(summaryData, summarySheet);

        // 一次批量查询，按单号分组
        List<PurchaseOrderDetailExportVO> allDetails = purchaseOrderService.getDetailExportList(list);
        var grouped = allDetails.stream().collect(Collectors.groupingBy(PurchaseOrderDetailExportVO::getOrderNo, java.util.LinkedHashMap::new, Collectors.toList()));

        // 汇总明细 sheet：所有订单明细合在一起，不同订单之间空一行
        WriteSheet summaryDetailSheet = EasyExcel.writerSheet("汇总明细").head(PurchaseOrderDetailExportVO.class).build();
        boolean first = true;
        for (var entry : grouped.entrySet()) {
            if (!first) {
                // 空行分隔不同订单
                List<Object> emptyRow = new ArrayList<>();
                for (int i = 0; i < 13; i++) emptyRow.add("");
                excelWriter.write(List.of(emptyRow), summaryDetailSheet);
            }
            excelWriter.write(entry.getValue(), summaryDetailSheet);
            first = false;
        }

        // 每个订单单独一个 sheet
        for (var entry : grouped.entrySet()) {
            WriteSheet writeSheet = EasyExcel.writerSheet(entry.getKey()).head(PurchaseOrderDetailExportVO.class).build();
            excelWriter.write(entry.getValue(), writeSheet);
        }
        excelWriter.finish();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "更新草稿采购订单")
    @PutMapping("/{id}/draft")
    public R<Void> updateDraft(@PathVariable Long id, @RequestBody PurchaseOrder order) {
        order.setId(id);
        purchaseOrderService.updateDraft(order);
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "删除采购订单")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        purchaseOrderService.delete(id);
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "批量删除采购订单")
    @DeleteMapping("/batch")
    public R<Void> batchDelete(@RequestBody List<Long> ids) {
        purchaseOrderService.batchDelete(ids);
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "作废采购订单")
    @PutMapping("/{id}/void")
    public R<Void> voidOrder(@PathVariable Long id, @RequestBody Map<String, String> body) {
        purchaseOrderService.voidOrder(id, body.getOrDefault("reason", ""));
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "批量作废采购订单")
    @PutMapping("/batch-void")
    public R<Void> batchVoid(@RequestBody Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        List<Integer> ids = (List<Integer>) body.get("ids");
        String reason = (String) body.getOrDefault("reason", "");
        purchaseOrderService.batchVoid(ids.stream().map(Long::valueOf).collect(Collectors.toList()), reason);
        return R.ok();
    }
}
