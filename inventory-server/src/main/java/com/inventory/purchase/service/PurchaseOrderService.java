package com.inventory.purchase.service;

import cn.hutool.core.date.DateUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.common.constant.OrderStatus;
import com.inventory.common.exception.BusinessException;
import com.inventory.customer.mapper.CustomerMapper;
import com.inventory.customer.entity.Customer;
import com.inventory.inventory.entity.Inventory;
import com.inventory.inventory.entity.InventoryLog;
import com.inventory.inventory.mapper.InventoryLogMapper;
import com.inventory.inventory.mapper.InventoryMapper;
import com.inventory.product.entity.Product;
import com.inventory.product.mapper.ProductMapper;
import com.inventory.purchase.entity.PurchaseOrder;
import com.inventory.purchase.entity.PurchaseOrderItem;
import com.inventory.purchase.mapper.PurchaseOrderItemMapper;
import com.inventory.purchase.mapper.PurchaseOrderMapper;
import com.inventory.supplier.entity.Supplier;
import com.inventory.supplier.mapper.SupplierMapper;
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
public class PurchaseOrderService {

    private final PurchaseOrderMapper purchaseOrderMapper;
    private final PurchaseOrderItemMapper purchaseOrderItemMapper;
    private final InventoryMapper inventoryMapper;
    private final InventoryLogMapper inventoryLogMapper;
    private final SupplierMapper supplierMapper;
    private final WarehouseMapper warehouseMapper;
    private final SysUserMapper userMapper;
    private final ProductMapper productMapper;

    public PurchaseOrderService(PurchaseOrderMapper purchaseOrderMapper,
                                PurchaseOrderItemMapper purchaseOrderItemMapper,
                                InventoryMapper inventoryMapper,
                                InventoryLogMapper inventoryLogMapper,
                                SupplierMapper supplierMapper,
                                WarehouseMapper warehouseMapper,
                                SysUserMapper userMapper,
                                ProductMapper productMapper) {
        this.purchaseOrderMapper = purchaseOrderMapper;
        this.purchaseOrderItemMapper = purchaseOrderItemMapper;
        this.inventoryMapper = inventoryMapper;
        this.inventoryLogMapper = inventoryLogMapper;
        this.supplierMapper = supplierMapper;
        this.warehouseMapper = warehouseMapper;
        this.userMapper = userMapper;
        this.productMapper = productMapper;
    }

    public Page<PurchaseOrder> page(Page<PurchaseOrder> page, String orderNo, Long supplierId, Long warehouseId,
                                    Integer minQuantity, Integer maxQuantity, Integer status,
                                    LocalDate startDate, LocalDate endDate) {
        LambdaQueryWrapper<PurchaseOrder> wrapper = new LambdaQueryWrapper<PurchaseOrder>()
                .like(orderNo != null, PurchaseOrder::getOrderNo, orderNo)
                .eq(supplierId != null, PurchaseOrder::getSupplierId, supplierId)
                .eq(warehouseId != null, PurchaseOrder::getWarehouseId, warehouseId)
                .ge(startDate != null, PurchaseOrder::getOrderDate, startDate)
                .le(endDate != null, PurchaseOrder::getOrderDate, endDate)
                .orderByDesc(PurchaseOrder::getId);

        wrapper.ne(PurchaseOrder::getStatus, OrderStatus.VOIDED);
        if (status != null) wrapper.eq(PurchaseOrder::getStatus, status);
        if (minQuantity != null) wrapper.ge(PurchaseOrder::getTotalQuantity, minQuantity);
        if (maxQuantity != null) wrapper.le(PurchaseOrder::getTotalQuantity, maxQuantity);

        Page<PurchaseOrder> result = purchaseOrderMapper.selectPage(page, wrapper);
        enrichOrdersBatch(result.getRecords());
        return result;
    }

    public List<PurchaseOrder> listAll() {
        List<PurchaseOrder> list = purchaseOrderMapper.selectList(
                new LambdaQueryWrapper<PurchaseOrder>().orderByDesc(PurchaseOrder::getId));
        enrichOrdersBatch(list);
        return list;
    }

    public PurchaseOrder getDetail(Long id) {
        PurchaseOrder order = purchaseOrderMapper.selectById(id);
        if (order != null) {
            List<PurchaseOrderItem> items = purchaseOrderItemMapper.selectList(
                    new LambdaQueryWrapper<PurchaseOrderItem>()
                            .eq(PurchaseOrderItem::getOrderId, id));
            order.setItems(items);
            enrichOrdersBatch(List.of(order));
        }
        return order;
    }

    /** 批量预加载所有关联数据，N 条订单只需固定次数 SQL */
    private void enrichOrdersBatch(List<PurchaseOrder> orders) {
        if (orders == null || orders.isEmpty()) return;
        // 收集所有订单ID + 关联实体ID
        Set<Long> orderIds = new HashSet<>();
        Set<Long> supplierIds = new HashSet<>();
        Set<Long> warehouseIds = new HashSet<>();
        Set<Long> userIds = new HashSet<>();
        for (PurchaseOrder o : orders) {
            orderIds.add(o.getId());
            if (o.getSupplierId() != null) supplierIds.add(o.getSupplierId());
            if (o.getWarehouseId() != null) warehouseIds.add(o.getWarehouseId());
            if (o.getOperatorId() != null) userIds.add(o.getOperatorId());
            if (o.getApproverId() != null) userIds.add(o.getApproverId());
        }
        // 批量加载订单明细
        List<PurchaseOrderItem> allItems = orderIds.isEmpty() ? List.of()
                : purchaseOrderItemMapper.selectList(
                    new LambdaQueryWrapper<PurchaseOrderItem>().in(PurchaseOrderItem::getOrderId, orderIds));
        Map<Long, List<PurchaseOrderItem>> itemMap = allItems.stream()
                .collect(Collectors.groupingBy(PurchaseOrderItem::getOrderId));
        // 收集明细中的商品ID
        Set<Long> productIds = allItems.stream().map(PurchaseOrderItem::getProductId)
                .filter(Objects::nonNull).collect(Collectors.toSet());
        // 批量加载关联实体
        Map<Long, Supplier> supplierMap = supplierIds.isEmpty() ? new HashMap<>()
                : supplierMapper.selectBatchIds(supplierIds).stream()
                    .collect(Collectors.toMap(Supplier::getId, s -> s, (a, b) -> a));
        Map<Long, Warehouse> warehouseMap = warehouseIds.isEmpty() ? new HashMap<>()
                : warehouseMapper.selectBatchIds(warehouseIds).stream()
                    .collect(Collectors.toMap(Warehouse::getId, w -> w, (a, b) -> a));
        Map<Long, SysUser> userMap = userIds.isEmpty() ? new HashMap<>()
                : userMapper.selectBatchIds(userIds).stream()
                    .collect(Collectors.toMap(SysUser::getId, u -> u, (a, b) -> a));
        Map<Long, Product> productMap = productIds.isEmpty() ? new HashMap<>()
                : productMapper.selectBatchIds(productIds).stream()
                    .collect(Collectors.toMap(Product::getId, p -> p, (a, b) -> a));
        // 纯内存组装
        for (PurchaseOrder o : orders) {
            Supplier s = supplierMap.get(o.getSupplierId());
            if (s != null) o.setSupplierName(s.getName());
            Warehouse w = warehouseMap.get(o.getWarehouseId());
            if (w != null) o.setWarehouseName(w.getName());
            SysUser op = userMap.get(o.getOperatorId());
            if (op != null) o.setOperatorName(op.getRealName());
            SysUser ap = userMap.get(o.getApproverId());
            if (ap != null) o.setApproverName(ap.getRealName());
            List<PurchaseOrderItem> items = itemMap.getOrDefault(o.getId(), List.of());
            for (PurchaseOrderItem item : items) {
                Product p = productMap.get(item.getProductId());
                if (p != null) { item.setProductName(p.getName()); item.setProductCode(p.getCode()); }
            }
            o.setItems(items);
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public Long create(PurchaseOrder order) {
        order.setOrderNo(generateOrderNo());
        order.setStatus(OrderStatus.DRAFT);
        order.setOrderDate(order.getOrderDate() != null ? order.getOrderDate() : LocalDate.now());

        BigDecimal totalAmount = BigDecimal.ZERO;
        int totalQty = 0;
        List<PurchaseOrderItem> items = order.getItems();
        if (items != null) {
            for (PurchaseOrderItem item : items) {
                if (item.getProductId() == null) {
                    throw new BusinessException("商品ID不能为空");
                }
                item.setOrderId(null);
                if (item.getUnitPrice() == null) item.setUnitPrice(BigDecimal.ZERO);
                BigDecimal amount = item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                item.setAmount(amount);
                totalAmount = totalAmount.add(amount);
                totalQty += item.getQuantity();
            }
        }
        order.setTotalAmount(totalAmount);
        order.setTotalQuantity(totalQty);

        purchaseOrderMapper.insert(order);

        if (items != null) {
            for (PurchaseOrderItem item : items) {
                item.setOrderId(order.getId());
                purchaseOrderItemMapper.insert(item);
            }
        }
        return order.getId();
    }

    @Transactional(rollbackFor = Exception.class)
    public synchronized void submit(Long id) {
        PurchaseOrder order = purchaseOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("采购单不存在");
        if (order.getStatus() != OrderStatus.DRAFT) throw new BusinessException("当前状态不可提交");
        order.setStatus(OrderStatus.PENDING);
        purchaseOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public synchronized void approve(Long id) {
        PurchaseOrder order = purchaseOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("采购单不存在");
        if (order.getStatus() != OrderStatus.PENDING) throw new BusinessException("当前状态不可审核");

        List<PurchaseOrderItem> items = purchaseOrderItemMapper.selectList(
                new LambdaQueryWrapper<PurchaseOrderItem>().eq(PurchaseOrderItem::getOrderId, id));

        for (PurchaseOrderItem item : items) {
            // 移动加权平均法：先计算该商品该仓库当前的库存总金额和总数量
            List<Inventory> existingBatches = inventoryMapper.selectList(
                    new LambdaQueryWrapper<Inventory>()
                            .eq(Inventory::getProductId, item.getProductId())
                            .eq(Inventory::getWarehouseId, order.getWarehouseId()));
            BigDecimal oldTotalValue = BigDecimal.ZERO;
            int oldTotalQty = 0;
            for (Inventory b : existingBatches) {
                if (b.getCostPrice() != null) {
                    oldTotalValue = oldTotalValue.add(
                            b.getCostPrice().multiply(BigDecimal.valueOf(b.getQuantity())));
                }
                oldTotalQty += b.getQuantity();
            }

            // 每次入库生成新的库存行（按入库日期区分），自动生成批次号
            String batchNo = (item.getBatchNo() != null && !item.getBatchNo().isEmpty())
                    ? item.getBatchNo()
                    : "IN" + order.getOrderDate().toString().replace("-", "");
            // 同一天同一商品多次入库，加序号区分
            long sameDayCount = inventoryMapper.selectCount(
                    new LambdaQueryWrapper<Inventory>()
                            .eq(Inventory::getProductId, item.getProductId())
                            .eq(Inventory::getWarehouseId, order.getWarehouseId())
                            .likeRight(Inventory::getBatchNo, batchNo));
            if (sameDayCount > 0) {
                batchNo = batchNo + "-" + (sameDayCount + 1);
            }
            Inventory inv = new Inventory();
            inv.setProductId(item.getProductId());
            inv.setWarehouseId(order.getWarehouseId());
            inv.setLocationId(order.getLocationId());
            inv.setBatchNo(batchNo);
            inv.setQuantity(item.getQuantity());
            inv.setLockedQty(0);
            // 该批次的成本价 = 入库时的采购单价
            BigDecimal batchCost = item.getUnitPrice() != null ? item.getUnitPrice() : BigDecimal.ZERO;
            inv.setCostPrice(batchCost);
            inventoryMapper.insert(inv);
            int beforeQty = oldTotalQty;
            int afterQty = oldTotalQty + item.getQuantity();

            InventoryLog log = new InventoryLog();
            log.setProductId(item.getProductId());
            log.setWarehouseId(order.getWarehouseId());
            log.setLocationId(order.getLocationId());
            log.setBatchNo(item.getBatchNo());
            log.setChangeType(OrderStatus.PURCHASE_IN);
            log.setChangeQty(item.getQuantity());
            log.setBeforeQty(beforeQty);
            log.setAfterQty(afterQty);
            log.setUnitPrice(item.getUnitPrice());
            log.setAmount(item.getAmount());
            log.setRefOrderNo(order.getOrderNo());
            log.setOperatorId(order.getOperatorId());
            log.setRemark("采购入库");
            inventoryLogMapper.insert(log);
        }

        order.setApproverId(cn.dev33.satoken.stp.StpUtil.getLoginIdAsLong());
        order.setApproveTime(LocalDateTime.now());
        order.setStatus(OrderStatus.CONFIRMED);
        purchaseOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void reject(Long id, String reason) {
        PurchaseOrder order = purchaseOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("采购单不存在");
        if (order.getStatus() != OrderStatus.PENDING) throw new BusinessException("当前状态不可驳回");
        order.setStatus(OrderStatus.DRAFT);
        order.setRemark((order.getRemark() != null ? order.getRemark() + " | " : "") + "驳回原因: " + (reason != null ? reason : ""));
        purchaseOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public synchronized void cancel(Long id) {
        PurchaseOrder order = purchaseOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("采购单不存在");
        if (order.getStatus() == OrderStatus.CANCELED) throw new BusinessException("采购单已取消");
        if (order.getStatus() == OrderStatus.VOIDED) throw new BusinessException("已作废的单据不可取消");

        if (order.getStatus() == OrderStatus.PENDING) {
            // 待审批状态仅管理员可取消
            long uid = cn.dev33.satoken.stp.StpUtil.getLoginIdAsLong();
            SysUser u = userMapper.selectById(uid);
            if (u == null || u.getRole() == null || u.getRole() != 1) {
                throw new BusinessException("待审批状态仅管理员可取消");
            }
            order.setStatus(OrderStatus.CANCELED);
            purchaseOrderMapper.updateById(order);
            return;
        }

        if (order.getStatus() == OrderStatus.CONFIRMED) {
            throw new BusinessException("已入库的单据不可取消，请使用作废功能（作废不会影响库存）");
        }

        order.setStatus(OrderStatus.CANCELED);
        purchaseOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateDraft(PurchaseOrder order) {
        PurchaseOrder existing = purchaseOrderMapper.selectById(order.getId());
        if (existing == null) throw new BusinessException("采购单不存在");
        if (existing.getStatus() != OrderStatus.DRAFT) throw new BusinessException("仅草稿状态可编辑");

        // 删除旧明细
        purchaseOrderItemMapper.delete(new LambdaQueryWrapper<PurchaseOrderItem>()
                .eq(PurchaseOrderItem::getOrderId, order.getId()));

        // 重新计算
        BigDecimal totalAmount = BigDecimal.ZERO;
        int totalQty = 0;
        List<PurchaseOrderItem> items = order.getItems();
        if (items != null) {
            for (PurchaseOrderItem item : items) {
                item.setId(null);
                item.setOrderId(order.getId());
                if (item.getUnitPrice() == null) item.setUnitPrice(BigDecimal.ZERO);
                BigDecimal amount = item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                item.setAmount(amount);
                totalAmount = totalAmount.add(amount);
                totalQty += item.getQuantity();
                purchaseOrderItemMapper.insert(item);
            }
        }
        order.setTotalAmount(totalAmount);
        order.setTotalQuantity(totalQty);
        purchaseOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        PurchaseOrder order = purchaseOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("采购单不存在");
        if (order.getStatus() == OrderStatus.CONFIRMED) throw new BusinessException("已入库的订单不能作废，请先取消");
        order.setStatus(OrderStatus.VOIDED);
        purchaseOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void batchDelete(List<Long> ids) {
        for (Long id : ids) {
            PurchaseOrder order = purchaseOrderMapper.selectById(id);
            if (order != null && order.getStatus() != OrderStatus.CONFIRMED) {
                order.setStatus(OrderStatus.VOIDED);
                purchaseOrderMapper.updateById(order);
            }
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void voidOrder(Long id, String reason) {
        PurchaseOrder order = purchaseOrderMapper.selectById(id);
        if (order == null) throw new BusinessException("采购单不存在");
        if (order.getStatus() == OrderStatus.CONFIRMED) throw new BusinessException("已确认的单据不可作废");
        order.setStatus(OrderStatus.VOIDED);
        order.setRemark((order.getRemark() != null ? order.getRemark() + " | " : "") + "作废原因: " + (reason != null ? reason : ""));
        order.setUpdateTime(LocalDateTime.now());
        purchaseOrderMapper.updateById(order);
    }

    @Transactional(rollbackFor = Exception.class)
    public void batchVoid(List<Long> ids, String reason) {
        for (Long id : ids) {
            voidOrder(id, reason);
        }
    }

    private synchronized String generateOrderNo() {
        String prefix = "PO";
        String dateStr = DateUtil.format(new Date(), "yyyyMMdd");
        String likePrefix = prefix + dateStr;
        LambdaQueryWrapper<PurchaseOrder> wrapper = new LambdaQueryWrapper<PurchaseOrder>()
                .likeRight(PurchaseOrder::getOrderNo, likePrefix)
                .orderByDesc(PurchaseOrder::getOrderNo);
        Page<PurchaseOrder> page = purchaseOrderMapper.selectPage(new Page<>(1, 1), wrapper);
        int seq = 1;
        if (!page.getRecords().isEmpty()) {
            String lastNo = page.getRecords().get(0).getOrderNo();
            seq = Integer.parseInt(lastNo.substring(lastNo.length() - 4)) + 1;
        }
        String orderNo = prefix + dateStr + String.format("%04d", seq);
        while (purchaseOrderMapper.selectCount(new LambdaQueryWrapper<PurchaseOrder>().eq(PurchaseOrder::getOrderNo, orderNo)) > 0) {
            seq++;
            orderNo = prefix + dateStr + String.format("%04d", seq);
        }
        return orderNo;
    }
}
