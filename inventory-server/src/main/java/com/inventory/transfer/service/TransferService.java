package com.inventory.transfer.service;

import cn.hutool.core.date.DateUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.inventory.common.constant.OrderStatus;
import com.inventory.common.exception.BusinessException;
import com.inventory.inventory.entity.Inventory;
import com.inventory.inventory.entity.InventoryLog;
import com.inventory.inventory.mapper.InventoryLogMapper;
import com.inventory.inventory.mapper.InventoryMapper;
import com.inventory.product.entity.Product;
import com.inventory.product.mapper.ProductMapper;
import cn.dev33.satoken.stp.StpUtil;
import com.inventory.system.entity.SysUser;
import com.inventory.system.mapper.SysUserMapper;
import com.inventory.transfer.entity.InventoryTransfer;
import com.inventory.transfer.entity.InventoryTransferItem;
import com.inventory.transfer.entity.TransferDetailExportVO;
import com.inventory.transfer.mapper.InventoryTransferItemMapper;
import com.inventory.transfer.mapper.InventoryTransferMapper;
import com.inventory.warehouse.entity.Warehouse;
import com.inventory.warehouse.mapper.WarehouseMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class TransferService {

    private final InventoryTransferMapper transferMapper;
    private final InventoryTransferItemMapper transferItemMapper;
    private final InventoryMapper inventoryMapper;
    private final InventoryLogMapper inventoryLogMapper;
    private final WarehouseMapper warehouseMapper;
    private final SysUserMapper userMapper;
    private final ProductMapper productMapper;

    public TransferService(InventoryTransferMapper transferMapper,
                           InventoryTransferItemMapper transferItemMapper,
                           InventoryMapper inventoryMapper,
                           InventoryLogMapper inventoryLogMapper,
                           WarehouseMapper warehouseMapper,
                           SysUserMapper userMapper,
                           ProductMapper productMapper) {
        this.transferMapper = transferMapper;
        this.transferItemMapper = transferItemMapper;
        this.inventoryMapper = inventoryMapper;
        this.inventoryLogMapper = inventoryLogMapper;
        this.warehouseMapper = warehouseMapper;
        this.userMapper = userMapper;
        this.productMapper = productMapper;
    }

    private boolean isAdmin() {
        try {
            long uid = StpUtil.getLoginIdAsLong();
            SysUser u = userMapper.selectById(uid);
            return u != null && u.getRole() != null && u.getRole() == 1;
        } catch (Exception e) {
            return false;
        }
    }

    public Page<InventoryTransfer> page(Page<InventoryTransfer> page, String orderNo,
                                        Long fromWarehouseId, Long toWarehouseId, Integer status,
                                        Integer minQuantity, Integer maxQuantity, String operatorName,
                                        LocalDate startDate, LocalDate endDate) {
        LocalDateTime startDateTime = startDate != null ? startDate.atStartOfDay() : null;
        LocalDateTime endDateTime = endDate != null ? endDate.atTime(LocalTime.MAX) : null;
        LambdaQueryWrapper<InventoryTransfer> wrapper = new LambdaQueryWrapper<InventoryTransfer>()
                .like(orderNo != null && !orderNo.isEmpty(), InventoryTransfer::getOrderNo, orderNo)
                .eq(fromWarehouseId != null, InventoryTransfer::getFromWarehouseId, fromWarehouseId)
                .eq(toWarehouseId != null, InventoryTransfer::getToWarehouseId, toWarehouseId)
                .eq(status != null, InventoryTransfer::getStatus, status)
                .ge(minQuantity != null, InventoryTransfer::getTotalQuantity, minQuantity)
                .le(maxQuantity != null, InventoryTransfer::getTotalQuantity, maxQuantity)
                .ge(startDateTime != null, InventoryTransfer::getCreateTime, startDateTime)
                .le(endDateTime != null, InventoryTransfer::getCreateTime, endDateTime)
                .ne(InventoryTransfer::getStatus, OrderStatus.VOIDED)
                .orderByDesc(InventoryTransfer::getId);
        Page<InventoryTransfer> result = transferMapper.selectPage(page, wrapper);
        enrichTransfersBatch(result.getRecords());

        if (operatorName != null && !operatorName.isEmpty()) {
            List<InventoryTransfer> filtered = result.getRecords().stream()
                    .filter(t -> t.getOperatorName() != null && t.getOperatorName().contains(operatorName))
                    .collect(Collectors.toList());
            result.setRecords(filtered);
            result.setTotal(filtered.size());
        }
        return result;
    }

    public List<InventoryTransfer> listAll() {
        List<InventoryTransfer> list = transferMapper.selectList(
                new LambdaQueryWrapper<InventoryTransfer>().orderByDesc(InventoryTransfer::getId));
        enrichTransfersBatch(list);
        return list;
    }

    public InventoryTransfer getDetail(Long id) {
        InventoryTransfer transfer = transferMapper.selectById(id);
        if (transfer != null) {
            List<InventoryTransferItem> items = transferItemMapper.selectList(
                    new LambdaQueryWrapper<InventoryTransferItem>()
                            .eq(InventoryTransferItem::getTransferId, id));
            transfer.setItems(items);
            enrichTransfersBatch(List.of(transfer));
        }
        return transfer;
    }

    private void enrichTransfersBatch(List<InventoryTransfer> transfers) {
        if (transfers == null || transfers.isEmpty()) return;
        Set<Long> transferIds = new HashSet<>();
        Set<Long> warehouseIds = new HashSet<>();
        Set<Long> userIds = new HashSet<>();
        for (InventoryTransfer t : transfers) {
            transferIds.add(t.getId());
            if (t.getFromWarehouseId() != null) warehouseIds.add(t.getFromWarehouseId());
            if (t.getToWarehouseId() != null) warehouseIds.add(t.getToWarehouseId());
            if (t.getOperatorId() != null) userIds.add(t.getOperatorId());
            if (t.getApproverId() != null) userIds.add(t.getApproverId());
        }
        List<InventoryTransferItem> allItems = transferIds.isEmpty() ? List.of()
                : transferItemMapper.selectList(
                    new LambdaQueryWrapper<InventoryTransferItem>().in(InventoryTransferItem::getTransferId, transferIds));
        Map<Long, List<InventoryTransferItem>> itemMap = allItems.stream()
                .collect(Collectors.groupingBy(InventoryTransferItem::getTransferId));
        Set<Long> productIds = allItems.stream().map(InventoryTransferItem::getProductId)
                .filter(Objects::nonNull).collect(Collectors.toSet());
        Map<Long, Warehouse> warehouseMap = warehouseIds.isEmpty() ? new HashMap<>()
                : warehouseMapper.selectBatchIds(warehouseIds).stream()
                    .collect(Collectors.toMap(Warehouse::getId, w -> w, (a, b) -> a));
        Map<Long, SysUser> userMap = userIds.isEmpty() ? new HashMap<>()
                : userMapper.selectBatchIds(userIds).stream()
                    .collect(Collectors.toMap(SysUser::getId, u -> u, (a, b) -> a));
        Map<Long, Product> productMap = productIds.isEmpty() ? new HashMap<>()
                : productMapper.selectBatchIds(productIds).stream()
                    .collect(Collectors.toMap(Product::getId, p -> p, (a, b) -> a));
        for (InventoryTransfer t : transfers) {
            Warehouse fw = warehouseMap.get(t.getFromWarehouseId());
            if (fw != null) t.setFromWarehouseName(fw.getName());
            Warehouse tw = warehouseMap.get(t.getToWarehouseId());
            if (tw != null) t.setToWarehouseName(tw.getName());
            SysUser op = userMap.get(t.getOperatorId());
            if (op != null) t.setOperatorName(op.getRealName());
            SysUser ap = userMap.get(t.getApproverId());
            if (ap != null) t.setApproverName(ap.getRealName());
            List<InventoryTransferItem> items = itemMap.getOrDefault(t.getId(), List.of());
            for (InventoryTransferItem item : items) {
                Product p = productMap.get(item.getProductId());
                if (p != null) { item.setProductName(p.getName()); item.setProductCode(p.getCode()); }
            }
            t.setItems(items);
        }
    }

    public List<TransferDetailExportVO> getExportDetailList(List<InventoryTransfer> list) {
        // 先批量预加载所有关联数据（items + products + warehouses + users）
        enrichTransfersBatch(list);
        List<TransferDetailExportVO> result = new ArrayList<>();
        for (InventoryTransfer t : list) {
            List<InventoryTransferItem> items = t.getItems() != null ? t.getItems() : List.of();
            for (InventoryTransferItem item : items) {
                TransferDetailExportVO vo = new TransferDetailExportVO();
                vo.setOrderNo(t.getOrderNo());
                vo.setFromWarehouseName(t.getFromWarehouseName());
                vo.setToWarehouseName(t.getToWarehouseName());
                vo.setStatus(t.getStatus() != null ? (t.getStatus() == 0 ? "草稿" : t.getStatus() == 1 ? "已完成" : t.getStatus() == 2 ? "已取消" : t.getStatus() == 4 ? "待审批" : "未知") : "未知");
                if (t.getOrderDate() != null) vo.setOrderDate(t.getOrderDate());
                if (t.getOperatorName() != null) vo.setOperatorName(t.getOperatorName());
                vo.setProductName(item.getProductName());
                vo.setProductCode(item.getProductCode());
                vo.setQuantity(item.getQuantity());
                vo.setBatchNo(item.getBatchNo());
                result.add(vo);
            }
            if (items.isEmpty()) {
                TransferDetailExportVO vo = new TransferDetailExportVO();
                vo.setOrderNo(t.getOrderNo());
                vo.setFromWarehouseName(t.getFromWarehouseName());
                vo.setToWarehouseName(t.getToWarehouseName());
                if (t.getOrderDate() != null) vo.setOrderDate(t.getOrderDate());
                if (t.getOperatorName() != null) vo.setOperatorName(t.getOperatorName());
                result.add(vo);
            }
        }
        return result;
    }

    @Transactional(rollbackFor = Exception.class)
    public Long create(InventoryTransfer transfer) {
        transfer.setOrderNo(generateOrderNo());
        transfer.setStatus(OrderStatus.DRAFT);
        if (transfer.getOrderDate() == null) {
            transfer.setOrderDate(LocalDate.now());
        }

        int totalQty = 0;
        List<InventoryTransferItem> items = transfer.getItems();
        if (items != null) {
            for (InventoryTransferItem item : items) {
                if (item.getProductId() == null) {
                    throw new BusinessException("商品ID不能为空");
                }
                item.setTransferId(null);
                totalQty += item.getQuantity();
            }
        }
        transfer.setTotalQuantity(totalQty);

        transferMapper.insert(transfer);

        if (items != null) {
            for (InventoryTransferItem item : items) {
                item.setTransferId(transfer.getId());
                transferItemMapper.insert(item);
            }
        }
        return transfer.getId();
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateDraft(InventoryTransfer transfer) {
        InventoryTransfer existing = transferMapper.selectById(transfer.getId());
        if (existing == null) throw new BusinessException("调拨单不存在");
        if (existing.getStatus() != OrderStatus.DRAFT) throw new BusinessException("仅草稿状态可编辑");

        // 删除旧明细
        transferItemMapper.delete(new LambdaQueryWrapper<InventoryTransferItem>()
                .eq(InventoryTransferItem::getTransferId, transfer.getId()));

        // 重新计算总数量
        int totalQty = 0;
        List<InventoryTransferItem> items = transfer.getItems();
        if (items != null) {
            for (InventoryTransferItem item : items) {
                item.setId(null);
                item.setTransferId(transfer.getId());
                if (item.getProductId() == null) {
                    throw new BusinessException("商品ID不能为空");
                }
                totalQty += item.getQuantity();
                transferItemMapper.insert(item);
            }
        }
        transfer.setTotalQuantity(totalQty);
        // 保留仓库信息（fromWarehouseId/toWarehouseId 应由控制器设好）
        if (transfer.getFromWarehouseId() == null) transfer.setFromWarehouseId(existing.getFromWarehouseId());
        if (transfer.getToWarehouseId() == null) transfer.setToWarehouseId(existing.getToWarehouseId());
        transferMapper.updateById(transfer);
    }

    @Transactional(rollbackFor = Exception.class)
    public synchronized void submit(Long id) {
        InventoryTransfer transfer = transferMapper.selectById(id);
        if (transfer == null) throw new BusinessException("调拨单不存在");
        if (transfer.getStatus() != OrderStatus.DRAFT) throw new BusinessException("当前状态不可提交");
        transfer.setStatus(OrderStatus.PENDING);
        transferMapper.updateById(transfer);
    }

    @Transactional(rollbackFor = Exception.class)
    public synchronized void approve(Long id) {
        InventoryTransfer transfer = transferMapper.selectById(id);
        if (transfer == null) throw new BusinessException("调拨单不存在");
        if (transfer.getStatus() != OrderStatus.PENDING) throw new BusinessException("当前状态不可审核");

        List<InventoryTransferItem> items = transferItemMapper.selectList(
                new LambdaQueryWrapper<InventoryTransferItem>().eq(InventoryTransferItem::getTransferId, id));

        // 扣减源仓库库存（优先指定批次，否则后进先出）
        for (InventoryTransferItem item : items) {
            int toReduce = item.getQuantity();
            int totalBefore;

            if (item.getBatchNo() != null && !item.getBatchNo().isEmpty()) {
                // 指定批次：只从该批次扣
                Inventory target = inventoryMapper.selectOne(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getProductId, item.getProductId())
                                .eq(Inventory::getWarehouseId, transfer.getFromWarehouseId())
                                .eq(Inventory::getBatchNo, item.getBatchNo()));
                if (target == null || target.getQuantity() < toReduce) {
                    throw new BusinessException("所选批次库存不足");
                }
                totalBefore = target.getQuantity();
                target.setQuantity(totalBefore - toReduce);
                inventoryMapper.updateById(target);
            } else {
                // 未指定批次：后进先出
                List<Inventory> batches = inventoryMapper.selectList(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getProductId, item.getProductId())
                                .eq(Inventory::getWarehouseId, transfer.getFromWarehouseId())
                                .gt(Inventory::getQuantity, 0)
                                .orderByDesc(Inventory::getCreateTime));
                int totalAvailable = batches.stream().mapToInt(Inventory::getQuantity).sum();
                if (totalAvailable < toReduce) {
                    throw new BusinessException("商品库存不足（可用: " + totalAvailable + "，需调拨: " + toReduce + "）");
                }
                totalBefore = totalAvailable;
                for (Inventory inv : batches) {
                    if (toReduce <= 0) break;
                    int reduce = Math.min(inv.getQuantity(), toReduce);
                    inv.setQuantity(inv.getQuantity() - reduce);
                    toReduce -= reduce;
                    inventoryMapper.updateById(inv);
                }
            }
            InventoryLog outLog = new InventoryLog();
            outLog.setProductId(item.getProductId());
            outLog.setWarehouseId(transfer.getFromWarehouseId());
            outLog.setChangeType("TRANSFER_OUT");
            outLog.setChangeQty(-item.getQuantity());
            outLog.setBeforeQty(totalBefore);
            outLog.setAfterQty(totalBefore - item.getQuantity());
            outLog.setRefOrderNo(transfer.getOrderNo());
            outLog.setOperatorId(transfer.getOperatorId());
            outLog.setRemark("调拨出库");
            inventoryLogMapper.insert(outLog);
        }

        // 增加目标仓库库存（每次调入生成新批次行）
        for (InventoryTransferItem item : items) {
            // 获取调出仓库该商品的成本价（优先取指定批次）
            List<Inventory> srcBatches;
            if (item.getBatchNo() != null && !item.getBatchNo().isEmpty()) {
                srcBatches = inventoryMapper.selectList(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getProductId, item.getProductId())
                                .eq(Inventory::getWarehouseId, transfer.getFromWarehouseId())
                                .eq(Inventory::getBatchNo, item.getBatchNo()));
            } else {
                srcBatches = inventoryMapper.selectList(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getProductId, item.getProductId())
                                .eq(Inventory::getWarehouseId, transfer.getFromWarehouseId()));
            }
            BigDecimal srcCost = BigDecimal.ZERO;
            if (!srcBatches.isEmpty() && srcBatches.get(0).getCostPrice() != null) {
                srcCost = srcBatches.get(0).getCostPrice();
            }

            // 计算目标仓库调整前的总金额和总数量
            List<Inventory> destBatches = inventoryMapper.selectList(
                    new LambdaQueryWrapper<Inventory>()
                            .eq(Inventory::getProductId, item.getProductId())
                            .eq(Inventory::getWarehouseId, transfer.getToWarehouseId()));
            BigDecimal destOldValue = BigDecimal.ZERO;
            int destOldQty = 0;
            for (Inventory b : destBatches) {
                if (b.getCostPrice() != null) {
                    destOldValue = destOldValue.add(
                            b.getCostPrice().multiply(BigDecimal.valueOf(b.getQuantity())));
                }
                destOldQty += b.getQuantity();
            }

            // 每次调入生成新库存行
            String inBatchNo = (item.getBatchNo() != null && !item.getBatchNo().isEmpty())
                    ? item.getBatchNo()
                    : "TR" + transfer.getOrderDate().toString().replace("-", "");
            long sameDayCount = inventoryMapper.selectCount(
                    new LambdaQueryWrapper<Inventory>()
                            .eq(Inventory::getProductId, item.getProductId())
                            .eq(Inventory::getWarehouseId, transfer.getToWarehouseId())
                            .likeRight(Inventory::getBatchNo, inBatchNo));
            if (sameDayCount > 0) inBatchNo = inBatchNo + "-" + (sameDayCount + 1);
            Inventory inv = new Inventory();
            inv.setProductId(item.getProductId());
            inv.setWarehouseId(transfer.getToWarehouseId());
            inv.setBatchNo(inBatchNo);
            // 成本价沿用源仓库该批次的成本价
            inv.setCostPrice(srcCost);
            inv.setQuantity(item.getQuantity());
            inv.setLockedQty(0);
            inventoryMapper.insert(inv);

            // 记录调入日志
            InventoryLog inLog = new InventoryLog();
            inLog.setProductId(item.getProductId());
            inLog.setWarehouseId(transfer.getToWarehouseId());
            inLog.setBatchNo(item.getBatchNo());
            inLog.setChangeType("TRANSFER_IN");
            inLog.setChangeQty(item.getQuantity());
            inLog.setBeforeQty(destOldQty);
            inLog.setAfterQty(destOldQty + item.getQuantity());
            inLog.setRefOrderNo(transfer.getOrderNo());
            inLog.setOperatorId(transfer.getOperatorId());
            inLog.setRemark("调拨入库");
            inventoryLogMapper.insert(inLog);
        }

        transfer.setApproverId(cn.dev33.satoken.stp.StpUtil.getLoginIdAsLong());
        transfer.setApproveTime(LocalDateTime.now());
        transfer.setStatus(OrderStatus.CONFIRMED);
        transferMapper.updateById(transfer);
    }

    @Transactional(rollbackFor = Exception.class)
    public void reject(Long id, String reason) {
        InventoryTransfer transfer = transferMapper.selectById(id);
        if (transfer == null) throw new BusinessException("调拨单不存在");
        if (transfer.getStatus() != OrderStatus.PENDING) throw new BusinessException("当前状态不可驳回");
        transfer.setStatus(OrderStatus.DRAFT);
        transfer.setRemark((transfer.getRemark() != null ? transfer.getRemark() + " | " : "") + "驳回原因: " + (reason != null ? reason : ""));
        transferMapper.updateById(transfer);
    }

    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        InventoryTransfer transfer = transferMapper.selectById(id);
        if (transfer == null) throw new BusinessException("调拨单不存在");
        if (transfer.getStatus() == OrderStatus.CONFIRMED) throw new BusinessException("已完成调拨单不可作废");
        transfer.setStatus(OrderStatus.VOIDED);
        transferMapper.updateById(transfer);
    }

    @Transactional(rollbackFor = Exception.class)
    public void batchDelete(List<Long> ids) {
        for (Long id : ids) {
            InventoryTransfer transfer = transferMapper.selectById(id);
            if (transfer != null) {
                transfer.setStatus(OrderStatus.VOIDED);
                transferMapper.updateById(transfer);
            }
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void voidOrder(Long id, String reason) {
        InventoryTransfer transfer = transferMapper.selectById(id);
        if (transfer == null) throw new BusinessException("调拨单不存在");
        if (transfer.getStatus() == OrderStatus.CONFIRMED) throw new BusinessException("已确认的单据不可作废");
        transfer.setStatus(OrderStatus.VOIDED);
        transfer.setRemark((transfer.getRemark() != null ? transfer.getRemark() + " | " : "") + "作废原因: " + (reason != null ? reason : ""));
        transfer.setUpdateTime(LocalDateTime.now());
        transferMapper.updateById(transfer);
    }

    @Transactional(rollbackFor = Exception.class)
    public void batchVoid(List<Long> ids, String reason) {
        for (Long id : ids) {
            voidOrder(id, reason);
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public synchronized void cancel(Long id) {
        InventoryTransfer transfer = transferMapper.selectById(id);
        if (transfer == null) throw new BusinessException("调拨单不存在");
        if (transfer.getStatus() == OrderStatus.CANCELED) throw new BusinessException("调拨单已取消");
        if (transfer.getStatus() == OrderStatus.VOIDED) throw new BusinessException("已作废的单据不可取消");

        if (transfer.getStatus() == OrderStatus.PENDING) {
            long uid = cn.dev33.satoken.stp.StpUtil.getLoginIdAsLong();
            SysUser u = userMapper.selectById(uid);
            if (u == null || u.getRole() == null || u.getRole() != 1) {
                throw new BusinessException("待审批状态仅管理员可取消");
            }
            transfer.setStatus(OrderStatus.CANCELED);
            transferMapper.updateById(transfer);
            return;
        }

        // 如果已确认，需要回滚库存
        if (transfer.getStatus() == OrderStatus.CONFIRMED) {
            // 已完成状态仅管理员可取消（涉及库存回滚）
            long uid = cn.dev33.satoken.stp.StpUtil.getLoginIdAsLong();
            SysUser u = userMapper.selectById(uid);
            if (u == null || u.getRole() == null || u.getRole() != 1) {
                throw new BusinessException("已完成状态仅管理员可取消");
            }
            List<InventoryTransferItem> items = transferItemMapper.selectList(
                    new LambdaQueryWrapper<InventoryTransferItem>().eq(InventoryTransferItem::getTransferId, id));

            // 回滚目标仓库：从最新批次扣减（后进先出）
            for (InventoryTransferItem item : items) {
                List<Inventory> batches = inventoryMapper.selectList(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getProductId, item.getProductId())
                                .eq(Inventory::getWarehouseId, transfer.getToWarehouseId())
                                .gt(Inventory::getQuantity, 0)
                                .orderByDesc(Inventory::getCreateTime));
                int totalAvailable = batches.stream().mapToInt(Inventory::getQuantity).sum();
                if (totalAvailable < item.getQuantity()) {
                    throw new BusinessException("目标仓库库存不足，无法取消调拨");
                }
                int toReduce = item.getQuantity();
                for (Inventory inv : batches) {
                    if (toReduce <= 0) break;
                    int beforeQty = inv.getQuantity();
                    int reduce = Math.min(beforeQty, toReduce);
                    inv.setQuantity(beforeQty - reduce);
                    toReduce -= reduce;
                    inventoryMapper.updateById(inv);
                }
                InventoryLog log = new InventoryLog();
                log.setProductId(item.getProductId());
                log.setWarehouseId(transfer.getToWarehouseId());
                log.setChangeType("TRANSFER_CANCEL");
                log.setChangeQty(-item.getQuantity());
                log.setBeforeQty(totalAvailable);
                log.setAfterQty(totalAvailable - item.getQuantity());
                log.setRefOrderNo(transfer.getOrderNo());
                log.setOperatorId(transfer.getOperatorId());
                log.setRemark("调拨取消，回滚入库库存");
                inventoryLogMapper.insert(log);
            }

            // 回滚源仓库：创建新库存行恢复调出的库存
            for (InventoryTransferItem item : items) {
                String retBatchNo = "TRRET" + transfer.getOrderDate().toString().replace("-", "");
                long sameDayCount = inventoryMapper.selectCount(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getProductId, item.getProductId())
                                .eq(Inventory::getWarehouseId, transfer.getFromWarehouseId())
                                .likeRight(Inventory::getBatchNo, retBatchNo));
                if (sameDayCount > 0) retBatchNo = retBatchNo + "-" + (sameDayCount + 1);
                Inventory inv = new Inventory();
                inv.setProductId(item.getProductId());
                inv.setWarehouseId(transfer.getFromWarehouseId());
                inv.setBatchNo(retBatchNo);
                inv.setQuantity(item.getQuantity());
                inv.setLockedQty(0);
                // 沿用该仓库当前均价
                List<Inventory> allSrcBatches = inventoryMapper.selectList(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getProductId, item.getProductId())
                                .eq(Inventory::getWarehouseId, transfer.getFromWarehouseId()));
                BigDecimal totalValue = BigDecimal.ZERO;
                int totalQty = 0;
                for (Inventory b : allSrcBatches) {
                    if (b.getQuantity() > 0 && b.getCostPrice() != null) {
                        totalValue = totalValue.add(b.getCostPrice().multiply(BigDecimal.valueOf(b.getQuantity())));
                        totalQty += b.getQuantity();
                    }
                }
                inv.setCostPrice(totalQty > 0 ? totalValue.divide(BigDecimal.valueOf(totalQty), 4, RoundingMode.HALF_UP) : BigDecimal.ZERO);
                inventoryMapper.insert(inv);
                InventoryLog log = new InventoryLog();
                log.setProductId(item.getProductId());
                log.setWarehouseId(transfer.getFromWarehouseId());
                log.setChangeType("TRANSFER_CANCEL");
                log.setChangeQty(item.getQuantity());
                log.setBeforeQty(totalQty);
                log.setAfterQty(totalQty + item.getQuantity());
                log.setRefOrderNo(transfer.getOrderNo());
                log.setOperatorId(transfer.getOperatorId());
                log.setRemark("调拨取消，回滚出库库存");
                inventoryLogMapper.insert(log);
            }
        }

        transfer.setStatus(OrderStatus.CANCELED);
        transferMapper.updateById(transfer);
    }

    private synchronized String generateOrderNo() {
        String prefix = "DB";
        String dateStr = DateUtil.format(new Date(), "yyyyMMdd");
        String likePrefix = prefix + dateStr;
        LambdaQueryWrapper<InventoryTransfer> wrapper = new LambdaQueryWrapper<InventoryTransfer>()
                .likeRight(InventoryTransfer::getOrderNo, likePrefix)
                .orderByDesc(InventoryTransfer::getOrderNo);
        Page<InventoryTransfer> page = transferMapper.selectPage(new Page<>(1, 1), wrapper);
        int seq = 1;
        if (!page.getRecords().isEmpty()) {
            String lastNo = page.getRecords().get(0).getOrderNo();
            seq = Integer.parseInt(lastNo.substring(lastNo.length() - 4)) + 1;
        }
        String orderNo = prefix + dateStr + String.format("%04d", seq);
        while (transferMapper.selectCount(new LambdaQueryWrapper<InventoryTransfer>().eq(InventoryTransfer::getOrderNo, orderNo)) > 0) {
            seq++;
            orderNo = prefix + dateStr + String.format("%04d", seq);
        }
        return orderNo;
    }
}
