-- =====================================================
-- 修复05测试数据：将3级仓库的库存/单据转移到4级仓库
-- 设计原则：3级仓库为虚拟节点，不存放实际库存
-- =====================================================

USE `inventory`;

SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- 1. 仓库结构：删除3级仓库，让4级直接挂在2级下面
-- =====================================================

-- 先更新4级仓库的parent_id，从指向3级改为指向2级
UPDATE warehouse SET parent_id = 2 WHERE id IN (7, 8, 9);   -- 浦东-A/B/C → 上海分区
UPDATE warehouse SET parent_id = 2 WHERE id IN (10, 11);     -- 松江-A/B → 上海分区
UPDATE warehouse SET parent_id = 3 WHERE id IN (12, 13, 14); -- 杭州-A/B/C → 杭州分区

-- 删除3级仓库
DELETE FROM warehouse WHERE id IN (4, 5, 6);

-- =====================================================
-- 2. 库存表：将3级仓库的库存随机分配到对应4级仓库
-- =====================================================

-- 浦东主仓(id=4) → 浦东A区(7)、浦东B区(8)、浦东C区(9)
-- 按产品ID取模分配
UPDATE inventory SET warehouse_id = 7 WHERE warehouse_id = 4 AND product_id % 3 = 0;
UPDATE inventory SET warehouse_id = 8 WHERE warehouse_id = 4 AND product_id % 3 = 1;
UPDATE inventory SET warehouse_id = 9 WHERE warehouse_id = 4 AND product_id % 3 = 2;

-- 松江分仓(id=5) → 松江A区(10)、松江B区(11)
UPDATE inventory SET warehouse_id = 10 WHERE warehouse_id = 5 AND product_id % 2 = 0;
UPDATE inventory SET warehouse_id = 11 WHERE warehouse_id = 5 AND product_id % 2 = 1;

-- 杭州总仓(id=6) → 杭州A区(12)、杭州B区(13)、杭州C区(14)
UPDATE inventory SET warehouse_id = 12 WHERE warehouse_id = 6 AND product_id % 3 = 0;
UPDATE inventory SET warehouse_id = 13 WHERE warehouse_id = 6 AND product_id % 3 = 1;
UPDATE inventory SET warehouse_id = 14 WHERE warehouse_id = 6 AND product_id % 3 = 2;

-- =====================================================
-- 3. 采购单：3级仓库 → 对应4级仓库
-- =====================================================
UPDATE purchase_order SET warehouse_id = 7 WHERE warehouse_id = 4 AND id % 3 = 0;
UPDATE purchase_order SET warehouse_id = 8 WHERE warehouse_id = 4 AND id % 3 = 1;
UPDATE purchase_order SET warehouse_id = 9 WHERE warehouse_id = 4 AND id % 3 = 2;

UPDATE purchase_order SET warehouse_id = 10 WHERE warehouse_id = 5 AND id % 2 = 0;
UPDATE purchase_order SET warehouse_id = 11 WHERE warehouse_id = 5 AND id % 2 = 1;

UPDATE purchase_order SET warehouse_id = 12 WHERE warehouse_id = 6 AND id % 3 = 0;
UPDATE purchase_order SET warehouse_id = 13 WHERE warehouse_id = 6 AND id % 3 = 1;
UPDATE purchase_order SET warehouse_id = 14 WHERE warehouse_id = 6 AND id % 3 = 2;

-- =====================================================
-- 4. 销售单：3级仓库 → 对应4级仓库
-- =====================================================
UPDATE sales_order SET warehouse_id = 7 WHERE warehouse_id = 4 AND id % 3 = 0;
UPDATE sales_order SET warehouse_id = 8 WHERE warehouse_id = 4 AND id % 3 = 1;
UPDATE sales_order SET warehouse_id = 9 WHERE warehouse_id = 4 AND id % 3 = 2;

UPDATE sales_order SET warehouse_id = 10 WHERE warehouse_id = 5 AND id % 2 = 0;
UPDATE sales_order SET warehouse_id = 11 WHERE warehouse_id = 5 AND id % 2 = 1;

UPDATE sales_order SET warehouse_id = 12 WHERE warehouse_id = 6 AND id % 3 = 0;
UPDATE sales_order SET warehouse_id = 13 WHERE warehouse_id = 6 AND id % 3 = 1;
UPDATE sales_order SET warehouse_id = 14 WHERE warehouse_id = 6 AND id % 3 = 2;

-- =====================================================
-- 5. 调拨单：3级仓库 → 对应4级仓库
-- =====================================================
UPDATE inventory_transfer SET from_warehouse_id = 7 WHERE from_warehouse_id = 4 AND id % 3 = 0;
UPDATE inventory_transfer SET from_warehouse_id = 8 WHERE from_warehouse_id = 4 AND id % 3 = 1;
UPDATE inventory_transfer SET from_warehouse_id = 9 WHERE from_warehouse_id = 4 AND id % 3 = 2;
UPDATE inventory_transfer SET to_warehouse_id = 7 WHERE to_warehouse_id = 4 AND id % 3 = 0;
UPDATE inventory_transfer SET to_warehouse_id = 8 WHERE to_warehouse_id = 4 AND id % 3 = 1;
UPDATE inventory_transfer SET to_warehouse_id = 9 WHERE to_warehouse_id = 4 AND id % 3 = 2;

UPDATE inventory_transfer SET from_warehouse_id = 10 WHERE from_warehouse_id = 5 AND id % 2 = 0;
UPDATE inventory_transfer SET from_warehouse_id = 11 WHERE from_warehouse_id = 5 AND id % 2 = 1;
UPDATE inventory_transfer SET to_warehouse_id = 10 WHERE to_warehouse_id = 5 AND id % 2 = 0;
UPDATE inventory_transfer SET to_warehouse_id = 11 WHERE to_warehouse_id = 5 AND id % 2 = 1;

UPDATE inventory_transfer SET from_warehouse_id = 12 WHERE from_warehouse_id = 6 AND id % 3 = 0;
UPDATE inventory_transfer SET from_warehouse_id = 13 WHERE from_warehouse_id = 6 AND id % 3 = 1;
UPDATE inventory_transfer SET from_warehouse_id = 14 WHERE from_warehouse_id = 6 AND id % 3 = 2;
UPDATE inventory_transfer SET to_warehouse_id = 12 WHERE to_warehouse_id = 6 AND id % 3 = 0;
UPDATE inventory_transfer SET to_warehouse_id = 13 WHERE to_warehouse_id = 6 AND id % 3 = 1;
UPDATE inventory_transfer SET to_warehouse_id = 14 WHERE to_warehouse_id = 6 AND id % 3 = 2;

-- =====================================================
-- 6. 盘点单：3级仓库 → 对应4级仓库
-- =====================================================
UPDATE stock_take SET warehouse_id = 7 WHERE warehouse_id = 4;
UPDATE stock_take SET warehouse_id = 10 WHERE warehouse_id = 5;
UPDATE stock_take SET warehouse_id = 12 WHERE warehouse_id = 6;

-- =====================================================
-- 7. 库存流水：3级仓库 → 对应4级仓库
-- =====================================================
UPDATE inventory_log SET warehouse_id = 7 WHERE warehouse_id = 4 AND product_id % 3 = 0;
UPDATE inventory_log SET warehouse_id = 8 WHERE warehouse_id = 4 AND product_id % 3 = 1;
UPDATE inventory_log SET warehouse_id = 9 WHERE warehouse_id = 4 AND product_id % 3 = 2;

UPDATE inventory_log SET warehouse_id = 10 WHERE warehouse_id = 5 AND product_id % 2 = 0;
UPDATE inventory_log SET warehouse_id = 11 WHERE warehouse_id = 5 AND product_id % 2 = 1;

UPDATE inventory_log SET warehouse_id = 12 WHERE warehouse_id = 6 AND product_id % 3 = 0;
UPDATE inventory_log SET warehouse_id = 13 WHERE warehouse_id = 6 AND product_id % 3 = 1;
UPDATE inventory_log SET warehouse_id = 14 WHERE warehouse_id = 6 AND product_id % 3 = 2;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- 验证结果
-- =====================================================
SELECT '=== 仓库结构 ===' AS info;
SELECT id, name, level, parent_id FROM warehouse ORDER BY level, id;

SELECT '=== 库存分布 ===' AS info;
SELECT w.name, w.level, COUNT(i.id) AS cnt
FROM warehouse w LEFT JOIN inventory i ON w.id = i.warehouse_id
GROUP BY w.id, w.name, w.level
ORDER BY w.level, w.id;

SELECT '=== 单据分布 ===' AS info;
SELECT 'purchase' AS type, warehouse_id, COUNT(*) AS cnt FROM purchase_order GROUP BY warehouse_id
UNION ALL
SELECT 'sales', warehouse_id, COUNT(*) FROM sales_order GROUP BY warehouse_id;
