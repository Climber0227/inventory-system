<script setup>
import { ref, onMounted } from 'vue'
import { onPullDownRefresh } from '@dcloudio/uni-app'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'

const list = ref([])
const loading = ref(false)
const keyword = ref('')
const codeKeyword = ref('')
const page = ref(1)
const hasMore = ref(true)
const stockSort = ref('') // ''=默认 asc=升序 desc=降序

async function fetchData(append = false) {
  if (loading.value) return
  loading.value = true
  try {
    if (!append) { page.value = 1; hasMore.value = true }
    const params = { page: page.value, size: 20 }
    if (keyword.value) params.name = keyword.value
    if (codeKeyword.value) params.code = codeKeyword.value
    const res = await request.get('/product/page', { params })
    let records = res.data.records || []
    // 前端库存排序
    if (stockSort.value === 'asc') records.sort((a, b) => (a.inventoryQuantity || 0) - (b.inventoryQuantity || 0))
    else if (stockSort.value === 'desc') records.sort((a, b) => (b.inventoryQuantity || 0) - (a.inventoryQuantity || 0))
    if (append) {
      list.value = [...list.value, ...records]
    } else {
      list.value = records
    }
    hasMore.value = records.length >= 20
  } finally { loading.value = false }
}

function onSearch() { fetchData() }

function toggleStockSort() {
  stockSort.value = stockSort.value === 'desc' ? 'asc' : 'desc'
  fetchData()
}

function onScrollToLower() {
  if (!hasMore.value || loading.value) return
  page.value++
  fetchData(true)
}

onMounted(() => fetchData())
onPullDownRefresh(() => { fetchData(); uni.stopPullDownRefresh() })
</script>

<template>
  <view class="page">
    <view class="search-bar">
      <input v-model="keyword" class="search-input" placeholder="搜索商品名称" @confirm="onSearch" />
      <view class="search-btn" @click="onSearch">搜索</view>
    </view>
    <view class="search-bar" style="margin-top:0;">
      <input v-model="codeKeyword" class="search-input" placeholder="搜索商品编码" @confirm="onSearch" style="flex:2;" />
      <view class="sort-btn" :class="{ active: stockSort }" @click="toggleStockSort">
        库存{{ stockSort === 'asc' ? '↑' : stockSort === 'desc' ? '↓' : '' }}
      </view>
    </view>

    <scroll-view scroll-y class="scroll-list" @scrolltolower="onScrollToLower">
      <view v-if="loading && list.length === 0" class="loading">加载中...</view>
      <view v-else>
        <view v-for="item in list" :key="item.id" class="card" @click="uni.navigateTo({ url: '/pages/product/detail?id=' + item.id })">
          <view class="card-header">
            <text class="product-name">{{ item.name }}</text>
            <text class="product-status" :class="item.status === 1 ? 'on' : 'off'">{{ item.status === 1 ? '启用' : '停用' }}</text>
          </view>
          <view class="card-body">
            <text>编码: {{ item.code }}</text>
            <text v-if="item.spec">规格: {{ item.spec }}</text>
            <text>分类: {{ item.categoryName || '-' }} | 单位: {{ item.unit }}</text>
            <text>采购价: ¥{{ item.purchasePrice ?? '-' }} | 销售价: ¥{{ item.salePrice ?? '-' }}</text>
            <text class="stock-line">当前库存: <text class="stock-num">{{ item.inventoryQuantity ?? 0 }}</text></text>
            <text style="font-size:11px;color:#bbb;margin-top:2px;">新增: {{ item.createTime?.slice(0,16) || '-' }}</text>
          </view>
        </view>
        <view v-if="loading && list.length > 0" class="loading">加载更多...</view>
        <view v-if="!hasMore && list.length > 0" class="loading" style="color:#ccc;">已加载全部</view>
        <view v-if="list.length === 0 && !loading" class="empty">暂无商品</view>
      </view>
    </scroll-view>
    <FloatingHome />
  </view>
</template>

<style scoped>
.page { padding: 12px; background: #f5f7f5; height: 100vh; display: flex; flex-direction: column; }
.search-bar { display: flex; gap: 8px; margin-bottom: 12px; }
.search-input { flex: 1; border: 1px solid #dcdfe6; border-radius: 6px; padding: 10px 12px; font-size: 14px; background: #fff; }
.search-btn { background: #2e7d32; color: #fff; border: none; border-radius: 6px; padding: 8px 16px; font-size: 14px; }
.sort-btn { border: 1px solid #dcdfe6; border-radius: 6px; padding: 8px 12px; font-size: 13px; background: #fff; white-space: nowrap; }
.sort-btn.active { border-color: #2e7d32; color: #2e7d32; }
.scroll-list { flex: 1; overflow-y: auto; }
.card { background: #fff; border-radius: 8px; padding: 12px 16px; margin-bottom: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
.product-name { font-weight: 600; font-size: 14px; }
.product-status { font-size: 11px; padding: 2px 8px; border-radius: 3px; }
.product-status.on { background: #e8f5e9; color: #2e7d32; }
.product-status.off { background: #f5f5f5; color: #999; }
.card-body { display: flex; flex-direction: column; gap: 3px; font-size: 13px; color: #666; }
.stock-line { margin-top: 4px; padding-top: 4px; border-top: 1px solid #f0f0f0; }
.stock-num { color: #2e7d32; font-weight: 600; }
.loading, .empty { text-align: center; color: #999; padding: 20px 0; }
</style>
