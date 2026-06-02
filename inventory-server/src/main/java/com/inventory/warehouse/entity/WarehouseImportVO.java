package com.inventory.warehouse.entity;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.Data;

@Data
public class WarehouseImportVO {
    @ExcelProperty("一级仓库") private String level1Name;
    @ExcelProperty("二级仓库") private String level2Name;
    @ExcelProperty("三级仓库") private String level3Name;
    @ExcelProperty("四级仓库") private String level4Name;
    @ExcelProperty("编码") private String code;
    @ExcelProperty("联系人") private String contact;
    @ExcelProperty("电话") private String phone;
    @ExcelProperty("地址") private String address;
    @ExcelProperty("状态") private String status;
}
