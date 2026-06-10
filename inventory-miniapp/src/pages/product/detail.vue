<script setup>
import { ref, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import request from '@/api/request'
import FloatingHome from '@/components/FloatingHome'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()

// 图片基础路径，从 API 请求地址提取（去掉 /api/v1）
const API_HOST = 'http://192.168.10.162:8080'
function imgUrl(path) {
  if (!path) return ''
  if (path.startsWith('http')) return path
  return API_HOST + path
}

const product = ref(null)
const loading = ref(false)
const editing = ref(false)
const categories = ref([])
const flatCategories = ref([])
const uploading = ref(false)

function flattenTree(list, result = []) {
  for (const item of list) { result.push(item); if (item.children?.length) flattenTree(item.children, result) }
  return result
}

const form = ref({
  name: '', spec: '', unit: '', categoryId: null,
  purchasePrice: null, salePrice: null,
  minStock: 0, maxStock: 0, remark: '', imageUrl: '',
})

let id = null
const isCreate = ref(false)

onLoad(async (options) => {
  id = options?.id
  // 加载分类（编辑和新建都需要）
  try {
    const cRes = await request.get('/category/tree')
    categories.value = cRes.data || []
    flatCategories.value = flattenTree(categories.value)
  } catch {}
  if (id) {
    fetchDetail()
  } else {
    // 新建模式
    isCreate.value = true
    product.value = { status: 1 }
    editing.value = true
  }
})

async function fetchDetail() {
  if (!id) return
  loading.value = true
  try {
    const pRes = await request.get(`/product/${id}`)
    product.value = pRes.data
    Object.assign(form.value, {
      name: pRes.data.name, spec: pRes.data.spec || '', unit: pRes.data.unit || '',
      categoryId: pRes.data.categoryId,
      purchasePrice: pRes.data.purchasePrice, salePrice: pRes.data.salePrice,
      minStock: pRes.data.minStock || 0, maxStock: pRes.data.maxStock || 0,
      remark: pRes.data.remark || '', imageUrl: pRes.data.imageUrl || '',
    })
  } finally { loading.value = false }
}

function chooseImage() {
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => {
      const filePath = res.tempFilePaths[0]
      uploadImage(filePath)
    },
  })
}

async function uploadImage(filePath) {
  uploading.value = true
  try {
    const token = uni.getStorageSync('token')
    const res = await uni.uploadFile({
      url: API_HOST + '/api/v1/file/upload',
      filePath: filePath,
      name: 'file',
      header: { Authorization: 'Bearer ' + token },
    })
    const data = JSON.parse(res.data)
    if (data.code === 200) {
      form.value.imageUrl = data.data
      uni.showToast({ title: '上传成功', icon: 'success' })
    } else {
      uni.showToast({ title: data.message || '上传失败', icon: 'none' })
    }
  } catch (err) {
    uni.showToast({ title: '上传失败', icon: 'none' })
  } finally { uploading.value = false }
}

async function handleSave() {
  if (!form.value.name) { uni.showToast({ title: '商品名称不能为空', icon: 'none' }); return }
  loading.value = true
  try {
    if (isCreate.value) {
      await request.post('/product', form.value)
      uni.showToast({ title: '创建成功', icon: 'success' })
      uni.navigateBack()
    } else {
      await request.put(`/product/${id}`, form.value)
      uni.showToast({ title: '保存成功', icon: 'success' })
      editing.value = false
      fetchDetail()
    }
  } finally { loading.value = false }
}

function toggleEdit() {
  if (editing.value) {
    handleSave()
  } else {
    editing.value = true
  }
}
</script>

<template>
  <view class="page">
    <view v-if="loading && !product" style="text-align:center;padding:40px;color:#999;">加载中...</view>

    <view v-else-if="product">
      <view class="detail-header">
        <!-- 新建模式 -->
        <template v-if="isCreate">
          <text class="dh-name">新建商品</text>
        </template>
        <template v-else>
          <view class="img-wrap">
            <image v-if="product.imageUrl" :src="imgUrl(product.imageUrl)" mode="widthFix" class="product-img" @click="uni.previewImage({urls:[imgUrl(product.imageUrl)]})" @error="product.imageUrl = ''" />
            <view v-else class="img-placeholder" style="width:120px;height:120px;display:flex;align-items:center;justify-content:center;background:#f5f5f5;border-radius:8px;margin:0 auto 12px;">
              <text style="font-size:32px;color:#ccc;">📷</text>
            </view>
          </view>
          <text class="dh-name">{{ product.name }}</text>
          <text class="dh-code">{{ product.code }}</text>
          <view class="dh-tags">
            <text class="dh-tag" :class="product.status === 1 ? 'tag-on' : 'tag-off'">{{ product.status === 1 ? '启用' : '停用' }}</text>
            <text class="dh-tag tag-cat">{{ product.categoryName || '未分类' }}</text>
          </view>
        </template>
      </view>

      <!-- 查看模式 -->
      <view class="section" v-if="!editing">
        <view class="info-row"><text class="il">规格</text><text class="iv">{{ product.spec || '-' }}</text></view>
        <view class="info-row"><text class="il">单位</text><text class="iv">{{ product.unit || '-' }}</text></view>
        <view v-if="userStore.isAdmin" class="info-row"><text class="il">采购价</text><text class="iv price">¥{{ product.purchasePrice ?? '-' }}</text></view>
        <view class="info-row"><text class="il">销售价</text><text class="iv price">¥{{ product.salePrice ?? '-' }}</text></view>
        <view class="info-row"><text class="il">最低库存</text><text class="iv">{{ product.minStock }}</text></view>
        <view class="info-row"><text class="il">最高库存</text><text class="iv">{{ product.maxStock }}</text></view>
        <view class="info-row" style="border:none;"><text class="il">备注</text><text class="iv" style="color:#999;">{{ product.remark || '-' }}</text></view>
      </view>

      <!-- 编辑模式 -->
      <view class="section" v-if="editing">
        <!-- 图片上传 -->
        <view class="form-item">
          <text class="label">商品图片</text>
          <view class="upload-area" @click="chooseImage">
            <image v-if="form.imageUrl" :src="imgUrl(form.imageUrl)" mode="aspectFit" class="upload-preview" />
            <view v-else class="upload-trigger">
              <text style="font-size:24px;">+</text>
              <text style="font-size:11px;color:#999;margin-top:4px;">拍照或相册</text>
            </view>
            <text v-if="uploading" class="upload-mask">上传中...</text>
          </view>
        </view>
        <view class="form-item">
          <text class="label">名称 *</text>
          <input v-model="form.name" class="input" placeholder="商品名称" />
        </view>
        <view class="form-item">
          <text class="label">规格</text>
          <input v-model="form.spec" class="input" placeholder="如: L/XL/500g" />
        </view>
        <view class="form-item">
          <text class="label">单位</text>
          <input v-model="form.unit" class="input" placeholder="如: 盆/个/箱" />
        </view>
        <view class="form-item">
          <text class="label">分类</text>
          <picker @change="e => form.categoryId = flatCategories[e.detail.value]?.id" :range="flatCategories" range-key="name">
            <view class="picker">{{ flatCategories.find(c => c.id === form.categoryId)?.name || '未分类' }}</view>
          </picker>
        </view>
        <view class="form-row">
          <view v-if="userStore.isAdmin" class="form-item" style="flex:1;">
            <text class="label">采购价</text>
            <input v-model="form.purchasePrice" class="input" type="digit" placeholder="0.00" />
          </view>
          <view class="form-item" style="flex:1;">
            <text class="label">销售价</text>
            <input v-model="form.salePrice" class="input" type="digit" placeholder="0.00" />
          </view>
        </view>
        <view class="form-row">
          <view class="form-item" style="flex:1;">
            <text class="label">最低库存</text>
            <input v-model="form.minStock" class="input" type="number" placeholder="0" />
          </view>
          <view class="form-item" style="flex:1;">
            <text class="label">最高库存</text>
            <input v-model="form.maxStock" class="input" type="number" placeholder="0" />
          </view>
        </view>
        <view class="form-item">
          <text class="label">备注</text>
          <input v-model="form.remark" class="input" placeholder="备注信息" />
        </view>
      </view>

      <button v-if="userStore.isAdmin" class="action-btn" :class="editing ? 'btn-save' : 'btn-edit'" :loading="loading" @click="toggleEdit">
        {{ isCreate ? '创建商品' : editing ? '保存' : '编辑' }}
      </button>
    </view>

    <view v-else-if="!isCreate" style="text-align:center;padding:40px;color:#999;">未找到该商品</view>
    <FloatingHome />
  </view>
</template>

<style scoped>
.page { padding: 12px; background: #f5f7f5; min-height: 100vh; }
.detail-header { background: #fff; border-radius: 8px; padding: 20px 16px; text-align: center; margin-bottom: 10px; }
.img-wrap { width: 120px; height: 120px; margin: 0 auto 12px; border-radius: 8px; overflow: hidden; }
.img-placeholder { background: #f5f5f5; display: flex; align-items: center; justify-content: center; }
.product-img { width: 100%; height: 100%; }
.dh-name { font-size: 18px; font-weight: 700; display: block; }
.dh-code { font-size: 12px; color: #999; margin-top: 4px; display: block; }
.dh-tags { display: flex; justify-content: center; gap: 6px; margin-top: 8px; }
.dh-tag { font-size: 11px; padding: 2px 10px; border-radius: 4px; }
.tag-on { background: #e8f5e9; color: #2e7d32; }
.tag-off { background: #f5f5f5; color: #999; }
.tag-cat { background: #e3f2fd; color: #1565c0; }

.section { background: #fff; border-radius: 8px; padding: 16px; margin-bottom: 10px; }
.info-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #f5f5f5; font-size: 14px; }
.il { color: #999; } .iv { font-weight: 500; color: #333; } .iv.price { color: #e65100; }

.form-item { margin-bottom: 12px; }
.label { display: block; font-size: 13px; color: #333; margin-bottom: 4px; }
.input { border: 1px solid #dcdfe6; border-radius: 6px; padding: 10px 12px; font-size: 15px; background: #fff; }
.picker { border: 1px solid #dcdfe6; border-radius: 6px; padding: 14px 16px; font-size: 14px; color: #333; background: #fff; }
.form-row { display: flex; gap: 12px; }

.upload-area { width: 100px; height: 100px; position: relative; }
.upload-trigger { width: 100px; height: 100px; border: 1.5px dashed #dcdfe6; border-radius: 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; background: #fafafa; }
.upload-preview { width: 100px; height: 100px; border-radius: 8px; }
.upload-mask { position: absolute; inset: 0; background: rgba(0,0,0,0.4); color: #fff; display: flex; align-items: center; justify-content: center; border-radius: 8px; font-size: 12px; }

.action-btn { width: 100%; border: none; border-radius: 8px; height: 44px; line-height: 44px; font-size: 16px; text-align: center; margin-top: 8px; }
.btn-edit { background: #2e7d32; color: #fff; }
.btn-save { background: #1565c0; color: #fff; }
</style>
