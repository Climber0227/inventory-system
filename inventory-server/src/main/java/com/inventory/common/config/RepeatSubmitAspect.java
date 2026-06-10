package com.inventory.common.config;

import cn.dev33.satoken.stp.StpUtil;
import com.inventory.common.annotation.RepeatSubmit;
import com.inventory.common.exception.BusinessException;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/** 防重复提交切面 */
@Aspect
@Component
public class RepeatSubmitAspect {

    /** key = userId + ":" + uri + ":" + bodyHash */
    private final Map<String, Long> cache = new ConcurrentHashMap<>();

    @Around("@annotation(repeatSubmit)")
    public Object around(ProceedingJoinPoint pjp, RepeatSubmit repeatSubmit) throws Throwable {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs == null) return pjp.proceed();

        HttpServletRequest req = attrs.getRequest();
        long userId = 0;
        try { userId = StpUtil.getLoginIdAsLong(); } catch (Exception ignored) {}

        // 用 userId + URI + 参数哈希做去重 key
        String key = userId + ":" + req.getRequestURI() + ":" + req.getHeader("Content-Type");
        long now = System.currentTimeMillis();
        Long last = cache.get(key);

        if (last != null && (now - last) < repeatSubmit.interval()) {
            throw new BusinessException("请勿重复提交");
        }

        cache.put(key, now);
        try {
            return pjp.proceed();
        } finally {
            // 清理过期缓存（简单实现，每隔一段时间清理一次）
            if (cache.size() > 1000) cache.clear();
        }
    }
}
