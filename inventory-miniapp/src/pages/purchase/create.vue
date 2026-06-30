<script setup>
import { ref, onMounted, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()

const editingId = ref(null)
const suppliers = ref([])
const products = ref([])
const categories = ref([]) // 分类树
const warehouseStock = ref({})
const submitting = ref(false)
const showPicker = ref(false)
const pickerIndex = ref(0)
const searchKeyword = ref('')
const remarkFocused = ref(false)
const searchFocused = ref(false)

// 级联仓库选择
const warehouseTree = ref([])
const whCascade = ref([])     // 当前级联路径
const whStep = ref(0)                 // 0=未选, 1=选1级, 2=选2级...
const whOptions = ref([])      // 当前可选项
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
      w._path = getWarehousePath(w.id)
      const treeNode = findWhInTree(warehouseTree.value, w.id)
      if (treeNode) w.children = treeNode.children
      return w
    })
    whSearched.value = true
  } finally { whSearching.value = false }
}
function selectWhSearchResult(item) {
  form.value.warehouseId = item.id
  showWhPicker.value = false
  whSearchKeyword.value = ''
  whSearchResults.value = []
  whSearched.value = false
  loadStock(item.id)
}
function getWarehousePath(id) {
  function find(nodes, targetId, path) {
    for (const n of nodes) {
      if (n.id === targetId) return [...path, n.name]
      if (n.children?.length) {
        const r = find(n.children, targetId, [...path, n.name])
        if (r) return r
      }
    }
    return null
  }
  return find(warehouseTree.value, id, [])?.join(' / ') || ''
}
function findWhInTree(nodes, id) {
  for (const n of nodes) {
    if (n.id === id) return n
    if (n.children?.length) { const r = findWhInTree(n.children, id); if (r) return r }
  }
  return null
}

const form = ref({
  supplierId: null, warehouseId: null,
  orderDate: new Date().toISOString().slice(0, 10),
  remark: '', items: [],
})

onLoad((options) => {
  // 非管理员跳转首页
  if (!userStore.isAdmin) {
    uni.redirectTo({ url: '/pages/home/home' })
    return
  }
  if (options?.id) editingId.value = Number(options.id)
})

onMounted(async () => {
  const [sRes, tRes, pRes, cRes] = await Promise.all([
    request.get('/supplier/list'), request.get('/warehouse/tree'), request.get('/product/list'), request.get('/category/tree'),
  ])
  suppliers.value = sRes.data; warehouseTree.value = tRes.data || []; products.value = pRes.data
  categories.value = cRes.data || []

  if (editingId.value) {
    const res = await request.get(`/purchase-order/${editingId.value}`)
    const data = res.data
    form.value.supplierId = data.supplierId
    form.value.warehouseId = data.warehouseId
    form.value.orderDate = data.orderDate
    form.value.remark = data.remark || ''
    form.value.items = (data.items || []).map(i => ({
      productId: i.productId, productName: i.productName, spec: i.spec || '',
      quantity: i.quantity, unitPrice: i.unitPrice, amount: i.amount, batchNo: i.batchNo || '',
    }))
    if (data.warehouseId) loadStock(data.warehouseId)
  }
})

// 打开仓库选择器
function openWarehousePicker() {
  whCascade.value = []
  whStep.value = 1
  whOptions.value = warehouseTree.value || []
  showWhPicker.value = true
}
function selectWhLevel(item) {
  whCascade.value.push(item)
  if (item.children?.length) {
    whStep.value++
    whOptions.value = item.children
  } else {
    // 叶子节点，确认选择
    form.value.warehouseId = item.id
    showWhPicker.value = false
    // 加载库存
    loadStock(item.id)
  }
}
function goBackTo(index) {
  whCascade.value = whCascade.value.slice(0, index + 1)
  const parent = whCascade.value.length ? whCascade.value[whCascade.value.length - 1] : null
  whOptions.value = parent ? (parent.children || []) : (warehouseTree.value || [])
  whStep.value = index + 2
}
function goBackWhLevel() {
  whCascade.value.pop()
  const parent = whCascade.value.length ? whCascade.value[whCascade.value.length - 1] : null
  whOptions.value = parent ? (parent.children || []) : (warehouseTree.value || [])
  whStep.value--
}

// 仓库路径显示
const whDisplay = computed(() => {
  if (!form.value.warehouseId) return '请选择'
  // 从树中递归查找仓库名称
  function find(nodes, id) {
    for (const n of nodes) {
      if (n.id === id) return n.name
      if (n.children) { const r = find(n.children, id); if (r) return r }
    }
    return null
  }
  return find(warehouseTree.value, form.value.warehouseId) || '仓库' + form.value.warehouseId
})

async function loadStock(id) {
  warehouseStock.value = {}
  try {
    const res = await request.get('/inventory/page', { params: { warehouseId: id, page: 1, size: 999 } })
    const stock = {}
    for (const r of res.data.records || []) stock[r.productId] = (stock[r.productId] || 0) + (r.quantity || 0)
    warehouseStock.value = stock
  } catch { /* ignore */ }
}

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

// 快速创建商品
const showCreateForm = ref(false)
const newProductName = ref('')
const newProductUnit = ref('个')
const newProductSpec = ref('')
const newProductPurchasePrice = ref('')
const newProductCategoryId = ref(null)
const newProductCategoryIndex = ref(-1)

// 扁平化分类树（带缩进）用于 picker
const flatCategories = computed(() => {
  const result = []
  function walk(nodes, depth) {
    for (const n of nodes) {
      if (!n) continue
      result.push({ id: n.id, name: (depth ? '--'.repeat(depth) + '> ' : '') + n.name })
      if (n.children?.length) walk(n.children, depth + 1)
    }
  }
  walk(categories.value, 0)
  return result
})

function onCategoryChange(e) {
  newProductCategoryIndex.value = e.detail.value
  const cat = flatCategories.value[newProductCategoryIndex.value]
  newProductCategoryId.value = cat ? cat.id : null
}
const categoryDisplayName = computed(() => {
  const idx = newProductCategoryIndex.value
  if (idx < 0 || idx >= flatCategories.value.length) return '选择分类'
  const name = flatCategories.value[idx].name || ''
  return name.replace(/^[- >]+/, '')
})

function openCreateForm() {
  newProductName.value = ''
  newProductUnit.value = '个'
  newProductSpec.value = ''
  newProductPurchasePrice.value = ''
  newProductCategoryId.value = null
  newProductCategoryIndex.value = -1
  showCreateForm.value = true
}
async function confirmCreateProduct() {
  if (!newProductName.value.trim()) { uni.showToast({ title: '请输入商品名称', icon: 'none' }); return }
  try {
    const body = { name: newProductName.value.trim(), unit: newProductUnit.value || '个' }
    if (newProductSpec.value.trim()) body.spec = newProductSpec.value.trim()
    if (newProductPurchasePrice.value && !isNaN(Number(newProductPurchasePrice.value))) body.purchasePrice = Number(newProductPurchasePrice.value)
    if (newProductCategoryId.value != null) body.categoryId = newProductCategoryId.value
    const res = await request.post('/product/quick-create', body)
    const p = res.data
    products.value.push(p)
    showCreateForm.value = false
    // 自动添加一行并选中新商品
    form.value.items.push({
      productId: p.id, productName: p.name, spec: p.spec || '',
      quantity: 1, unitPrice: p.purchasePrice || null, amount: p.purchasePrice || null, batchNo: '',
    })
    uni.showToast({ title: '已添加', icon: 'success' })
  } catch { uni.showToast({ title: '创建失败', icon: 'none' }) }
}

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

async function handleSaveDraft() {
  if (!form.value.warehouseId || !form.value.items.length) {
    uni.showToast({ title: '请选择仓库并添加商品', icon: 'none' }); return
  }
  submitting.value = true
  try {
    if (editingId.value) {
      await request.put(`/purchase-order/${editingId.value}/draft`, form.value)
    } else {
      const res = await request.post('/purchase-order', form.value)
      editingId.value = res.data
    }
    uni.showToast({ title: '已保存草稿', icon: 'success' })
    setTimeout(() => uni.switchTab({ url: '/pages/purchase/list' }), 300)
  } finally { submitting.value = false }
}

async function handleSubmit() {
  if (!form.value.warehouseId || form.value.items.length === 0) {
    uni.showToast({ title: '请填写完整信息', icon: 'none' }); return
  }
  submitting.value = true
  try {
    if (editingId.value) {
      await request.put(`/purchase-order/${editingId.value}/draft`, form.value)
      await request.put(`/purchase-order/${editingId.value}/submit`)
    } else {
      const res = await request.post('/purchase-order', form.value)
      await request.put(`/purchase-order/${res.data}/submit`)
    }
    uni.showToast({ title: '已提交审批', icon: 'success' })
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
        <view class="picker picker-select" @click="openWarehousePicker">
          <text :style="!form.warehouseId ? 'color:#bbb;' : ''">{{ whDisplay }}</text>
        </view>

        <!-- 级联仓库选择弹窗 -->
        <view v-if="showWhPicker" class="picker-overlay" @click="showWhPicker = false">
          <view class="picker-modal" @click.stop>
            <view class="picker-header">
              <text class="picker-cancel" @click="showWhPicker = false">取消</text>
              <text class="picker-title" style="font-weight:bold;">选择仓库</text>
              <view style="width:40px;"></view>
            </view>
            <view class="picker-search" style="padding:8px 16px 4px;">
              <view style="display:flex;gap:6px;">
                <input v-model="whSearchKeyword" class="search-input" placeholder="仓库名称/编码" style="flex:1;" @confirm="doWhSearch" />
                <text class="search-btn" @click="doWhSearch">搜索</text>
              </view>
            </view>
            <view v-if="whSearched" class="wh-breadcrumb">
              <text style="font-size:12px;color:#999;padding:4px 16px;">搜索结果</text>
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
        <text class="label">备注</text>
        <input v-model="form.remark" class="input" :class="{ focused: remarkFocused }" @focus="remarkFocused = true" @blur="remarkFocused = false" placeholder="备注信息" />
      </view>
    </view>

    <view class="section">
      <view class="section-header">
        <text class="section-title">商品明细</text>
        <view style="display:flex;gap:8px;align-items:center;">
          <text style="color:#666;font-size:13px;padding:4px 10px;border:1px solid #dcdfe6;border-radius:4px;" @click="openCreateForm">+ 新建商品</text>
          <text class="add-link" @click="addItem">+ 添加商品</text>
        </view>
      </view>
      <text class="scan-hint">「新建商品」录入系统未收录的商品，「添加商品」从已有商品中选择</text>
      <view v-for="(item, index) in form.items" :key="index" class="item-card">
        <view class="item-header">
          <text>商品 {{ index + 1 }}</text>
          <text class="del-link" @click="removeItem(index)">删除</text>
        </view>
        <view class="ic-row">
          <view class="picker picker-select" @click="openPicker(index)" style="flex:1;overflow:hidden;">
            {{ item.productName || '选择商品' }}
          </view>
          <view class="scan-btn" @click="scanCode(index)">📱</view>
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
              <view style="font-size:14px;font-weight:500;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ p.name }}</view>
              <text style="font-size:11px;color:#999;">{{ p.code }} | {{ p.spec || '-' }}</text>
              <text style="font-size:11px;color:#666;display:block;">
                采购价 ¥{{ p.purchasePrice }}
                <text class="stock-text" :class="{ 'has-stock': (warehouseStock[p.id] || 0) > 0 }"> | 库存 {{ warehouseStock[p.id] ?? '-' }}</text>
              </text>
            </view>
          </view>
          <view v-if="filteredProducts.length === 0" style="text-align:center;padding:20px;color:#999;">无匹配商品</view>
        </scroll-view>
      </view>
    </view>

    <!-- 快速创建商品弹窗 -->
    <view v-if="showCreateForm" class="picker-overlay" @click="showCreateForm = false">
      <view class="picker-modal" @click.stop style="padding:20px;">
        <view style="font-size:16px;font-weight:bold;margin-bottom:16px;">新建商品</view>
        <view class="form-item">
          <text class="label">商品名称 *</text>
          <input v-model="newProductName" class="input" placeholder="输入商品名称" />
        </view>
        <view class="form-item">
          <text class="label">规格</text>
          <input v-model="newProductSpec" class="input" placeholder="例如：500ml、XL（选填）" />
        </view>
        <view class="form-item">
          <text class="label">单位</text>
          <input v-model="newProductUnit" class="input" placeholder="例如：个、箱、kg（默认个）" />
        </view>
        <view class="form-item">
          <text class="label">采购价</text>
          <input v-model="newProductPurchasePrice" class="input" type="digit" placeholder="采购单价（选填）" />
        </view>
        <view class="form-item">
          <text class="label">分类</text>
          <picker :value="newProductCategoryIndex" :range="flatCategories" range-key="name" @change="onCategoryChange">
            <view class="picker">{{ categoryDisplayName }}</view>
          </picker>
        </view>
        <view style="display:flex;gap:12px;margin-top:20px;">
          <button style="flex:1;background:#f5f5f5;color:#666;border:none;border-radius:8px;height:44px;" @click="showCreateForm = false">取消</button>
          <button style="flex:1;background:#2e7d32;color:#fff;border:none;border-radius:8px;height:44px;" @click="confirmCreateProduct">确认创建</button>
        </view>
      </view>
    </view>

    <view style="display:flex;gap:10px;position:fixed;bottom:16px;left:16px;right:16px;">
      <button class="btn-draft" :loading="submitting" @click="handleSaveDraft">保存草稿</button>
      <button class="btn-submit" :loading="submitting" @click="handleSubmit">{{ editingId ? '保存并提交' : '确认入库' }}</button>
    </view>
    <FloatingHome v-if="!showWhPicker && !showPicker && !showCreateForm" />
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
.picker-header { display: flex; align-items: center; justify-content: space-between; padding: 16px; border-bottom: 1px solid #eee; }
.picker-cancel { color: #666; font-size: 14px; }
.picker-title { font-size: 16px; }
.wh-breadcrumb { display: flex; flex-wrap: wrap; gap: 4px; padding: 10px 16px; background: #f5f7fa; font-size: 13px; }
.wh-crumb { color: #2e7d32; }
.amount { font-size: 14px; color: #f56c6c; font-weight: bold; }
.btn-draft { flex:1; background:#fff; color:#666; border:1px solid #dcdfe6; border-radius:8px; height:44px; line-height:44px; font-size:15px; }
.btn-submit { flex:1; background: #2e7d32; color: #fff; border: none; border-radius: 8px; height: 44px; line-height: 44px; font-size: 15px; }
.ic-row { display: flex; align-items: center; gap: 8px; }
.scan-btn { width: 40px; height: 40px; background: #e8f5e9; border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 20px; flex-shrink: 0; }
.scan-hint { display: block; font-size: 11px; color: #999; margin-bottom: 8px; }
.picker-select:active { background: #e8f5e9; }
.picker-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); z-index: 999; display: flex; align-items: flex-end; }
.picker-modal { background: #fff; border-radius: 16px 16px 0 0; width: 100%; max-height: 70vh; display: flex; flex-direction: column; overflow: hidden; box-sizing: border-box; }
.picker-search { padding: 16px 16px 8px; }
.picker-search .search-input {
  border: 1px solid #dcdfe6; border-radius: 4px; padding: 10px 12px; }
.picker-list { padding: 0 16px 20px; max-height: 55vh; overflow-y: auto; }
.picker-item { display: flex; align-items: center; padding: 12px 0; border-bottom: 1px solid #f5f5f5; overflow: hidden; }
.picker-item:active { background: #f5f7f5; }
.stock-text { color: #999; }
.stock-text.has-stock { color: #2e7d32; font-weight:500; }
.search-btn { display:inline-block; background:#2e7d32; color:#fff; padding:8px 16px; border-radius:4px; font-size:13px; white-space:nowrap; }
.search-btn:active { opacity:0.8; }
.level-tab { display:inline-block; padding:4px 10px; border-radius:4px; font-size:12px; background:#f5f5f5; color:#666; }
.level-tab.active { background:#2e7d32; color:#fff; }
</style>
