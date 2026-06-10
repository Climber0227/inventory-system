package com.inventory.product.service;

import com.alibaba.excel.context.AnalysisContext;
import com.alibaba.excel.event.AnalysisEventListener;
import com.inventory.common.exception.BusinessException;
import com.inventory.common.util.ImportResult;
import com.inventory.product.entity.ProductImportVO;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.List;

/**
 * 商品导入监听器——批量处理，失败时逐条定位错误行。
 */
@Slf4j
public class ProductImportListener extends AnalysisEventListener<ProductImportVO> {

    private final ProductService productService;
    private final ImportResult result = new ImportResult();
    private final List<ProductImportVO> allRows = new ArrayList<>();
    private int rowNum = 0;

    public ProductImportListener(ProductService productService) {
        this.productService = productService;
    }

    @Override
    public void invoke(ProductImportVO row, AnalysisContext ctx) {
        rowNum++;
        if (row.getName() == null || row.getName().trim().isEmpty()) return;
        String err = com.inventory.common.util.ValidatorUtils.validate(row);
        if (err != null) {
            result.addError(rowNum, err);
            return;
        }
        allRows.add(row);
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext ctx) {
        if (allRows.isEmpty()) return;
        try {
            int count = productService.importExcel(allRows);
            for (int i = 0; i < count; i++) result.addSuccess();
        } catch (Exception e) {
            log.error("商品导入失败", e);
            String msg = e instanceof BusinessException ? e.getMessage() : "系统错误";
            result.addError(1, msg);
        }
    }

    public ImportResult getResult() { return result; }
}
