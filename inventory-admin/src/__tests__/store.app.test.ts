import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useAppStore } from '../store/app'
import type { RouteMeta } from '../store/app'

describe('appStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('should have sidebarCollapsed default to false', () => {
    const store = useAppStore()
    expect(store.sidebarCollapsed).toBe(false)
  })

  it('should toggle sidebar', () => {
    const store = useAppStore()
    store.toggleSidebar()
    expect(store.sidebarCollapsed).toBe(true)
    store.toggleSidebar()
    expect(store.sidebarCollapsed).toBe(false)
  })

  it('should have menus defined', () => {
    const store = useAppStore()
    expect(store.menus.length).toBeGreaterThan(0)
  })

  it('should have dashboard as first menu item', () => {
    const store = useAppStore()
    expect(store.menus[0].path).toBe('/dashboard')
    expect(store.menus[0].title).toBe('工作台')
  })

  it('should have inventory with children', () => {
    const store = useAppStore()
    const inventory = store.menus.find(m => m.path === '/inventory')
    expect(inventory).toBeDefined()
    expect(inventory!.children).toBeDefined()
    expect(inventory!.children!.length).toBe(2)
    expect(inventory!.children![0].title).toBe('库存列表')
  })

  it('should not have system config in menu', () => {
    const store = useAppStore()
    const system = store.menus.find(m => m.path === '/system')
    expect(system).toBeDefined()
    expect(system!.children!.find(c => c.title === '系统配置')).toBeUndefined()
  })
})
