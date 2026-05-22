# 系统使用说明页面 实现计划

> **面向 AI 代理的工作者：** 必需子技能：使用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 逐任务实现此计划。步骤使用复选框（`- [ ]`）语法来跟踪进度。

**目标：** 在 Web 管理端新增一个「使用说明」独立页面，以左侧目录树+右侧内容区的布局，涵盖所有 14 个模块的详细操作指南。

**架构：** 纯前端静态页面，所有内容存放在 guideData.ts 中，HelpGuide.vue 负责渲染布局和交互。无需后端接口。

**技术栈：** Vue 3 + TypeScript + Element Plus

**涉及文件：**
- 创建：`src/views/help/HelpGuide.vue`
- 创建：`src/views/help/data/guideData.ts`
- 修改：`src/router/index.ts`
- 修改：`src/store/app.ts`

---

### 任务 1：创建内容数据文件 guideData.ts

**文件：**
- 创建：`src/views/help/data/guideData.ts`

定义数据结构并编写全部 14 个章节的静态内容。

- [ ] **步骤 1：定义数据类型并导出完整内容数据**

```ts
// src/views/help/data/guideData.ts

export interface ContentBlock {
  type: 'text' | 'table' | 'flow' | 'note' | 'warning'
  title?: string
  /** type=text/note/warning 时使用 */
  body?: string
  /** type=table 时使用 */
  headers?: string[]
  rows?: string[][]
  /** type=flow 时使用：状态流转描述 */
  steps?: { from: string; arrow: string; to: string; desc?: string }[]
}

export interface GuideSection {
  id: string
  title: string
  content: ContentBlock[]
}

export interface NavItem {
  id: string
  title: string
  icon?: string
  children?: { id: string; title: string }[]
}

/** 左侧导航树结构 */
export const navTree: NavItem[] = [
  { id: 'dashboard', title: '工作台', icon: 'Odometer' },
  {
    id: 'product', title: '商品管理', icon: 'Goods',
    children: [
      { id: 'product-list', title: '商品列表' },
      { id: 'product-category', title: '商品分类' },
    ],
  },
  { id: 'supplier', title: '供应商管理', icon: 'UserFilled' },
  { id: 'customer', title: '客户管理', icon: 'Avatar' },
  { id: 'warehouse', title: '仓库管理', icon: 'HomeFilled' },
  { id: 'purchase', title: '采购入库', icon: 'Download' },
  { id: 'sales', title: '销售出库', icon: 'Upload' },
  {
    id: 'inventory', title: '库存管理', icon: 'List',
    children: [
      { id: 'inventory-list', title: '库存列表' },
      { id: 'inventory-log', title: '库存流水' },
    ],
  },
  { id: 'stocktake', title: '库存盘点', icon: 'Search' },
  { id: 'transfer', title: '库存调拨', icon: 'Refresh' },
  { id: 'report', title: '统计报表', icon: 'DataAnalysis' },
  {
    id: 'system', title: '系统管理', icon: 'Setting',
    children: [
      { id: 'system-user', title: '员工管理' },
      { id: 'system-log', title: '操作日志' },
      { id: 'system-config', title: '系统配置' },
      { id: 'system-recycle', title: '已作废列表' },
    ],
  },
  { id: 'permission', title: '权限说明', icon: 'Lock' },
  { id: 'faq', title: '常见问题', icon: 'Warning' },
]

/** 各章节内容（以 id 为 key 的映射表） */
export const sections: Record<string, GuideSection> = {
  dashboard: {
    id: 'dashboard', title: '工作台',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '工作台是登录系统后的默认页面，展示核心经营数据的实时概览。包含统计卡片、快捷操作入口、趋势图表、最近动态和库存预警五个区域，帮助您快速了解当前运营状况。',
      },
      {
        type: 'table', title: '统计卡片说明',
        headers: ['卡片', '含义', '更新时机'],
        rows: [
          ['商品总数', '系统中所有商品的数量（含启用和停用）', '新增/删除商品后'],
          ['仓库数量', '系统中所有仓库的数量', '新增/删除仓库后'],
          ['今日入库', '今日采购入库的单数和总件数', '每次入库审核通过后'],
          ['今日出库', '今日销售出库的单数和总件数', '每次出库审核通过后'],
        ],
      },
      {
        type: 'text', title: '图表区域',
        body: '图表区展示近 30 天的每日入库/出库趋势图，以及本月累计入库/出库曲线。鼠标悬停可查看具体数据。如需更详细的数据分析，请前往「统计报表」模块。',
      },
      {
        type: 'text', title: '快捷操作',
        body: '快捷操作区提供常用功能的快速入口，包括：新建入库单、新建出库单、新建盘点单、新建调拨单，以及商品管理、库存查看、统计报表等跳转链接。',
      },
      {
        type: 'text', title: '最近动态',
        body: '展示系统最近的操作日志，包括操作人、操作模块和操作内容。方便追踪谁在什么时间做了什么操作。完整日志请查看「系统管理 > 操作日志」。',
      },
      {
        type: 'warning', title: '库存预警',
        body: '当商品库存低于设置的安全库存（minStock）时，该商品会出现在库存预警列表中。预警数字显示当前低于安全库存的商品种类数。点击「查看全部」可跳转到库存列表查看详情。',
      },
    ],
  },
  'product-list': {
    id: 'product-list', title: '商品列表',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '商品列表是管理系统所有商品资料的页面，支持增删改查、导入导出、条码打印等功能。商品信息是整个系统的基础数据，采购入库、销售出库、库存盘点等操作都依赖商品数据。',
      },
      {
        type: 'table', title: '字段释义',
        headers: ['字段', '说明', '是否必填'],
        rows: [
          ['编码', '商品的唯一标识，支持扫码枪输入', '必填'],
          ['名称', '商品名称，用于搜索和显示', '必填'],
          ['规格', '商品的规格型号，如"500ml/瓶"', '选填'],
          ['单位', '计量单位，如"个/箱/kg"', '必填'],
          ['分类', '商品所属分类，树形结构', '选填'],
          ['采购价', '商品的采购单价', '选填'],
          ['销售价', '商品的销售单价', '选填'],
          ['安全库存', '库存预警阈值，低于此值会触发预警', '选填，默认0'],
          ['上限库存', '库存上限，超过此值会提示', '选填，默认0'],
          ['状态', '启用/停用，停用的商品在新建单据时不可选', '—'],
        ],
      },
      {
        type: 'text', title: '操作说明',
        body: '• 新建：点击「新建商品」按钮，填写表单后保存。\n• 编辑：点击行末「编辑」按钮修改商品信息。\n• 复制：点击「复制」可基于当前商品快速创建新的商品。\n• 条码：点击「条码」可查看该商品的条形码图片，支持打印。\n• 批量打印条码：选中多个商品后点击「打印条码」可批量下载条码 ZIP 包。\n• 停用/启用：点击「停用」按钮，商品将不再出现在单据的商品选择列表中。\n• 删除：点击「删除」按钮，确认后删除（仅管理员可操作）。',
      },
      {
        type: 'note', title: '导入说明',
        body: '点击「导入Excel」可批量导入商品数据。导入前请下载模板，按模板格式填写后上传。导入时会校验编码是否重复，重复编码的商品会被跳过。',
      },
    ],
  },
  'product-category': {
    id: 'product-category', title: '商品分类',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '商品分类采用树形结构，支持多级分类（最多三级）。合理设置分类有助于商品管理和数据统计。',
      },
      {
        type: 'text', title: '操作说明',
        body: '• 新建：点击「新建分类」按钮，填写名称并选择父级分类。\n• 编辑：点击分类后的编辑图标修改名称。\n• 删除：删除分类前需确保该分类下没有子分类和商品。',
      },
    ],
  },
  supplier: {
    id: 'supplier', title: '供应商管理',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '供应商管理模块用于维护企业的供应商信息。供应商数据在采购入库单中使用，新建采购入库单时需选择供应商。',
      },
      {
        type: 'table', title: '字段释义',
        headers: ['字段', '说明', '是否必填'],
        rows: [
          ['名称', '供应商名称', '必填'],
          ['联系人', '供应商联系人姓名', '选填'],
          ['联系电话', '联系人的电话号码', '选填'],
          ['地址', '供应商地址', '选填'],
          ['备注', '其他补充信息', '选填'],
        ],
      },
      {
        type: 'note',
        body: '新建和编辑供应商仅管理员可操作。普通员工只能查看和搜索供应商列表。',
      },
    ],
  },
  customer: {
    id: 'customer', title: '客户管理',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '客户管理模块用于维护企业的客户信息。客户数据在销售出库单中使用，新建销售出库单时需选择客户。',
      },
      {
        type: 'table', title: '字段释义',
        headers: ['字段', '说明', '是否必填'],
        rows: [
          ['名称', '客户名称', '必填'],
          ['联系人', '客户联系人姓名', '选填'],
          ['联系电话', '联系人的电话号码', '选填'],
          ['地址', '客户地址', '选填'],
          ['备注', '其他补充信息', '选填'],
        ],
      },
      {
        type: 'note',
        body: '新建和编辑客户仅管理员可操作。普通员工只能查看和搜索客户列表。',
      },
    ],
  },
  warehouse: {
    id: 'warehouse', title: '仓库管理',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '仓库管理模块用于维护企业的仓库信息。系统支持多级仓库结构，最多可设置 4 级层级（如：总仓 → 区域仓 → 门店仓 → 货架位）。合理的仓库层级有助于精细化管理库存。',
      },
      {
        type: 'table', title: '仓库层级说明',
        headers: ['级别', '名称示例', '说明'],
        rows: [
          ['1级', '总仓库', '最高层级，通常代表企业总仓或总部仓'],
          ['2级', '区域中心仓', '按区域划分的中心仓库'],
          ['3级', '门店仓/分拣仓', '具体门店或分拣区域'],
          ['4级', '货架位/库位', '最细粒度的库位管理'],
        ],
      },
      {
        type: 'text', title: '操作说明',
        body: '• 新建：点击「新建仓库」，填写名称并选择上级仓库。上级仓库为空时为 1 级仓库。\n• 编辑：修改仓库名称或上级关系。\n• 注意：删除仓库前需确保仓库中没有库存记录。',
      },
      {
        type: 'warning',
        body: '仓库层级一旦建立并产生库存数据后，不建议随意调整上级关系，以免影响历史数据的统计。',
      },
    ],
  },
  purchase: {
    id: 'purchase', title: '采购入库',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '采购入库是管理商品入库的核心模块。支持从创建草稿到提交审批、审核入库的完整流程。包含列表页（搜索/筛选/导出）、新建/编辑页、详情页。',
      },
      {
        type: 'text', title: '列表页操作',
        body: '列表页展示所有采购入库单，支持以下操作：\n• 搜索筛选：按入库单号、供应商、仓库、状态、日期范围、数量范围筛选。\n• 导出：点击「导出Excel」导出当前列表数据；选中单据后点击「批量导出」仅导出选中的数据。\n• 批量作废：选中多个单据后批量作废（仅管理员）。\n• 单据操作：详情查看、编辑（草稿状态）、审核通过/驳回（待审批状态，仅管理员）、取消、作废。\n• 列表底部显示合计行，汇总总数量和总金额。',
      },
      {
        type: 'table', title: '状态流转说明',
        headers: ['当前状态', '可执行操作', '下一状态'],
        rows: [
          ['草稿(0)', '编辑 / 提交 / 取消 / 作废', '待审批(4) / 已取消(2) / 已作废(3)'],
          ['待审批(4)', '审核通过 / 驳回', '已入库(1) / 草稿(0)'],
          ['已入库(1)', '取消入库', '已取消(2)'],
          ['已取消(2)', '作废（需填写原因）', '已作废(3)'],
          ['已作废(3)', '仅可查看', '—'],
        ],
      },
      {
        type: 'flow', title: '状态流转图',
        steps: [
          { from: '草稿', arrow: '→', to: '待审批', desc: '提交审批' },
          { from: '草稿', arrow: '→', to: '已取消', desc: '取消' },
          { from: '草稿', arrow: '→', to: '已作废', desc: '管理员作废' },
          { from: '待审批', arrow: '→', to: '已入库', desc: '管理员审核通过，更新库存' },
          { from: '待审批', arrow: '→', to: '草稿', desc: '管理员驳回，退回草稿' },
          { from: '已入库', arrow: '→', to: '已取消', desc: '取消入库（库存回滚）' },
          { from: '已取消', arrow: '→', to: '已作废', desc: '管理员作废' },
        ],
      },
      {
        type: 'text', title: '新建/编辑入库单',
        body: '• 供应商：从已维护的供应商列表中选择。\n• 仓库：从仓库树中选择目标仓库（必须是叶子节点）。\n• 商品明细：点击「+ 添加」新增行，选择商品、填写数量和单价，系统自动计算金额。\n• 保存草稿：仅保存为草稿状态，不进入审批流程。\n• 确认入库：保存并提交审批，进入待审批状态。',
      },
      {
        type: 'warning', title: '审核注意事项',
        body: '• 审核通过后将更新对应仓库的库存数量。\n• 审核通过后不可撤回，如需调整请使用「取消入库」操作。\n• 取消入库会回滚库存，但仅限于已入库状态。',
      },
    ],
  },
  sales: {
    id: 'sales', title: '销售出库',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '销售出库是管理商品出库的核心模块，与采购入库流程类似。包含列表页、新建/编辑页、详情页，支持从草稿到审批出库的完整流程。',
      },
      {
        type: 'text', title: '列表页操作',
        body: '列表页展示所有销售出库单。支持按出库单号、客户、仓库、状态、销售员、数量金额范围、日期范围筛选。其他操作（导出、批量作废、审核等）与采购入库一致。',
      },
      {
        type: 'table', title: '状态流转说明',
        headers: ['当前状态', '可执行操作', '下一状态'],
        rows: [
          ['草稿(0)', '编辑 / 提交 / 取消 / 作废', '待审批(4) / 已取消(2) / 已作废(3)'],
          ['待审批(4)', '审核通过 / 驳回', '已出库(1) / 草稿(0)'],
          ['已出库(1)', '取消出库', '已取消(2)'],
          ['已取消(2)', '作废（需填写原因）', '已作废(3)'],
          ['已作废(3)', '仅可查看', '—'],
        ],
      },
      {
        type: 'text', title: '新建/编辑出库单',
        body: '• 客户：从已维护的客户列表中选择。\n• 仓库：选择出库仓库（叶子节点）。\n• 销售员：填写销售员姓名（选填）。\n• 商品明细：添加商品后，单价默认取自商品资料中的销售价，可手动修改。\n• 系统会自动校验商品在所选仓库中的可用库存，库存不足将无法提交（库存不足时以草稿保存）。',
      },
      {
        type: 'warning',
        body: '• 审核通过后将扣减对应仓库的库存，请确保库存充足。\n• 已出库的订单取消出库后，库存会加回原仓库。',
      },
    ],
  },
  'inventory-list': {
    id: 'inventory-list', title: '库存列表',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '库存列表以仓库树的形式展示所有仓库的库存情况。支持按商品名称/编码搜索，按仓库筛选。树形结构可按层级展开/折叠，直观查看每个仓库下的库存明细。',
      },
      {
        type: 'text', title: '页面说明',
        body: '• 左侧树：按仓库层级展示（1级→2级→…），点击箭头展开子仓库，叶子节点显示该仓库的库存商品清单。\n• 每个仓库节点显示：商品种类数、总库存件数、库存总金额。\n• 叶子节点表格显示：商品编码、名称、批次、数量、均价、金额。\n• 页面底部显示所有仓库的汇总行（总件数 + 总金额）。\n• 点击「导出Excel」导出当前筛选条件下的库存数据。',
      },
      {
        type: 'note',
        body: '库存数据按批次（batchNo）维度存储，同一商品同一仓库不同批次会分别展示。均价 = 该批次入库时的成本价。',
      },
    ],
  },
  'inventory-log': {
    id: 'inventory-log', title: '库存流水',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '库存流水记录每一次库存变动的详情，包括入库、出库、盘点调整等操作。可按时间、单号、商品名称等条件追溯查询。',
      },
      {
        type: 'table', title: '字段释义',
        headers: ['字段', '说明'],
        rows: [
          ['时间', '操作发生的时间'],
          ['商品名称/编码', '发生变动的商品信息'],
          ['仓库', '变动的仓库'],
          ['变动类型', '入库(+) / 出库(-) / 调整(±)'],
          ['变动数量', '具体变动数量，正数表示增加，负数表示减少'],
          ['变动后库存', '操作完成后的即时库存'],
          ['关联单号', '触发库存变动的单据号（入库单/出库单/盘点单/调拨单）'],
          ['操作人', '执行操作的用户'],
        ],
      },
      {
        type: 'text', title: '搜索功能',
        body: '• 搜索框支持同时按商品名称/编码或关联单号搜索。\n• 可按仓库筛选。\n• 所有筛选条件合并使用 AND 逻辑，日期范围和搜索词使用 OR 逻辑。',
      },
    ],
  },
  stocktake: {
    id: 'stocktake', title: '库存盘点',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '库存盘点用于定期核对实际库存与系统库存的一致性，发现差异并进行调整。支持全盘和抽盘两种方式。',
      },
      {
        type: 'text', title: '盘点流程',
        body: '① 新建盘点单 → ② 选择盘点方式和仓库 → ③ 录入商品实盘数量 → ④ 提交盘点 → ⑤ 管理员审核 → ⑥ 执行调整（更新系统库存）',
      },
      {
        type: 'table', title: '盘点方式',
        headers: ['方式', '说明'],
        rows: [
          ['全盘', '盘点指定仓库下的所有商品，系统自动加载全部商品列表'],
          ['抽盘', '只盘点指定的部分商品，需手动选择要盘点的商品'],
        ],
      },
      {
        type: 'table', title: '状态流转',
        headers: ['状态', '说明', '可执行操作'],
        rows: [
          ['盘点中(0)', '正在盘点中，可修改实盘数量', '审核通过（管理员）'],
          ['已审核(1)', '审核通过，但库存尚未调整', '执行调整（管理员）'],
          ['已调整(2)', '库存已按盘点结果更新', '仅可查看'],
        ],
      },
      {
        type: 'warning',
        body: '• 「执行调整」操作仅管理员可执行，执行后将按盘点差异更新库存。\n• 差异数 = 系统库存与实盘数量不一致的商品种类数。\n• 盘点审核通过后如发现错误，在未执行调整前可联系管理员处理。',
      },
    ],
  },
  transfer: {
    id: 'transfer', title: '库存调拨',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '库存调拨用于在不同仓库之间转移库存商品。支持从草稿到审批完成的完整流程，调拨时会校验调出仓库的可用库存是否充足。',
      },
      {
        type: 'table', title: '状态流转',
        headers: ['状态', '说明'],
        rows: [
          ['草稿(0)', '新建或驳回后保存，可编辑或提交'],
          ['待审批(4)', '已提交审批，等待管理员审核'],
          ['已完成(1)', '审核通过，库存已从调出仓转移到调入仓'],
          ['已取消(2)', '取消调拨'],
          ['已作废(3)', '管理员作废'],
        ],
      },
      {
        type: 'text', title: '注意事项',
        body: '• 调出仓库和调入仓库不能相同。\n• 调拨审核通过后，调出仓库库存扣减，调入仓库库存增加。\n• 提交调拨时会校验调出仓的可用库存，库存不足将提示失败。\n• 若库存不足，系统会自动将调拨单作废并提示。',
      },
    ],
  },
  report: {
    id: 'report', title: '统计报表',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '统计报表提供经营数据的汇总分析，包含入库汇总、出库汇总、库存周转率和库存预警四个维度，以图表和表格形式呈现。',
      },
      {
        type: 'table', title: '报表说明',
        headers: ['报表类型', '展示内容', '用途'],
        rows: [
          ['入库汇总', '近 30 天每日入库数量柱状图 + 总单数/总数量/总金额', '了解入库趋势和采购规模'],
          ['出库汇总', '近 30 天每日出库数量柱状图 + 总单数/总数量/总金额', '了解出库趋势和销售规模'],
          ['库存周转率', '各商品在指定时间内的周转次数', '分析商品流动性，优化库存结构'],
          ['库存预警', '低于安全库存的商品列表，显示商品名称、仓库、当前库存和安全库存', '及时发现缺货风险'],
        ],
      },
    ],
  },
  'system-user': {
    id: 'system-user', title: '员工管理',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '员工管理用于维护系统用户账号和权限。支持新建/编辑员工、修改密码、启用/禁用账号。此模块仅管理员可访问。',
      },
      {
        type: 'table', title: '权限角色说明',
        headers: ['角色', '说明', '可执行操作'],
        rows: [
          ['管理员（role_1）', '拥有系统全部权限', '所有操作，包括审核、作废、员工管理、系统配置'],
          ['员工（role_2）', '基础操作权限', '新建单据、编辑草稿、查看详情、导出数据、取消单据'],
        ],
      },
      {
        type: 'text', title: '操作说明',
        body: '• 新建：点击「新增员工」，填写账号、姓名、密码并选择权限角色。\n• 编辑：修改员工基本信息。\n• 改密：为员工重置密码。\n• 启用/禁用：禁用后该员工无法登录系统。\n• 删除：删除员工账号。注意：admin 账号不可删除和禁用。',
      },
      {
        type: 'note',
        body: '员工创建后需要分配权限角色才能正常使用系统。建议：管理人员设为「管理员」，普通操作人员设为「员工」。',
      },
    ],
  },
  'system-log': {
    id: 'system-log', title: '操作日志',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '操作日志记录所有用户在系统中的操作痕迹，包括新增、修改、删除、审核、导入、导出等操作。可按模块和时间范围筛选查询。此模块仅管理员可访问。',
      },
      {
        type: 'table', title: '日志字段',
        headers: ['字段', '说明'],
        rows: [
          ['时间', '操作的精确时间'],
          ['操作人', '执行操作的用户账号'],
          ['模块', '操作的业务模块（商品/入库/出库/盘点/系统等）'],
          ['操作', '操作类型（新增/修改/作废/审核/登录等）'],
          ['目标', '操作对象的 ID 或编号'],
          ['详情', '操作的详细描述'],
          ['IP地址', '操作时的客户端 IP'],
        ],
      },
    ],
  },
  'system-config': {
    id: 'system-config', title: '系统配置',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '系统配置页面展示系统运行所需的关键配置项，管理员可在此修改配置值。此模块仅管理员可访问。',
      },
      {
        type: 'note',
        body: '修改系统配置可能影响系统运行，请确保了解每个配置项的含义后再修改。如不确定，建议咨询系统管理员。',
      },
    ],
  },
  'system-recycle': {
    id: 'system-recycle', title: '已作废列表',
    content: [
      {
        type: 'text', title: '功能概述',
        body: '已作废列表集中展示所有已作废的单据，包括采购入库单、销售出库单、库存盘点单和库存调拨单。方便统一查看和管理已作废的记录。此模块仅管理员可访问。',
      },
      {
        type: 'text', title: '支持的单据类型',
        body: '• 采购入库单（已作废）\n• 销售出库单（已作废）\n• 库存盘点单（已作废）\n• 库存调拨单（已作废）',
      },
    ],
  },
  permission: {
    id: 'permission', title: '权限说明',
    content: [
      {
        type: 'text', title: '概述',
        body: '系统采用两种角色权限模型：管理员（role_1）和员工（role_2）。以下按模块列出具体权限差异。',
      },
      {
        type: 'table', title: '权限对照表',
        headers: ['模块', '操作', '管理员', '员工'],
        rows: [
          ['商品', '查看列表/详情', '✓', '✓'],
          ['商品', '新建/编辑/删除', '✓', '—'],
          ['商品', '导入导出', '✓', '✓'],
          ['供应商/客户', '查看列表', '✓', '✓'],
          ['供应商/客户', '新建/编辑', '✓', '—'],
          ['仓库', '新建/编辑/删除', '✓', '—'],
          ['采购/销售/调拨', '新建/编辑草稿', '✓', '✓'],
          ['采购/销售/调拨', '提交审批', '✓', '✓'],
          ['采购/销售/调拨', '审核通过/驳回', '✓', '—'],
          ['采购/销售/调拨', '取消', '✓', '✓'],
          ['采购/销售/调拨', '作废', '✓', '—'],
          ['采购/销售/调拨', '导出', '✓', '✓'],
          ['盘点', '新建/编辑', '✓', '✓'],
          ['盘点', '审核通过', '✓', '—'],
          ['盘点', '执行调整', '✓', '—'],
          ['系统管理', '全部操作', '✓', '—（菜单不可见）'],
        ],
      },
      {
        type: 'note',
        body: '员工角色登录后，侧边栏不会显示「系统管理」菜单。管理员专属的操作按钮（审核、作废等）对员工隐藏或置灰。',
      },
    ],
  },
  faq: {
    id: 'faq', title: '常见问题',
    content: [
      {
        type: 'text', title: 'Q: 单据审核流程是怎样的？',
        body: 'A: 所有单据（采购入库、销售出库、库存调拨）的审核流程均为：草稿 → 提交审批 → 管理员审核通过/驳回。盘点单流程为：盘点中 → 审核通过 → 执行调整。',
      },
      {
        type: 'text', title: 'Q: 审核通过后库存什么时候更新？',
        body: 'A: 审核通过后立即更新。采购入库审核 → 库存增加；销售出库审核 → 库存减少；调拨审核 → 调出仓扣减、调入仓增加；盘点调整 → 按实盘数量更新。',
      },
      {
        type: 'text', title: 'Q: "取消"和"作废"有什么区别？',
        body: 'A: 取消是将单据从当前状态回退（如已入库→已取消），通常用于业务终止。作废是彻底废弃单据，需填写作废原因，且仅管理员可操作。作废后的单据不可再修改或恢复。',
      },
      {
        type: 'text', title: 'Q: 为什么某些按钮不可点击？',
        body: 'A: 按钮不可点击通常有以下原因：① 当前登录账号是员工角色，无操作权限（如审核、作废按钮）；② 当前单据状态不允许该操作（如已入库的单据不能编辑）；③ 未选中任何数据（如批量操作按钮）。',
      },
      {
        type: 'text', title: 'Q: 如何理解多级仓库？',
        body: 'A: 多级仓库采用树形结构组织仓库，从 1 级（根节点）到 4 级（叶子节点）。只有叶子节点才能存储库存。例如：总仓库(1级) → 北京仓(2级) → 朝阳区分拣中心(3级) → A货架(4级)。A货架是叶子节点，实际库存存放在该层级。',
      },
      {
        type: 'text', title: 'Q: 商品条码如何生成和打印？',
        body: 'A: 在商品列表中，点击单行商品的「条码」按钮可预览条码图片；选中多个商品后点击「打印条码」可批量下载包含所有商品条码的 ZIP 压缩包。条码内容使用商品的「编码」字段生成。',
      },
      {
        type: 'text', title: 'Q: 数据导入有格式要求吗？',
        body: 'A: 有。导入前必须先下载模板文件，按模板的列格式填写数据后再上传。系统会校验数据的完整性和编码唯一性，不合法的数据会被跳过并提示。',
      },
    ],
  },
}
```

---

### 任务 2：创建 HelpGuide.vue 主页面

**文件：**
- 创建：`src/views/help/HelpGuide.vue`

左侧目录树（含搜索框）+ 右侧折叠内容区 + 搜索高亮 + 滚动跟随高亮。

- [ ] **步骤 1：创建 HelpGuide.vue 完整文件**

```vue
<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { navTree, sections, type NavItem } from './data/guideData'

const searchKeyword = ref('')
const activeId = ref('dashboard')
const collapsedSections = ref<Set<string>>(new Set())
const contentRef = ref<HTMLDivElement>()

// 搜索逻辑：遍历所有 content 的 body 匹配关键词
const matchedIds = computed(() => {
  const kw = searchKeyword.value.trim().toLowerCase()
  if (!kw) return new Set<string>()
  const ids = new Set<string>()
  for (const [id, section] of Object.entries(sections)) {
    for (const block of section.content) {
      const text = (block.body || '').toLowerCase()
      if (text.includes(kw)) {
        ids.add(id)
        break
      }
      if (block.headers) {
        for (const h of block.headers) {
          if (h.toLowerCase().includes(kw)) { ids.add(id); break }
        }
      }
      if (block.rows) {
        for (const row of block.rows) {
          if (row.some(c => c.toLowerCase().includes(kw))) { ids.add(id); break }
        }
      }
    }
  }
  return ids
})

// 所有展开的 flat 导航项（含子节点）
const flatNav = computed(() => {
  const result: { id: string; title: string; parentTitle?: string }[] = []
  for (const item of navTree) {
    result.push({ id: item.id, title: item.title })
    if (item.children) {
      for (const child of item.children) {
        result.push({ id: child.id, title: child.title, parentTitle: item.title })
      }
    }
  }
  return result
})

function scrollTo(id: string) {
  activeId.value = id
  const el = document.getElementById('section-' + id)
  if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

// 滚动监听 - 高亮当前可见章节
function handleScroll() {
  if (searchKeyword.value.trim()) return
  const container = contentRef.value
  if (!container) return
  let closestId = flatNav.value[0]?.id || 'dashboard'
  let closestDist = Infinity
  for (const item of flatNav.value) {
    const el = document.getElementById('section-' + item.id)
    if (!el) continue
    const rect = el.getBoundingClientRect()
    const dist = Math.abs(rect.top - 100)
    if (dist < closestDist) { closestDist = dist; closestId = item.id }
  }
  if (closestId !== activeId.value) activeId.value = closestId
}

function toggleCollapse(id: string) {
  if (collapsedSections.value.has(id)) collapsedSections.value.delete(id)
  else collapsedSections.value.add(id)
}

// 高亮搜索关键词
function highlightText(text: string): string {
  const kw = searchKeyword.value.trim()
  if (!kw) return text
  const escaped = kw.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  const regex = new RegExp(`(${escaped})`, 'gi')
  return text.replace(regex, '<mark class="search-highlight">$1</mark>')
}

function isNavMatch(item: NavItem): boolean {
  if (!searchKeyword.value.trim()) return true
  if (matchedIds.value.has(item.id)) return true
  if (item.children) return item.children.some(c => matchedIds.value.has(c.id))
  return false
}

onMounted(() => {
  // 默认展开所有章节
  for (const item of flatNav.value) {
    collapsedSections.value.add(item.id)
  }
  // 全部展开
  collapsedSections.value.clear()
  window.addEventListener('scroll', handleScroll, { passive: true })
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>

<template>
  <div class="help-layout">
    <!-- 左侧目录 -->
    <aside class="help-sidebar">
      <div class="help-search">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索使用说明…"
          clearable
          prefix-icon="Search"
          size="large"
        />
        <div v-if="searchKeyword.trim() && matchedIds.size === 0" class="search-empty">
          未找到相关内容，试试其他关键词
        </div>
      </div>
      <nav class="help-nav">
        <template v-for="item in navTree" :key="item.id">
          <!-- 有子菜单 -->
          <div v-if="item.children" class="nav-group" v-show="isNavMatch(item)">
            <div class="nav-group-title">{{ item.title }}</div>
            <div
              v-for="child in item.children"
              :key="child.id"
              class="nav-item nav-item-child"
              :class="{ active: activeId === child.id }"
              :style="{ display: (!searchKeyword.trim() || matchedIds.has(child.id)) ? '' : 'none' }"
              @click="scrollTo(child.id)"
            >
              {{ child.title }}
            </div>
          </div>
          <!-- 无子菜单 -->
          <div
            v-else
            class="nav-item"
            :class="{ active: activeId === item.id }"
            v-show="(!searchKeyword.trim() || matchedIds.has(item.id))"
            @click="scrollTo(item.id)"
          >
            {{ item.title }}
          </div>
        </template>
      </nav>
    </aside>

    <!-- 右侧内容 -->
    <main ref="contentRef" class="help-content">
      <h1 class="help-title">系统使用说明</h1>
      <p class="help-subtitle">本指南涵盖系统的所有功能模块，帮助您快速上手和深入了解各模块的使用方法。</p>

      <template v-for="item in flatNav" :key="item.id">
        <div
          :id="'section-' + item.id"
          class="help-section"
          :class="{ 'search-match': searchKeyword.trim() && matchedIds.has(item.id) }"
        >
          <div class="section-header" @click="toggleCollapse(item.id)">
            <h2 class="section-title">{{ item.title }}</h2>
            <el-tag v-if="item.parentTitle" size="small" type="info">{{ item.parentTitle }}</el-tag>
            <span class="collapse-icon">{{ collapsedSections.has(item.id) ? '▶' : '▼' }}</span>
          </div>

          <div v-show="!collapsedSections.has(item.id)" class="section-body">
            <template v-for="(block, bi) in (sections[item.id]?.content || [])" :key="bi">
              <!-- 纯文本 -->
              <div v-if="block.type === 'text'" class="content-block">
                <h4 v-if="block.title" class="block-title">{{ block.title }}</h4>
                <div class="block-body" v-html="highlightText(block.body || '')"></div>
              </div>

              <!-- 表格 -->
              <div v-if="block.type === 'table'" class="content-block">
                <h4 v-if="block.title" class="block-title">{{ block.title }}</h4>
                <el-table :data="block.rows || []" stripe border size="small">
                  <el-table-column
                    v-for="(header, hi) in (block.headers || [])"
                    :key="hi"
                    :label="header"
                    min-width="130"
                  >
                    <template #default="{ row }">
                      <span v-html="highlightText(row[hi] || '')"></span>
                    </template>
                  </el-table-column>
                </el-table>
              </div>

              <!-- 状态流转 -->
              <div v-if="block.type === 'flow'" class="content-block">
                <h4 v-if="block.title" class="block-title">{{ block.title }}</h4>
                <div class="flow-list">
                  <div v-for="(step, si) in (block.steps || [])" :key="si" class="flow-item">
                    <el-tag size="small" type="info">{{ step.from }}</el-tag>
                    <span class="flow-arrow">{{ step.arrow }}</span>
                    <el-tag size="small" type="success">{{ step.to }}</el-tag>
                    <span class="flow-desc">{{ step.desc }}</span>
                  </div>
                </div>
              </div>

              <!-- 注意 -->
              <div v-if="block.type === 'note'" class="content-block note-block">
                <div class="note-icon">💡</div>
                <div class="block-body" v-html="highlightText(block.body || '')"></div>
              </div>

              <!-- 警告 -->
              <div v-if="block.type === 'warning'" class="content-block warning-block">
                <div class="note-icon">⚠️</div>
                <div class="block-body" v-html="highlightText(block.body || '')"></div>
              </div>
            </template>
          </div>
        </div>
      </template>

      <!-- 搜索无结果 -->
      <div
        v-if="searchKeyword.trim() && matchedIds.size === 0"
        class="no-results"
      >
        <el-empty description="未找到相关内容" />
        <p style="color:#999;font-size:13px;margin-top:8px;">试试其他关键词，如"入库"、"审核"、"权限"</p>
      </div>
    </main>
  </div>
</template>

<style scoped>
.help-layout {
  display: flex;
  gap: 20px;
  align-items: flex-start;
}

/* 左侧侧边栏 */
.help-sidebar {
  width: 220px;
  flex-shrink: 0;
  position: sticky;
  top: 24px;
  max-height: calc(100vh - 120px);
  overflow-y: auto;
  background: #fff;
  border-radius: 8px;
  border: 1px solid #e8ece8;
  padding: 16px 0;
}

.help-search {
  padding: 0 12px 12px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 8px;
}

.search-empty {
  font-size: 12px;
  color: #999;
  margin-top: 6px;
  text-align: center;
}

.help-nav {
  padding: 0 8px;
}

.nav-group-title {
  font-size: 12px;
  font-weight: 600;
  color: #999;
  padding: 8px 12px 4px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.nav-item {
  padding: 8px 12px;
  font-size: 13px;
  color: #666;
  cursor: pointer;
  border-radius: 6px;
  margin: 1px 0;
  transition: all 0.15s;
}

.nav-item:hover {
  background: #e8f5e9;
  color: #2e7d32;
}

.nav-item.active {
  background: #2e7d32;
  color: #fff;
  font-weight: 500;
}

.nav-item-child {
  padding-left: 24px;
  font-size: 12px;
}

/* 右侧内容 */
.help-content {
  flex: 1;
  min-width: 0;
  background: #fff;
  border-radius: 8px;
  border: 1px solid #e8ece8;
  padding: 32px;
}

.help-title {
  font-size: 24px;
  color: #303133;
  margin: 0 0 8px;
  border: none;
  padding: 0;
}

.help-subtitle {
  font-size: 14px;
  color: #909399;
  margin: 0 0 32px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
}

/* 每个章节 */
.help-section {
  margin-bottom: 8px;
  border: 1px solid #e8ece8;
  border-radius: 8px;
  overflow: hidden;
  transition: border-color 0.2s;
}

.help-section.search-match {
  border-color: #2e7d32;
  box-shadow: 0 0 0 1px #2e7d32;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 16px;
  cursor: pointer;
  background: #fafbfa;
  user-select: none;
}

.section-header:hover {
  background: #f0f5f0;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0;
  border: none;
  padding: 0;
  flex: 1;
}

.collapse-icon {
  font-size: 10px;
  color: #909399;
}

.section-body {
  padding: 4px 16px 16px;
  border-top: 1px solid #f0f0f0;
}

.content-block {
  margin-top: 16px;
}

.block-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 8px;
}

.block-body {
  font-size: 13px;
  line-height: 1.8;
  color: #606266;
  white-space: pre-line;
}

/* 表格覆盖 */
:deep(.el-table) {
  font-size: 12px;
}

/* 高亮 */
:deep(.search-highlight) {
  background: #fff3cd;
  padding: 0 2px;
  border-radius: 2px;
  color: #e6a23c;
}

/* 流 */
.flow-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.flow-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  padding: 4px 8px;
  background: #fafbfa;
  border-radius: 4px;
}

.flow-arrow {
  color: #909399;
  font-weight: bold;
}

.flow-desc {
  color: #909399;
  font-size: 12px;
}

/* 注意 / 警告 */
.note-block {
  background: #f0f9eb;
  border-radius: 6px;
  padding: 12px 16px;
  display: flex;
  gap: 8px;
}

.warning-block {
  background: #fef0f0;
  border-radius: 6px;
  padding: 12px 16px;
  display: flex;
  gap: 8px;
}

.note-icon {
  font-size: 16px;
  flex-shrink: 0;
  margin-top: 1px;
}

.no-results {
  text-align: center;
  padding: 60px 0;
}
</style>
```

---

### 任务 3：注册路由和菜单项

**文件：**
- 修改：`src/router/index.ts`
- 修改：`src/store/app.ts`

- [ ] **步骤 1：在 router/index.ts 中添加 /help 路由**

在 router 的 children 数组中，在 `customer` 路由配置之后（或其他合适位置）添加：

```ts
{
  path: 'help',
  name: 'Help',
  component: () => import('../views/help/HelpGuide.vue'),
  meta: { title: '使用说明' },
},
```

- [ ] **步骤 2：在 store/app.ts 的 menus 数组中添加菜单项**

在菜单数组末尾（系统管理之前或之后），添加：

```ts
{
  path: '/help',
  title: '使用说明',
  icon: 'Reading',
},
```

注意：需要确认 `Reading` 图标在 `@element-plus/icons-vue` 中是否存在。如不存在，可使用 `InfoFilled`、`Document` 或 `QuestionFilled` 替代。

---

### 任务 4：验证

- [ ] **步骤 1：运行开发服务器确认页面正常加载**

```bash
cd /c/Users/28135/Desktop/inventory/inventory-admin
npm run dev
```

确认：
1. 侧边栏显示「使用说明」菜单项
2. 点击后页面正常渲染左侧导航和右侧内容
3. 切换章节正常
4. 搜索功能正常工作
5. 折叠/展开功能正常
6. 滚动时左侧导航高亮跟随
