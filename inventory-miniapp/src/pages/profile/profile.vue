<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/store/user'
import request from '@/api/request'

const userStore = useUserStore()
const userName = ref(userStore.userInfo?.realName || userStore.userInfo?.username || '用户')
const alertCount = ref(0)
const statusBarHeight = ref(0)

function goPage(url) { uni.navigateTo({ url }) }
function confirmLogout() {
  uni.showModal({ title: '提示', content: '确定要退出登录吗？', success: (r) => { if (r.confirm) userStore.logout() } })
}
function changePwd() {
  uni.showModal({ title: '修改密码', content: '请联系管理员重置密码', showCancel: false })
}

onMounted(async () => {
  statusBarHeight.value = uni.getSystemInfoSync().statusBarHeight || 20
  try {
    const res = await request.get('/dashboard/stats')
    alertCount.value = res.data?.alertCount || 0
  } catch { /* ignore */ }
})
</script>

<template>
  <view class="profile-page" :style="{ paddingTop: statusBarHeight + 'px' }">
    <!-- 顶部用户信息 -->
    <view class="profile-header">
      <view class="ph-bg"></view>
      <view class="ph-content">
        <view class="ph-avatar">{{ (userName).charAt(0) }}</view>
        <text class="ph-name">{{ userName }}</text>
        <view class="ph-role">{{ userStore.isAdmin ? '管理员' : '员工' }}</view>
      </view>
    </view>

    <!-- 菜单卡片 -->
    <view class="menu-card">
      <view class="menu-item" @click="goPage('/pages/product/list')">
        <view class="mi-icon mi-green">📃</view>
        <text class="mi-lbl">商品列表</text>
        <view class="mi-right">
          <text class="mi-arrow">›</text>
        </view>
      </view>
      <view class="menu-divider"></view>
      <view class="menu-item" @click="goPage('/pages/alert/list')">
        <view class="mi-icon mi-orange">⚠️</view>
        <text class="mi-lbl">库存预警</text>
        <view class="mi-right">
          <text v-if="alertCount > 0" class="mi-badge">{{ alertCount }}</text>
          <text class="mi-arrow">›</text>
        </view>
      </view>
      <view class="menu-divider"></view>
      <view class="menu-item" @click="changePwd">
        <view class="mi-icon mi-blue">🔑</view>
        <text class="mi-lbl">修改密码</text>
        <view class="mi-right">
          <text class="mi-arrow">›</text>
        </view>
      </view>
      <view class="menu-divider"></view>
      <view class="menu-item">
        <view class="mi-icon mi-gray">ℹ️</view>
        <text class="mi-lbl">关于系统</text>
        <view class="mi-right">
          <text style="font-size:12px;color:#aaa;">v2.0</text>
          <text class="mi-arrow">›</text>
        </view>
      </view>
    </view>

    <!-- 退出按钮 -->
    <view class="logout-btn" @click="confirmLogout">
      <text>退出登录</text>
    </view>
  </view>
</template>

<style scoped>
.profile-page {
  min-height: 100vh;
  background: #e8f0e8;
}

/* ===== 顶部用户信息 ===== */
.profile-header {
  position: relative;
  overflow: hidden;
  padding: 36px 20px 40px;
  border-radius: 0 0 30px 30px;
}
.ph-bg {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: linear-gradient(160deg, #1b5e20, #2e7d32, #388e3c);
  z-index: 0;
}
.ph-bg::after {
  content: '';
  position: absolute;
  top: -60px; right: -40px;
  width: 180px; height: 180px;
  border-radius: 50%;
  background: rgba(255,255,255,0.06);
}
.ph-content {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.ph-avatar {
  width: 68px; height: 68px;
  border-radius: 50%;
  background: rgba(255,255,255,0.18);
  color: #fff;
  display: flex; align-items: center; justify-content: center;
  font-size: 28px; font-weight: 700;
  margin-bottom: 12px;
  border: 2px solid rgba(255,255,255,0.2);
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}
.ph-name { font-size: 20px; font-weight: 700; color: #fff; margin-bottom: 6px; }
.ph-role {
  display: inline-block;
  background: rgba(255,255,255,0.15);
  color: rgba(255,255,255,0.85);
  font-size: 12px; padding: 3px 16px; border-radius: 12px;
}

/* ===== 菜单卡片 ===== */
.menu-card {
  background: #fff;
  border-radius: 16px;
  margin: -20px 16px 16px;
  padding: 6px 0;
  box-shadow: 0 4px 20px rgba(0,0,0,0.06);
  position: relative;
  z-index: 2;
}
.menu-item {
  display: flex;
  align-items: center;
  padding: 16px 16px;
  font-size: 14px;
  transition: background 0.15s;
}
.menu-item:active { background: #f5faf5; }
.mi-icon {
  width: 36px; height: 36px;
  border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
  font-size: 18px; margin-right: 14px;
}
.mi-green { background: #e8f5e9; }
.mi-orange { background: #fff3e0; }
.mi-blue { background: #e3f2fd; }
.mi-gray { background: #f5f5f5; }
.mi-lbl { flex: 1; color: #333; font-weight: 500; }
.mi-right { display: flex; align-items: center; gap: 8px; }
.mi-badge {
  background: #c62828; color: #fff;
  min-width: 22px; height: 22px; border-radius: 11px;
  display: flex; align-items: center; justify-content: center;
  font-size: 11px; font-weight: 700; padding: 0 6px;
}
.mi-arrow { color: #ccc; font-size: 20px; }
.menu-divider { height: 1px; background: #f5f5f5; margin: 0 16px; }

/* ===== 退出按钮 ===== */
.logout-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 8px 16px;
  padding: 16px;
  background: #fff;
  color: #c62828;
  border-radius: 14px;
  font-size: 15px;
  font-weight: 500;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  transition: all 0.15s;
}
.logout-btn:active { transform: scale(0.96); }
</style>
