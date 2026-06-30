<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'

const editingId = ref(null)
const customers = ref([])
const products = ref([])
const whInventoryRecords = ref([]) // 当前仓库库存明细
const allInvRecords = ref([]) // 全部仓库库存（多仓库模式）
const warehouseStock = ref({})
const submitting = ref(false)
const showPicker = ref(false)
const pickerIndex = ref(0)
const searchKeyword = ref('')
const salesmanFocused = ref(false)
const searchFocused = ref(false)
const multiWarehouse = ref(false) // 多仓库出库
const isChildOrder = ref(false)   // 子订单编辑，禁止再拆
const pickingFor = ref('form') // 仓库选择器上下文：'form' 或行索引 number

// 级联仓库选择
const warehouseTree = ref([])
const whCascade = ref([])
const whOptions = ref([])
const showWhPicker = ref(false)
const whSearchKeyword = ref('')
const whSearchResults = ref([])
const whSearching = ref(false)
const whSearched = ref(false)

async function doWhSearch() {
  const kw = whSearchKeyword.value.trim()
  if (!kw) return
  whSearching.value = true
  try {
    const res = await request.get('/warehouse/search', { params: { keyword: kw } })
    whSearchResults.value = (res.data || []).map(w => {
      w._path = getWhPath(w.id)
      const treeNode = findWhInTree(warehouseTree.value, w.id)
      if (treeNode) w.children = treeNode.children
      return w
    })
    whSearched.value = true
  } finally { whSearching.value = false }
}
function selectWhSearchResult(item) {
  if (typeof pickingFor.value === 'number') {
    const idx = pickingFor.value
    if (form.value.items[idx]) form.value.items[idx].warehouseId = item.id
  } else {
    form.value.warehouseId = item.id; loadStock(item.id)
  }
  showWhPicker.value = false; pickingFor.value = 'form'
  whSearchKeyword.value = ''; whSearchResults.value = []; whSearched.value = false
}
function getWhPath(id) {
  function f(nodes, target, path) {
    for (const n of nodes) {
      if (n.id === target) return [...path, n.name]
      if (n.children?.length) { const r = f(n.children, target, [...path, n.name]); if (r) return r }
    }
    return null
  }
  return f(warehouseTree.value, id, [])?.join(' / ') || ''
}
function findWhInTree(nodes, id) {
  for (const n of nodes) {
    if (n.id === id) return n
    if (n.children?.length) { const r = findWhInTree(n.children, id); if (r) return r }
  }
  return null
}

const form = ref({
  customerId: null, warehouseId: null, salesman: '',
  orderDate: new Date().toISOString().slice(0, 10), remark: '', items: [],
})

onLoad((options) => {
  if (options?.id) editingId.value = Number(options.id)
})

onMounted(async () => {
  const [cRes, tRes, pRes, invRes] = await Promise.all([
    request.get('/customer/list'), request.get('/warehouse/tree'),
    request.get('/product/list'),
    request.get('/inventory/page', { params: { page: 1, size: 99999 } }),
  ])
  customers.value = cRes.data; warehouseTree.value = tRes.data || []; products.value = pRes.data
  allInvRecords.value = (invRes.data.records || []).filter(r => (r.quantity || 0) > 0)

  if (editingId.value) {
    const res = await request.get(`/sales-order/${editingId.value}`)
    const data = res.data
    form.value.customerId = data.customerId
    form.value.warehouseId = data.warehouseId
    form.value.salesman = data.salesman || ''
    form.value.orderDate = data.orderDate
    form.value.remark = data.remark || ''
    form.value.items = (data.items || []).map(i => ({
      productId: i.productId, productName: i.productName, spec: i.spec || '',
      quantity: i.quantity, unitPrice: i.unitPrice, amount: i.amount, batchNo: i.batchNo || '',
      warehouseId: data.warehouseId,
    }))
    if (data.parentOrderNo) { multiWarehouse.value = false; isChildOrder.value = true }
    if (data.warehouseId) loadStock(data.warehouseId)
  }
})

// 仓库级联
function openWarehousePicker(forIdx) {
  pickingFor.value = forIdx !== undefined ? forIdx : 'form'
  whCascade.value = []; whOptions.value = warehouseTree.value || []; showWhPicker.value = true
}
function selectWhLevel(item) {
  whCascade.value.push(item)
  if (item.children?.length) { whOptions.value = item.children }
  else {
    if (typeof pickingFor.value === 'number') {
      const idx = pickingFor.value
      if (form.value.items[idx]) form.value.items[idx].warehouseId = item.id
    } else {
      form.value.warehouseId = item.id; loadStock(item.id)
    }
    showWhPicker.value = false; pickingFor.value = 'form'
  }
}
function goBackTo(index) {
  whCascade.value = whCascade.value.slice(0, index + 1)
  const parent = whCascade.value.length ? whCascade.value[whCascade.value.length - 1] : null
  whOptions.value = parent ? (parent.children || []) : (warehouseTree.value || [])
}
const whDisplay = computed(() => {
  if (!form.value.warehouseId) return '请选择'
  function find(nodes, id) { for (const n of nodes) { if (n.id === id) return n.name; if (n.children) { const r = find(n.children, id); if (r) return r } } return null }
  return find(warehouseTree.value, form.value.warehouseId) || '仓库' + form.value.warehouseId
})

async function loadStock(id) {
  warehouseStock.value = {}
  whInventoryRecords.value = []
  try {
    const res = await request.get('/inventory/page', { params: { warehouseId: id, page: 1, size: 999 } })
    const records = (res.data.records || []).filter(r => (r.quantity || 0) > 0)
    records.sort((a, b) => (b.createTime || '').localeCompare(a.createTime || ''))
    whInventoryRecords.value = records
    // 聚合库存
    const stock = {}
    for (const r of records) stock[r.productId] = (stock[r.productId] || 0) + (r.quantity || 0)
    warehouseStock.value = stock
  } catch { /* ignore */ }
}

watch(() => form.value.warehouseId, async (id) => {
  if (id) loadStock(id)
})

// 多仓库切换时清空主仓库/行仓库
watch(multiWarehouse, (on) => {
  if (on) {
    form.value.warehouseId = null
  } else {
    for (const item of form.value.items) {
      item.warehouseId = form.value.warehouseId || undefined
    }
  }
})

function getInvForItem(index) {
  if (!multiWarehouse.value) return whInventoryRecords.value
  const whId = form.value.items[index]?.warehouseId
  if (!whId) return []
  return allInvRecords.value.filter(r => r.warehouseId === whId && r.productId && (r.quantity || 0) > 0)
    .sort((a, b) => (b.createTime || '').localeCompare(a.createTime || ''))
}

// 只显示当前仓库（或多仓库各行对应仓库）有库存的商品
const sortedProducts = computed(() => {
  const inv = getInvForItem(pickerIndex.value)
  return inv.map(r => {
    const p = products.value.find(x => x.id === r.productId)
    return { id: r.productId, name: r.productName || (p ? p.name : ''), code: r.productCode || (p ? p.code : ''), spec: p ? p.spec : '', salePrice: p ? p.salePrice : null, stock: r.quantity || 0, stockDate: r.createTime?.substring(0, 16) || '', batchNo: r.batchNo || '' }
  }).sort((a, b) => (b.stockDate || '').localeCompare(a.stockDate || ''))
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
  item.productId = p.id; item.productName = p.name; item.spec = p.spec || ''; item.batchNo = p.batchNo || ''
  if (!item.unitPrice) item.unitPrice = p.salePrice
  calcAmount(item)
  showPicker.value = false
}

function addItem() {
  form.value.items.push({ productId: null, productName: '', spec: '', quantity: 1, unitPrice: null, amount: null, batchNo: '', warehouseId: form.value.warehouseId || null })
}

function removeItem(index) { form.value.items.splice(index, 1) }

function scanCode(index) {
  uni.scanCode({
    success: (res) => {
      const item = form.value.items[index]
      if (!item) return
      // 确定搜索范围：多仓库模式搜全部，单仓库模式搜当前仓库
      const pool = multiWarehouse.value
        ? (item.warehouseId ? allInvRecords.value.filter(r => r.warehouseId === item.warehouseId) : allInvRecords.value)
        : whInventoryRecords.value
      let match = pool.find(r => r.productCode === res.result || r.productCode)
      if (!match) {
        const p = products.value.find(x => x.code === res.result)
        match = pool.find(r => r.productId === (p ? p.id : null))
      }
      if (!match) { uni.showToast({ title: multiWarehouse.value ? '所有仓库无此商品库存' : '当前仓库无此商品库存', icon: 'none' }); return }
      item.productId = match.productId; item.productName = match.productName; item.batchNo = match.batchNo || ''
      // 多仓库下如果该行还选了仓库，扫码结果自动绑定
      if (multiWarehouse.value && !item.warehouseId && match.warehouseId) {
        item.warehouseId = match.warehouseId
      }
      const p = products.value.find(x => x.id === match.productId)
      if (p) { item.spec = p.spec || ''; if (!item.unitPrice) item.unitPrice = p.salePrice }
      calcAmount(item)
    },
  })
}

function calcAmount(item) {
  if (item.quantity && item.unitPrice != null) item.amount = item.quantity * item.unitPrice
}

async function handleSaveDraft() {
  if (submitting.value) return
  if (!form.value.warehouseId && !multiWarehouse.value) {
    uni.showToast({ title: '请选择仓库或开启多仓库', icon: 'none' }); return
  }
  if (!form.value.items.length) { uni.showToast({ title: '请添加商品', icon: 'none' }); return }
  submitting.value = true
  try {
    if (editingId.value) {
      await request.put(`/sales-order/${editingId.value}/draft`, form.value)
    } else {
      const res = await request.post('/sales-order', form.value)
      const data = res.data
      const ids = data.ids || [data]
      editingId.value = ids[0]
      if (ids.length > 1) uni.showToast({ title: `已拆为 ${ids.length} 张草稿`, icon: 'success' })
      else uni.showToast({ title: '已保存草稿', icon: 'success' })
    }
    setTimeout(() => uni.switchTab({ url: '/pages/sales/list' }), 300)
  } finally { submitting.value = false }
}

async function handleSubmit() {
  if (submitting.value) return
  if (!form.value.warehouseId && !multiWarehouse.value) {
    uni.showToast({ title: '请选择仓库或开启多仓库', icon: 'none' }); return
  }
  if (!form.value.items.length) { uni.showToast({ title: '请添加商品', icon: 'none' }); return }
  for (const item of form.value.items) {
    if (!item.productId) { uni.showToast({ title: '请为每行选择商品', icon: 'none' }); return }
    if (!item.quantity || item.quantity <= 0) { uni.showToast({ title: '数量必须大于0', icon: 'none' }); return }
    if (item.unitPrice == null || item.unitPrice < 0) { uni.showToast({ title: '请输入有效售价', icon: 'none' }); return }
    if (multiWarehouse.value && !item.warehouseId) { uni.showToast({ title: '多仓库模式下每行必须选择仓库', icon: 'none' }); return }
  }
  submitting.value = true
  try {
    let ids = []
    if (editingId.value) {
      await request.put(`/sales-order/${editingId.value}/draft`, form.value)
      ids = [editingId.value]
    } else {
      const res = await request.post('/sales-order', form.value)
      const data = res.data
      ids = data.ids || [data]
    }
    for (const id of ids) {
      await request.put(`/sales-order/${id}/submit`)
    }
    const tip = ids.length > 1 ? `已拆为 ${ids.length} 张并提交` : '已提交审批'
    uni.showToast({ title: tip, icon: 'success' })
    setTimeout(() => uni.switchTab({ url: '/pages/sales/list' }), 300)
  } finally { submitting.value = false }
}
</script>

<template>
  <view class="page">
    <view class="section">
      <view class="form-item">
        <text class="label">客户</text>
        <picker @change="e => form.customerId = customers[e.detail.value]?.id" :range="customers" range-key="name">
          <view class="picker">{{ customers.find(c => c.id === form.customerId)?.name || '请选择' }}</view>
        </picker>
      </view>
      <view class="form-item">
        <text class="label">{{ multiWarehouse ? '默认仓库' : '仓库 *' }}</text>
        <view style="display:flex;align-items:center;gap:8px;">
          <view class="picker picker-select" :style="multiWarehouse ? 'opacity:0.5;' : ''" @click="!multiWarehouse && openWarehousePicker()" style="flex:1;">
            <text :style="!form.warehouseId ? 'color:#bbb;' : ''">{{ multiWarehouse ? '每行独立选择' : whDisplay }}</text>
          </view>
          <text v-if="!isChildOrder && form.items.length === 0" class="mw-toggle" :class="{ on: multiWarehouse }" @click="multiWarehouse = !multiWarehouse">{{ multiWarehouse ? '✓ 多仓库' : '多仓库出库' }}</text>
        </view>
        <!-- 级联仓库选择 -->
        <view v-if="showWhPicker" class="picker-overlay" @click="showWhPicker = false">
          <view class="picker-modal" @click.stop>
            <view class="picker-header">
              <text class="picker-cancel" @click="showWhPicker = false">取消</text>
              <text style="font-weight:bold;">选择仓库</text>
              <view style="width:40px;"></view>
            </view>
            <view style="padding:8px 16px 4px;">
              <view style="display:flex;gap:6px;">
                <input v-model="whSearchKeyword" class="search-input" placeholder="仓库名称/编码" style="flex:1;" @confirm="doWhSearch" />
                <text class="search-btn" @click="doWhSearch">搜索</text>
              </view>
            </view>
            <view v-if="whCascade.length" class="wh-breadcrumb">
              <text v-for="(c, i) in whCascade" :key="i" class="wh-crumb" @click="goBackTo(i)">{{ c.name }}<text v-if="i < whCascade.length - 1"> ›</text></text>
            </view>
            <scroll-view scroll-y class="picker-list">
              <!-- 搜索模式 -->
              <view v-if="whSearched">
                <view v-for="item in whSearchResults" :key="item.id" class="picker-item" @click="selectWhSearchResult(item)">
                  <view style="width:100%;overflow:hidden;">
                    <view style="font-size:14px;font-weight:500;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ item.name }}</view>
                    <view style="font-size:11px;color:#999;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ item.level }}级 · <text :style="{color: item.children?.length ? '#409eff' : '#2e7d32'}">{{ item.children?.length ? '虚拟节点' : '库存 '+ (item.productCount||0) }}</text></view>
                    <view style="font-size:11px;color:#666;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ item._path }}</view>
                  </view>
                </view>
                <view v-if="!whSearching && !whSearchResults.length" style="text-align:center;padding:30px 0;color:#999;">未找到匹配仓库</view>
              </view>
              <!-- 浏览模式 -->
              <view v-else>
                <view v-for="item in whOptions" :key="item.id" class="picker-item" @click="selectWhLevel(item)">
                  <view style="flex:1;overflow:hidden;">
                    <view :style="{ fontWeight: item.children?.length ? 'bold' : 'normal', overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }">{{ item.name }}</view>
                    <view style="font-size:10px;color:#999;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ item.level }}级 · <text :style="{color: item.children?.length ? '#409eff' : '#2e7d32'}">{{ item.children?.length ? '虚拟节点' : '库存'+ (item.productCount||0) }}</text></view>
                  </view>
                  <view v-if="item.children?.length" style="margin-left:8px;color:#ccc;">›</view>
                </view>
                <view v-if="!whOptions.length" style="text-align:center;padding:30px 0;color:#999;">无下级仓库</view>
              </view>
            </scroll-view>
          </view>
        </view>
      </view>
      <view class="form-item">
        <text class="label">销售员</text>
        <input v-model="form.salesman" class="input" :class="{ focused: salesmanFocused }" @focus="salesmanFocused = true" @blur="salesmanFocused = false" placeholder="销售员名称" />
      </view>
    </view>

    <view class="section">
      <view class="section-header">
        <text class="section-title">商品明细</text>
        <text class="add-link" @click="addItem">+ 添加</text>
      </view>
      <text class="scan-hint">提示：请手动添加商品，或使用右侧 📱 按钮扫条码快速选择</text>
      <view v-if="multiWarehouse && form.items.length === 0" style="background:#e8f5e9;border-radius:6px;padding:10px 12px;margin-bottom:8px;font-size:12px;color:#2e7d32;line-height:1.6;">
        💡 已开启<b>多仓库出库</b>，点击「+ 添加」开始添加商品，每行可独立选择出库仓库
      </view>
      <view v-if="multiWarehouse && form.items.length > 0" style="background:#e8f5e9;border-radius:6px;padding:10px 12px;margin-bottom:8px;font-size:12px;color:#2e7d32;line-height:1.6;">
        💡 <b>多仓库出库</b>：提交后自动拆为多张出库单各自审批，请确认每行仓库无误
      </view>
      <view v-for="(item, index) in form.items" :key="index" class="item-card">
        <view class="item-header">
          <text>商品 {{ index + 1 }}</text>
          <text class="del-link" @click="removeItem(index)">删除</text>
        </view>
        <view v-if="multiWarehouse" style="margin-bottom:4px;">
          <view class="picker picker-select" @click="openWarehousePicker(index)" style="font-size:13px;">
            <text :style="!item.warehouseId ? 'color:#bbb;' : ''">{{ item.warehouseId ? (findWhInTree(warehouseTree, item.warehouseId)?.name || '仓库'+item.warehouseId) : '选择仓库' }}</text>
          </view>
        </view>
        <view class="ic-row">
          <view class="picker picker-select" @click="openPicker(index)" style="flex:1;overflow:hidden;">
            {{ item.productName || '选择商品' }}
          </view>
          <view class="scan-btn" @click="scanCode(index)">📱</view>
        </view>
        <view v-if="item.productId" class="selected-info">
          <text>规格: {{ item.spec || '-' }}</text>
          <text>{{ multiWarehouse ? '' : '仓库库存: ' + (warehouseStock[item.productId] ?? '-') }}</text>
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
          <view v-for="p in filteredProducts" :key="p.id + '_' + p.stockDate + '_' + p.batchNo" class="picker-item" @click="selectProduct(p)">
            <view style="flex:1;overflow:hidden;">
              <view style="font-size:14px;font-weight:500;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ p.name }}</view>
              <text style="font-size:11px;color:#999;">{{ p.code }} | {{ p.spec || '-' }}</text>
              <text style="font-size:11px;color:#666;display:block;">
                {{ p.stock }}件 · {{ p.stockDate }}
                <text v-if="p.batchNo" style="color:#bbb;"> · {{ p.batchNo }}</text>
                <text style="margin-left:8px;">售价 ¥{{ p.salePrice }}</text>
              </text>
            </view>
          </view>
          <view v-if="filteredProducts.length === 0" style="text-align:center;padding:20px;color:#999;">
            <template v-if="multiWarehouse && !form.items[pickerIndex]?.warehouseId">请先选择该行的出库仓库</template>
            <template v-else>该仓库暂无可用库存</template>
          </view>
        </scroll-view>
      </view>
    </view>

    <view style="display:flex;gap:10px;position:fixed;bottom:16px;left:16px;right:16px;">
      <button class="btn-draft" :loading="submitting" @click="handleSaveDraft">保存草稿</button>
      <button class="btn-submit" :loading="submitting" @click="handleSubmit">{{ editingId ? '保存并提交' : '确认出库' }}</button>
    </view>
    <FloatingHome v-if="!showWhPicker && !showPicker" />
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
.selected-info { display: flex; gap: 16px; font-size: 11px; color: #666; margin: 6px 0 2px; padding: 4px 8px; background: #fff3e0; border-radius: 4px; }
.item-row { display: flex; gap: 8px; margin-top: 8px; }
.item-field { flex: 1; }
.label-sm { font-size: 12px; color: #666; }
.input-sm { border: 1px solid #dcdfe6; border-radius: 4px; padding: 10px 12px; }
.input.focused { border-color: #2e7d32; border-width: 1.5px; }
.picker-search .search-input.focused { border-color: #2e7d32; border-width: 1.5px; }
.amount { font-size: 14px; color: #f56c6c; font-weight: bold; }
.btn-draft { flex:1; background:#fff; color:#666; border:1px solid #dcdfe6; border-radius:8px; height:44px; line-height:44px; font-size:15px; }
.btn-submit { flex:1; background: #2e7d32; color: #fff; border: none; border-radius: 8px; height: 44px; line-height: 44px; font-size: 15px; }
.ic-row { display: flex; align-items: center; gap: 8px; }
.scan-btn { width: 40px; height: 40px; background: #e8f5e9; border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 20px; flex-shrink: 0; }
.scan-hint { display: block; font-size: 11px; color: #999; margin-bottom: 8px; }
.picker-select:active { background: #e8f5e9; }
.picker-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); z-index: 999; display: flex; align-items: flex-end; }
.picker-modal { background: #fff; border-radius: 16px 16px 0 0; width: 100%; max-height: 70vh; display: flex; flex-direction: column; }
.picker-search { padding: 16px 16px 8px; }
.picker-search .search-input {
  border: 1px solid #dcdfe6; border-radius: 4px; padding: 10px 12px; }
.picker-list { padding: 0 16px 20px; max-height: 55vh; overflow-y: auto; }
.picker-item { display: flex; align-items: center; padding: 12px 0; border-bottom: 1px solid #f5f5f5; overflow: hidden; }
.picker-item:active { background: #f5f7f5; }
.stock-text { color: #999; }
.stock-text.has-stock { color: #2e7d32; font-weight:500; }
.picker-header { display: flex; align-items: center; justify-content: space-between; padding: 16px; border-bottom: 1px solid #eee; }
.picker-cancel { color: #666; font-size: 14px; }
.wh-breadcrumb { display: flex; flex-wrap: wrap; gap: 4px; padding: 10px 16px; background: #f5f7fa; font-size: 13px; }
.wh-crumb { color: #2e7d32; }
.search-btn { display:inline-block; background:#2e7d32; color:#fff; padding:8px 16px; border-radius:4px; font-size:13px; white-space:nowrap; }
.search-btn:active { opacity:0.8; }
.level-tab { display:inline-block; padding:4px 10px; border-radius:4px; font-size:12px; background:#f5f5f5; color:#666; }
.level-tab.active { background:#2e7d32; color:#fff; }
.mw-toggle { display:inline-block; padding:6px 12px; border-radius:6px; font-size:13px; white-space:nowrap; background:#f5f5f5; color:#666; border:1px solid #dcdfe6; }
.mw-toggle.on { background:#e8f5e9; color:#2e7d32; border-color:#a5d6a7; font-weight:bold; }
.mw-toggle:active { opacity:0.7; }
</style>
