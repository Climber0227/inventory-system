<script setup>
import { ref, onMounted } from 'vue'
import request from '@/api/request'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
const stats = ref({ productCount: 0, warehouseCount: 0, todayPurchaseCount: 0, todaySalesCount: 0, todayPurchaseQty: 0, todaySalesQty: 0, alertCount: 0 })

onMounted(async () => {
  try {
    const res = await request.get('/dashboard/stats')
    stats.value = res.data
  } catch { /* ignore */ }
})

function goPage(url) {
  const tabs = ['/pages/purchase/list','/pages/sales/list','/pages/home/home','/pages/inventory/query','/pages/profile/profile']
  if (tabs.includes(url)) uni.switchTab({ url })
  else uni.navigateTo({ url })
}
</script>

<template>
  <view class="page">
    <view class="header-bar">
      <text class="header-title">工作台</text>
      <text class="header-role">{{ userStore.isAdmin ? '管理员' : '员工' }}</text>
    </view>

    <!-- 统计卡片（纯展示，不可点击） -->
    <view class="stats-section">
      <text class="section-label">数据概览</text>
      <view class="stats-grid">
        <view class="stat-card">
          <text class="stat-num">{{ stats.productCount }}</text>
          <text class="stat-lbl">商品总数</text>
        </view>
        <view class="stat-card">
          <text class="stat-num">{{ stats.warehouseCount }}</text>
          <text class="stat-lbl">仓库数量</text>
        </view>
        <view class="stat-card">
          <text class="stat-num">{{ stats.todayPurchaseQty }}</text>
          <text class="stat-lbl">今日入库</text>
        </view>
        <view class="stat-card">
          <text class="stat-num" style="color:#e65100;">{{ stats.alertCount }}</text>
          <text class="stat-lbl">库存预警</text>
        </view>
      </view>
    </view>

    <!-- 快捷操作 -->
    <view class="action-section">
      <text class="section-label">快捷操作</text>
      <view class="quick-grid">
        <view class="quick-item" @click="goPage('/pages/purchase/create')">
          <view class="qi-icon qi-green">+</view>
          <text class="qi-lbl">新建入库</text>
        </view>
        <view class="quick-item" @click="goPage('/pages/sales/create')">
          <view class="qi-icon qi-orange">+</view>
          <text class="qi-lbl">新建出库</text>
        </view>
        <view class="quick-item" @click="goPage('/pages/stocktake/create')">
          <view class="qi-icon qi-blue">+</view>
          <text class="qi-lbl">新建盘点</text>
        </view>
        <view class="quick-item" @click="goPage('/pages/transfer/create')">
          <view class="qi-icon qi-purple">+</view>
          <text class="qi-lbl">新建调拨</text>
        </view>
      </view>
    </view>

    <!-- 库存预警 -->
    <view class="alert-card" @click="goPage('/pages/alert/list')">
      <view style="display:flex;justify-content:space-between;width:100%;">
        <text style="font-weight:600;font-size:14px;">⚠ 库存预警</text>
        <text style="color:#c62828;font-weight:600;">{{ stats.alertCount }}项</text>
      </view>
      <text style="font-size:12px;color:#999;margin-top:4px;" v-if="stats.alertCount">点击查看预警商品</text>
      <text style="font-size:12px;color:#999;margin-top:4px;" v-else>暂无预警</text>
    </view>

    <!-- 基础资料 -->
    <view class="action-section">
      <text class="section-label">基础资料</text>
      <view class="doc-grid">
        <view class="doc-item" @click="goPage('/pages/warehouse/list')">
          <text class="doc-icon">🏭</text><text class="doc-lbl">仓库管理</text>
        </view>
        <view class="doc-item" @click="goPage('/pages/supplier/list')">
          <text class="doc-icon">📦</text><text class="doc-lbl">供应商</text>
        </view>
        <view class="doc-item" @click="goPage('/pages/customer/list')">
          <text class="doc-icon">👥</text><text class="doc-lbl">客户管理</text>
        </view>
        <view class="doc-item" @click="goPage('/pages/report/index')">
          <text class="doc-icon">📊</text><text class="doc-lbl">统计报表</text>
        </view>
      </view>
    </view>

    <!-- 单据列表 -->
    <view class="action-section">
      <text class="section-label">单据列表</text>
      <view class="doc-grid">
        <view class="doc-item" @click="goPage('/pages/purchase/list')">
          <text class="doc-icon">📦</text>
          <text class="doc-lbl">入库列表</text>
        </view>
        <view class="doc-item" @click="goPage('/pages/sales/list')">
          <text class="doc-icon">📤</text>
          <text class="doc-lbl">出库列表</text>
        </view>
        <view class="doc-item" @click="goPage('/pages/stocktake/list')">
          <text class="doc-icon">📋</text>
          <text class="doc-lbl">盘点单据</text>
        </view>
        <view class="doc-item" @click="goPage('/pages/transfer/list')">
          <text class="doc-icon">🔄</text>
          <text class="doc-lbl">调拨单据</text>
        </view>
        <view class="doc-item" @click="goPage('/pages/inventory/log')">
          <text class="doc-icon">📊</text>
          <text class="doc-lbl">库存流水</text>
        </view>
        <view class="doc-item" @click="goPage('/pages/product/list')">
          <text class="doc-icon">📃</text>
          <text class="doc-lbl">商品列表</text>
        </view>
      </view>
    </view>
  </view>
</template>

<style scoped>
.page { padding: 12px; background: #f5f7f5; min-height: 100vh; }
.header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.header-title { font-size: 18px; font-weight: 700; color: #333; }
.header-role { font-size: 13px; color: #999; }

.section-label { font-size: 12px; color: #999; margin-bottom: 8px; display: block; }

/* 统计区域 — 浅色扁平，无阴影，像仪表盘数字 */
.stats-section { margin-bottom: 20px; }
.stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.stat-card {
  background: #f0f4f0; border-radius: 6px; padding: 14px 12px; text-align: center;
}
.stat-num { font-size: 24px; font-weight: 700; color: #2e7d32; display: block; line-height: 1.2; }
.stat-lbl { font-size: 11px; color: #888; margin-top: 2px; display: block; }

/* 操作区域 */
.action-section { margin-bottom: 14px; }

/* 快捷操作 — 四宫格 */
.quick-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.quick-item {
  background: #fff; border-radius: 10px; padding: 16px 12px; text-align: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06); transition: transform 0.1s;
}
.quick-item:active { transform: scale(0.96); }
.qi-icon {
  width: 40px; height: 40px; border-radius: 12px;
  display: inline-flex; align-items: center; justify-content: center;
  font-size: 22px; font-weight: 700; margin-bottom: 6px;
}
.qi-green { background: #e8f5e9; color: #2e7d32; }
.qi-orange { background: #fff3e0; color: #e65100; }
.qi-blue { background: #e3f2fd; color: #1565c0; }
.qi-purple { background: #f3e5f5; color: #7b1fa2; }
.qi-lbl { font-size: 13px; color: #333; display: block; font-weight: 500; }

/* 单据列表 — 三列 */
.doc-grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; }
.doc-item {
  background: #fff; border-radius: 10px; padding: 14px 6px; text-align: center;
  box-shadow: 0 1px 4px rgba(0,0,0,0.05); transition: transform 0.1s;
}
.doc-item:active { transform: scale(0.96); }
.doc-icon { display: block; font-size: 20px; margin-bottom: 4px; }
.doc-lbl { font-size: 12px; color: #555; display: block; }

.alert-card {
  background: #fff; border-radius: 10px; padding: 14px 16px;
  display: flex; flex-direction: column; box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}
.nav-link { font-size: 12px; color: #2e7d32; }
.mini-card {
  background: #fff; border-radius: 8px; padding: 10px 14px; margin-bottom: 8px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}
</style>
