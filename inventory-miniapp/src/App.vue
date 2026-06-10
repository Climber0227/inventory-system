<script setup>
import { onLaunch } from '@dcloudio/uni-app'
import { useUserStore } from './store/user'
import request from './api/request'

onLaunch(async () => {
  const userStore = useUserStore()
  const token = uni.getStorageSync('token')
  if (token) {
    userStore.token = token
    try {
      const res = await request.get('/auth/userinfo')
      userStore.userInfo = res.data
    } catch {
      // token 过期或无效，清除
      userStore.token = ''
      uni.removeStorageSync('token')
    }
  }
})
</script>

<template>
  <view />
</template>

<style>
/* ===== 全局样式 v3.0 ===== */
page {
  background-color: #e8f0e8;
  font-size: 14px;
  color: #1a1a1a;
  font-family: -apple-system, BlinkMacSystemFont, 'PingFang SC', 'Helvetica Neue', sans-serif;
}
.page { padding: 16px; min-height: 100vh; }

/* 页面标题 */
.page-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; }
.page-title {
  font-size: 20px; font-weight: 700; color: #1a1a1a;
  position: relative; padding-left: 12px;
}
.page-title::before {
  content: '';
  position: absolute; left: 0; top: 50%; transform: translateY(-50%);
  width: 3px; height: 18px; background: #2e7d32; border-radius: 2px;
}

/* 新建按钮 */
.add-btn {
  background: linear-gradient(135deg, #2e7d32, #43a047);
  color: #fff; border-radius: 16px; padding: 6px 16px;
  font-size: 12px; line-height: 22px; height: auto;
  box-shadow: 0 3px 10px rgba(46,125,50,0.25);
  transition: all 0.2s;
}
.add-btn:active { transform: scale(0.9); box-shadow: 0 1px 4px rgba(46,125,50,0.15); }

/* 搜索栏 */
.search-bar { margin-bottom: 14px; }
.search-input {
  background: #fff; border-radius: 10px; padding: 12px 16px;
  font-size: 14px; color: #333; border: none;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
  transition: box-shadow 0.25s;
}
.search-input:focus { box-shadow: 0 3px 16px rgba(46,125,50,0.12); }
.search-input::placeholder { color: #bbb; }

/* 卡片（交错入场动画） */
.card {
  background: #fff; border-radius: 14px; padding: 14px 16px;
  margin-bottom: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
  border-left: 3px solid #c8e6c9;
  opacity: 0; transform: translateY(16px) scale(0.97);
  animation: cardIn 0.4s cubic-bezier(0.22, 1, 0.36, 1) forwards;
}
.card:active { transform: scale(0.96) !important; }
.card:nth-child(1) { animation-delay: 0.03s; }
.card:nth-child(2) { animation-delay: 0.07s; }
.card:nth-child(3) { animation-delay: 0.11s; }
.card:nth-child(4) { animation-delay: 0.15s; }
.card:nth-child(5) { animation-delay: 0.19s; }
.card:nth-child(6) { animation-delay: 0.23s; }
@keyframes cardIn {
  to { opacity: 1; transform: translateY(0) scale(1); }
}

.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
.order-no { font-weight: 600; font-size: 15px; color: #1a1a1a; }

/* 状态标签 */
.status { font-size: 11px; padding: 3px 10px; border-radius: 10px; font-weight: 500; }
.status-0 { background: #f5f5f5; color: #888; }
.status-1 { background: #e8f5e9; color: #2e7d32; }
.status-2 { background: #fce4ec; color: #c62828; }

/* 卡片内容 */
.card-body { display: flex; flex-direction: column; gap: 5px; font-size: 13px; color: #666; }
.card-body text { line-height: 1.6; }
.card-footer {
  display: flex; justify-content: space-between;
  margin-top: 10px; padding-top: 10px;
  border-top: 1px solid #eef4ee;
  font-size: 12px; color: #aaa;
}

/* 汇总栏 */
.summary-bar {
  display: flex; justify-content: space-between;
  padding: 12px 16px;
  background: linear-gradient(135deg, #e8f5e9, #f1f8e9);
  border-radius: 10px; font-size: 13px; font-weight: 600; color: #2e7d32;
  margin-top: 8px;
}

/* 骨架屏 */
.skeleton {
  background: #fff; border-radius: 14px; padding: 16px; margin-bottom: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
}
.skeleton-line {
  height: 14px;
  background: linear-gradient(90deg, #f0f4f0 25%, #dce8dc 50%, #f0f4f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 6px; margin-bottom: 10px;
}
.skeleton-line:last-child { margin-bottom: 0; }
.skeleton-line.w60 { width: 60%; }
.skeleton-line.w40 { width: 40%; }
.skeleton-line.w80 { width: 80%; }
@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* 空状态 */
.loading, .empty { text-align: center; color: #aaa; padding: 50px 0; font-size: 14px; }

/* 导航链接 */
.nav-link { font-size: 13px; color: #2e7d32; font-weight: 500; }
.nav-link:active { opacity: 0.5; }

/* 详情卡片 */
.detail-card {
  background: #fff; border-radius: 14px; padding: 16px; margin-bottom: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
  border-top: 3px solid #2e7d32;
  animation: fadeUp 0.35s ease forwards;
}
.detail-label { font-size: 12px; color: #999; margin-bottom: 4px; display: block; }
.detail-value { font-size: 15px; color: #1a1a1a; font-weight: 500; display: block; }
.detail-divider { height: 1px; background: #f0f4f0; margin: 12px 0; }
.section-title {
  font-size: 15px; font-weight: 600; color: #1a1a1a;
  margin-bottom: 12px; padding-left: 10px; position: relative;
}
.section-title::before {
  content: '';
  position: absolute; left: 0; top: 50%; transform: translateY(-50%);
  width: 3px; height: 14px; background: #2e7d32; border-radius: 2px;
}

/* 通用动画 */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes fadeDown {
  from { opacity: 0; transform: translateY(-12px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
