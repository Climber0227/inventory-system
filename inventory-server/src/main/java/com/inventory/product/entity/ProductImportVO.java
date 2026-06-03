package com.inventory.product.entity;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class ProductImportVO {
    @ExcelProperty("商品名称") private String name;
    @ExcelProperty("编码") private String code;
    @ExcelProperty("分类路径") private String categoryPath;
    @ExcelProperty("规格") private String spec;
    @ExcelProperty("单位") private String unit;
    @ExcelProperty("采购价") private BigDecimal purchasePrice;
    @ExcelProperty("销售价") private BigDecimal salePrice;
    @ExcelProperty("最低库存") private Integer minStock;
    @ExcelProperty("最高库存") private Integer maxStock;
    @ExcelProperty("状态") private String status;
}
