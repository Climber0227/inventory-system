package com.inventory.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.common.exception.BusinessException;
import com.inventory.system.entity.SysUser;
import com.inventory.system.mapper.SysUserMapper;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SysUserService {

    private final SysUserMapper sysUserMapper;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public SysUserService(SysUserMapper sysUserMapper) {
        this.sysUserMapper = sysUserMapper;
    }

    public Page<SysUser> page(Page<SysUser> page, String username, String realName, Integer status, String roleType) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<SysUser>()
                .like(username != null, SysUser::getUsername, username)
                .like(realName != null, SysUser::getRealName, realName)
                .eq(status != null, SysUser::getStatus, status)
                .orderByDesc(SysUser::getId);
        // 角色筛选
        if ("admin".equals(roleType)) {
            wrapper.eq(SysUser::getRole, 1);
        } else if ("employee".equals(roleType)) {
            wrapper.eq(SysUser::getRole, 2);
        }
        return sysUserMapper.selectPage(page, wrapper);
    }

    @Transactional(rollbackFor = Exception.class)
    public void saveUser(SysUser user) {
        long count = sysUserMapper.selectCount(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, user.getUsername()));
        if (count > 0) throw new BusinessException("用户名已存在");
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        if (user.getRole() == null) {
            user.setRole(2); // 默认为员工
        }
        sysUserMapper.insert(user);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateUser(SysUser user) {
        SysUser existing = sysUserMapper.selectById(user.getId());
        if (existing == null) throw new BusinessException("用户不存在");

        // 超级管理员 admin 账号不可降级、禁用、改名
        if ("admin".equals(existing.getUsername())) {
            user.setRole(null);
            user.setStatus(null);
            user.setUsername(null);
        }

        String newUsername = user.getUsername();
        if (newUsername != null && !newUsername.equals(existing.getUsername())) {
            long c = sysUserMapper.selectCount(
                    new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, newUsername));
            if (c > 0) throw new BusinessException("用户名已存在");
        }
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        } else {
            user.setPassword(null);
        }
        sysUserMapper.updateById(user);
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteUser(Long id) {
        SysUser user = sysUserMapper.selectById(id);
        if (user == null) throw new BusinessException("用户不存在");
        if ("admin".equals(user.getUsername())) throw new BusinessException("admin账号不可删除");
        sysUserMapper.deleteById(id);
    }
}
