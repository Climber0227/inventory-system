<script setup>
import { ref } from 'vue'
import { onShow, onPullDownRefresh } from '@dcloudio/uni-app'
import request from '@/api/request'

const list = ref([])
const loading = ref(false)
const warehouses = ref([])
const warehouseId = ref(null)
const keyword = ref('')
let loaded = false

async function fetchData() {
  loading.value = true
  try {
    const params = { page: 1, size: 50 }
    if (warehouseId.value) params.warehouseId = warehouseId.value
    if (keyword.value) params.productName = keyword.value
    const res = await request.get('/inventory/page', { params })
    list.value = res.data.records
  } finally { loading.value = false }
}

async function fetchWarehouses() {
  const res = await request.get('/warehouse/list')
  warehouses.value = res.data
}

function onSearch() { fetchData() }

onShow(() => {
  if (!loaded) { loaded = true; fetchWarehouses() }
  fetchData()
})
onPullDownRefresh(() => { fetchData(); uni.stopPullDownRefresh() })
</script>

<template>
  <view class="page">
    <view class="page-bar">
      <text class="page-title">库存查询</text>
      <text class="nav-link" @click="uni.navigateTo({ url: '/pages/inventory/log' })">流水 ›</text>
    </view>
    <view class="search-bar" style="display:flex;gap:8px;">
      <input v-model="keyword" class="search-input" placeholder="搜索商品名称" style="flex:1;" @confirm="onSearch" />
      <picker @change="e => { warehouseId = warehouses[e.detail.value]?.id; fetchData() }" :range="warehouses" range-key="name">
        <view class="filter-pill">{{ warehouses.find(w => w.id === warehouseId)?.name || '全部仓库' }}</view>
      </picker>
    </view>

    <view v-if="loading">
      <view class="skeleton" v-for="n in 4" :key="n">
        <view class="skeleton-line w60"></view>
        <view class="skeleton-line w80"></view>
        <view class="skeleton-line w40" style="margin-bottom:0;"></view>
      </view>
    </view>
    <view v-else>
      <view v-for="item in list" :key="item.id" class="card" style="border-left-color:#43a047;">
        <view style="display:flex;justify-content:space-between;align-items:center;">
          <view style="flex:1;min-width:0;">
            <view style="display:flex;align-items:center;gap:6px;">
              <text style="font-size:16px;">📦</text>
              <text style="font-weight:600;font-size:15px;color:#1a1a1a;">{{ item.productName }}</text>
            </view>
            <text style="font-size:12px;color:#999;margin-top:3px;display:block;">
              {{ item.productCode }} · {{ item.warehouseName }}
            </text>
          </view>
          <view style="text-align:right;">
            <text :style="{ fontSize:'24px', fontWeight:'700', color: (item.quantity || 0) <= 5 ? '#c62828' : '#2e7d32' }">
              {{ item.quantity }}
            </text>
            <text style="font-size:11px;color:#aaa;display:block;">{{ item.batchNo || '-' }}</text>
          </view>
        </view>
        <view v-if="item.costPrice" style="margin-top:8px;padding-top:8px;border-top:1px solid #f0f4f0;font-size:12px;color:#aaa;display:flex;justify-content:space-between;">
          <text>均价 ¥{{ (item.costPrice || 0).toFixed(2) }}</text>
          <text>金额 ¥{{ ((item.costPrice || 0) * (item.quantity || 0)).toFixed(2) }}</text>
        </view>
      </view>
      <view v-if="list.length === 0" class="empty">暂无库存数据</view>
    </view>
  </view>
</template>

<style scoped>
.filter-pill { background:#fff; border-radius:10px; padding:12px 14px; font-size:13px; white-space:nowrap; box-shadow:0 1px 4px rgba(0,0,0,0.04); }
</style>
