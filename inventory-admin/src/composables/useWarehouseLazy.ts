import request from '../api/request'

/** el-cascader 懒加载 props —— 按需加载仓库树 */
export function useWarehouseCascaderProps() {
  return {
    lazy: true,
    checkStrictly: true,
    emitPath: false,
    lazyLoad(node: any, resolve: Function) {
      const parentId = node.level === 0 ? null : node.value
      const url = parentId ? `/warehouse/children-all/${parentId}` : '/warehouse/roots'
      request.get(url).then(res => {
        const nodes = (res.data.data || []).map((w: any) => ({
          value: w.id,
          label: w.name,
          leaf: !w.hasChildren,
        }))
        resolve(nodes)
      })
    },
  }
}
