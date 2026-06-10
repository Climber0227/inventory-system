<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import request from '../../api/request'
import type { StockTake } from '../../types/api'
import { ElMessage, ElMessageBox } from 'element-plus'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const order = ref<any>(null)
const whInventory = ref<any[]>([])
const editing = ref(false)
const addProductId = ref<string>('')

const statusMap: Record<number, { label: string; type: string }> = {
  0: { label: '盘点中', type: 'warning' },
  1: { label: '已审核', type: 'success' },
  2: { label: '已调整', type: 'info' },
}

async function fetchDetail() {
  loading.value = true
  try {
    const res = await request.get(`/stock-take/${route.params.id}`)
    order.value = res.data.data
    // 给每个明细补充库存批次的入库时间
    if (order.value?.items) {
      for (const item of order.value.items) {
        const inv = whInventory.value.find((i: any) =>
          i.productId === item.productId && i.batchNo === item.batchNo)
        if (inv) item.stockDate = inv.createTime?.substring(0, 16) || ''
      }
    }
  } catch {
    ElMessage.error('获取盘点单详情失败')
    order.value = null
  } finally { loading.value = false }
}

// 添加盘点项（抽盘用）
async function handleAddItem() {
  if (!order.value || !addProductId.value) { ElMessage.warning('请选择商品'); return }
  const parts = addProductId.value.split('|')
  const pid = Number(parts[0])
  const batchNo = parts[1] || ''

  try {
    await request.post('/stock-take/item', {
      stockTakeId: order.value.id,
      productId: pid,
      batchNo: batchNo,
      diffReason: '',
    })
    ElMessage.success('已添加')
    addProductId.value = ''
    fetchDetail()
  } catch { /* handled */ }
}

// 更新实盘数量
let updateTimer: ReturnType<typeof setTimeout>
function handleUpdateActual(item: any) {
  clearTimeout(updateTimer)
  updateTimer = setTimeout(async () => {
    if (!order.value || !item.id) return
    try {
      await request.put(`/stock-take/item/${item.id}`, {
        actualQty: item.actualQty,
        diffReason: item.diffReason || '',
      })
      // 刷新差异显示但不重新加载全部数据
      const diff = (item.actualQty || 0) - (item.bookQty || 0)
      item.diffQty = diff
    } catch { /* handled */ }
  }, 300)
}

async function handleApprove() {
  try { await ElMessageBox.confirm('确认审核通过此盘点单？审核后不可修改实盘数。', '确认审核', { type: 'warning' }) } catch { return }
  await request.put(`/stock-take/${route.params.id}/approve`)
  ElMessage.success('已审核'); fetchDetail()
}

async function handleAdjust() {
  try { await ElMessageBox.confirm('确认执行库存调整？调整后库存将根据差异自动变更。', '确认调整', { type: 'warning' }) } catch { return }
  await request.put(`/stock-take/${route.params.id}/adjust`)
  ElMessage.success('盘点调整已完成'); fetchDetail()
}

async function handleDeleteItem(itemId: number) {
  await request.delete(`/stock-take/item/${itemId}`)
  ElMessage.success('已删除'); fetchDetail()
}

const availableProducts = computed(() => {
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

async function fetchProducts() {
  try {
    if (order.value?.warehouseId) {
      const iRes = await request.get('/inventory/page', { params: { warehouseId: order.value.warehouseId, page: 1, size: 9999 } })
      whInventory.value = (iRes.data.data.records || []).filter((r: any) => r.quantity > 0)
      whInventory.value.sort((a: any, b: any) => (b.createTime || '').localeCompare(a.createTime || ''))
    }
  } catch { whInventory.value = [] }
}

onMounted(() => { fetchDetail().then(() => fetchProducts()) })
</script>

<template>
  <div v-loading="loading">
    <div class="page-header">
      <h2>盘点单详情</h2>
      <div>
        <el-button @click="router.push('/stocktake')">返回列表</el-button>
        <el-button v-if="order?.status === 0" type="primary" @click="handleApprove">审核通过</el-button>
        <el-button v-if="order?.status === 1 && (order?.diffItems || 0) > 0" type="warning" @click="handleAdjust">执行调整</el-button>
      </div>
    </div>

    <div class="detail-card" v-if="order">
      <h3>基本信息</h3>
      <el-descriptions :column="4" border>
        <el-descriptions-item label="盘点单号">{{ order.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="仓库">{{ order.warehouseName }}</el-descriptions-item>
        <el-descriptions-item label="盘点方式">{{ order.takeType === 0 ? '全盘' : '抽盘' }}</el-descriptions-item>
        <el-descriptions-item label="盘点日期">{{ order.orderDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="statusMap[order.status]?.type as any">{{ statusMap[order.status]?.label }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="盘点人">{{ order.operatorName }}</el-descriptions-item>
        <el-descriptions-item label="总商品数">{{ order.totalItems }}</el-descriptions-item>
        <el-descriptions-item label="差异数">{{ order.diffItems }}</el-descriptions-item>
        <el-descriptions-item label="审核人">{{ order.approverName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="4">{{ order.remark || '-' }}</el-descriptions-item>
      </el-descriptions>
    </div>

    <div class="detail-card" v-if="order">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
        <h3 style="margin:0;">盘点明细</h3>
        <div v-if="order.status === 0 && order.takeType === 1" style="display:flex;gap:8px;">
          <el-select v-model="addProductId" filterable placeholder="选择商品添加" style="width:260px;">
            <el-option v-for="p in availableProducts" :key="p.productId + '_' + p.stockDate + '_' + p.batchNo"
              :value="p.productId + '|' + p.batchNo" :label="`${p.productName} (${p.productCode}) ${p.qty}件 ${p.stockDate}`">
              <span style="display:flex;justify-content:space-between;width:100%;font-size:13px;">
                <span>{{ p.productName }} <span style="color:#999;">({{ p.productCode }})</span></span>
                <span style="display:flex;gap:12px;">
                  <span style="color:#2e7d32;font-weight:600;">{{ p.qty }}件</span>
                  <span style="color:#666;font-size:11px;">{{ p.stockDate }}</span>
                  <span v-if="p.batchNo" style="color:#bbb;font-size:11px;">{{ p.batchNo }}</span>
                </span>
              </span>
            </el-option>
          </el-select>
          <el-button type="primary" size="small" @click="handleAddItem">添加</el-button>
        </div>
      </div>
      <el-table :data="order.items || []" border stripe>
        <el-table-column prop="productName" label="商品" min-width="160" />
        <el-table-column prop="productCode" label="编码" width="110" />
        <el-table-column label="批次/入库时间" min-width="180">
          <template #default="{ row }">
            <span style="font-size:12px;">{{ row.batchNo || '-' }}</span>
            <span v-if="row.stockDate" style="color:#999;font-size:11px;display:block;">{{ row.stockDate }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="bookQty" label="账面数" width="80" />
        <el-table-column label="实盘数" width="100">
          <template #default="{ row }">
            <el-input-number
              v-if="order.status === 0"
              v-model="row.actualQty"
              :min="0"
              size="small"
              style="width:90px"
              @change="handleUpdateActual(row)"
            />
            <span v-else>{{ row.actualQty }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="diffQty" label="差异" width="80">
          <template #default="{ row }">
            <span :style="{ color: row.diffQty > 0 ? '#67c23a' : row.diffQty < 0 ? '#f56c6c' : '', fontWeight: 'bold' }">
              {{ row.diffQty > 0 ? '+' : '' }}{{ row.diffQty }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="差异原因" min-width="150">
          <template #default="{ row }">
            <el-input
              v-if="order.status === 0"
              v-model="row.diffReason"
              size="small"
              placeholder="填写原因"
              @blur="handleUpdateActual(row)"
            />
            <span v-else>{{ row.diffReason || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column v-if="order.status === 0" label="操作" width="90">
          <template #default="{ row }">
            <el-button size="small" type="danger" text @click="handleDeleteItem(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>
