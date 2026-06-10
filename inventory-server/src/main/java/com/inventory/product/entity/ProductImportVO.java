package com.inventory.product.entity;

import com.alibaba.excel.annotation.ExcelProperty;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class ProductImportVO {
    @NotBlank(message = "商品名称不能为空")
    @ExcelProperty("商品名称") private String name;

    @ExcelProperty("编码") private String code;
    @ExcelProperty("分类路径") private String categoryPath;
    @ExcelProperty("规格") private String spec;
    @ExcelProperty("单位") private String unit;

    @DecimalMin(value = "0", message = "采购价不能为负数")
    @ExcelProperty("采购价") private BigDecimal purchasePrice;

    @DecimalMin(value = "0", message = "销售价不能为负数")
    @ExcelProperty("销售价") private BigDecimal salePrice;

    @Min(value = 0, message = "最低库存不能为负数")
    @ExcelProperty("最低库存") private Integer minStock;

    @Min(value = 0, message = "最高库存不能为负数")
    @ExcelProperty("最高库存") private Integer maxStock;

    @ExcelProperty("状态") private String status;
}
