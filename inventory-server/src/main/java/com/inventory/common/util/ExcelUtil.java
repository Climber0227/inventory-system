package com.inventory.common.util;

import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.ExcelWriter;
import com.alibaba.excel.write.metadata.WriteSheet;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

public class ExcelUtil {

    /** 分页数据获取器 */
    @FunctionalInterface
    public interface PageFetcher<T> {
        List<T> fetch(int page, int pageSize);
    }

    /** 标准导出（小数据集，一次性加载到内存后写入） */
    public static void export(HttpServletResponse response, List<?> data,
                              String fileName, Class<?> clazz) {
        setHeaders(response, fileName);
        EasyExcel.write(getOutputStream(response), clazz).sheet("Sheet1").doWrite(data);
    }

    /**
     * 流式导出（大数据集，分页从 DB 读取，边读边写，内存占用恒定）。
     * 示例：
     * <pre>
     * ExcelUtil.exportStreaming(response, "库存导出", InventoryExportVO.class, 1000,
     *     (page, size) -> service.page(new Page(page, size)).getRecords().stream().map(...).toList());
     * </pre>
     */
    public static <T> void exportStreaming(HttpServletResponse response, String fileName,
                                           Class<T> clazz, int pageSize, PageFetcher<T> fetcher) {
        setHeaders(response, fileName);
        try (ExcelWriter excelWriter = EasyExcel.write(getOutputStream(response), clazz).build()) {
            WriteSheet sheet = EasyExcel.writerSheet("Sheet1").build();
            int page = 1;
            List<T> data;
            do {
                data = fetcher.fetch(page++, pageSize);
                if (data != null && !data.isEmpty()) excelWriter.write(data, sheet);
            } while (data != null && !data.isEmpty());
        }
    }

    private static void setHeaders(HttpServletResponse response, String fileName) {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String encoded = URLEncoder.encode(fileName, StandardCharsets.UTF_8).replaceAll("\\+", "%20");
        response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + encoded + ".xlsx");
    }

    private static java.io.OutputStream getOutputStream(HttpServletResponse response) {
        try { return response.getOutputStream(); }
        catch (IOException e) { throw new RuntimeException("获取输出流失败", e); }
    }
}
