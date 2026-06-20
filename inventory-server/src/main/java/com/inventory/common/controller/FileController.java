package com.inventory.common.controller;

import cn.hutool.core.io.FileUtil;
import cn.hutool.core.util.IdUtil;
import com.inventory.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

@Tag(name = "文件管理")
@RestController
@RequestMapping("/api/v1/file")
public class FileController {

    @Value("${app.upload-base-path:${user.dir}/uploads}")
    private String uploadBasePath;

    private String imageDir;

    @PostConstruct
    public void init() {
        imageDir = uploadBasePath + "/images";
        File dir = new File(imageDir);
        if (!dir.exists()) dir.mkdirs();
    }

    @Operation(summary = "上传图片")
    @PostMapping("/upload")
    public R<String> upload(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return R.fail("上传文件为空");
        }
        String ext = FileUtil.extName(file.getOriginalFilename());
        if (ext == null || !java.util.Set.of("jpg", "jpeg", "png", "gif").contains(ext.toLowerCase())) {
            return R.fail("仅支持 jpg/png/gif 格式");
        }
        try {
            String fileName = IdUtil.fastSimpleUUID() + "." + ext;
            File dest = new File(imageDir, fileName);
            file.transferTo(dest);
            return R.ok("/api/v1/file/view/" + fileName);
        } catch (IOException e) {
            return R.fail("文件上传失败: " + e.getMessage());
        }
    }

    @Operation(summary = "查看图片")
    @GetMapping("/view/{filename}")
    public void view(@PathVariable String filename, HttpServletResponse response) throws IOException {
        File file = new File(imageDir, filename);
        if (!file.exists()) {
            response.sendError(404);
            return;
        }
        String ext = FileUtil.extName(filename).toLowerCase();
        String contentType = switch (ext) {
            case "png" -> "image/png";
            case "gif" -> "image/gif";
            default -> "image/jpeg";
        };
        response.setContentType(contentType);
        Files.copy(file.toPath(), response.getOutputStream());
    }
}
