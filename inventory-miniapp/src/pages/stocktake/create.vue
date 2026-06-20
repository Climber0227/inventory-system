<script setup>
import { ref, onMounted, watch, computed } from 'vue'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'

const products = ref([])
const loading = ref(false)
const warehouseInventory = ref([])
const selectedIds = ref(new Set())
const items = ref([])
// 级联仓库选择
const warehouseTree = ref([])
const whCascade = ref([])
const whOptions = ref([])
const showWhPicker = ref(false)
const whSearchKeyword = ref('')
const whSearchResults = ref([])
const whSearching = ref(false)
const whSearched = ref(false)

const form = ref({
  warehouseId: null,
  takeType: 0,
  stockTakeId: null,
})

const step = ref('config')

// 级联仓库
function openWarehousePicker() { whCascade.value = []; whOptions.value = warehouseTree.value || []; showWhPicker.value = true; whSearched.value = false }
function selectWhLevel(item) {
  whCascade.value.push(item)
  if (item.children?.length) { whOptions.value = item.children }
  else { form.value.warehouseId = item.id; showWhPicker.value = false }
}
function goBackTo(index) {
  whCascade.value = whCascade.value.slice(0, index + 1)
  const parent = whCascade.value.length ? whCascade.value[whCascade.value.length - 1] : null
  whOptions.value = parent ? (parent.children || []) : (warehouseTree.value || [])
}
async function doWhSearch() {
  const kw = whSearchKeyword.value.trim()
  if (!kw) return
  whSearching.value = true
  try {
    const res = await request.get('/warehouse/search', { params: { keyword: kw } })
    whSearchResults.value = (res.data || []).map(w => {
      w._path = getWhPath(w.id)
      // search 接口不返回 children，需从 tree 数据判断是否有子级
      const treeNode = findInTree(warehouseTree.value, w.id)
      if (treeNode) w.children = treeNode.children
      return w
    })
    whSearched.value = true
  } finally { whSearching.value = false }
}
function findInTree(nodes, id) {
  for (const n of nodes) {
    if (n.id === id) return n
    if (n.children?.length) { const r = findInTree(n.children, id); if (r) return r }
  }
  return null
}
function selectWhSearchResult(item) {
  form.value.warehouseId = item.id; showWhPicker.value = false
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
const whLabel = computed(() => {
  if (!form.value.warehouseId) return '请选择仓库'
  function find(nodes, id) { for (const n of nodes) { if (n.id === id) return n.name; if (n.children) { const r = find(n.children, id); if (r) return r } } return null }
  return find(warehouseTree.value, form.value.warehouseId) || '请选择仓库'
})

async function fetchBase() {
  const [tRes, pRes] = await Promise.all([
    request.get('/warehouse/tree'),
    request.get('/product/list'),
  ])
  warehouseTree.value = tRes.data || []
  products.value = pRes.data
}

// 仓库切换时刷新该仓库存
watch(() => form.value.warehouseId, async (id) => {
  if (!id) { warehouseInventory.value = []; return }
  loading.value = true
  try {
    const res = await request.get('/inventory/page', { params: { warehouseId: id, page: 1, size: 999 } })
    warehouseInventory.value = (res.data.records || []).map(i => ({
      productId: i.productId,
      productName: i.productName,
      productCode: i.productCode,
      batchNo: i.batchNo,
      quantity: i.quantity,
    }))
    selectedIds.value = new Set(warehouseInventory.value.map(i => i.productId))
  } finally { loading.value = false }
})

// 抽盘：勾选/取消
function toggleSelect(productId) {
  const s = new Set(selectedIds.value)
  if (s.has(productId)) s.delete(productId); else s.add(productId)
  selectedIds.value = s
}

// 抽盘：扫码添加
function scanToAdd() {
  uni.scanCode({
    success: (res) => {
      const p = products.value.find(x => x.code === res.result)
      if (!p) { uni.showToast({ title: '未找到该商品', icon: 'none' }); return }
      if (selectedIds.value.has(p.id)) { uni.showToast({ title: '已在列表中', icon: 'none' }); return }
      // 不在当前仓库库存中也可以添加（盘亏场景）
      selectedIds.value = new Set([...selectedIds.value, p.id])
      if (!warehouseInventory.value.find(i => i.productId === p.id)) {
        warehouseInventory.value.push({
          productId: p.id, productName: p.name, productCode: p.code,
          batchNo: '', quantity: 0,
        })
      }
      uni.showToast({ title: `已添加: ${p.name}`, icon: 'success' })
    },
  })
}

// 抽盘：从搜索列表选择添加
function manualSelect(p) {
  selectedIds.value = new Set([...selectedIds.value, p.id])
  if (!warehouseInventory.value.find(i => i.productId === p.id)) {
    warehouseInventory.value.push({
      productId: p.id, productName: p.name, productCode: p.code,
      batchNo: '', quantity: 0,
    })
  }
  uni.showToast({ title: `已添加: ${p.name}`, icon: 'success' })
  showPicker.value = false
}

const showPicker = ref(false)
const pickerMode = ref('') // 'scan' or 'manual'
const pickerKeyword = ref('')
const searchFocused = ref(false)
const selectedCount = computed(() => selectedIds.value.size)

const sortedAllProducts = computed(() => {
  const withStock = [], without = []
  for (const p of products.value) {
    const s = warehouseInventory.value.find(i => i.productId === p.id)?.quantity || 0
    ;(s > 0 ? withStock : without).push(p)
  }
  return [...withStock, ...without]
})

const filteredPickerProducts = computed(() => {
  const kw = pickerKeyword.value.trim().toLowerCase()
  if (!kw) return sortedAllProducts.value
  return sortedAllProducts.value.filter(p =>
    p.name.toLowerCase().includes(kw) || (p.code && p.code.toLowerCase().includes(kw)))
})

function openManualPicker() {
  pickerKeyword.value = ''
  pickerMode.value = 'manual'
  showPicker.value = true
}

async function startTake() {
  if (!form.value.warehouseId) { uni.showToast({ title: '请选择仓库', icon: 'none' }); return }
  if (form.value.takeType === 1 && selectedCount.value === 0) {
    uni.showToast({ title: '请至少选择一个商品', icon: 'none' }); return
  }
  loading.value = true
  try {
    const res = await request.post('/stock-take', {
      warehouseId: form.value.warehouseId,
      takeType: form.value.takeType,
    })
    form.value.stockTakeId = res.data

    // 根据勾选状态生成盘点明细
    const selected = form.value.takeType === 0
      ? warehouseInventory.value
      : warehouseInventory.value.filter(i => selectedIds.value.has(i.productId))

    items.value = selected.map(i => ({
      productId: i.productId,
      productName: i.productName,
      batchNo: i.batchNo,
      bookQty: i.quantity,
      actualQty: i.quantity,
      diffQty: 0,
    }))
    step.value = 'counting'
  } finally { loading.value = false }
}

function onQtyChange(item) {
  item.diffQty = (item.actualQty || 0) - (item.bookQty || 0)
}

async function finishTake() {
  loading.value = true
  try {
    if (form.value.takeType === 0) {
      // 全盘：后端已创建明细（actualQty=bookQty），需获取ID后更新实盘数
      const detailRes = await request.get(`/stock-take/${form.value.stockTakeId}`)
      const backendItems = detailRes.data.items || []
      for (const item of items.value) {
        const bi = backendItems.find(
          b => b.productId === item.productId && (b.batchNo || '') === (item.batchNo || '')
        )
        if (bi && item.actualQty !== bi.actualQty) {
          await request.put(`/stock-take/item/${bi.id}`, { actualQty: item.actualQty })
        }
      }
    } else {
      // 抽盘：逐个创建明细
      for (const item of items.value) {
        await request.post('/stock-take/item', {
          stockTakeId: form.value.stockTakeId,
          productId: item.productId,
          batchNo: item.batchNo,
          bookQty: item.bookQty,
          actualQty: item.actualQty,
          diffQty: item.diffQty,
        })
      }
    }
    uni.showToast({ title: '盘点完成', icon: 'success' })
    setTimeout(() => uni.redirectTo({ url: '/pages/stocktake/detail?id=' + form.value.stockTakeId }), 300)
  } finally { loading.value = false }
}

onMounted(fetchBase)
</script>

<template>
  <view class="page">
    <!-- ===== 配置阶段 ===== -->
    <view v-if="step === 'config'" class="section">
      <view class="form-item">
        <text class="label">盘点仓库 *</text>
        <view class="picker picker-select" @click="openWarehousePicker">{{ whLabel }}</view>
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
                    <view style="font-size:11px;color:#999;">{{ item.level }}级 · <text :style="{color: item.children?.length ? '#409eff' : '#2e7d32'}">{{ item.children?.length ? '虚拟节点' : '库存 '+ (item.productCount||0) }}</text></view>
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
                    <view style="font-size:10px;color:#999;">{{ item.level }}级 · <text :style="{color: item.children?.length ? '#409eff' : '#2e7d32'}">{{ item.children?.length ? '虚拟节点' : '库存'+ (item.productCount||0) }}</text></view>
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
        <text class="label">盘点方式</text>
        <view class="take-type-row">
          <view class="type-option" :class="{ active: form.takeType === 0 }" @click="form.takeType = 0">
            <text class="type-icon">📋</text>
            <text style="font-weight:600;">全盘</text>
            <text class="type-desc">盘点该仓所有商品</text>
          </view>
          <view class="type-option" :class="{ active: form.takeType === 1 }" @click="form.takeType = 1">
            <text class="type-icon">🎯</text>
            <text style="font-weight:600;">抽盘</text>
            <text class="type-desc">仅盘点勾选商品</text>
          </view>
        </view>
      </view>

      <!-- 库存预览 -->
      <view v-if="form.warehouseId" style="margin-top:12px;">
        <view class="preview-header">
          <text style="font-weight:600;font-size:14px;">
            {{ form.takeType === 0 ? '该仓全部商品' : '选择要盘点的商品' }}
          </text>
          <view style="display:flex;gap:6px;">
            <text v-if="form.takeType === 1" class="action-tag" @click="scanToAdd">📷 扫码</text>
            <text v-if="form.takeType === 1" class="action-tag" @click="openManualPicker()">＋ 手动</text>
          </view>
        </view>
        <text style="font-size:12px;color:#999;display:block;margin-bottom:8px;">
          共 {{ warehouseInventory.length }} 种
          <template v-if="form.takeType === 1"> | 已选 {{ selectedCount }} 种</template>
        </text>

        <view v-for="inv in warehouseInventory" :key="inv.productId" class="inv-item"
          @click="form.takeType === 1 ? toggleSelect(inv.productId) : null">
          <view v-if="form.takeType === 1" class="check-box" :class="{ checked: selectedIds.has(inv.productId) }">
            {{ selectedIds.has(inv.productId) ? '✓' : '' }}
          </view>
          <view style="flex:1;">
            <text style="font-weight:500;font-size:14px;">{{ inv.productName }}</text>
            <text style="font-size:11px;color:#999;margin-left:6px;">{{ inv.productCode }}</text>
            <text style="font-size:12px;color:#666;display:block;">库存 {{ inv.quantity }}</text>
          </view>
        </view>
      </view>

      <button class="start-btn" :loading="loading" @click="startTake"
        :disabled="!form.warehouseId || (form.takeType === 1 && selectedCount === 0)">
        {{ form.takeType === 0 ? '开始全盘' : '开始抽盘' }}
      </button>
    </view>

    <!-- ===== 盘点录入阶段 ===== -->
    <view v-if="step === 'counting'" class="section">
      <view class="section-header">
        <text class="section-title">盘点录入 ({{ items.length }})</text>
        <text style="font-size:12px;color:#999;">{{ form.takeType === 0 ? '全盘' : '抽盘' }}</text>
      </view>

      <view v-for="(item, index) in items" :key="index" class="item-card">
        <text class="item-name">{{ item.productName }}</text>
        <view class="qty-row">
          <view class="qty-field">
            <text class="label-sm">账面</text>
            <text class="qty-book">{{ item.bookQty }}</text>
          </view>
          <view class="qty-field">
            <text class="label-sm">实盘</text>
            <input v-model="item.actualQty" class="input-sm" type="number" @input="onQtyChange(item)" />
          </view>
          <view class="qty-field">
            <text class="label-sm">差异</text>
            <text class="qty-diff" :class="{ 'has-diff': item.diffQty !== 0 }">{{ item.diffQty > 0 ? '+' : '' }}{{ item.diffQty }}</text>
          </view>
        </view>
      </view>

      <button class="submit-btn" :loading="loading" @click="finishTake">完成盘点</button>
    </view>

    <!-- 手动添加商品弹窗 -->
    <!-- 手动添加商品弹窗（支持搜索） -->
    <view v-if="showPicker && pickerMode === 'manual'" class="picker-overlay" @click="showPicker = false">
      <view class="picker-modal" @click.stop>
        <view class="picker-search">
          <input v-model="pickerKeyword" class="search-input" :class="{ focused: searchFocused }" @focus="searchFocused = true" @blur="searchFocused = false" placeholder="搜索商品名称或编码" focus />
        </view>
        <scroll-view scroll-y class="picker-list">
          <view v-for="p in filteredPickerProducts" :key="p.id" class="picker-item" @click="manualSelect(p)">
            <view style="flex:1;overflow:hidden;">
              <text style="font-size:14px;font-weight:500;">{{ p.name }}</text>
              <text style="font-size:11px;color:#999;margin-left:4px;">{{ p.code }}</text>
              <text style="font-size:11px;color:#666;display:block;">{{ p.spec || '-' }}</text>
            </view>
          </view>
          <view v-if="filteredPickerProducts.length === 0" style="text-align:center;padding:20px;color:#999;">无匹配商品</view>
        </scroll-view>
      </view>
    </view>
    <FloatingHome v-if="!showWhPicker && !showPicker" />
  </view>
</template>

<style scoped>
.page { padding: 16px; padding-bottom: 60px; }
.section { background: #fff; border-radius: 8px; padding: 16px; margin-bottom: 12px; }
.form-item { margin-bottom: 12px; }
.label { display: block; font-size: 14px; color: #333; margin-bottom: 4px; }
.picker { border: 1px solid #dcdfe6; border-radius: 6px; padding: 14px 16px; font-size: 14px; background: #fff; }

.take-type-row { display: flex; gap: 10px; }
.type-option { flex: 1; border: 1.5px solid #dcdfe6; border-radius: 8px; padding: 12px; text-align: center; }
.type-option.active { border-color: #2e7d32; background: #e8f5e9; }
.type-icon { display: block; font-size: 20px; margin-bottom: 4px; }
.type-desc { display: block; font-size: 10px; color: #999; margin-top: 2px; }

.preview-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.action-tag { font-size: 12px; color: #2e7d32; padding: 3px 8px; background: #e8f5e9; border-radius: 4px; }

.inv-item { display: flex; align-items: center; gap: 10px; padding: 10px 0; border-bottom: 1px solid #f5f5f5; }
.inv-item:last-child { border-bottom: none; }
.check-box { width: 22px; height: 22px; border: 2px solid #dcdfe6; border-radius: 4px; display: flex; align-items: center; justify-content: center; font-size: 12px; color: #fff; flex-shrink: 0; }
.check-box.checked { background: #2e7d32; border-color: #2e7d32; }

.start-btn { width: 100%; background: #2e7d32; color: #fff; border: none; border-radius: 6px; height: 42px; line-height: 42px; font-size: 15px; margin-top: 12px; }
.start-btn:disabled { background: #ccc; }

.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.section-title { font-weight: bold; }

.item-card { background: #f8f9fa; border-radius: 6px; padding: 12px; margin-bottom: 8px; }
.item-name { font-size: 14px; font-weight: 500; }
.qty-row { display: flex; gap: 12px; margin-top: 8px; }
.qty-field { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px; }
.label-sm { font-size: 12px; color: #666; }
.qty-book { font-size: 18px; font-weight: bold; }
.input-sm { border: 1px solid #2e7d32; border-radius: 4px; padding: 10px 12px; }
.qty-diff { font-size: 16px; font-weight: bold; color: #666; }
.has-diff { color: #f56c6c; }
.submit-btn { width: 100%; background: #2e7d32; color: #fff; border: none; border-radius: 6px; height: 42px; line-height: 42px; font-size: 15px; margin-top: 12px; }

.picker-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); z-index: 999; display: flex; align-items: flex-end; }
.picker-modal { background: #fff; border-radius: 16px 16px 0 0; width: 100%; max-height: 70vh; display: flex; flex-direction: column; }
.picker-search { padding: 16px 16px 8px; }
.picker-search .search-input {
  border: 1px solid #dcdfe6; border-radius: 4px; padding: 10px 12px; }
.picker-search .search-input.focused { border-color: #2e7d32; border-width: 1.5px; }
.picker-list { padding: 0 16px 20px; max-height: 55vh; overflow-y: auto; }
.picker-item { display: flex; align-items: center; gap: 8px; padding: 12px 0; border-bottom: 1px solid #f5f5f5; }
.picker-item:active { background: #f5f7f5; }
.picker-header { display: flex; align-items: center; justify-content: space-between; padding: 16px; border-bottom: 1px solid #eee; }
.picker-cancel { color: #666; font-size: 14px; }
.wh-breadcrumb { display: flex; flex-wrap: wrap; gap: 4px; padding: 10px 16px; background: #f5f7fa; font-size: 13px; }
.wh-crumb { color: #2e7d32; }
.search-btn { display:inline-block; background:#2e7d32; color:#fff; padding:8px 16px; border-radius:4px; font-size:13px; white-space:nowrap; }
.search-btn:active { opacity:0.8; }
</style>
