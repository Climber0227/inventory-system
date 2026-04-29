<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'

const warehouses = ref([])
const products = ref([])
const fromStock = ref({})
const stockLoaded = ref(false)
const submitting = ref(false)
const showPicker = ref(false)
const pickerIndex = ref(0)
const searchKeyword = ref('')
const searchFocused = ref(false)

const form = ref({
  fromWarehouseId: null, toWarehouseId: null, remark: '', items: [],
})

onMounted(async () => {
  const [wRes, pRes] = await Promise.all([
    request.get('/warehouse/list'), request.get('/product/list'),
  ])
  warehouses.value = wRes.data; products.value = pRes.data
})

watch(() => form.value.fromWarehouseId, async (id) => {
  stockLoaded.value = false
  fromStock.value = {}
  if (!id) return
  try {
    const res = await request.get('/inventory/page', { params: { warehouseId: id, page: 1, size: 999 } })
    const stock = {}
    for (const r of res.data.records || []) stock[r.productId] = (stock[r.productId] || 0) + (r.quantity || 0)
    fromStock.value = stock
    stockLoaded.value = true
  } catch { stockLoaded.value = true }
})

const sortedProducts = computed(() => {
  const withStock = [], without = []
  for (const p of products.value) {
    const s = fromStock.value[p.id] || 0
    ;(s > 0 ? withStock : without).push({ ...p, stock: s })
  }
  withStock.sort((a, b) => b.stock - a.stock)
  return [...withStock, ...without]
})

const filteredProducts = computed(() => {
  const kw = searchKeyword.value.trim().toLowerCase()
  if (!kw) return sortedProducts.value
  return sortedProducts.value.filter(p =>
    p.name.toLowerCase().includes(kw) || (p.code && p.code.toLowerCase().includes(kw)))
})

function openPicker(idx) { pickerIndex.value = idx; searchKeyword.value = ''; showPicker.value = true }

function selectProduct(p) {
  const item = form.value.items[pickerIndex.value]
  if (!item) return
  item.productId = p.id; item.productName = p.name; item.spec = p.spec || ''
  showPicker.value = false
}

function addItem() {
  form.value.items.push({ productId: null, productName: '', spec: '', quantity: 1, batchNo: '' })
}

function removeItem(index) { form.value.items.splice(index, 1) }

function scanCode(index) {
  uni.scanCode({
    success: (res) => {
      const p = products.value.find(x => x.code === res.result)
      if (!p) { uni.showToast({ title: '未找到该商品', icon: 'none' }); return }
      const item = form.value.items[index]
      if (!item) return
      item.productId = p.id; item.productName = p.name; item.spec = p.spec || ''
    },
  })
}

async function handleSubmit() {
  if (submitting.value) return
  if (!form.value.fromWarehouseId || !form.value.toWarehouseId) {
    uni.showToast({ title: '请选择仓库', icon: 'none' }); return
  }
  if (form.value.fromWarehouseId === form.value.toWarehouseId) {
    uni.showToast({ title: '调出和调入不能相同', icon: 'none' }); return
  }
  if (form.value.items.length === 0) {
    uni.showToast({ title: '请添加商品', icon: 'none' }); return
  }
  if (!stockLoaded.value) {
    uni.showToast({ title: '库存数据加载中，请稍后', icon: 'none' }); return
  }
  // 前端校验库存
  for (const item of form.value.items) {
    if (item.productId) {
      const qty = Number(item.quantity) || 0
      const stock = fromStock.value[item.productId] || 0
      if (qty > stock) {
        uni.showToast({ title: `${item.productName || '商品'}库存不足(可用${stock})`, icon: 'none' })
        return
      }
    }
  }
  submitting.value = true
  try {
    const res = await request.post('/transfer', form.value)
    const id = res.data
    try {
      await request.put(`/transfer/${id}/submit`)
      uni.showToast({ title: '调拨成功', icon: 'success' })
      setTimeout(() => uni.redirectTo({ url: '/pages/transfer/list' }), 300)
    } catch {
      // submit失败，作废草稿
      try { await request.put(`/transfer/${id}/void`, { reason: '库存不足自动作废' }) } catch {}
      uni.showToast({ title: '库存不足，调拨失败', icon: 'none' })
    }
  } finally { submitting.value = false }
}
</script>

<template>
  <view class="page">
    <view class="section">
      <view class="form-item">
        <text class="label">调出仓库 *</text>
        <picker @change="e => form.fromWarehouseId = warehouses[e.detail.value]?.id" :range="warehouses" range-key="name">
          <view class="picker">{{ warehouses.find(w => w.id === form.fromWarehouseId)?.name || '请选择' }}</view>
        </picker>
      </view>
      <view class="form-item">
        <text class="label">调入仓库 *</text>
        <picker @change="e => form.toWarehouseId = warehouses[e.detail.value]?.id" :range="warehouses" range-key="name">
          <view class="picker">{{ warehouses.find(w => w.id === form.toWarehouseId)?.name || '请选择' }}</view>
        </picker>
      </view>
    </view>

    <view class="section">
      <view class="section-header">
        <text class="section-title">调拨商品</text>
        <text class="add-link" @click="addItem">+ 添加</text>
      </view>
      <view v-for="(item, index) in form.items" :key="index" class="item-card">
        <view class="item-header">
          <text>商品 {{ index + 1 }}</text>
          <text class="del-link" @click="removeItem(index)">删除</text>
        </view>
        <view class="ic-row">
          <view class="picker picker-select" @click="openPicker(index)" style="flex:1;overflow:hidden;">
            {{ item.productName || '选择商品' }}
          </view>
          <view class="scan-btn" @click="scanCode(index)">📷</view>
        </view>
        <view v-if="item.productId" class="selected-info">
          <text>规格: {{ item.spec || '-' }}</text>
          <text>调出仓库存: {{ fromStock[item.productId] ?? '-' }}</text>
        </view>
        <view class="item-row">
          <view class="item-field"><text class="label-sm">数量</text><input v-model="item.quantity" class="input-sm" type="number" /></view>
          <view class="item-field"><text class="label-sm">批次号</text><input v-model="item.batchNo" class="input-sm" placeholder="选填" /></view>
        </view>
      </view>
    </view>

    <!-- 商品选择弹窗 -->
    <view v-if="showPicker" class="picker-overlay" @click="showPicker = false">
      <view class="picker-modal" @click.stop>
        <view class="picker-search">
          <input v-model="searchKeyword" class="search-input" :class="{ focused: searchFocused }" @focus="searchFocused = true" @blur="searchFocused = false" placeholder="搜索商品名称或编码" focus />
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-for="p in filteredProducts" :key="p.id" class="picker-item" @click="selectProduct(p)">
            <view style="flex:1;overflow:hidden;">
              <text style="font-size:14px;font-weight:500;">{{ p.name }}</text>
              <text style="font-size:11px;color:#999;margin-left:4px;">{{ p.code }}</text>
              <text style="font-size:11px;color:#666;display:block;">{{ p.spec || '-' }}</text>
            </view>
            <view class="stock-badge" :class="{ 'has-stock': (fromStock[p.id] || 0) > 0 }">
              库存 {{ fromStock[p.id] ?? '-' }}
            </view>
          </view>
          <view v-if="filteredProducts.length === 0" style="text-align:center;padding:20px;color:#999;">无匹配商品</view>
        </scroll-view>
      </view>
    </view>

    <button class="submit-btn" :loading="submitting" @click="handleSubmit">确认调拨</button>
    <FloatingHome />
  </view>
</template>

<style scoped>
.page { padding: 16px; padding-bottom: 80px; background: #f5f7f5; min-height: 100vh; }
.section { background: #fff; border-radius: 8px; padding: 16px; margin-bottom: 12px; }
.form-item { margin-bottom: 12px; }
.label { display: block; font-size: 14px; color: #333; margin-bottom: 4px; }
.picker { border: 1px solid #dcdfe6; border-radius: 6px; padding: 14px 16px; font-size: 14px; color: #333; background: #fff; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.section-title { font-weight: bold; }
.add-link { color: #2e7d32; font-size: 14px; }
.item-card { background: #f8f9fa; border-radius: 6px; padding: 12px; margin-bottom: 8px; }
.item-header { display: flex; justify-content: space-between; margin-bottom: 8px; font-weight: bold; }
.del-link { color: #ff4d4f; }
.selected-info { display: flex; gap: 16px; font-size: 11px; color: #666; margin: 6px 0 2px; padding: 4px 8px; background: #e8f5e9; border-radius: 4px; }
.item-row { display: flex; gap: 8px; margin-top: 8px; }
.item-field { flex: 1; }
.label-sm { font-size: 12px; color: #666; }
.input-sm { border: 1px solid #dcdfe6; border-radius: 4px; padding: 10px 12px; }
.ic-row { display: flex; align-items: center; gap: 8px; }
.scan-btn { width: 40px; height: 40px; background: #e8f5e9; border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 20px; flex-shrink: 0; }
.picker-select:active { background: #e8f5e9; }
.submit-btn { position: fixed; bottom: 0; left: 0; right: 0; margin: 16px; background: #2e7d32; color: #fff; border: none; border-radius: 8px; height: 44px; line-height: 44px; font-size: 16px; }
.picker-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); z-index: 999; display: flex; align-items: flex-end; }
.picker-modal { background: #fff; border-radius: 16px 16px 0 0; width: 100%; max-height: 70vh; display: flex; flex-direction: column; }
.picker-search { padding: 16px 16px 8px; }
.picker-search .search-input {
  border: 1px solid #dcdfe6; border-radius: 4px; padding: 10px 12px; }
.picker-search .search-input.focused { border-color: #2e7d32; border-width: 1.5px; }
.picker-list { padding: 0 16px 20px; max-height: 55vh; overflow-y: auto; }
.picker-item { display: flex; align-items: center; gap: 8px; padding: 12px 0; border-bottom: 1px solid #f5f5f5; }
.picker-item:active { background: #f5f7f5; }
.stock-badge { font-size: 11px; padding: 3px 8px; border-radius: 4px; background: #f5f5f5; color: #999; white-space: nowrap; flex-shrink: 0; }
.stock-badge.has-stock { background: #e8f5e9; color: #2e7d32; }
</style>
