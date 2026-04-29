import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import * as ElementPlus from 'element-plus'
import { ElMessage } from 'element-plus'

// Mock router
vi.mock('vue-router', () => ({
  useRouter: () => ({ push: vi.fn() }),
  useRoute: () => ({ path: '/login' }),
}))

// Mock request
vi.mock('../api/request', () => ({
  default: {
    get: vi.fn(() => Promise.resolve({ data: { data: [] } })),
    post: vi.fn(() => Promise.resolve({ data: { data: { token: 'mock-token', roles: ['role_1'], isAdmin: true } } })),
  },
}))

describe('Login.vue', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    // Mock localStorage
    vi.stubGlobal('localStorage', {
      getItem: vi.fn(() => null),
      setItem: vi.fn(),
      removeItem: vi.fn(),
    })
  })

  it('should render the login form', async () => {
    const LoginPage = await import('../views/login/Login.vue')
    const wrapper = mount(LoginPage.default, {
      global: {
        plugins: [ElementPlus, createPinia()],
      },
    })

    // 应显示标题
    expect(wrapper.text()).toContain('进销存管理系统')

    // 应有两个输入框
    const inputs = wrapper.findAll('input')
    expect(inputs.length).toBeGreaterThanOrEqual(2)

    // 有登录按钮
    const btn = wrapper.find('button')
    expect(btn.exists()).toBe(true)
    expect(btn.text()).toContain('登')
  })

  it('should show warning when username is empty', async () => {
    const warnSpy = vi.spyOn(ElMessage, 'warning')

    const LoginPage = await import('../views/login/Login.vue')
    const wrapper = mount(LoginPage.default, {
      global: {
        plugins: [ElementPlus, createPinia()],
      },
    })

    // 直接调用登录（空表单）
    const vm = wrapper.vm as any
    await vm.handleLogin()

    expect(warnSpy).toHaveBeenCalledWith('请输入用户名和密码')
  })

  it('should render plant logo SVG', async () => {
    const LoginPage = await import('../views/login/Login.vue')
    const wrapper = mount(LoginPage.default, {
      global: {
        plugins: [ElementPlus, createPinia()],
      },
    })

    const svgs = wrapper.findAll('svg')
    expect(svgs.length).toBeGreaterThan(0)
  })
})
