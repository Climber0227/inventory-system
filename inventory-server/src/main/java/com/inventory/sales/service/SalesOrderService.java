package com.inventory.sales.service;

import cn.hutool.core.date.DateUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.common.constant.OrderStatus;
import com.inventory.common.exception.BusinessException;
import com.inventory.customer.entity.Customer;
import com.inventory.customer.mapper.CustomerMapper;
import com.inventory.inventory.entity.Inventory;
import com.inventory.inventory.entity.InventoryLog;
import com.inventory.inventory.mapper.InventoryLogMapper;
import com.inventory.inventory.mapper.InventoryMapper;
import com.inventory.product.entity.Product;
import com.inventory.product.mapper.ProductMapper;
import com.inventory.sales.entity.SalesOrder;
import com.inventory.sales.entity.SalesOrderDetailExportVO;
import com.inventory.sales.entity.SalesOrderItem;
import com.inventory.sales.mapper.SalesOrderItemMapper;
import com.inventory.sales.mapper.SalesOrderMapper;
import com.inventory.system.entity.SysUser;
import com.inventory.system.mapper.SysUserMapper;
import com.inventory.warehouse.entity.Warehouse;
import com.inventory.warehouse.mapper.WarehouseMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class SalesOrderService {

    private final SalesOrderMapper salesOrderMapper;
    private final SalesOrderItemMapper salesOrderItemMapper;
    private final InventoryMapper inventoryMapper;
    private final InventoryLogMapper inventoryLogMapper;
    private final CustomerMapper customerMapper;
    private final WarehouseMapper warehouseMapper;
    private final SysUserMapper userMapper;
    private final ProductMapper productMapper;

    public SalesOrderService(SalesOrderMapper salesOrderMapper,
                             SalesOrderItemMapper salesOrderItemMapper,
                             InventoryMapper inventoryMapper,
                             InventoryLogMapper inventoryLogMapper,
                             CustomerMapper customerMapper,
                             WarehouseMapper warehouseMapper,
                             SysUserMapper userMapper,
                             ProductMapper productMapper) {
        this.salesOrderMapper = salesOrderMapper;
        this.salesOrderItemMapper = salesOrderItemMapper;
        this.inventoryMapper = inventoryMapper;
        this.inventoryLogMapper = inventoryLogMapper;
        this.customerMapper = customerMapper;
        this.warehouseMapper = warehouseMapper;
        this.userMapper = userMapper;
        this.productMapper = productMapper;
    }

    public Page<SalesOrder> page(Page<SalesOrder> page, String orderNo, Long customerId, Long warehouseId,
                                 Integer minQuantity, Integer maxQuantity, BigDecimal minAmount, BigDecimal maxAmount,
                                 String salesman, Integer status,
                                 LocalDate startDate, LocalDate endDate) {
        LambdaQueryWrapper<SalesOrder> wrapper = new LambdaQueryWrapper<SalesOrder>()
                .like(orderNo != null, SalesOrder::getOrderNo, orderNo)
                .eq(customerId != null, SalesOrder::getCustomerId, customerId)
                .eq(warehouseId != null, SalesOrder::getWarehouseId, warehouseId)
                .ge(minQuantity != null, SalesOrder::getTotalQuantity, minQuantity)
                .le(maxQuantity != null, SalesOrder::getTotalQuantity, maxQuantity)
                .ge(minAmount != null, SalesOrder::getTotalAmount, minAmount)
                .le(maxAmount != null, SalesOrder::getTotalAmount, maxAmount)
                .like(salesman != null, SalesOrder::getSalesman, salesman)
                .eq(status != null, SalesOrder::getStatus, status)
                .ge(startDate != null, SalesOrder::getOrderDate, startDate)
                .le(endDate != null, SalesOrder::getOrderDate, endDate)
                .ne(SalesOrder::getStatus, OrderStatus.VOIDED)
                .orderByDesc(SalesOrder::getId);
        Page<SalesOrder> result = salesOrderMapper.selectPage(page, wrapper);
        enrichOrdersBatch(result.getRecords());
        return result;
    }

    public List<SalesOrder> listAll() {
        List<SalesOrder> list = salesOrderMapper.selectList(
                new LambdaQueryWrapper<SalesOrder>().orderByDesc(SalesOrder::getId));
        enrichOrdersBatch(list);
        return list;
    }

    public SalesOrder getDetail(Long id) {
        SalesOrder order = salesOrderMapper.selectById(id);
        if (order != null) {
            List<SalesOrderItem> items = salesOrderItemMapper.selectList(
                    new LambdaQueryWrapper<SalesOrderItem>().eq(SalesOrderItem::getOrderId, id));
            order.setItems(items);
            enrichOrdersBatch(List.of(order));
        }
        return order;
    }

    /** 批量预加载所有关联数据 */
    private void enrichOrdersBatch(List<SalesOrder> orders) {
        if (orders == null || orders.isEmpty()) return;
        Set<Long> orderIds = new HashSet<>();
        Set<Long> customerIds = new HashSet<>();
        Set<Long> warehouseIds = new HashSet<>();
        Set<Long> userIds = new HashSet<>();
        for (SalesOrder o : orders) {
            orderIds.add(o.getId());
            if (o.getCustomerId() != null) customerIds.add(o.getCustomerId());
            if (o.getWarehouseId() != null) warehouseIds.add(o.getWarehouseId());
            if (o.getOperatorId() != null) userIds.add(o.getOperatorId());
            if (o.getApproverId() != null) userIds.add(o.getApproverId());
        }
        List<SalesOrderItem> allItems = orderIds.isEmpty() ? List.of()
                : salesOrderItemMapper.selectList(
                    new LambdaQueryWrapper<SalesOrderItem>().in(SalesOrderItem::getOrderId, orderIds));
        Map<Long, List<SalesOrderItem>> itemMap = allItems.stream()
                .collect(Collectors.groupingBy(SalesOrderItem::getOrderId));
        Set<Long> productIds = allItems.stream().map(SalesOrderItem::getProductId)
                .filter(Objects::nonNull).collect(Collectors.toSet());
        Map<Long, Customer> customerMap = customerIds.isEmpty() ? new HashMap<>()
                : customerMapper.selectBatchIds(customerIds).stream()
                    .collect(Collectors.toMap(Customer::getId, c -> c, (a, b) -> a));
        Map<Long, Warehouse> warehouseMap = warehouseIds.isEmpty() ? new HashMap<>()
                : warehouseMapper.selectBatchIdsIgnoreDeleted(warehouseIds).stream()
                    .collect(Collectors.toMap(Warehouse::getId, w -> w, (a, b) -> a));
        // 加载所有仓库用于构建父级路径
        List<Warehouse> allWh = warehouseMapper.selectList(null);
        Map<Long, Warehouse> allWhMap = allWh.stream()
                .collect(Collectors.toMap(Warehouse::getId, w -> w, (a, b) -> a));
        Map<Long, SysUser> userMap = userIds.isEmpty() ? new HashMap<>()
                : userMapper.selectBatchIds(userIds).stream()
                    .collect(Collectors.toMap(SysUser::getId, u -> u, (a, b) -> a));
        Map<Long, Product> productMap = productIds.isEmpty() ? new HashMap<>()
                : productMapper.selectBatchIdsIgnoreDeleted(productIds).stream()
                    .collect(Collectors.toMap(Product::getId, p -> p, (a, b) -> a));
        for (SalesOrder o : orders) {
            Customer c = customerMap.get(o.getCustomerId());
            if (c != null) o.setCustomerName(c.getName());
            Warehouse w = warehouseMap.get(o.getWarehouseId());
            if (w != null) {
                o.setWarehouseName(w.getName());
                o.setWarehousePath(buildWhPath(w, allWhMap));
            }
            SysUser op = userMap.get(o.getOperatorId());
            if (op != null) o.setOperatorName(op.getRealName());
            SysUser ap = userMap.get(o.getApproverId());
            if (ap != null) o.setApproverName(ap.getRealName());
            List<SalesOrderItem> items = itemMap.getOrDefault(o.getId(), List.of());
            for (SalesOrderItem item : items) {
                Product p = productMap.get(item.getProductId());
                if (p != null) { item.setProductName(p.getName()); item.setProductCode(p.getCode()); }
            }
            o.setItems(items);
        }
    }

    /** 导出明细：每行一个商品 */
    public List<SalesOrderDetailExportVO> getDetailExportList(List<SalesOrder> orders) {
        enrichOrdersBatch(orders);
        List<SalesOrderDetailExportVO> result = new ArrayList<>();
        for (SalesOrder o : orders) {
            List<SalesOrderItem> items = o.getItems() != null ? o.getItems() : List.of();
            for (SalesOrderItem item : items) {
                SalesOrderDetailExportVO vo = new SalesOrderDetailExportVO();
                vo.setOrderNo(o.getOrderNo());
                vo.setCustomerName(o.getCustomerName());
                vo.setWarehouseName(o.getWarehouseName());
                vo.setWarehousePath(o.getWarehousePath());
                vo.setOrderDate(o.getOrderDate());
                vo.setOperatorName(o.getOperatorName());
                vo.setProductName(item.getProductName());
                vo.setProductCode(item.getProductCode());
                vo.setQuantity(item.getQuantity());
                vo.setUnitPrice(item.getUnitPrice());
                vo.setAmount(item.getAmount());
                vo.setStatus(switch (o.getStatus()) {
                    case 0 -> "草稿"; case 1 -> "已出库"; case 2 -> "已取消"; case 4 -> "待审批";
                    default -> "未知";
                });
                vo.setRemark(o.getRemark());
                result.add(vo);
            }
        }
        return result;
    }

    @Transactional(rollbackFor = Exception.class)
    public synchronized Map<String, Object> create(SalesOrder order) {
        List<SalesOrderItem> items = order.getItems();
        if (items == null || items.isEmpty()) throw new BusinessException("商品明细不能为空");

        order.setOrderDate(order.getOrderDate() != null ? order.getOrderDate() : LocalDate.now());

        // 收集每个明细的仓库归属
        Map<Long, List<SalesOrderItem>> groups = new LinkedHashMap<>();
        for (SalesOrderItem item : items) {
            if (item.getProductId() == null) throw new BusinessException("商品ID不能为空");
            Long whId = item.getWarehouseId() != null ? item.getWarehouseId() : order.getWarehouseId();
            if (whId == null) throw new BusinessException("商品" + item.getProductName() + "未指定仓库");
            groups.computeIfAbsent(whId, k -> new ArrayList<>()).add(item);
        }

        // 单一仓库：原逻辑
        if (groups.size() == 1) {
            Long whId = groups.keySet().iterator().next();
            order.setWarehouseId(whId);
            Long id = createSingle(order, groups.get(whId));
            Map<String, Object> result = new HashMap<>();
            result.put("ids", Collections.singletonList(id));
            return result;
        }

        // 多仓库：拆成多张子订单
        String parentOrderNo = generateOrderNo();
        List<Long> childIds = new ArrayList<>();
        int seq = 1;
        for (Map.Entry<Long, List<SalesOrderItem>> entry : groups.entrySet()) {
            SalesOrder child = new SalesOrder();
            child.setCustomerId(order.getCustomerId());
            child.setWarehouseId(entry.getKey());
            child.setSalesman(order.getSalesman());
            child.setExternalOrderNo(order.getExternalOrderNo());
            child.setOrderDate(order.getOrderDate());
            child.setRemark(order.getRemark());
            child.setOperatorId(order.getOperatorId());
            child.setParentOrderNo(parentOrderNo);
            child.setOrderNo(parentOrderNo + "-" + seq);
            Long cid = createSingle(child, entry.getValue());
            childIds.add(cid);
            seq++;
        }
        Map<String, Object> result = new HashMap<>();
        result.put("ids", childIds);
        result.put("parentOrderNo", parentOrderNo);
        return result;
    }

    /** 创建单张订单（共享逻辑，带重复键重试） */
    private Long createSingle(SalesOrder order, List<SalesOrderItem> items) {
        order.setOrderNo(order.getOrderNo() != null ? order.getOrderNo() : generateOrderNo());
        order.setStatus(OrderStatus.DRAFT);
        BigDecimal totalAmount = BigDecimal.ZERO;
        int totalQty = 0;

        // 库存校验：按商品汇总需求后，逐项检查仓库可用库存
        java.util.Map<Long, Integer> demandByProduct = new java.util.LinkedHashMap<>();
        for (SalesOrderItem item : items) {
            if (item.getProductId() != null && item.getQuantity() != null) {
                demandByProduct.merge(item.getProductId(), item.getQuantity(), Integer::sum);
            }
        }
        Long whId = order.getWarehouseId();
        for (java.util.Map.Entry<Long, Integer> e : demandByProduct.entrySet()) {
            Integer available = inventoryMapper.sumQuantityByProductAndWarehouse(e.getKey(), whId);
            int avail = available != null ? available : 0;
            if (e.getValue() > avail) {
                // 找到该商品名
                String pn = items.stream()
                    .filter(i -> e.getKey().equals(i.getProductId()))
                    .findFirst().map(SalesOrderItem::getProductName).orElse(String.valueOf(e.getKey()));
                throw new BusinessException(
                    "商品「" + pn + "」库存不足（需要 " + e.getValue() +
                    "，仓库可用 " + avail + "）"
                );
            }
        }

        for (SalesOrderItem item : items) {
            item.setOrderId(null);
            if (item.getUnitPrice() == null) item.setUnitPrice(BigDecimal.ZERO);
            BigDecimal amount = item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
            item.setAmount(amount);
            totalAmount = totalAmount.add(amount);
            totalQty += item.getQuantity();
        }
        order.setTotalAmount(totalAmount);
        order.setTotalQuantity(totalQty);

        // 重试机制：处理订单号生成的并发竞争
        int maxRetries = 5;
        for (int attempt = 0; ; attempt++) {
            try {
                salesOrderMapper.insert(order);
                break;
            } catch (org.springframework.dao.DuplicateKeyException e) {
                if (attempt >= maxRetries) throw e;
                // 重新生成订单号并设置到所有子订单
                String newOrderNo = generateOrderNo();
                if (order.getParentOrderNo() != null) {
                    // 子订单：用新的父前缀重建
                    String suffix = order.getOrderNo().substring(order.getOrderNo().lastIndexOf('-'));
                    order.setOrderNo(newOrderNo + suffix);
                    order.setParentOrderNo(newOrderNo);
                } else {
                    order.setOrderNo(newOrderNo);
                }
            }
        }

        for (SalesOrderItem item : items) {
            item.setOrderId(order.getId());
            salesOrderItemMapper.insert(item);
        }
        return order.getId();
    }

    @Transactional(rollbackFor = Exception.class)
    public synchronized void submit(Long id) {
        SalesOrder order = salesOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("销售单不存在");
        if (order.getStatus() != OrderStatus.DRAFT) throw new BusinessException("当前状态不可提交");
        order.setStatus(OrderStatus.PENDING);
        salesOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public synchronized void approve(Long id) {
        SalesOrder order = salesOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("销售单不存在");
        if (order.getStatus() != OrderStatus.PENDING) throw new BusinessException("当前状态不可审核");

        List<SalesOrderItem> items = salesOrderItemMapper.selectList(
                new LambdaQueryWrapper<SalesOrderItem>().eq(SalesOrderItem::getOrderId, id));

        for (SalesOrderItem item : items) {
            int needQty = item.getQuantity();

            // 如果指定了批次号，优先从该批次扣减
            if (item.getBatchNo() != null && !item.getBatchNo().isEmpty()) {
                Inventory targetBatch = inventoryMapper.selectOne(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getProductId, item.getProductId())
                                .eq(Inventory::getWarehouseId, order.getWarehouseId())
                                .eq(Inventory::getBatchNo, item.getBatchNo()));
                if (targetBatch == null || targetBatch.getQuantity() < needQty) {
                    int avail = targetBatch != null ? targetBatch.getQuantity() : 0;
                    throw new BusinessException("所选批次库存不足（批次: " + item.getBatchNo() + "，可用: " + avail + "，需出库: " + needQty + "）");
                }
                int beforeQty = targetBatch.getQuantity();
                targetBatch.setQuantity(beforeQty - needQty);
                inventoryMapper.updateById(targetBatch);
                InventoryLog log = new InventoryLog();
                log.setProductId(item.getProductId());
                log.setWarehouseId(order.getWarehouseId());
                log.setBatchNo(targetBatch.getBatchNo());
                log.setChangeType(OrderStatus.SALES_OUT);
                log.setChangeQty(-needQty);
                log.setBeforeQty(beforeQty);
                log.setAfterQty(targetBatch.getQuantity());
                log.setUnitPrice(item.getUnitPrice());
                log.setAmount(item.getUnitPrice() != null
                        ? item.getUnitPrice().multiply(BigDecimal.valueOf(needQty)) : BigDecimal.ZERO);
                log.setRefOrderNo(order.getOrderNo());
                log.setOperatorId(order.getOperatorId());
                inventoryLogMapper.insert(log);
                needQty = 0;
                continue;
            }

            // 未指定批次，FIFO 扣减
            List<Inventory> batchList = inventoryMapper.selectList(
                    new LambdaQueryWrapper<Inventory>()
                            .eq(Inventory::getProductId, item.getProductId())
                            .eq(Inventory::getWarehouseId, order.getWarehouseId())
                            .gt(Inventory::getQuantity, 0)
                            .orderByAsc(Inventory::getId));

            int totalAvailable = batchList.stream().mapToInt(Inventory::getQuantity).sum();
            if (totalAvailable < needQty) {
                throw new BusinessException("商品库存不足");
            }

            for (Inventory batch : batchList) {
                if (needQty <= 0) break;
                int deductQty = Math.min(needQty, batch.getQuantity());
                int beforeQty = batch.getQuantity();
                batch.setQuantity(beforeQty - deductQty);
                inventoryMapper.updateById(batch);

                InventoryLog log = new InventoryLog();
                log.setProductId(item.getProductId());
                log.setWarehouseId(order.getWarehouseId());
                log.setLocationId(batch.getLocationId());
                log.setBatchNo(batch.getBatchNo());
                log.setChangeType(OrderStatus.SALES_OUT);
                log.setChangeQty(-deductQty);
                log.setBeforeQty(beforeQty);
                log.setAfterQty(batch.getQuantity());
                log.setUnitPrice(item.getUnitPrice());
                log.setAmount(item.getUnitPrice() != null
                        ? item.getUnitPrice().multiply(BigDecimal.valueOf(deductQty)) : BigDecimal.ZERO);
                log.setRefOrderNo(order.getOrderNo());
                log.setOperatorId(order.getOperatorId());
                log.setRemark("销售出库(FIFO)");
                inventoryLogMapper.insert(log);
                needQty -= deductQty;
            }
        }

        order.setApproverId(cn.dev33.satoken.stp.StpUtil.getLoginIdAsLong());
        order.setApproveTime(LocalDateTime.now());
        order.setStatus(OrderStatus.CONFIRMED);
        salesOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void reject(Long id, String reason) {
        SalesOrder order = salesOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("销售单不存在");
        if (order.getStatus() != OrderStatus.PENDING) throw new BusinessException("当前状态不可驳回");
        order.setStatus(OrderStatus.DRAFT);
        order.setRemark((order.getRemark() != null ? order.getRemark() + " | " : "") + "驳回原因: " + (reason != null ? reason : ""));
        salesOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public synchronized void cancel(Long id) {
        SalesOrder order = salesOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("销售单不存在");
        if (order.getStatus() == OrderStatus.CANCELED) throw new BusinessException("销售单已取消");
        if (order.getStatus() == OrderStatus.VOIDED) throw new BusinessException("已作废的单据不可取消");
        if (order.getStatus() == OrderStatus.PENDING) {
            long uid = cn.dev33.satoken.stp.StpUtil.getLoginIdAsLong();
            var u = userMapper.selectById(uid);
            if (u == null || u.getRole() == null || u.getRole() != 1) {
                throw new BusinessException("待审批状态仅管理员可取消");
            }
            order.setStatus(OrderStatus.CANCELED);
            salesOrderMapper.updateById(order);
            return;
        }
        if (order.getStatus() == OrderStatus.CONFIRMED) {
            throw new BusinessException("已出库的单据不可取消，请使用作废功能（作废不会影响库存）");
        }
        order.setStatus(OrderStatus.CANCELED);
        salesOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateDraft(SalesOrder order) {
        SalesOrder existing = salesOrderMapper.selectById(order.getId());
        if (existing == null) throw new BusinessException("销售单不存在");
        if (existing.getStatus() != OrderStatus.DRAFT) throw new BusinessException("仅草稿状态可编辑");

        salesOrderItemMapper.delete(new LambdaQueryWrapper<SalesOrderItem>()
                .eq(SalesOrderItem::getOrderId, order.getId()));

        BigDecimal totalAmount = BigDecimal.ZERO;
        int totalQty = 0;
        List<SalesOrderItem> items = order.getItems();
        if (items != null) {
            for (SalesOrderItem item : items) {
                item.setId(null);
                item.setOrderId(order.getId());
                if (item.getUnitPrice() == null) item.setUnitPrice(BigDecimal.ZERO);
                BigDecimal amount = item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                item.setAmount(amount);
                totalAmount = totalAmount.add(amount);
                totalQty += item.getQuantity();
                salesOrderItemMapper.insert(item);
            }
        }
        order.setTotalAmount(totalAmount);
        order.setTotalQuantity(totalQty);
        salesOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        SalesOrder order = salesOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("销售单不存在");
        if (order.getStatus() == OrderStatus.CONFIRMED) throw new BusinessException("已出库的订单不能作废，请先取消");
        order.setStatus(OrderStatus.VOIDED);
        salesOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void batchDelete(List<Long> ids) {
        for (Long id : ids) {
            SalesOrder order = salesOrderMapper.selectById(id);
            if (order != null && order.getStatus() != OrderStatus.CONFIRMED) {
                order.setStatus(OrderStatus.VOIDED);
                salesOrderMapper.updateById(order);
            }
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void voidOrder(Long id, String reason) {
        SalesOrder order = salesOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("销售单不存在");
        if (order.getStatus() == OrderStatus.CONFIRMED) throw new BusinessException("已确认的单据不可作废");
        order.setStatus(OrderStatus.VOIDED);
        order.setRemark((order.getRemark() != null ? order.getRemark() + " | " : "") + "作废原因: " + (reason != null ? reason : ""));
        order.setUpdateTime(LocalDateTime.now());
        salesOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void batchVoid(List<Long> ids, String reason) {
        for (Long id : ids) {
            voidOrder(id, reason);
        }
    }

    private String buildWhPath(Warehouse wh, Map<Long, Warehouse> allMap) {
        java.util.List<String> parts = new java.util.ArrayList<>();
        Long cur = wh.getId();
        java.util.Set<Long> visited = new java.util.HashSet<>();
        while (cur != null && allMap.containsKey(cur) && visited.add(cur)) {
            Warehouse w = allMap.get(cur);
            parts.add(0, w.getName());
            cur = w.getParentId();
        }
        if (parts.size() > 1) parts.remove(parts.size() - 1);
        return parts.isEmpty() ? "" : String.join(" / ", parts);
    }

    private synchronized String generateOrderNo() {
        String prefix = "SO";
        String dateStr = DateUtil.format(new Date(), "yyyyMMdd");
        String likePrefix = prefix + dateStr;
        // 查询当天所有订单（含子订单），取最大单号
        LambdaQueryWrapper<SalesOrder> wrapper = new LambdaQueryWrapper<SalesOrder>()
                .likeRight(SalesOrder::getOrderNo, likePrefix)
                .orderByDesc(SalesOrder::getOrderNo);
        Page<SalesOrder> page = salesOrderMapper.selectPage(new Page<>(1, 1), wrapper);
        int seq = 1;
        if (!page.getRecords().isEmpty()) {
            String lastNo = page.getRecords().get(0).getOrderNo();
            // 提取数字部分：SO202606290001-3 → 001，SO202606290005 → 005
            String numPart = lastNo.substring(prefix.length() + dateStr.length());
            int dashIdx = numPart.indexOf('-');
            if (dashIdx > 0) numPart = numPart.substring(0, dashIdx);
            seq = Integer.parseInt(numPart) + 1;
        }
        String orderNo = prefix + dateStr + String.format("%04d", seq);
        while (salesOrderMapper.selectCount(new LambdaQueryWrapper<SalesOrder>().eq(SalesOrder::getOrderNo, orderNo)) > 0) {
            seq++;
            orderNo = prefix + dateStr + String.format("%04d", seq);
        }
        return orderNo;
    }
}
