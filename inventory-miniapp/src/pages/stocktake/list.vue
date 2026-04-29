<script setup>
import { ref } from 'vue'
import { onShow, onPullDownRefresh } from '@dcloudio/uni-app'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'

const list = ref([])
const loading = ref(false)
const keyword = ref('')
const takeType = ref(null)
const filterStatus = ref(null)
const statusMap = { 0: '盘点中', 1: '已审核', 2: '已调整' }
const typeOptions = [{ v: null, l: '全部方式' }, { v: 0, l: '全盘' }, { v: 1, l: '抽盘' }]
const statusOptions = [{ v: null, l: '全部状态' }, { v: 0, l: '盘点中' }, { v: 1, l: '已审核' }, { v: 2, l: '已调整' }]

async function fetchList() {
  loading.value = true
  try {
    const params = { page: 1, size: 20 }
    if (keyword.value) params.orderNo = keyword.value
    if (takeType.value != null) params.takeType = takeType.value
    if (filterStatus.value != null) params.status = filterStatus.value
    const res = await request.get('/stock-take/page', { params })
    list.value = res.data.records
  } finally { loading.value = false }
}

function goDetail(id) {
  uni.navigateTo({ url: `/pages/stocktake/detail?id=${id}` })
}

function onSearch() { fetchList() }
function onInput(e) { if (!e.detail.value) fetchList() }

onShow(fetchList)
onPullDownRefresh(() => { fetchList(); uni.stopPullDownRefresh() })
</script>

<template>
  <view class="page">
    <view class="page-header">
      <text class="page-title">库存盘点</text>
      <button class="add-btn" @click="uni.navigateTo({ url: '/pages/stocktake/create' })">+ 新建</button>
    </view>

    <view class="search-bar">
      <input v-model="keyword" class="search-input" placeholder="搜索盘点单号" @confirm="onSearch" @input="onInput" />
      <picker @change="e => { takeType = typeOptions[e.detail.value]?.v; fetchList() }" :range="typeOptions" range-key="l">
        <view class="filter-btn">{{ typeOptions.find(t => t.v === takeType)?.l }}</view>
      </picker>
      <picker @change="e => { filterStatus = statusOptions[e.detail.value]?.v; fetchList() }" :range="statusOptions" range-key="l">
        <view class="filter-btn">{{ statusOptions.find(s => s.v === filterStatus)?.l }}</view>
      </picker>
    </view>

    <view v-if="loading" class="loading">加载中...</view>
    <view v-else>
      <view v-for="item in list" :key="item.id" class="card" @click="goDetail(item.id)">
        <view class="card-header">
          <text class="order-no">{{ item.orderNo }}</text>
          <text class="status" :class="'status-' + item.status">{{ statusMap[item.status] || '未知' }}</text>
        </view>
        <view class="card-body">
          <text>仓库: {{ item.warehouseName || '-' }}</text>
          <text>盘点方式: {{ item.takeType === 0 ? '全盘' : '抽盘' }}</text>
          <text>商品数: {{ item.totalItems }} | 差异: {{ item.diffItems }}</text>
        </view>
        <view class="card-footer">
          <text>日期: {{ item.orderDate }}  创建: {{ item.createTime?.slice(0,16) || '-' }}</text>
        </view>
      </view>
      <view v-if="list.length === 0" class="empty">暂无盘点单</view>
    </view>
    <FloatingHome />
  </view>
</template>

<style scoped>
.page { padding: 16px; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.page-title { font-size: 18px; font-weight: bold; }
.add-btn { background: #2e7d32; color: #fff; border: none; border-radius: 6px; padding: 8px 16px; font-size: 14px; }
.search-bar { display: flex; gap: 8px; margin-bottom: 12px; }
.search-input { flex: 1; border: 1px solid #dcdfe6; border-radius: 6px; padding: 10px 12px; font-size: 14px; background: #fff; }
.filter-btn { border: 1px solid #dcdfe6; border-radius: 6px; padding: 8px 12px; font-size: 14px; background: #fff; white-space: nowrap; }
.card { background: #fff; border-radius: 8px; padding: 12px 16px; margin-bottom: 12px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.order-no { font-weight: bold; font-size: 15px; }
.status { font-size: 12px; padding: 2px 8px; border-radius: 4px; }
.status-0 { background: #fff8e1; color: #f57f17; }
.status-1 { background: #e8f5e9; color: #2e7d32; }
.status-2 { background: #e3f2fd; color: #1565c0; }
.card-body { display: flex; flex-direction: column; gap: 4px; font-size: 13px; color: #666; }
.card-footer { margin-top: 8px; font-size: 12px; color: #999; }
.loading, .empty { text-align: center; color: #999; padding: 40px 0; }
</style>
