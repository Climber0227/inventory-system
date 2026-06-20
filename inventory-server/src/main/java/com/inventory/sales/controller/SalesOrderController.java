package com.inventory.sales.controller;

import cn.dev33.satoken.annotation.SaCheckRole;
import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.common.constant.OrderStatus;
import com.inventory.common.result.PageResult;
import com.inventory.common.result.R;
import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.write.metadata.WriteSheet;
import com.inventory.common.util.ExcelUtil;
import com.inventory.sales.entity.SalesOrder;
import com.inventory.sales.entity.SalesOrderDetailExportVO;
import com.inventory.sales.entity.SalesOrderExportVO;
import com.inventory.sales.service.SalesOrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

import java.io.IOException;
import java.net.URLEncoder;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Tag(name = "销售订单管理")
@RestController
@RequestMapping("/api/v1/sales-order")
@RequiredArgsConstructor
public class SalesOrderController {

    private final SalesOrderService salesOrderService;

    @Operation(summary = "分页查询销售订单")
    @GetMapping("/page")
    public R<PageResult<SalesOrder>> page(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String orderNo,
            @RequestParam(required = false) Long customerId,
            @RequestParam(required = false) Long warehouseId,
            @RequestParam(required = false) Integer minQuantity,
            @RequestParam(required = false) Integer maxQuantity,
            @RequestParam(required = false) BigDecimal minAmount,
            @RequestParam(required = false) BigDecimal maxAmount,
            @RequestParam(required = false) String salesman,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) {
        return R.ok(PageResult.of(salesOrderService.page(new Page<>(page, size), orderNo, customerId, warehouseId, minQuantity, maxQuantity, minAmount, maxAmount, salesman, status, startDate, endDate)));
    }

    @Operation(summary = "获取销售订单详情")
    @GetMapping("/{id}")
    public R<SalesOrder> getById(@PathVariable Long id) {
        return R.ok(salesOrderService.getDetail(id));
    }

    @Operation(summary = "新增销售订单")
    @PostMapping
    public R<Long> create(@RequestBody SalesOrder order) {
        order.setOperatorId(StpUtil.getLoginIdAsLong());
        return R.ok(salesOrderService.create(order));
    }

    @Operation(summary = "提交销售订单")
    @PutMapping("/{id}/submit")
    public R<Void> submit(@PathVariable Long id) {
        salesOrderService.submit(id);
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "审核通过销售订单")
    @PutMapping("/{id}/approve")
    public R<Void> approve(@PathVariable Long id) {
        salesOrderService.approve(id);
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "驳回销售订单")
    @PutMapping("/{id}/reject")
    public R<Void> reject(@PathVariable Long id, @RequestBody Map<String, String> body) {
        salesOrderService.reject(id, body.getOrDefault("reason", ""));
        return R.ok();
    }

    @Operation(summary = "取消销售订单")
    @PutMapping("/{id}/cancel")
    public R<Void> cancel(@PathVariable Long id) {
        salesOrderService.cancel(id);
        return R.ok();
    }

    @Operation(summary = "更新草稿销售订单")
    @PutMapping("/{id}/draft")
    public R<Void> updateDraft(@PathVariable Long id, @RequestBody SalesOrder order) {
        order.setId(id);
        salesOrderService.updateDraft(order);
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "导出销售订单")
    @GetMapping("/export")
    public void export(HttpServletResponse response,
                       @RequestParam(required = false) String ids,
                       @RequestParam(required = false) String orderNo,
                       @RequestParam(required = false) Long customerId,
                       @RequestParam(required = false) Long warehouseId,
                       @RequestParam(required = false) Integer status,
                       @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
                       @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) {
        List<SalesOrder> allList = salesOrderService.page(
                new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(1, 99999),
                orderNo, customerId, warehouseId, null, null, null, null, null, status, startDate, endDate)
                .getRecords();
        if (ids != null && !ids.isEmpty()) {
            List<Long> idList = Arrays.stream(ids.split(",")).map(Long::parseLong).collect(Collectors.toList());
            allList = allList.stream().filter(o -> idList.contains(o.getId())).collect(Collectors.toList());
        }
        List<SalesOrderExportVO> voList = allList.stream()
                .map(order -> {
            SalesOrderExportVO vo = new SalesOrderExportVO();
            vo.setOrderNo(order.getOrderNo());
            vo.setCustomerName(order.getCustomerName());
            vo.setWarehouseName(order.getWarehouseName());
            vo.setWarehousePath(order.getWarehousePath());
            vo.setTotalQuantity(order.getTotalQuantity());
            vo.setTotalAmount(order.getTotalAmount());
            vo.setSalesman(order.getSalesman());
            vo.setOperatorName(order.getOperatorName());
            vo.setOrderDate(order.getOrderDate());
            if (order.getCreateTime() != null) vo.setCreateTime(order.getCreateTime());
            String statusText;
            if (order.getStatus() == OrderStatus.DRAFT) {
                statusText = "草稿";
            } else if (order.getStatus() == OrderStatus.CONFIRMED) {
                statusText = "已出库";
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
        ExcelUtil.export(response, voList, "销售订单列表", SalesOrderExportVO.class);
    }

    @SaCheckRole("role_1")
    @Operation(summary = "导出销售订单明细")
    @GetMapping("/export-detail")
    public void exportDetail(HttpServletResponse response,
                             @RequestParam(required = false) String ids,
                             @RequestParam(required = false) String orderNo,
                             @RequestParam(required = false) Long customerId,
                             @RequestParam(required = false) Long warehouseId,
                             @RequestParam(required = false) Integer status,
                             @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
                             @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) throws IOException {
        List<SalesOrder> allList = salesOrderService.page(
                new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(1, 99999),
                orderNo, customerId, warehouseId, null, null, null, null, null, status, startDate, endDate)
                .getRecords();
        if (ids != null && !ids.isEmpty()) {
            List<Long> idList = Arrays.stream(ids.split(",")).map(Long::parseLong).collect(Collectors.toList());
            allList = allList.stream().filter(o -> idList.contains(o.getId())).collect(Collectors.toList());
        }
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("销售订单明细", "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");
        var excelWriter = EasyExcel.write(response.getOutputStream()).build();

        // 汇总 sheet
        List<List<Object>> summaryData = new ArrayList<>();
        summaryData.add(Arrays.asList("订单编号", "客户", "仓库", "仓库路径", "总数量", "总金额", "日期", "操作人", "状态"));
        for (SalesOrder o : allList) {
            String statusText = switch (o.getStatus()) {
                case 0 -> "草稿"; case 1 -> "已出库"; case 2 -> "已取消"; case 4 -> "待审批";
                default -> "未知";
            };
            List<Object> row = new ArrayList<>();
            row.add(o.getOrderNo());
            row.add(o.getCustomerName() != null ? o.getCustomerName() : "");
            row.add(o.getWarehouseName() != null ? o.getWarehouseName() : "");
            row.add(o.getWarehousePath() != null ? o.getWarehousePath() : "");
            row.add(o.getTotalQuantity() != null ? o.getTotalQuantity() : 0);
            row.add(o.getTotalAmount() != null ? o.getTotalAmount() : "");
            row.add(o.getOrderDate() != null ? o.getOrderDate().toString() : "");
            row.add(o.getOperatorName() != null ? o.getOperatorName() : "");
            row.add(statusText);
            summaryData.add(row);
        }
        excelWriter.write(summaryData, EasyExcel.writerSheet("汇总").build());

        // 一次批量查询，按单号分组
        List<SalesOrderDetailExportVO> allDetails = salesOrderService.getDetailExportList(allList);
        var grouped = allDetails.stream().collect(Collectors.groupingBy(SalesOrderDetailExportVO::getOrderNo, java.util.LinkedHashMap::new, Collectors.toList()));

        // 汇总明细 sheet：所有订单明细合在一起，不同订单之间空一行
        WriteSheet summaryDetailSheet = EasyExcel.writerSheet("汇总明细").head(SalesOrderDetailExportVO.class).build();
        boolean first = true;
        for (var entry : grouped.entrySet()) {
            if (!first) {
                List<Object> emptyRow = new ArrayList<>();
                for (int i = 0; i < 13; i++) emptyRow.add("");
                excelWriter.write(List.of(emptyRow), summaryDetailSheet);
            }
            excelWriter.write(entry.getValue(), summaryDetailSheet);
            first = false;
        }

        // 每个订单单独一个 sheet
        for (var entry : grouped.entrySet()) {
            WriteSheet writeSheet = EasyExcel.writerSheet(entry.getKey()).head(SalesOrderDetailExportVO.class).build();
            excelWriter.write(entry.getValue(), writeSheet);
        }
        excelWriter.finish();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "删除销售订单")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        salesOrderService.delete(id);
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "批量删除销售订单")
    @DeleteMapping("/batch")
    public R<Void> batchDelete(@RequestBody List<Long> ids) {
        salesOrderService.batchDelete(ids);
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "作废销售订单")
    @PutMapping("/{id}/void")
    public R<Void> voidOrder(@PathVariable Long id, @RequestBody Map<String, String> body) {
        salesOrderService.voidOrder(id, body.getOrDefault("reason", ""));
        return R.ok();
    }

    @SaCheckRole("role_1")
    @Operation(summary = "批量作废销售订单")
    @PutMapping("/batch-void")
    public R<Void> batchVoid(@RequestBody Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        List<Integer> ids = (List<Integer>) body.get("ids");
        String reason = (String) body.getOrDefault("reason", "");
        salesOrderService.batchVoid(ids.stream().map(Long::valueOf).collect(Collectors.toList()), reason);
        return R.ok();
    }
}
