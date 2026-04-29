<script setup>
import { ref } from 'vue'
import { onShow, onPullDownRefresh } from '@dcloudio/uni-app'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'

const list = ref([])
const loading = ref(false)
const keyword = ref('')

async function fetchList() {
  loading.value = true
  try {
    const params = { page: 1, size: 20 }
    if (keyword.value) params.name = keyword.value
    const res = await request.get('/supplier/page', { params })
    list.value = res.data.records || []
  } finally { loading.value = false }
}

function goEdit(id) { uni.navigateTo({ url: `/pages/supplier/edit?id=${id}` }) }
function goCreate() { uni.navigateTo({ url: '/pages/supplier/edit' }) }
function onSearch() { fetchList() }
function onInput(e) { if (!e.detail.value) fetchList() }

onShow(fetchList)
onPullDownRefresh(() => { fetchList(); uni.stopPullDownRefresh() })
</script>

<template>
  <view class="page">
    <view class="page-bar">
      <text class="page-title">供应商管理</text>
      <button class="add-btn" @click="goCreate">+ 新建</button>
    </view>
    <view class="search-bar">
      <input v-model="keyword" class="search-input" placeholder="搜索供应商名称" @confirm="onSearch" @input="onInput" />
    </view>

    <view v-if="loading" class="loading">加载中...</view>
    <view v-else>
      <view v-for="item in list" :key="item.id" class="card" @click="goEdit(item.id)">
        <view class="card-header">
          <text class="card-title">{{ item.name }}</text>
        </view>
        <view class="card-body">
          <text>编码: {{ item.code || '-' }}</text>
          <text>联系人: {{ item.contact || '-' }}</text>
          <text>电话: {{ item.phone || '-' }}</text>
          <text>地址: {{ item.address || '-' }}</text>
        </view>
      </view>
      <view v-if="list.length === 0 && !loading" class="empty">暂无供应商</view>
    </view>
    <FloatingHome />
  </view>
</template>

<style scoped>
.page { padding: 16px; }
.page-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.page-title { font-size: 18px; font-weight: bold; }
.add-btn { background: #2e7d32; color: #fff; border: none; border-radius: 6px; padding: 8px 16px; font-size: 14px; }
.search-bar { margin-bottom: 12px; }
.search-input { border: 1px solid #dcdfe6; border-radius: 6px; padding: 10px 12px; font-size: 14px; background: #fff; }
.card { background: #fff; border-radius: 8px; padding: 12px 16px; margin-bottom: 12px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.card-title { font-weight: bold; font-size: 15px; }
.card-body { display: flex; flex-direction: column; gap: 4px; font-size: 13px; color: #666; }
.loading, .empty { text-align: center; color: #999; padding: 40px 0; }
</style>
