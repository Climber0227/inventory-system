package com.inventory.common.util;

import java.util.ArrayList;
import java.util.List;

/** 导入结果——成功数、失败数、逐行错误详情 */
public class ImportResult {
    private int success;
    private int failure;
    private int total;
    private final List<String> errors = new ArrayList<>();

    public void addSuccess() { success++; total++; }
    public void addError(int row, String msg) {
        failure++;
        total++;
        errors.add(String.format("第 %d 行: %s", row, msg));
    }

    public int getSuccess() { return success; }
    public int getFailure() { return failure; }
    public int getTotal() { return total; }
    public List<String> getErrors() { return errors; }
    public boolean hasErrors() { return failure > 0; }

    public String getSummary() {
        StringBuilder sb = new StringBuilder();
        sb.append("共 ").append(total).append(" 条: 成功 ").append(success).append(" 条");
        if (failure > 0) {
            sb.append(", 失败 ").append(failure).append(" 条");
            sb.append("\n错误详情:");
            for (int i = 0; i < Math.min(errors.size(), 10); i++) {
                sb.append("\n  ").append(errors.get(i));
            }
            if (errors.size() > 10) {
                sb.append("\n  ... 共 ").append(errors.size()).append(" 条错误");
            }
        }
        return sb.toString();
    }
}
