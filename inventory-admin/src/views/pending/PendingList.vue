<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import request from '../../api/request'
import { ElMessage, ElMessageBox } from 'element-plus'

type ModuleKey = 'purchase' | 'sales' | 'transfer' | 'stocktake'

const activeTab = ref<ModuleKey>('purchase')
const loading = ref(false)
const actionLoading = ref(false)
const list = ref<any[]>([])
const total = ref(0)
const page = ref(1)
const size = ref(10)
const searchOrderNo = ref('')
const counts = ref<Record<ModuleKey, number>>({ purchase: 0, sales: 0, transfer: 0, stocktake: 0 })

const tabs: { key: ModuleKey; label: string; api: string; status: number; statusLabel: string }[] = [
  { key: 'purchase', label: '采购入库', api: '/purchase-order/page', status: 4, statusLabel: '待审批' },
  { key: 'sales', label: '销售出库', api: '/sales-order/page', status: 4, statusLabel: '待审批' },
  { key: 'transfer', label: '库存调拨', api: '/transfer/page', status: 4, statusLabel: '待审批' },
  { key: 'stocktake', label: '库存盘点', api: '/stock-take/page', status: 0, statusLabel: '盘点中' },
]

// 加载各 tab 待审批数量
async function fetchCounts() {
  for (const tab of tabs) {
    try {
      const res = await request.get(tab.api, { params: { page: 1, size: 1, status: tab.status } })
      counts.value[tab.key] = res.data.data.total ?? 0
    } catch { counts.value[tab.key] = 0 }
  }
}

async function fetchData() {
  loading.value = true
  try {
    const tab = tabs.find(t => t.key === activeTab.value)!
    const params: any = { page: page.value, size: size.value, status: tab.status }
    if (searchOrderNo.value) params.orderNo = searchOrderNo.value
    const res = await request.get(tab.api, { params })
    let records = res.data.data.records || []
    // 按单据日期从新到旧排列
    records.sort((a: any, b: any) => {
      const da = a.orderDate || a.createTime?.substring(0, 10) || ''
      const db = b.orderDate || b.createTime?.substring(0, 10) || ''
      return db.localeCompare(da)
    })
    list.value = records
    total.value = res.data.data.total || 0
  } finally { loading.value = false }
}

function switchTab(key: ModuleKey) {
  activeTab.value = key
  page.value = 1
  searchOrderNo.value = ''
  fetchData()
}

async function handleApprove(row: any) {
  try {
    const tab = tabs.find(t => t.key === activeTab.value)!
    await ElMessageBox.confirm(`确定审核通过「${row.orderNo}」？`, { title: '审核确认', type: 'info' })
    actionLoading.value = true
    const approveApi = tab.key === 'stocktake'
      ? `/stock-take/${row.id}/approve`
      : `/${tab.key === 'purchase' ? 'purchase' : tab.key === 'sales' ? 'sales' : 'transfer'}-order/${row.id}/approve`
    await request.put(approveApi)
    ElMessage.success('审核通过')
    fetchData()
  } catch {} finally { actionLoading.value = false }
}

async function handleReject(row: any) {
  try {
    const { value } = await ElMessageBox.prompt('请输入驳回原因', {
      title: '驳回确认', type: 'warning',
      inputPlaceholder: '驳回原因（必填）',
      inputValidator: (v: string) => !!v.trim(),
      inputErrorMessage: '驳回原因不能为空',
    })
    actionLoading.value = true
    const tab = tabs.find(t => t.key === activeTab.value)!
    const rejectApi = `/${tab.key === 'purchase' ? 'purchase' : tab.key === 'sales' ? 'sales' : 'transfer'}-order/${row.id}/reject`
    await request.put(rejectApi, { reason: value })
    ElMessage.success('已驳回')
    fetchData()
  } catch {} finally { actionLoading.value = false }
}

function handleSearch() { page.value = 1; fetchData() }

function getDetailLink(row: any) {
  const m = activeTab.value
  if (m === 'purchase') return `/purchase/${row.id}`
  if (m === 'sales') return `/sales/${row.id}`
  if (m === 'transfer') return `/transfer/${row.id}`
  return `/stocktake/${row.id}`
}

const currentTab = computed(() => tabs.find(t => t.key === activeTab.value)!)

onMounted(() => { fetchCounts(); fetchData() })
</script>

<template>
  <div class="pending-page">
    <!-- Tab 切换 -->
    <div class="tab-bar">
      <div
        v-for="tab in tabs" :key="tab.key"
        class="tab-item" :class="{ active: activeTab === tab.key }"
        @click="switchTab(tab.key)"
      >
        <span>{{ tab.label }}</span>
        <el-badge v-if="counts[tab.key] > 0" :value="counts[tab.key]" type="warning" style="margin-left:6px" />
      </div>
    </div>

    <!-- 搜索 -->
    <div class="search-bar">
      <el-input v-model="searchOrderNo" placeholder="输入单号搜索" clearable style="width:240px" @keyup.enter="handleSearch" @clear="handleSearch" />
      <el-button type="primary" @click="handleSearch">查询</el-button>
    </div>

    <!-- 表格 -->
    <el-table :data="list" stripe border v-loading="loading" style="width:100%">
      <el-table-column prop="orderNo" label="单号" width="180" />
      <el-table-column label="关联方" min-width="160">
        <template #default="{ row }">
          <template v-if="activeTab === 'stocktake'">{{ row.warehouseName || '-' }}</template>
          <template v-else-if="activeTab === 'transfer'">{{ row.fromWarehouseName || '-' }} → {{ row.toWarehouseName || '-' }}</template>
          <template v-else>{{ row.supplierName || row.customerName || '-' }}</template>
        </template>
      </el-table-column>
      <el-table-column label="数量/金额" width="140">
        <template #default="{ row }">
          <template v-if="activeTab === 'stocktake'">{{ row.totalItems }} 项（差异 {{ row.diffItems }}）</template>
          <template v-else>{{ row.totalQuantity }} 件 / ¥{{ row.totalAmount?.toFixed(2) }}</template>
        </template>
      </el-table-column>
      <el-table-column prop="operatorName" label="操作人" width="100" />
      <el-table-column label="单据日期" width="120" sortable prop="orderDate">
        <template #default="{ row }">{{ row.orderDate || row.createTime?.substring(0, 10) }}</template>
      </el-table-column>
      <el-table-column label="状态" width="90">
        <template #default="{ row }">
          <el-tag type="warning" size="small">{{ currentTab.statusLabel }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="240" fixed="right">
        <template #default="{ row }">
          <el-button size="small" type="primary" @click="$router.push(getDetailLink(row))">查看</el-button>
          <el-button v-if="activeTab !== 'stocktake'" size="small" type="success" :loading="actionLoading" @click="handleApprove(row)">通过</el-button>
          <el-button v-if="activeTab !== 'stocktake'" size="small" type="warning" :loading="actionLoading" @click="handleReject(row)">驳回</el-button>
          <el-button v-if="activeTab === 'stocktake'" size="small" type="success" :loading="actionLoading" @click="handleApprove(row)">审核</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <el-pagination
      v-if="total > 0"
      v-model:current-page="page" :page-size="size" :total="total"
      layout="total, prev, pager, next" style="margin-top:16px;justify-content:flex-end"
      @current-change="fetchData"
    />
  </div>
</template>

<style scoped>
.pending-page { padding: 16px; }
.tab-bar { display: flex; gap: 0; margin-bottom: 16px; border-bottom: 2px solid #e4e7ed; }
.tab-item {
  padding: 10px 24px; cursor: pointer; font-size: 14px; color: #606266;
  border-bottom: 2px solid transparent; margin-bottom: -2px; transition: all 0.2s;
  display: flex; align-items: center;
}
.tab-item:hover { color: #409eff; }
.tab-item.active { color: #409eff; border-bottom-color: #409eff; font-weight: 600; }
.search-bar { display: flex; gap: 8px; margin-bottom: 16px; }
</style>
