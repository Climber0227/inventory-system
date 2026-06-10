package com.inventory.common.annotation;

import java.lang.annotation.*;

/** 防止重复提交——同一用户在同一接口的相同请求，interval 毫秒内只允许一次 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RepeatSubmit {
    /** 间隔(ms)，默认 3000ms */
    int interval() default 3000;
}
