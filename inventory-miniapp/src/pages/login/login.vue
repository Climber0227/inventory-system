<script setup>
import { ref } from 'vue'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
const username = ref('')
const password = ref('')
const loading = ref(false)
const focusField = ref('')

async function handleLogin() {
  if (!username.value || !password.value) {
    uni.showToast({ title: '请输入用户名和密码', icon: 'none' })
    return
  }
  loading.value = true
  try {
    await userStore.login(username.value, password.value)
    uni.showToast({ title: '登录成功', icon: 'success' })
    uni.switchTab({ url: '/pages/home/home' })
  } catch { /* handled */ } finally { loading.value = false }
}
</script>

<template>
  <view class="login-page">
    <!-- 装饰背景 -->
    <view class="deco-circle c1"></view>
    <view class="deco-circle c2"></view>
    <view class="deco-circle c3"></view>

    <!-- 品牌区 -->
    <view class="brand-area">
      <view class="brand-icon" :class="{ 'leaf-active': focusField }">
        <image class="leaf-img" src="/static/leaf.svg" mode="aspectFit"></image>
      </view>
      <text class="brand-name">进销存管理</text>
      <text class="brand-desc">采购 · 销售 · 库存 · 盘点</text>
    </view>

    <!-- 登录表单 -->
    <view class="form-card">
      <view :class="['input-group', { focused: focusField === 'user' }]">
        <text class="input-label">账号</text>
        <input
          v-model="username" class="input-field"
          placeholder="请输入账号" placeholder-class="ph"
          @focus="focusField = 'user'" @blur="focusField = ''"
        />
        <view class="input-line"></view>
      </view>

      <view :class="['input-group', { focused: focusField === 'pwd' }]">
        <text class="input-label">密码</text>
        <input
          v-model="password" class="input-field" type="password" password
          placeholder="请输入密码" placeholder-class="ph"
          @focus="focusField = 'pwd'" @blur="focusField = ''"
        />
        <view class="input-line"></view>
      </view>

      <button class="login-btn" :loading="loading" @click="handleLogin" :disabled="loading">
        <text v-if="!loading" class="btn-text">登 录</text>
        <view v-else class="btn-loading">
          <view class="dot-pulse"></view>
        </view>
      </button>
    </view>

    <text class="version">v2.0</text>
  </view>
</template>

<style scoped>
.login-page {
  min-height: 100vh;
  background: linear-gradient(160deg, #1a5c2a 0%, #2e7d32 30%, #4a9e5a 60%, #f0f7f0 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 32px;
  position: relative;
  overflow: hidden;
}

/* 装饰圆 */
.deco-circle {
  position: absolute;
  border-radius: 50%;
  opacity: 0.08;
}
.c1 {
  width: 300px; height: 300px;
  background: #fff;
  top: -80px; right: -80px;
}
.c2 {
  width: 200px; height: 200px;
  background: #fff;
  bottom: 60px; left: -60px;
}
.c3 {
  width: 120px; height: 120px;
  background: #fff;
  bottom: 200px; right: 40px;
}

/* 品牌区 */
.brand-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 40px;
  animation: fadeDown 0.6s ease;
}
.brand-icon {
  width: 72px; height: 72px;
  background: rgba(255,255,255,0.15);
  border-radius: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 14px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255,255,255,0.1);
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.leaf-img { width: 32px; height: 42px; transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1); }

/* 聚焦时叶片动画 */
.leaf-active {
  transform: scale(1.1);
  background: rgba(255,255,255,0.22);
  border-color: rgba(255,255,255,0.25);
  box-shadow: 0 0 30px rgba(255,255,255,0.1);
}
.leaf-active .leaf-img {
  transform: scale(1.15) rotate(-8deg);
}
.brand-name {
  font-size: 26px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 3px;
  text-shadow: 0 2px 8px rgba(0,0,0,0.1);
  margin-bottom: 6px;
}
.brand-desc {
  font-size: 13px;
  color: rgba(255,255,255,0.7);
  letter-spacing: 2px;
}

/* 表单卡片 */
.form-card {
  width: 100%;
  background: rgba(255,255,255,0.95);
  border-radius: 20px;
  padding: 32px 24px;
  backdrop-filter: blur(20px);
  box-shadow: 0 8px 40px rgba(0,0,0,0.1);
  animation: fadeUp 0.5s ease 0.2s both;
}

/* 输入组 */
.input-group {
  margin-bottom: 22px;
  position: relative;
}
.input-label {
  font-size: 13px;
  color: #888;
  margin-bottom: 6px;
  display: block;
  transition: color 0.2s;
}
.input-group.focused .input-label { color: #2e7d32; }
.input-field {
  width: 100%;
  height: 40px;
  font-size: 16px;
  color: #1a1a1a;
  background: transparent;
  border: none;
  outline: none;
  padding: 0;
}
.ph { color: #bbb; font-size: 15px; }
.input-line {
  height: 1.5px;
  background: #e0e0e0;
  border-radius: 1px;
  transition: all 0.3s;
}
.input-group.focused .input-line {
  background: #2e7d32;
  box-shadow: 0 0 6px rgba(46,125,50,0.3);
}

/* 登录按钮 */
.login-btn {
  width: 100%;
  height: 48px;
  background: linear-gradient(135deg, #1b5e20, #2e7d32);
  border: none;
  border-radius: 12px;
  margin-top: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 16px rgba(46,125,50,0.35);
  transition: all 0.2s;
}
.login-btn:active {
  transform: scale(0.96);
  box-shadow: 0 2px 8px rgba(46,125,50,0.2);
}
.login-btn[disabled] { opacity: 0.8; }
.btn-text {
  color: #fff;
  font-size: 17px;
  font-weight: 600;
  letter-spacing: 6px;
}

/* 加载动画 */
.btn-loading { display: flex; align-items: center; justify-content: center; height: 100%; }
.dot-pulse {
  width: 8px; height: 8px;
  background: #fff;
  border-radius: 50%;
  animation: pulse 1s ease-in-out infinite;
  box-shadow: 0 0 8px rgba(255,255,255,0.5);
}
@keyframes pulse {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.4); opacity: 0.6; }
}

/* 版本号 */
.version {
  position: absolute;
  bottom: 20px;
  font-size: 12px;
  color: rgba(255,255,255,0.3);
  letter-spacing: 2px;
}

/* 动画 */
@keyframes fadeDown {
  from { opacity: 0; transform: translateY(-20px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
