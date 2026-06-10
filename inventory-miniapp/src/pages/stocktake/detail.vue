<script setup>
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import request from '@/api/request'
import { useUserStore } from '@/store/user'
import FloatingHome from '@/components/FloatingHome'

const userStore = useUserStore()
const order = ref(null)
const items = ref([])
const loading = ref(false)
const actionLoading = ref(false)
const statusMap = { 0: '盘点中', 1: '已审核', 2: '已调整' }

let id = null
onLoad(async (options) => {
  if (options?.id) {
    id = options.id
  } else if (options?.orderNo) {
    const res = await request.get('/stock-take/page', { params: { orderNo: options.orderNo, page: 1, size: 1 } })
    if (res.data.records?.length) id = res.data.records[0].id
  }
  if (id) fetchDetail()
})

async function fetchDetail() {
  if (!id) return
  loading.value = true
  try {
    const res = await request.get(`/stock-take/${id}`)
    order.value = res.data
    const rawItems = res.data.items || []
    // 加载仓库库存以补充入库时间
    if (order.value?.warehouseId && rawItems.length > 0) {
      try {
        const invRes = await request.get('/inventory/page', { params: { warehouseId: order.value.warehouseId, page: 1, size: 9999 } })
        const invList = invRes.data.records || []
        items.value = rawItems.map(i => {
          const inv = invList.find(r => r.productId === i.productId && r.batchNo === i.batchNo)
          return { ...i, stockDate: inv?.createTime?.substring(0, 16) || '' }
        })
      } catch { items.value = rawItems.map(i => ({ ...i })) }
    } else {
      items.value = rawItems.map(i => ({ ...i }))
    }
  } finally { loading.value = false }
}

async function approveTake() {
  if (!order.value?.id) return
  actionLoading.value = true
  try {
    await request.put(`/stock-take/${order.value.id}/approve`)
    uni.showToast({ title: '审核通过', icon: 'success' })
    fetchDetail()
  } finally { actionLoading.value = false }
}

async function adjustTake() {
  if (!order.value?.id) return
  actionLoading.value = true
  try {
    await request.put(`/stock-take/${order.value.id}/adjust`)
    uni.showToast({ title: '调整完成', icon: 'success' })
    fetchDetail()
  } finally { actionLoading.value = false }
}

async function saveItem(item) {
  try {
    await request.put(`/stock-take/item/${item.id}`, { actualQty: item.actualQty })
    item.diffQty = (item.actualQty || 0) - (item.bookQty || 0)
  } catch { /* ignore */ }
}
</script>

<template>
  <view class="page">
    <view v-if="loading" style="text-align:center;padding:40px;color:#999;">加载中...</view>
    <view v-else-if="order">
      <view class="detail-header">
        <text class="dh-no">{{ order.orderNo }}</text>
        <text class="dh-st" :class="'dh-' + order.status">{{ statusMap[order.status] || '未知' }}</text>
      </view>
      <view class="info-grid">
        <view class="ig-row"><text class="ig-l">仓库</text><text class="ig-v">{{ order.warehouseName || '-' }}</text></view>
        <view class="ig-row"><text class="ig-l">盘点方式</text><text class="ig-v">{{ order.takeType === 0 ? '全盘' : '抽盘' }}</text></view>
        <view class="ig-row"><text class="ig-l">盘点日期</text><text class="ig-v">{{ order.orderDate || '-' }}</text></view>
        <view class="ig-row"><text class="ig-l">商品数</text><text class="ig-v">{{ order.totalItems }}</text></view>
        <view class="ig-row"><text class="ig-l">差异数</text><text class="ig-v" style="color:#e65100;">{{ order.diffItems }}</text></view>
      </view>
    </view>
    <view v-else style="text-align:center;padding:40px;color:#999;">未找到盘点单</view>

    <!-- 商品明细 -->
    <view v-if="order?.items && order.items.length > 0" class="items-section">
      <view class="items-header">
        <text class="items-title">商品明细 ({{ order.items.length }})</text>
      </view>
      <view v-for="item in items" :key="item.id" class="item-card">
        <view class="item-info">
          <text class="item-name">{{ item.productName || '-' }}</text>
          <text class="item-code">{{ item.productCode || '' }}</text>
        </view>
        <view v-if="item.batchNo || item.stockDate" class="item-batch">
          <text v-if="item.batchNo" class="batch-text">{{ item.batchNo }}</text>
          <text v-if="item.stockDate" class="batch-date">{{ item.stockDate }}</text>
        </view>
        <view class="qty-row">
          <view class="qty-field">
            <text class="label-sm">账面</text>
            <text class="qty-val">{{ item.bookQty }}</text>
          </view>
          <view class="qty-field">
            <text class="label-sm">实盘</text>
            <input v-if="order.status === 0" v-model="item.actualQty" class="input-sm" type="number" @blur="saveItem(item)" />
            <text v-else class="qty-val">{{ item.actualQty }}</text>
          </view>
          <view class="qty-field">
            <text class="label-sm">差异</text>
            <text class="qty-diff" :class="{ 'has-diff': item.diffQty !== 0 }">{{ item.diffQty > 0 ? '+' : '' }}{{ item.diffQty }}</text>
          </view>
        </view>
      </view>
    </view>
    <view class="action-bar">
      <button v-if="userStore.isAdmin && order?.status === 0" class="btn-approve" :loading="actionLoading" @click="approveTake">审核通过</button>
      <button v-if="userStore.isAdmin && order?.status === 1" class="btn-adjust" :loading="actionLoading" @click="adjustTake">执行调整</button>
    </view>
    <FloatingHome />
  </view>
</template>

<style scoped>
.page { padding: 12px; background: #f5f7f5; min-height: 100vh; }
.detail-header { background: #fff; border-radius: 8px; padding: 20px 16px; text-align: center; margin-bottom: 10px; }
.dh-no { font-size: 18px; font-weight: 700; display: block; }
.dh-st { display: inline-block; margin-top: 6px; font-size: 12px; padding: 3px 14px; border-radius: 12px; }
.dh-1 { background: #e8f5e9; color: #2e7d32; }
.dh-0 { background: #fff8e1; color: #f57f17; }
.dh-2 { background: #e3f2fd; color: #1565c0; }
.info-grid { background: #fff; border-radius: 8px; padding: 16px; margin-bottom: 10px; }
.ig-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #f0f0f0; font-size: 14px; }
.ig-row:last-child { border-bottom: none; }
.ig-l { color: #999; } .ig-v { font-weight: 500; color: #333; }
.action-bar { margin-top: 16px; padding-bottom: 32px; }
.btn-approve { width: 100%; background: #2e7d32; color: #fff; border: none; border-radius: 8px; height: 44px; line-height: 44px; font-size: 16px; }
.btn-adjust { width: 100%; background: #1565c0; color: #fff; border: none; border-radius: 8px; height: 44px; line-height: 44px; font-size: 16px; }
.items-section { margin-top: 10px; }
.items-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.items-title { font-size: 15px; font-weight: 600; }
.item-card { background: #fff; border-radius: 8px; padding: 12px; margin-bottom: 8px; }
.item-info { display: flex; align-items: baseline; gap: 6px; margin-bottom: 8px; }
.item-name { font-size: 14px; font-weight: 500; }
.item-code { font-size: 11px; color: #999; }
.item-batch { display: flex; gap: 8px; margin-bottom: 6px; }
.batch-text { font-size: 11px; color: #2e7d32; background: #e8f5e9; padding: 1px 6px; border-radius: 4px; }
.batch-date { font-size: 11px; color: #999; }
.qty-row { display: flex; gap: 12px; }
.qty-field { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px; }
.label-sm { font-size: 12px; color: #666; }
.qty-val { font-size: 16px; font-weight: bold; color: #333; }
.qty-diff { font-size: 16px; font-weight: bold; color: #666; }
.has-diff { color: #f56c6c; }
.input-sm { border: 1px solid #2e7d32; border-radius: 4px; padding: 6px 8px; width: 60px; text-align: center; }
</style>
