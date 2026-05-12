package com.inventory.transfer.entity;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.write.style.ColumnWidth;
import lombok.Data;
import java.time.LocalDate;

@Data
public class TransferDetailExportVO {
    @ExcelProperty("调拨单号") private String orderNo;
    @ExcelProperty("调出仓库") private String fromWarehouseName;
    @ExcelProperty("调入仓库") private String toWarehouseName;
    @ExcelProperty("状态") private String status;
    @ColumnWidth(18) @ExcelProperty("单据日期") private LocalDate orderDate;
    @ExcelProperty("操作人") private String operatorName;
    @ExcelProperty("商品名称") private String productName;
    @ExcelProperty("商品编码") private String productCode;
    @ExcelProperty("调拨数量") private Integer quantity;
    @ExcelProperty("批次号") private String batchNo;
}
