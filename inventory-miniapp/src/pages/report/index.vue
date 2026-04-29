<script setup>
import { ref } from 'vue'
import { onShow, onPullDownRefresh } from '@dcloudio/uni-app'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'

const days = ref(7)
const purchaseSummary = ref({ totalAmount: 0, totalQuantity: 0, count: 0 })
const salesSummary = ref({ totalAmount: 0, totalQuantity: 0, count: 0 })
const turnoverRate = ref([])
const dashboardStats = ref({ productCount: 0, warehouseCount: 0, alertCount: 0 })

async function fetchData() {
  try {
    const [purchaseRes, salesRes, turnoverRes, statsRes] = await Promise.all([
      request.get('/report/purchase-summary', { params: { days: days.value } }),
      request.get('/report/sales-summary', { params: { days: days.value } }),
      request.get('/report/turnover-rate', { params: { days: 30 } }),
      request.get('/dashboard/stats'),
    ])
    purchaseSummary.value = purchaseRes.data
    salesSummary.value = salesRes.data
    turnoverRate.value = turnoverRes.data || []
    dashboardStats.value = statsRes.data
  } catch { /* ignore */ }
}

function setDays(val) {
  days.value = val
  fetchData()
}

onShow(() => {
  fetchData()
})

onPullDownRefresh(() => {
  fetchData()
  uni.stopPullDownRefresh()
})
</script>

<template>
  <view class="page">
    <!-- 日期切换 -->
    <view class="date-bar">
      <view
        class="date-tab"
        :class="{ active: days === 7 }"
        @click="setDays(7)"
      >近7天</view>
      <view
        class="date-tab"
        :class="{ active: days === 30 }"
        @click="setDays(30)"
      >近30天</view>
    </view>

    <!-- 采购汇总 -->
    <view class="card">
      <text class="card-title">采购汇总</text>
      <view class="card-row">
        <view class="card-item">
          <text class="card-num green">{{ purchaseSummary.count || 0 }}</text>
          <text class="card-lbl">入库单数</text>
        </view>
        <view class="card-item">
          <text class="card-num green">{{ purchaseSummary.totalQuantity || 0 }}</text>
          <text class="card-lbl">入库数量</text>
        </view>
        <view class="card-item">
          <text class="card-num orange">{{ purchaseSummary.totalAmount || 0 }}</text>
          <text class="card-lbl">入库金额</text>
        </view>
      </view>
    </view>

    <!-- 销售汇总 -->
    <view class="card">
      <text class="card-title">销售汇总</text>
      <view class="card-row">
        <view class="card-item">
          <text class="card-num green">{{ salesSummary.count || 0 }}</text>
          <text class="card-lbl">出库单数</text>
        </view>
        <view class="card-item">
          <text class="card-num green">{{ salesSummary.totalQuantity || 0 }}</text>
          <text class="card-lbl">出库数量</text>
        </view>
        <view class="card-item">
          <text class="card-num orange">{{ salesSummary.totalAmount || 0 }}</text>
          <text class="card-lbl">出库金额</text>
        </view>
      </view>
    </view>

    <!-- 库存概况 -->
    <view class="card">
      <text class="card-title">库存概况</text>
      <view class="card-row">
        <view class="card-item">
          <text class="card-num green">{{ dashboardStats.productCount || 0 }}</text>
          <text class="card-lbl">商品总数</text>
        </view>
        <view class="card-item">
          <text class="card-num green">{{ dashboardStats.warehouseCount || 0 }}</text>
          <text class="card-lbl">仓库数</text>
        </view>
        <view class="card-item">
          <text class="card-num orange">{{ dashboardStats.alertCount || 0 }}</text>
          <text class="card-lbl">预警数</text>
        </view>
      </view>
    </view>

    <!-- 周转率 (可选展示) -->
    <view class="card" v-if="turnoverRate.length">
      <text class="card-title">库存周转率（近30天）</text>
      <view class="turnover-list">
        <view class="turnover-item" v-for="item in turnoverRate" :key="item.productId || item.name">
          <text class="to-name">{{ item.name || item.productName }}</text>
          <text class="to-rate">{{ item.rate != null ? item.rate.toFixed(2) : '-' }}</text>
        </view>
      </view>
    </view>

    <FloatingHome />
  </view>
</template>

<style scoped>
.page { padding: 12px; background: #f5f7f5; min-height: 100vh; }

/* 日期切换栏 */
.date-bar {
  display: flex; gap: 8px; margin-bottom: 14px;
}
.date-tab {
  flex: 1; text-align: center; padding: 10px 0;
  background: #fff; border-radius: 8px; font-size: 14px; font-weight: 500;
  color: #666; box-shadow: 0 1px 4px rgba(0,0,0,0.05);
}
.date-tab.active {
  background: #2e7d32; color: #fff;
}

/* 白色卡片 */
.card {
  background: #fff; border-radius: 10px; padding: 16px 14px;
  margin-bottom: 12px; box-shadow: 0 1px 4px rgba(0,0,0,0.05);
}
.card-title {
  font-size: 15px; font-weight: 600; color: #333; display: block; margin-bottom: 12px;
}
.card-row {
  display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px;
}
.card-item {
  text-align: center;
}
.card-num {
  font-size: 22px; font-weight: 700; display: block; line-height: 1.3;
}
.card-num.green { color: #2e7d32; }
.card-num.orange { color: #e65100; }
.card-lbl {
  font-size: 12px; color: #888; display: block; margin-top: 2px;
}

/* 周转率列表 */
.turnover-list {
  display: flex; flex-direction: column; gap: 8px;
}
.turnover-item {
  display: flex; justify-content: space-between; padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}
.turnover-item:last-child { border-bottom: none; }
.to-name { font-size: 13px; color: #333; }
.to-rate { font-size: 13px; color: #2e7d32; font-weight: 600; }
</style>
