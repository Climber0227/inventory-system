<script setup>
import { ref, computed } from 'vue'
import { onShow, onPullDownRefresh } from '@dcloudio/uni-app'
import request from '@/api/request'

const list = ref([])
const loading = ref(false)
const warehouseTree = ref([])
const warehouseId = ref(null)
const keyword = ref('')
// 级联仓库选择
const whCascade = ref([])
const whOptions = ref([])
const showWhPicker = ref(false)

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

async function fetchWarehouseTree() {
  const res = await request.get('/warehouse/tree')
  warehouseTree.value = res.data || []
}

// 级联
function openWarehousePicker() { whCascade.value = []; whOptions.value = warehouseTree.value || []; showWhPicker.value = true }
function selectWhLevel(item) {
  whCascade.value.push(item)
  if (item.children?.length) { whOptions.value = item.children }
  else { warehouseId.value = item.id; showWhPicker.value = false; fetchData() }
}
function goBackTo(index) {
  whCascade.value = whCascade.value.slice(0, index + 1)
  const parent = whCascade.value.length ? whCascade.value[whCascade.value.length - 1] : null
  whOptions.value = parent ? (parent.children || []) : (warehouseTree.value || [])
}
const whLabel = computed(() => {
  if (!warehouseId.value) return '全部仓库'
  function find(nodes, id) { for (const n of nodes) { if (n.id === id) return n.name; if (n.children) { const r = find(n.children, id); if (r) return r } } return null }
  return find(warehouseTree.value, warehouseId.value) || '全部仓库'
})

// 构建仓库路径映射
const pathMap = computed(() => {
  const m = {}
  function walk(nodes, prefix) { for (const n of nodes) { const p = prefix ? prefix + ' > ' + n.name : n.name; m[n.id] = p; if (n.children) walk(n.children, p) } }
  walk(warehouseTree.value, '')
  return m
})

function onSearch() { fetchData() }

onShow(() => {
  if (!warehouseTree.value.length) fetchWarehouseTree()
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
      <view class="filter-pill picker-select" @click="openWarehousePicker">{{ whLabel }}</view>
      <!-- 级联仓库选择 -->
      <view v-if="showWhPicker" class="picker-overlay" @click="showWhPicker = false">
        <view class="picker-modal" @click.stop>
          <view class="picker-header">
            <text class="picker-cancel" @click="showWhPicker = false">取消</text>
            <text style="font-weight:bold;">选择仓库</text>
            <view style="width:40px;"></view>
          </view>
          <view v-if="whCascade.length" class="wh-breadcrumb">
            <text v-for="(c, i) in whCascade" :key="i" class="wh-crumb" @click="goBackTo(i)">{{ c.name }}<text v-if="i < whCascade.length - 1"> ›</text></text>
          </view>
          <scroll-view scroll-y class="picker-list">
            <view v-for="item in whOptions" :key="item.id" class="picker-item" @click="selectWhLevel(item)">
              <text :style="{ fontWeight: item.children?.length ? 'bold' : 'normal' }">{{ item.name }}</text>
              <text style="font-size:11px;color:#999;margin-left:4px;">{{ item.level }}级</text>
              <text v-if="item.children?.length" style="margin-left:auto;color:#ccc;">›</text>
            </view>
            <view v-if="!whOptions.length" style="text-align:center;padding:30px 0;color:#999;">无下级仓库</view>
          </scroll-view>
        </view>
      </view>
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
            <text style="font-size:11px;color:#999;margin-top:3px;display:block;">
              {{ item.productCode }} · {{ pathMap[item.warehouseId] || item.warehouseName }}
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
.picker-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); z-index: 999; display: flex; align-items: flex-end; }
.picker-modal { background: #fff; border-radius: 16px 16px 0 0; width: 100%; max-height: 70vh; display: flex; flex-direction: column; }
.picker-header { display: flex; align-items: center; justify-content: space-between; padding: 16px; border-bottom: 1px solid #eee; }
.picker-cancel { color: #666; font-size: 14px; }
.wh-breadcrumb { display: flex; flex-wrap: wrap; gap: 4px; padding: 10px 16px; background: #f5f7fa; font-size: 13px; }
.wh-crumb { color: #2e7d32; }
.picker-list { padding: 0 16px 20px; max-height: 55vh; overflow-y: auto; }
.picker-item { display: flex; align-items: center; gap: 8px; padding: 12px 0; border-bottom: 1px solid #f5f5f5; }
.picker-item:active { background: #f5f7f5; }
</style>
