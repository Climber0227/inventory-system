package com.inventory.warehouse.service;

import com.alibaba.excel.context.AnalysisContext;
import com.alibaba.excel.event.AnalysisEventListener;
import com.inventory.common.exception.BusinessException;
import com.inventory.common.util.ImportResult;
import com.inventory.warehouse.entity.WarehouseImportVO;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.List;

@Slf4j
public class WarehouseImportListener extends AnalysisEventListener<WarehouseImportVO> {

    private final WarehouseService warehouseService;
    private final ImportResult result = new ImportResult();
    private final List<WarehouseImportVO> allRows = new ArrayList<>();

    public WarehouseImportListener(WarehouseService warehouseService) {
        this.warehouseService = warehouseService;
    }

    @Override
    public void invoke(WarehouseImportVO row, AnalysisContext ctx) {
        boolean allEmpty = (row.getLevel1Name() == null || row.getLevel1Name().trim().isEmpty())
                && (row.getLevel2Name() == null || row.getLevel2Name().trim().isEmpty())
                && (row.getLevel3Name() == null || row.getLevel3Name().trim().isEmpty())
                && (row.getLevel4Name() == null || row.getLevel4Name().trim().isEmpty());
        if (allEmpty) return;
        allRows.add(row);
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext ctx) {
        if (allRows.isEmpty()) return;
        try {
            int count = warehouseService.importExcel(allRows);
            for (int i = 0; i < count; i++) result.addSuccess();
        } catch (Exception e) {
            log.error("仓库导入失败", e);
            String msg = e instanceof BusinessException ? e.getMessage() : e.getClass().getSimpleName() + ": " + e.getMessage();
            result.addError(1, msg);
        }
    }

    public ImportResult getResult() { return result; }
}
