<script setup>
import { ref, reactive, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import request, { BASE_URL } from '@/api/request'
import FloatingHome from '@/components/FloatingHome'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()

// 图片基础路径 = API 地址去掉 /api/v1（即服务器根路径）
const API_HOST = BASE_URL.replace(/\/api\/v1\/?$/, '')
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

// 多图解析：兼容旧单图和新 JSON 数组格式
function parseImages(imageUrl) {
  if (!imageUrl) return []
  if (imageUrl.startsWith('[')) { try { return JSON.parse(imageUrl) } catch { return [] } }
  return [imageUrl]
}
function serializeImages(images) {
  return images.length ? JSON.stringify(images) : ''
}
const imageList = ref([])
// 图片加载骨架：'loading' | 'loaded' | 'error'
const imgStatus = reactive({})
const editImgStatus = reactive({})
function onImgLoad(i) { imgStatus[i] = 'loaded' }
function onImgError(i) { imgStatus[i] = 'error' }
function onEditImgLoad(i) { editImgStatus[i] = 'loaded' }
function onEditImgError(i) { editImgStatus[i] = 'error' }
function resetImgStatus(count) {
  for (let i = 0; i < count; i++) { imgStatus[i] = 'loading' }
}
function resetEditImgStatus(count) {
  for (let i = 0; i < count; i++) { editImgStatus[i] = 'loading' }
}

function flattenTree(list, result = []) {
  for (const item of list) { result.push(item); if (item.children?.length) flattenTree(item.children, result) }
  return result
}

const form = ref({
  name: '', spec: '', unit: '', categoryId: null,
  purchasePrice: null, salePrice: null,
  minStock: 0, maxStock: 0, remark: '', imageUrl: '',
})

function resetForm() {
  form.value = { name: '', spec: '', unit: '', categoryId: null, purchasePrice: null, salePrice: null, minStock: 0, maxStock: 0, remark: '', imageUrl: '' }
  imageList.value = []
}

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
    resetForm()
  }
})

async function fetchDetail() {
  if (!id) return
  loading.value = true
  try {
    const pRes = await request.get(`/product/${id}`)
    product.value = pRes.data
    resetImgStatus(parseImages(pRes.data.imageUrl).length)
    resetEditImgStatus(parseImages(pRes.data.imageUrl).length)
    Object.assign(form.value, {
      name: pRes.data.name, spec: pRes.data.spec || '', unit: pRes.data.unit || '',
      categoryId: pRes.data.categoryId,
      purchasePrice: pRes.data.purchasePrice, salePrice: pRes.data.salePrice,
      minStock: pRes.data.minStock || 0, maxStock: pRes.data.maxStock || 0,
      remark: pRes.data.remark || '', imageUrl: pRes.data.imageUrl || '',
    })
    imageList.value = parseImages(pRes.data.imageUrl)
  } finally { loading.value = false }
}

function chooseImage() {
  const remain = 5 - imageList.value.length
  if (remain <= 0) { uni.showToast({ title: '最多上传5张图片', icon: 'none' }); return }
  uni.chooseImage({
    count: remain,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => {
      res.tempFilePaths.forEach(fp => uploadImage(fp))
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
      imageList.value.push(data.data)
      uni.showToast({ title: '上传成功', icon: 'success' })
    } else {
      uni.showToast({ title: data.message || '上传失败', icon: 'none' })
    }
  } catch (err) {
    uni.showToast({ title: '上传失败', icon: 'none' })
  } finally { uploading.value = false }
}

function removeImage(index) {
  imageList.value.splice(index, 1)
}

async function handleSave() {
  if (!form.value.name) { uni.showToast({ title: '商品名称不能为空', icon: 'none' }); return }
  form.value.imageUrl = serializeImages(imageList.value)
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
          <view v-if="parseImages(product.imageUrl).length" class="img-grid">
            <view v-for="(img, i) in parseImages(product.imageUrl)" :key="i" class="img-wrap">
              <view v-if="imgStatus[i] !== 'loaded'" class="img-skeleton"><text class="skeleton-text">{{ imgStatus[i] === 'error' ? '加载失败' : '图片' }}</text></view>
              <image :src="imgUrl(img)" mode="aspectFill" class="img-thumb" :class="{ 'img-hide': imgStatus[i] !== 'loaded' }" @load="onImgLoad(i)" @error="onImgError(i)" @click="uni.previewImage({urls: parseImages(product.imageUrl).map(u => imgUrl(u)), current: i})" />
            </view>
          </view>
          <view v-else class="img-placeholder">
            <text class="placeholder-text">暂无图片</text>
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
          <text class="label">商品图片（最多5张）</text>
          <view class="img-grid-edit">
            <view v-for="(img, i) in imageList" :key="i" class="img-item">
              <view v-if="editImgStatus[i] !== 'loaded'" class="img-skeleton img-edit-skeleton"><text class="skeleton-text">{{ editImgStatus[i] === 'error' ? '加载失败' : '图片' }}</text></view>
              <image :src="imgUrl(img)" mode="aspectFill" class="img-thumb-edit" :class="{ 'img-hide': editImgStatus[i] !== 'loaded' }" @load="onEditImgLoad(i)" @error="onEditImgError(i)" />
              <view class="img-del" @click="removeImage(i)">×</view>
            </view>
            <view v-if="imageList.length < 5" class="img-add" @click="chooseImage">
              <text style="font-size:24px;color:#999;">+</text>
              <text style="font-size:11px;color:#999;">添加</text>
            </view>
          </view>
          <text v-if="uploading" style="font-size:12px;color:#2e7d32;margin-top:4px;">上传中...</text>
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
.img-placeholder { width:120px;height:120px;background:#f5f5f5;border-radius:8px;margin:0 auto 12px;display:flex;align-items:center;justify-content:center; }
.placeholder-text { font-size: 13px; color: #bbb; }
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

/* 多图网格 - 查看模式 */
.img-grid { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 12px; }
.img-wrap { position: relative; width: 80px; height: 80px; }
.img-thumb { width: 80px; height: 80px; border-radius: 6px; }
.img-hide { position: absolute; opacity: 0; pointer-events: none; }

/* 多图网格 - 编辑模式 */
.img-grid-edit { display: flex; flex-wrap: wrap; gap: 8px; }
.img-item { position: relative; width: 80px; height: 80px; }
.img-edit-skeleton { position: absolute; left: 0; top: 0; }
.img-thumb-edit { width: 80px; height: 80px; border-radius: 6px; }

/* 图片骨架屏 */
.img-skeleton { width: 80px; height: 80px; border-radius: 6px; background: #f0f0f0; display: flex; align-items: center; justify-content: center; }
.skeleton-text { font-size: 12px; color: #ccc; }
.img-del { position: absolute; top: -6px; right: -6px; width: 20px; height: 20px; background: #f56c6c; color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 14px; }
.img-add { width: 80px; height: 80px; border: 1.5px dashed #dcdfe6; border-radius: 6px; display: flex; flex-direction: column; align-items: center; justify-content: center; background: #fafafa; }

.action-btn { width: 100%; border: none; border-radius: 8px; height: 44px; line-height: 44px; font-size: 16px; text-align: center; margin-top: 8px; }
.btn-edit { background: #2e7d32; color: #fff; }
.btn-save { background: #1565c0; color: #fff; }
</style>
