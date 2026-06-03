package com.inventory.inventory.entity;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.write.style.ColumnWidth;
import lombok.Data;

@Data
public class InventoryExportVO {

    @ColumnWidth(18)
    @ExcelProperty("商品编码")
    private String productCode;

    @ColumnWidth(24)
    @ExcelProperty("商品名称")
    private String productName;

    @ColumnWidth(18)
    @ExcelProperty("一级仓库")
    private String level1Name;

    @ColumnWidth(18)
    @ExcelProperty("二级仓库")
    private String level2Name;

    @ColumnWidth(18)
    @ExcelProperty("三级仓库")
    private String level3Name;

    @ColumnWidth(18)
    @ExcelProperty("四级仓库")
    private String level4Name;

    @ColumnWidth(14)
    @ExcelProperty("库存数量")
    private Integer quantity;

    @ColumnWidth(16)
    @ExcelProperty("成本均价")
    private String costPrice;

    @ColumnWidth(16)
    @ExcelProperty("库存金额")
    private String amount;
}
