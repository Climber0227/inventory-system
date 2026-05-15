<script setup>
import { ref, computed } from 'vue'
import { onShow, onPullDownRefresh } from '@dcloudio/uni-app'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'

const list = ref([])
const loading = ref(false)
const keyword = ref('')
const filterStatus = ref(null)
const startDate = ref('')
const endDate = ref('')
const showFilters = ref(false)
const statusMap = { 0: '草稿', 1: '已完成', 2: '已取消', 4: '待审批' }
const statusOptions = [{ v: null, l: '全部状态' }, { v: 0, l: '草稿' }, { v: 4, l: '待审批' }, { v: 1, l: '已完成' }, { v: 2, l: '已取消' }]

async function fetchList() {
  loading.value = true
  try {
    const params = { page: 1, size: 20 }
    if (keyword.value) params.orderNo = keyword.value
    if (filterStatus.value !== null) params.status = filterStatus.value
    if (startDate.value) params.startDate = startDate.value
    if (endDate.value) params.endDate = endDate.value
    const res = await request.get('/transfer/page', { params })
    list.value = res.data.records || []
  } finally { loading.value = false }
}

function goCreate() { uni.navigateTo({ url: '/pages/transfer/create' }) }
function goDetail(id) { uni.navigateTo({ url: `/pages/transfer/detail?id=${id}` }) }
function onSearch() { fetchList() }
function setFilterStatus(v) { filterStatus.value = v; fetchList() }
function handleReset() {
  keyword.value = ''; filterStatus.value = null; startDate.value = ''; endDate.value = ''; fetchList()
}

function filterActive() { return filterStatus.value !== null || startDate.value || endDate.value }

onShow(fetchList)
onPullDownRefresh(() => { fetchList(); uni.stopPullDownRefresh() })
</script>

<template>
  <view class="page">
    <view class="page-bar">
      <text class="page-title">库存调拨</text>
      <view style="display:flex;gap:6px;align-items:center;">
        <text class="add-btn" @click="goCreate">+ 新建</text>
      </view>
    </view>
    <view class="search-bar" style="display:flex;gap:6px;">
      <input v-model="keyword" class="search-input" placeholder="搜索调拨单号" style="flex:1;" @confirm="onSearch" />
      <view class="search-btn" @click="onSearch">搜索</view>
      <view class="reset-btn" @click="handleReset()">重置</view>
      <view class="filter-btn" :class="{ active: filterActive() }" @click="showFilters = !showFilters">筛选</view>
    </view>

    <view v-if="showFilters" class="filter-bar">
      <view class="filter-row">
        <text class="filter-label">状态</text>
        <scroll-view scroll-x class="filter-scroll">
          <view v-for="opt in statusOptions" :key="opt.v ?? 'all'" class="filter-pill"
            :class="{ on: filterStatus === opt.v }" @click="setFilterStatus(opt.v)">{{ opt.l }}</view>
        </scroll-view>
      </view>
      <view class="filter-row">
        <text class="filter-label">日期</text>
        <picker mode="date" :value="startDate" @change="e => { startDate = e.detail.value; fetchList() }">
          <text class="date-text">{{ startDate || '开始日期' }}</text>
        </picker>
        <text style="color:#999;margin:0 4px;">~</text>
        <picker mode="date" :value="endDate" @change="e => { endDate = e.detail.value; fetchList() }">
          <text class="date-text">{{ endDate || '结束日期' }}</text>
        </picker>
      </view>
    </view>

    <view v-if="loading">
      <view class="skeleton" v-for="n in 3" :key="n">
        <view class="skeleton-line w60"></view>
        <view class="skeleton-line w80"></view>
        <view class="skeleton-line w40" style="margin-bottom:0;"></view>
      </view>
    </view>
    <view v-else>
      <view v-for="item in list" :key="item.id" class="card" @click="goDetail(item.id)"
        :style="{ borderLeftColor: item.status === 1 ? '#2e7d32' : item.status === 2 ? '#c62828' : item.status === 4 ? '#ff9800' : '#e0e0e0' }">
        <view class="card-header">
          <view style="display:flex;align-items:center;gap:8px;">
            <text style="font-size:16px;">🔄</text>
            <text class="order-no">{{ item.orderNo }}</text>
          </view>
          <text class="status" :class="'status-' + item.status">{{ statusMap[item.status] || '未知' }}</text>
        </view>
        <view class="card-body">
          <view style="display:flex;justify-content:space-between;">
            <text>🏭 {{ item.fromWarehouseName || '-' }}</text>
            <text>→</text>
            <text>🏭 {{ item.toWarehouseName || '-' }}</text>
          </view>
          <view style="color:#888;">
            <text>数量: {{ item.totalQuantity }}</text>
          </view>
        </view>
        <view class="card-footer">
          <text>{{ item.orderDate }}</text>
          <text>{{ item.operatorName }}</text>
        </view>
      </view>
      <view v-if="list.length === 0" class="empty">暂无调拨单</view>
    </view>
    <FloatingHome />
  </view>
</template>

<style scoped>
.search-btn { background: #2e7d32; color: #fff; border-radius: 10px; padding: 0 16px; font-size: 13px; display: flex; align-items: center; white-space: nowrap; }
.reset-btn { background: #f5f5f5; color: #666; border-radius: 10px; padding: 0 16px; font-size: 13px; display: flex; align-items: center; white-space: nowrap; }
.filter-btn { background: #f5f5f5; color: #666; border-radius: 10px; padding: 0 16px; font-size: 13px; display: flex; align-items: center; white-space: nowrap; }
.filter-btn.active { background: #e8f5e9; color: #2e7d32; font-weight: 600; }
.filter-bar { background: #fff; border-radius: 10px; padding: 12px; margin-bottom: 10px; box-shadow: 0 1px 4px rgba(0,0,0,0.04); }
.filter-row { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
.filter-row:last-child { margin-bottom: 0; }
.filter-label { font-size: 12px; color: #888; white-space: nowrap; min-width: 36px; }
.filter-scroll { display: flex; gap: 6px; overflow-x: auto; white-space: nowrap; }
.filter-pill { background: #f5f5f5; border-radius: 8px; padding: 6px 12px; font-size: 12px; color: #666; white-space: nowrap; }
.filter-pill.on { background: #e8f5e9; color: #2e7d32; font-weight: 600; }
.date-text { border: 1px solid #dcdfe6; border-radius: 6px; padding: 6px 10px; font-size: 12px; background: #fff; min-width: 90px; display: inline-block; color: #666; }
</style>
