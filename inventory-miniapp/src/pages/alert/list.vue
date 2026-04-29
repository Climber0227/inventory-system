<script setup>
import { ref } from 'vue'
import { onShow, onPullDownRefresh } from '@dcloudio/uni-app'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'

const alerts = ref([])

async function loadAlerts() {
  try {
    const res = await request.get('/report/inventory-alert')
    alerts.value = res.data || []
  } catch { /* ignore */ }
}
onShow(loadAlerts)
onPullDownRefresh(() => { loadAlerts(); uni.stopPullDownRefresh() })
</script>

<template>
  <view class="page">
    <view class="alert-item" v-for="r in alerts" :key="r.productName">
      <view>
        <text class="alert-name">{{ r.productName }}</text>
        <text class="alert-loc">{{ r.warehouseName }}</text>
      </view>
      <text class="alert-qty">{{ r.quantity }} / {{ r.minStock }}</text>
    </view>
    <view v-if="!alerts.length" style="text-align:center;color:#999;padding:40px 0;">暂无预警</view>
    <FloatingHome />
  </view>
</template>

<style scoped>
.page { padding: 12px; background: #f5f7f5; min-height: 100vh; }
.alert-item { background: #fff; border-radius: 8px; padding: 12px 16px; margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center; border-left: 3px solid #e65100; }
.alert-name { font-weight: 600; font-size: 14px; color: #333; display: block; }
.alert-loc { font-size: 12px; color: #999; display: block; margin-top: 2px; }
.alert-qty { color: #c62828; font-weight: 700; font-size: 16px; }
</style>
