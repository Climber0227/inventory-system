package com.inventory.common.util;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import java.util.Set;
import java.util.stream.Collectors;

/** JSR 校验工具 */
public final class ValidatorUtils {
    private static final Validator VALIDATOR;

    static {
        try (ValidatorFactory factory = Validation.buildDefaultValidatorFactory()) {
            VALIDATOR = factory.getValidator();
        }
    }

    /** 校验对象，返回错误信息（null=通过） */
    public static String validate(Object obj) {
        Set<ConstraintViolation<Object>> violations = VALIDATOR.validate(obj);
        if (violations.isEmpty()) return null;
        return violations.stream()
                .map(v -> v.getPropertyPath() + ": " + v.getMessage())
                .collect(Collectors.joining("; "));
    }

    private ValidatorUtils() {}
}
