<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'

const suppliers = ref([])
const warehouses = ref([])
const products = ref([])
const warehouseStock = ref({})
const submitting = ref(false)
const showPicker = ref(false)
const pickerIndex = ref(0)
const searchKeyword = ref('')
const remarkFocused = ref(false)
const searchFocused = ref(false)

const form = ref({
  supplierId: null, warehouseId: null,
  orderDate: new Date().toISOString().slice(0, 10),
  remark: '', items: [],
})

onMounted(async () => {
  const [sRes, wRes, pRes] = await Promise.all([
    request.get('/supplier/list'), request.get('/warehouse/list'), request.get('/product/list'),
  ])
  suppliers.value = sRes.data; warehouses.value = wRes.data; products.value = pRes.data
})

watch(() => form.value.warehouseId, async (id) => {
  warehouseStock.value = {}
  if (!id) return
  try {
    const res = await request.get('/inventory/page', { params: { warehouseId: id, page: 1, size: 999 } })
    const stock = {}
    for (const r of res.data.records || []) stock[r.productId] = (stock[r.productId] || 0) + (r.quantity || 0)
    warehouseStock.value = stock
  } catch { /* ignore */ }
})

const sortedProducts = computed(() => {
  const withStock = [], without = []
  for (const p of products.value) {
    const s = warehouseStock.value[p.id] || 0
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
  const items = form.value.items
  const item = items[pickerIndex.value]
  if (!item) return
  item.productId = p.id; item.productName = p.name; item.spec = p.spec || ''
  if (!item.unitPrice) item.unitPrice = p.purchasePrice
  calcAmount(item)
  showPicker.value = false
}

function addItem() {
  form.value.items.push({ productId: null, productName: '', spec: '', quantity: 1, unitPrice: null, amount: null, batchNo: '' })
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
      if (!item.unitPrice) item.unitPrice = p.purchasePrice
      calcAmount(item)
    },
  })
}

function calcAmount(item) {
  if (item.quantity && item.unitPrice != null) item.amount = item.quantity * item.unitPrice
}

async function handleSubmit() {
  if (!form.value.warehouseId || form.value.items.length === 0) {
    uni.showToast({ title: '请填写完整信息', icon: 'none' }); return
  }
  submitting.value = true
  try {
    const res = await request.post('/purchase-order', form.value)
    await request.put(`/purchase-order/${res.data}/submit`)
    uni.showToast({ title: '入库成功', icon: 'success' })
    setTimeout(() => uni.switchTab({ url: '/pages/purchase/list' }), 300)
  } finally { submitting.value = false }
}
</script>

<template>
  <view class="page">
    <view class="section">
      <view class="form-item">
        <text class="label">供应商</text>
        <picker @change="e => form.supplierId = suppliers[e.detail.value]?.id" :range="suppliers" range-key="name">
          <view class="picker">{{ suppliers.find(s => s.id === form.supplierId)?.name || '请选择' }}</view>
        </picker>
      </view>
      <view class="form-item">
        <text class="label">仓库 *</text>
        <picker @change="e => form.warehouseId = warehouses[e.detail.value]?.id" :range="warehouses" range-key="name">
          <view class="picker">{{ warehouses.find(w => w.id === form.warehouseId)?.name || '请选择' }}</view>
        </picker>
      </view>
      <view class="form-item">
        <text class="label">备注</text>
        <input v-model="form.remark" class="input" :class="{ focused: remarkFocused }" @focus="remarkFocused = true" @blur="remarkFocused = false" placeholder="备注信息" />
      </view>
    </view>

    <view class="section">
      <view class="section-header">
        <text class="section-title">商品明细</text>
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
          <text>仓库库存: {{ warehouseStock[item.productId] ?? '-' }}</text>
        </view>
        <view class="item-row">
          <view class="item-field">
            <text class="label-sm">数量</text>
            <input v-model="item.quantity" class="input-sm" type="number" @input="calcAmount(item)" />
          </view>
          <view class="item-field">
            <text class="label-sm">单价</text>
            <input v-model="item.unitPrice" class="input-sm" type="digit" @input="calcAmount(item)" />
          </view>
          <view class="item-field">
            <text class="label-sm">金额</text>
            <text class="amount">¥{{ (item.amount || 0).toFixed(2) }}</text>
          </view>
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
              <text style="font-size:11px;color:#666;display:block;">{{ p.spec || '-' }} | 采购价 ¥{{ p.purchasePrice }}</text>
            </view>
            <view class="stock-badge" :class="{ 'has-stock': (warehouseStock[p.id] || 0) > 0 }">
              库存 {{ warehouseStock[p.id] ?? '-' }}
            </view>
          </view>
          <view v-if="filteredProducts.length === 0" style="text-align:center;padding:20px;color:#999;">无匹配商品</view>
        </scroll-view>
      </view>
    </view>

    <button class="submit-btn" :loading="submitting" @click="handleSubmit">确认入库</button>
    <FloatingHome />
  </view>
</template>

<style scoped>
.page { padding: 16px; padding-bottom: 80px; }
.section { background: #fff; border-radius: 8px; padding: 16px; margin-bottom: 12px; }
.form-item { margin-bottom: 12px; }
.label { display: block; font-size: 14px; color: #333; margin-bottom: 4px; }
.picker { border: 1px solid #dcdfe6; border-radius: 6px; padding: 14px 16px; font-size: 14px; color: #333; background: #fff; }
.input { border: 1px solid #dcdfe6; border-radius: 4px; padding: 10px 12px; }
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
.input.focused { border-color: #2e7d32; border-width: 1.5px; }
.picker-search .search-input.focused { border-color: #2e7d32; border-width: 1.5px; }
.amount { font-size: 14px; color: #f56c6c; font-weight: bold; }
.submit-btn { position: fixed; bottom: 0; left: 0; right: 0; margin: 16px; background: #2e7d32; color: #fff; border: none; border-radius: 8px; height: 44px; line-height: 44px; font-size: 16px; }
.ic-row { display: flex; align-items: center; gap: 8px; }
.scan-btn { width: 40px; height: 40px; background: #e8f5e9; border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 20px; flex-shrink: 0; }
.picker-select:active { background: #e8f5e9; }
.picker-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); z-index: 999; display: flex; align-items: flex-end; }
.picker-modal { background: #fff; border-radius: 16px 16px 0 0; width: 100%; max-height: 70vh; display: flex; flex-direction: column; }
.picker-search { padding: 16px 16px 8px; }
.picker-search .search-input {
  border: 1px solid #dcdfe6; border-radius: 4px; padding: 10px 12px; }
.picker-list { padding: 0 16px 20px; max-height: 55vh; overflow-y: auto; }
.picker-item { display: flex; align-items: center; gap: 8px; padding: 12px 0; border-bottom: 1px solid #f5f5f5; }
.picker-item:active { background: #f5f7f5; }
.stock-badge { font-size: 11px; padding: 3px 8px; border-radius: 4px; background: #f5f5f5; color: #999; white-space: nowrap; flex-shrink: 0; }
.stock-badge.has-stock { background: #e8f5e9; color: #2e7d32; }
</style>
