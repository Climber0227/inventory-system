<script setup lang="ts">
import { ref, onMounted, reactive, watch, computed } from 'vue'
import request from '../../api/request'
import type { Customer, Product } from '../../types/api'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRoute, useRouter, onBeforeRouteLeave } from 'vue-router'

const router = useRouter()
const route = useRoute()
const isEdit = ref(false)
const orderId = ref<number | null>(null)
const submitting = ref(false)
const warehouseTree = ref<any[]>([])
const customers = ref<Customer[]>([])
const products = ref<Product[]>([])
const whInventory = ref<any[]>([]) // 当前仓库的库存明细
const allWhInventory = ref<any[]>([]) // 多仓库模式下所有仓库的库存
const batchInventory = ref<Record<number, Array<{batchNo: string; quantity: number}>>>({})
const warehouseStock = ref<Record<number, number>>({})
const productStock = ref<Record<number, number>>({})
const dirty = ref(false)
const saved = ref(false)
const multiWarehouse = ref(false) // 多仓库出库模式
const isChildOrder = ref(false)  // 拆出来的子订单，禁止再拆
const itemWhInventories = ref<Record<number, any[]>>({}) // 每行对应仓库的库存
const allWarehouses = ref<any[]>([]) // 所有叶子仓库列表（用于快速选择）

// 当前仓库库存明细（每个入库批次一行，不聚合）
const availableProducts = computed(() => {
  if (!form.warehouseId) return []
  return whInventory.value
    .filter((inv: any) => inv.productId && (inv.quantity || 0) > 0)
    .map((inv: any) => ({
      productId: inv.productId,
      productName: inv.productName || '',
      productCode: inv.productCode || '',
      qty: inv.quantity || 0,
      batchNo: inv.batchNo || '',
      stockDate: inv.createTime?.substring(0, 16) || '',
    }))
})

const selectedCustomer = computed(() =>
  customers.value.find(c => c.id === form.customerId)
)

const form = reactive({
  customerId: undefined as number | undefined,
  warehouseId: undefined as number | undefined,
  salesman: '',
  externalOrderNo: '',
  orderDate: new Date().toISOString().slice(0, 10),
  remark: '',
  items: [] as Array<{
    productId: number | undefined
    productName: string
    quantity: number
    unitPrice: number | null
    amount: number | null
    batchNo: string
    remark: string
    warehouseId: number | undefined  // 多仓库模式每行独立仓库
  }>,
})

async function fetchWarehouseTree() {
  const res = await request.get('/warehouse/tree?stats=false')
  warehouseTree.value = res.data.data
}

async function onWarehouseChange(val: number) {
  form.warehouseId = val
  // whInventory 由 form.warehouseId watcher 统一加载
}

async function fetchBase() {
  const [cRes, pRes] = await Promise.all([
    request.get('/customer/list'),
    request.get('/product/list'),
    loadAllInventory(),
  ])
  customers.value = cRes.data.data
  products.value = pRes.data.data
  await fetchWarehouseTree()
}

function addItem() {
  form.items.push({ productId: undefined, productName: '', quantity: 1, unitPrice: null, amount: null, batchNo: '', remark: '', warehouseId: undefined })
}

// 加载所有仓库的库存（多仓库模式）
async function loadAllInventory() {
  try {
    const res = await request.get('/inventory/page', { params: { page: 1, size: 99999 } })
    allWhInventory.value = (res.data.data.records || []).filter((r: any) => (r.quantity || 0) > 0)
  } catch { allWhInventory.value = [] }
}

// 多仓库模式下每行仓库变更
async function onItemWarehouseChange(whId: number, index: number) {
  form.items[index].warehouseId = whId
  form.items[index].productId = undefined
  form.items[index].productName = ''
  form.items[index].batchNo = ''
  if (whId) {
    const inv = allWhInventory.value.filter((r: any) => r.warehouseId === whId)
    inv.sort((a: any, b: any) => (b.createTime || '').localeCompare(a.createTime || ''))
    itemWhInventories.value[index] = inv
  } else {
    itemWhInventories.value[index] = []
  }
}
function removeItem(index: number) { form.items.splice(index, 1) }
function calcAmount(index: number) {
  const item = form.items[index]
  if (item.quantity && item.unitPrice != null) item.amount = item.quantity * item.unitPrice
}

async function fetchBatchInventory(productId: number, warehouseId: number) {
  if (!productId || !warehouseId) return
  try {
    const res = await request.get('/inventory/page', {
      params: { productId, warehouseId, page: 1, size: 100 }
    })
    batchInventory.value[productId] = (res.data.data.records || [])
      .filter((r: any) => r.batchNo && r.quantity > 0)
      .map((r: any) => ({ batchNo: r.batchNo, quantity: r.quantity }))
  } catch { /* ignore */ }
}

async function onProductSelect(key: string, index: number) {
  if (index < 0 || index >= form.items.length) return
  const parts = key.split('|')
  const productId = Number(parts[0])
  const batchNo = parts[1] || ''
  form.items[index].productId = productId
  form.items[index].batchNo = batchNo
  const item = form.items[index]

  // 检查是否与其他行重复
  const dupIndex = form.items.findIndex((it, i) => i !== index && it.productId === productId)
  if (dupIndex !== -1) {
    try {
      await ElMessageBox.confirm('该商品已在明细中，确定再次添加？', '重复商品', { type: 'warning' })
    } catch {
      form.items[index].productId = undefined
      form.items[index].batchNo = ''
      return
    }
  }

  // 从产品列表中取售价
  const product = products.value.find(p => p.id === productId)
  if (product && product.salePrice != null) {
    item.unitPrice = product.salePrice
  }
  // 自动填商品名
  const invList = multiWarehouse.value ? (itemWhInventories.value[index] || []) : whInventory.value
  const ap = invList.find((p: any) => p.productId === productId)
  if (ap) item.productName = ap.productName || ap.product?.name
  calcAmount(index)
}

function disabledDate(time: Date) {
  return time.getTime() > Date.now()
}

async function handleSave() {
  if (submitting.value) return
  if (!multiWarehouse.value && !form.warehouseId) { ElMessage.warning('请选择仓库或启用多仓库出库'); return }
  if (form.items.length === 0) { ElMessage.warning('请添加商品'); return }
  submitting.value = true
  try {
    if (isEdit.value && orderId.value) {
      await request.put(`/sales-order/${orderId.value}/draft`, form)
      ElMessage.success('更新成功')
    } else {
      const res = await request.post('/sales-order', form)
      const data = res.data.data
      const ids: number[] = data.ids || [data]
      if (ids.length > 1) {
        ElMessage.success(`已拆为 ${ids.length} 张出库单（草稿）`)
      } else {
        ElMessage.success('保存成功（草稿）')
      }
    }
    saved.value = true; router.push('/sales')
  } finally { submitting.value = false }
}

async function handleSubmit() {
  if (submitting.value) return
  if (!multiWarehouse.value && !form.warehouseId) { ElMessage.warning('请选择仓库或启用多仓库出库'); return }
  if (form.items.length === 0) { ElMessage.warning('请添加商品'); return }
  for (let i = 0; i < form.items.length; i++) {
    const item = form.items[i]
    if (!item.productId) { ElMessage.warning(`第 ${i + 1} 行请选择商品`); return }
    if (!item.quantity || item.quantity <= 0) { ElMessage.warning(`第 ${i + 1} 行数量必须大于0`); return }
    if (item.unitPrice == null || item.unitPrice < 0) { ElMessage.warning(`第 ${i + 1} 行请输入有效售价`); return }
    if (multiWarehouse.value && !item.warehouseId) { ElMessage.warning(`第 ${i + 1} 行请选择仓库`); return }
  }
  const totalQty = form.items.reduce((s, i) => s + i.quantity, 0)
  const totalAmt = form.items.reduce((s, i) => s + (i.amount || 0), 0)
  submitting.value = true
  try { await ElMessageBox.confirm(`确认出库？共 ${form.items.length} 种 ${totalQty} 件，总金额 ¥${totalAmt.toFixed(2)}\n\n提交后将进入审批状态，请联系管理员审批通过。`, '确认出库', { type: 'warning' }) } catch { submitting.value = false; return }
  try {
    let ids: number[] = []
    if (isEdit.value && orderId.value) {
      await request.put(`/sales-order/${orderId.value}/draft`, form)
      ids = [orderId.value]
    } else {
      const res = await request.post('/sales-order', form)
      const data = res.data.data
      ids = data.ids || [data]
    }
    // 逐张提交
    for (const id of ids) {
      await request.put(`/sales-order/${id}/submit`)
    }
    const tip = ids.length > 1 ? `已拆为 ${ids.length} 张出库单并提交审批` : '出库成功'
    ElMessage.success(tip); saved.value = true; router.push('/sales')
  } finally { submitting.value = false }
}

onBeforeRouteLeave(async (to, from, next) => {
  if (!dirty.value || saved.value) { next(); return }
  try { await ElMessageBox.confirm('表单尚未保存，确定离开？', '未保存的更改', { type: 'warning' }); next() } catch { next(false) }
})

watch(form, () => { if (!saved.value) dirty.value = true }, { deep: true })

watch(multiWarehouse, (on) => {
  if (on) { form.warehouseId = undefined as any; whInventory.value = [] }
})

watch(() => form.warehouseId, async (whId) => {
  if (whId) {
    try {
      const res = await request.get('/inventory/page', { params: { warehouseId: whId, page: 1, size: 1000 } })
      const records = res.data.data.records || []
      // 明细库存（用于商品下拉选择）
      whInventory.value = records
        .filter((r: any) => (r.quantity || 0) > 0)
        .sort((a: any, b: any) => (b.createTime || '').localeCompare(a.createTime || ''))
      // 聚合库存（用于显示总库存数）
      const stock: Record<number, number> = {}
      for (const r of records) {
        const pid = r.productId
        stock[pid] = (stock[pid] || 0) + (r.quantity || 0)
      }
      warehouseStock.value = stock
    } catch { whInventory.value = []; warehouseStock.value = {} }
  } else {
    whInventory.value = []
    warehouseStock.value = {}
  }
})

onMounted(async () => {
  await fetchBase()
  const editId = route.query.edit
  if (editId) {
    try {
      const res = await request.get(`/sales-order/${editId}`)
      const data = res.data.data
      if (data.status === 0) {
        isEdit.value = true
        orderId.value = data.id
        if (data.parentOrderNo) { multiWarehouse.value = false; isChildOrder.value = true }
        form.customerId = data.customerId
        form.warehouseId = data.warehouseId
        form.salesman = data.salesman || ''
        form.externalOrderNo = data.externalOrderNo || ''
        form.orderDate = data.orderDate || new Date().toISOString().slice(0, 10)
        form.remark = data.remark || ''
        form.items = (data.items || []).map((item: any) => ({
          productId: item.productId,
          productName: item.productName || '',
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          amount: item.amount,
          batchNo: item.batchNo || '',
          remark: item.remark || '',
          warehouseId: data.warehouseId,
        }))
      }
    } catch { /* 非草稿或不存在 */ }
  }
})
</script>

<template>
  <div>
    <div class="page-header"><h2>{{ isEdit ? '编辑出库单' : '新建出库单' }}</h2></div>
    <div class="detail-card">
      <el-form :model="form" label-width="100px">
        <el-row :gutter="24">
          <el-col :span="8">
            <el-form-item label="客户" required>
              <div style="display:flex;gap:8px;width:100%;">
                <el-select v-model="form.customerId" filterable style="flex:1" placeholder="选择客户">
                  <el-option v-for="c in customers" :key="c.id" :label="c.name" :value="c.id" />
                </el-select>
                <div v-if="form.customerId" style="display:flex;align-items:center;gap:8px;white-space:nowrap;font-size:13px;color:#666;line-height:32px;">
                  <span>{{ selectedCustomer?.contact || '-' }}</span>
                  <span style="color:#999;">|</span>
                  <span>{{ selectedCustomer?.phone || '-' }}</span>
                </div>
              </div>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item :label="multiWarehouse ? '默认仓库' : '仓库'" :required="!multiWarehouse">
              <div style="display:flex;align-items:center;gap:8px;">
                <el-cascader
                  v-model="form.warehouseId"
                  :options="warehouseTree"
                  :props="{ value: 'id', label: 'name', children: 'children', emitPath: false, checkStrictly: false }"
                  :placeholder="multiWarehouse ? '每行可独立选择' : '选择仓库'"
                  :disabled="multiWarehouse"
                  filterable
                  clearable
                  style="flex:1"
                  @change="onWarehouseChange"
                >
                  <template #default="{ data }">
                    <span>{{ data.name }}</span>
                    <el-tag v-if="data.children?.length" size="small" type="info" effect="plain" style="margin-left:6px;">虚拟</el-tag>
                  </template>
                </el-cascader>
                <el-checkbox v-model="multiWarehouse" :disabled="isChildOrder || form.items.length > 0" style="white-space:nowrap;">多仓库出库</el-checkbox>
              </div>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="出库日期">
              <el-date-picker v-model="form.orderDate" type="date" value-format="YYYY-MM-DD" style="width:100%" :disabled-date="disabledDate" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="24">
          <el-col :span="8">
            <el-form-item label="销售员"><el-input v-model="form.salesman" /></el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="外部单号"><el-input v-model="form.externalOrderNo" /></el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="备注"><el-input v-model="form.remark" /></el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </div>
    <div class="detail-card">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
        <h3>商品明细</h3>
        <el-button type="primary" size="small" @click="addItem">+ 添加商品</el-button>
      </div>
      <div v-if="multiWarehouse" style="background:#e8f5e9;border:1px solid #a5d6a7;border-radius:6px;padding:10px 14px;margin-bottom:12px;font-size:13px;color:#2e7d32;line-height:1.8;">
        💡 <b>多仓库出库模式</b>：每行商品独立选择出库仓库，提交后自动拆分为多张出库单，各自独立审批。<br/>
        ⚠️ 注意：拆分后的子订单<b>不可合并、不可再拆</b>，请确认每行仓库无误后再提交。
      </div>
      <div style="color:#f56c6c;font-size:13px;margin-bottom:12px;">已自动填充销售价，支持手动修改，修改后请务必核实单价</div>
      <el-table :data="form.items" border stripe>
        <el-table-column v-if="multiWarehouse" label="出库仓库" width="220">
          <template #default="{ $index }">
            <el-cascader
              v-model="form.items[$index].warehouseId"
              :options="warehouseTree"
              :props="{ value: 'id', label: 'name', children: 'children', emitPath: false, checkStrictly: false }"
              placeholder="选择仓库"
              filterable
              clearable
              style="width:100%"
              @change="(val: any) => onItemWarehouseChange(val, $index)"
            />
          </template>
        </el-table-column>
        <el-table-column label="商品" min-width="200">
          <template #default="{ $index }">
            <template v-if="multiWarehouse">
              <el-select :model-value="form.items[$index].productId ? (form.items[$index].productId + '|' + form.items[$index].batchNo) : ''"
                filterable :placeholder="form.items[$index].warehouseId ? '选择商品' : '请先选仓库'" style="width:100%"
                :disabled="!form.items[$index].warehouseId"
                @change="(val: any) => onProductSelect(val, $index)">
                <el-option v-for="p in (itemWhInventories[$index] || [])" :key="p.productId + '_' + (p.stockDate || '') + '_' + (p.batchNo || '')"
                  :value="p.productId + '|' + p.batchNo" :label="(p.productName || '') + ' (' + (p.productCode || '') + ') 库存' + (p.quantity || 0) + '件 ' + (p.createTime?.substring(0, 16) || '')">
                  <span style="display:flex;justify-content:space-between;width:100%;font-size:13px;">
                    <span>{{ p.productName || '' }} <span style="color:#999;">({{ p.productCode || '' }})</span></span>
                    <span style="display:flex;gap:12px;align-items:center;">
                      <span style="color:#2e7d32;font-weight:600;">{{ p.quantity || 0 }}件</span>
                      <span style="color:#666;font-size:11px;">{{ (p.createTime || '').substring(0, 16) }}</span>
                      <span v-if="p.batchNo" style="color:#bbb;font-size:11px;">{{ p.batchNo }}</span>
                    </span>
                  </span>
                </el-option>
                <el-option v-if="!form.items[$index].warehouseId" value="" disabled label="请先选择仓库" />
              </el-select>
            </template>
            <template v-else>
              <el-select :model-value="form.items[$index].productId ? (form.items[$index].productId + '|' + form.items[$index].batchNo) : ''"
                filterable placeholder="请先选择仓库" style="width:100%" :disabled="!form.warehouseId"
                @change="(val: any) => onProductSelect(val, $index)">
                <el-option v-for="p in availableProducts" :key="p.productId + '_' + p.stockDate + '_' + p.batchNo"
                  :value="p.productId + '|' + p.batchNo" :label="p.productName + ' (' + p.productCode + ') 库存' + p.qty + '件 ' + p.stockDate">
                  <span style="display:flex;justify-content:space-between;width:100%;font-size:13px;">
                    <span>{{ p.productName }} <span style="color:#999;">({{ p.productCode }})</span></span>
                    <span style="display:flex;gap:12px;align-items:center;">
                      <span style="color:#2e7d32;font-weight:600;">{{ p.qty }}件</span>
                      <span style="color:#666;font-size:11px;">{{ p.stockDate }}</span>
                      <span v-if="p.batchNo" style="color:#bbb;font-size:11px;">{{ p.batchNo }}</span>
                    </span>
                  </span>
                </el-option>
                <el-option v-if="availableProducts.length === 0 && form.warehouseId" value="" disabled label="该仓库暂无库存" />
              </el-select>
            </template>
          </template>
        </el-table-column>
        <el-table-column label="数量" width="180">
          <template #default="{ $index }">
            <el-input-number v-model="form.items[$index].quantity" :min="1" style="width:100%" @change="calcAmount($index)" />
          </template>
        </el-table-column>
        <el-table-column label="售价" width="180">
          <template #default="{ $index }">
            <el-input-number v-model="form.items[$index].unitPrice" :precision="2" :min="0" style="width:100%" @change="calcAmount($index)" />
          </template>
        </el-table-column>
        <el-table-column label="金额" width="180">
          <template #default="{ $index }">¥{{ (form.items[$index].amount ?? 0).toFixed(2) }}</template>
        </el-table-column>
        <!-- 批次已禁用 -->
        <!-- <el-table-column label="批次/库存" width="200">
          <template #default="{ $index }">
            <el-select v-model="form.items[$index].batchNo" filterable allow-create clearable placeholder="自动FIFO" style="width:100%">
              <el-option
                v-for="b in (batchInventory[form.items[$index].productId ?? 0] || [])"
                :key="b.batchNo"
                :label="`${b.batchNo} (余${b.quantity})`"
                :value="b.batchNo"
              />
            </el-select>
          </template>
        </el-table-column> -->
        <el-table-column label="操作" width="80" fixed="right">
          <template #default="{ $index }"><el-button size="small" type="danger" @click="removeItem($index)">删除</el-button></template>
        </el-table-column>
      </el-table>
    </div>
    <div style="display:flex;gap:12px;justify-content:flex-end">
      <el-button @click="router.push('/sales')">返回</el-button>
      <el-button :loading="submitting" @click="handleSave">保存草稿</el-button>
      <el-button type="primary" :loading="submitting" @click="handleSubmit">提交审批</el-button>
    </div>
  </div>
</template>
