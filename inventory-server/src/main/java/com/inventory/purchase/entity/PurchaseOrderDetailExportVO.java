package com.inventory.purchase.entity;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.write.style.ColumnWidth;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class PurchaseOrderDetailExportVO {
    @ExcelProperty("订单编号") private String orderNo;
    @ExcelProperty("供应商") private String supplierName;
    @ExcelProperty("仓库") private String warehouseName;
    @ExcelProperty("仓库路径") private String warehousePath;
    @ColumnWidth(18) @ExcelProperty("日期") private LocalDate orderDate;
    @ExcelProperty("操作人") private String operatorName;
    @ExcelProperty("商品名称") private String productName;
    @ExcelProperty("商品编码") private String productCode;
    @ExcelProperty("数量") private Integer quantity;
    @ExcelProperty("单价") private BigDecimal unitPrice;
    @ExcelProperty("金额") private BigDecimal amount;
    @ExcelProperty("状态") private String status;
    @ExcelProperty("备注") private String remark;
}
