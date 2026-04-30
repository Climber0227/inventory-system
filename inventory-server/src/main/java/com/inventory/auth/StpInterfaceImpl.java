package com.inventory.auth;

import cn.dev33.satoken.stp.StpInterface;
import com.inventory.system.entity.SysUser;
import com.inventory.system.mapper.SysUserMapper;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Component
public class StpInterfaceImpl implements StpInterface {

    private final SysUserMapper userMapper;

    public StpInterfaceImpl(SysUserMapper userMapper) {
        this.userMapper = userMapper;
    }

    @Override
    public List<String> getPermissionList(Object loginId, String loginType) {
        return new ArrayList<>();
    }

    @Override
    public List<String> getRoleList(Object loginId, String loginType) {
        SysUser user = userMapper.selectById(Long.parseLong(loginId.toString()));
        if (user != null && user.getRole() != null && user.getRole() == 1) {
            return Collections.singletonList("role_1");
        }
        return Collections.emptyList();
    }
}
