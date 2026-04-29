import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import * as ElementPlus from 'element-plus'

vi.mock('vue-router', () => ({
  useRouter: () => ({ push: vi.fn() }),
  useRoute: () => ({ path: '/inventory' }),
}))

// Mock API responses
vi.mock('../api/request', () => ({
  default: {
    get: vi.fn((url: string) => {
      if (url.includes('/inventory/page')) {
        return Promise.resolve({
          data: {
            data: {
              records: [
                { id: 1, productId: 1, productName: '豌豆射手', productCode: 'GD001', warehouseId: 1, warehouseName: '主仓库', quantity: 88, costPrice: 12.50, updateTime: '2026-04-29T10:00:00' },
                { id: 2, productId: 1, productName: '豌豆射手', productCode: 'GD001', warehouseId: 2, warehouseName: '二号仓库', quantity: 11, costPrice: 10.00, updateTime: '2026-04-29T10:00:00' },
                { id: 3, productId: 2, productName: '向日葵', productCode: 'GD002', warehouseId: 1, warehouseName: '主仓库', quantity: 30, costPrice: 8.00, updateTime: '2026-04-28T10:00:00' },
              ],
              total: 3,
            },
          },
        })
      }
      if (url.includes('/warehouse/list')) {
        return Promise.resolve({
          data: {
            data: [
              { id: 1, name: '主仓库' },
              { id: 2, name: '二号仓库' },
            ],
          },
        })
      }
      return Promise.resolve({ data: { data: [] } })
    }),
  },
}))

describe('InventoryList.vue', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('should render title and buttons', async () => {
    const InventoryList = await import('../views/inventory/InventoryList.vue')
    const wrapper = mount(InventoryList.default, {
      global: {
        plugins: [ElementPlus, createPinia()],
      },
    })

    // 等待数据加载
    await new Promise(r => setTimeout(r, 100))
    await wrapper.vm.$nextTick()

    expect(wrapper.text()).toContain('库存查询')
  })

  it('should group inventory by warehouse', async () => {
    const InventoryList = await import('../views/inventory/InventoryList.vue')
    const wrapper = mount(InventoryList.default, {
      global: {
        plugins: [ElementPlus, createPinia()],
      },
    })

    await new Promise(r => setTimeout(r, 100))
    await wrapper.vm.$nextTick()

    const vm = wrapper.vm as any
    // 验证 computed 分组结果
    expect(vm.grouped.length).toBe(2)
    expect(vm.grouped[0].wName).toBe('主仓库')
    expect(vm.grouped[1].wName).toBe('二号仓库')
  })

  it('should calculate subtotal correctly', async () => {
    const InventoryList = await import('../views/inventory/InventoryList.vue')
    const wrapper = mount(InventoryList.default, {
      global: {
        plugins: [ElementPlus, createPinia()],
      },
    })

    await new Promise(r => setTimeout(r, 100))
    await wrapper.vm.$nextTick()

    const vm = wrapper.vm as any

    // 主仓库：豌豆88个×12.5 + 向日葵30个×8 = 1100 + 240 = 1340
    const mainWH = vm.grouped[0]
    const subtotal = vm.warehouseSubtotal(mainWH.items)
    expect(subtotal.qty).toBe(118) // 88+30
    expect(subtotal.amount).toBe(1340) // 1100+240

    // 二号仓库：豌豆11个×10 = 110
    const wh2 = vm.grouped[1]
    const subtotal2 = vm.warehouseSubtotal(wh2.items)
    expect(subtotal2.qty).toBe(11)
    expect(subtotal2.amount).toBe(110)
  })

  it('should calculate grand total correctly', async () => {
    const InventoryList = await import('../views/inventory/InventoryList.vue')
    const wrapper = mount(InventoryList.default, {
      global: {
        plugins: [ElementPlus, createPinia()],
      },
    })

    await new Promise(r => setTimeout(r, 100))
    await wrapper.vm.$nextTick()

    const vm = wrapper.vm as any
    expect(vm.grandTotal.qty).toBe(129) // 88+11+30
    expect(vm.grandTotal.amount).toBe(1450) // 1340+110
  })
})
