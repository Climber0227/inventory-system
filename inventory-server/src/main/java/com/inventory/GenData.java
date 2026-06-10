package com.inventory;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 极限负载测试数据生成器（纯 JDBC，不依赖 Spring）。
 *
 * 运行：mvn compile exec:java "-Dexec.mainClass=com.inventory.GenData"
 *
 * 生成约：
 *   3,800 仓库 | 500 商品 | 6 万库存
 *   500 采购单 | 1,000 销售单 | 8 千条库存流水
 */
public class GenData {

    // ============ 数据量配置 ============
    static final int L1 = 7, L2_PER_L1 = 10, L3_PER_L2 = 6, L4_PER_L3 = 8;
    // 仓库: L1=7 + L2=70 + L3=420 + L4=3360 = 3,857

    static final int CATS = 10, PROD_PER_CAT = 50;               // 500 商品
    static final int INV_MIN = 5, INV_MAX = 30;                  // 每叶子仓库库存数
    // 预估库存: 3360 × avg(17) ≈ 5.7 万条

    static final int PURCHASE_ORDERS = 500;                      // 采购单
    static final int SALES_ORDERS = 1000;                        // 销售单
    static final int ITEMS_MIN = 3, ITEMS_MAX = 8;               // 每单明细数
    // ====================================

    static final String URL  = "jdbc:mysql://localhost:3306/inventory?useUnicode=true&connectionCollation=utf8mb4_unicode_ci&serverTimezone=Asia/Shanghai&rewriteBatchedStatements=true";
    static final String USER = "root";
    static final String PASS = "123456";

    static final ThreadLocalRandom R = ThreadLocalRandom.current();
    static final DateTimeFormatter DF = DateTimeFormatter.ofPattern("yyyyMMdd");

    static final String[] UNITS  = {"个","箱","KG","瓶","袋","包","卷","盒","桶","件"};
    static final String[] SPECS  = {"标准","大号","小号","A型","B型","通用","加厚","轻型","加强版","普通"};
    static final String[] WORDS  = {"耐磨","防潮","速干","高强度","环保","食品级","医疗级","工业级",
            "加厚型","轻量","防静电","耐高温","耐低温","防腐蚀","高精度","快拆","折叠","便携","静音","节能","智能"};
    static final String[] REGIONS = {"华东","华南","华北","华中","西南","西北","东北"};
    static final String[] CITIES  = {"上海","广州","北京","武汉","成都","西安","沈阳","深圳","杭州","南京",
            "重庆","天津","苏州","郑州","长沙","青岛","大连","厦门","福州","合肥"};

    // 缓存：叶子仓库ID列表、商品ID列表
    static List<Long> leafWhIds = new ArrayList<>();
    static List<Long> productIds = new ArrayList<>();

    public static void main(String[] args) throws Exception {
        System.out.println("╔══════════════════════════════════════╗");
        System.out.println("║   极限负载测试数据生成器              ║");
        System.out.println("╚══════════════════════════════════════╝");
        System.out.printf("仓库目标: ~%d | 商品: %d | 库存: ~144万%n",
                L1 + L1*L2_PER_L1 + L1*L2_PER_L1*L3_PER_L2 + L1*L2_PER_L1*L3_PER_L2*L4_PER_L3,
                CATS * PROD_PER_CAT);
        System.out.printf("采购单: %d | 销售单: %d%n", PURCHASE_ORDERS, SALES_ORDERS);
        System.out.println();
        long t0 = System.currentTimeMillis();

        try (Connection c = DriverManager.getConnection(URL, USER, PASS)) {
            c.setAutoCommit(false);

            // ── 清空 ──
            System.out.print("清空旧数据... ");
            long t = System.currentTimeMillis();
            try (Statement s = c.createStatement()) {
                s.execute("SET FOREIGN_KEY_CHECKS=0");
                s.execute("TRUNCATE TABLE inventory_log");
                s.execute("TRUNCATE TABLE inventory");
                s.execute("TRUNCATE TABLE purchase_order_item");
                s.execute("TRUNCATE TABLE purchase_order");
                s.execute("TRUNCATE TABLE sales_order_item");
                s.execute("TRUNCATE TABLE sales_order");
                s.execute("TRUNCATE TABLE inventory_transfer_item");
                s.execute("TRUNCATE TABLE inventory_transfer");
                s.execute("TRUNCATE TABLE stock_take_item");
                s.execute("TRUNCATE TABLE stock_take");
                s.execute("TRUNCATE TABLE product");
                s.execute("TRUNCATE TABLE warehouse");
                s.execute("SET FOREIGN_KEY_CHECKS=1");
            }
            System.out.printf("完成 (%dms)%n", System.currentTimeMillis() - t);

            // ── 1. 仓库 ──
            System.out.println("[1/5] 生成仓库...");
            t = System.currentTimeMillis();
            genWarehouses(c);
            System.out.printf("  仓库: %d 个 (叶子 %d)，耗时 %dms%n",
                    L1 + L1*L2_PER_L1 + L1*L2_PER_L1*L3_PER_L2 + leafWhIds.size(),
                    leafWhIds.size(), System.currentTimeMillis() - t);

            // ── 2. 商品 ──
            System.out.println("[2/5] 生成商品...");
            t = System.currentTimeMillis();
            genProducts(c);
            System.out.printf("  商品: %d 个，耗时 %dms%n", productIds.size(), System.currentTimeMillis() - t);

            // ── 3. 库存 ──
            System.out.printf("[3/5] 生成库存 (%d~%d 条/仓库)...%n", INV_MIN, INV_MAX);
            t = System.currentTimeMillis();
            int invCount = genInventory(c);
            System.out.printf("  库存: %d 条，耗时 %dms%n", invCount, System.currentTimeMillis() - t);

            // ── 4. 采购单 + 明细 + 流水 ──
            System.out.printf("[4/5] 生成采购单 (%d 单)...%n", PURCHASE_ORDERS);
            t = System.currentTimeMillis();
            int[] po = genPurchaseOrders(c);
            System.out.printf("  采购单: %d 单, 明细: %d 条, 流水: %d 条，耗时 %dms%n",
                    po[0], po[1], po[2], System.currentTimeMillis() - t);

            // ── 5. 销售单 + 明细 + 流水 ──
            System.out.printf("[5/5] 生成销售单 (%d 单)...%n", SALES_ORDERS);
            t = System.currentTimeMillis();
            int[] so = genSalesOrders(c);
            System.out.printf("  销售单: %d 单, 明细: %d 条, 流水: %d 条，耗时 %dms%n",
                    so[0], so[1], so[2], System.currentTimeMillis() - t);

            // ── 汇总 ──
            long totalMs = System.currentTimeMillis() - t0;
            System.out.println();
            System.out.println("╔══════════════════════════════════════╗");
            System.out.printf("║  生成完毕! 总耗时 %6d ms (%d s)║%n", totalMs, totalMs / 1000);
            System.out.println("╠══════════════════════════════════════╣");
            System.out.printf("║  仓库: %5d  (叶子 %5d)   ║%n",
                    L1 + L1*L2_PER_L1 + L1*L2_PER_L1*L3_PER_L2 + leafWhIds.size(), leafWhIds.size());
            System.out.printf("║  商品: %5d                        ║%n", productIds.size());
            System.out.printf("║  库存: %6d                     ║%n", invCount);
            System.out.printf("║  采购单: %4d  明细: %5d       ║%n", po[0], po[1]);
            System.out.printf("║  销售单: %4d  明细: %5d       ║%n", so[0], so[1]);
            System.out.printf("║  流水:   %5d                     ║%n", po[2] + so[2]);
            System.out.println("╚══════════════════════════════════════╝");
        }
    }

    // ======================== 仓库 ========================
    static void genWarehouses(Connection c) throws SQLException {
        String sql = "INSERT INTO warehouse (code,name,level,parent_id,status,contact,phone,address) VALUES (?,?,?,?,1,?,?,?)";
        long code = 1;

        try (PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            for (int i1 = 1; i1 <= L1; i1++) {
                String r = REGIONS[(i1-1) % REGIONS.length];
                long id1 = insWh(ps, c, code++, r + "大区-" + p(i1), 1, null);
                for (int i2 = 1; i2 <= L2_PER_L1; i2++) {
                    String city = CITIES[(i1*i2 + i2) % CITIES.length];
                    long id2 = insWh(ps, c, code++, r + "-" + city + "-分拨" + p(i2), 2, id1);
                    for (int i3 = 1; i3 <= L3_PER_L2; i3++) {
                        long id3 = insWh(ps, c, code++, r + "-" + city + "-仓" + p(i3), 3, id2);
                        for (int i4 = 1; i4 <= L4_PER_L3; i4++) {
                            long id4 = insWh(ps, c, code++, r + "-" + city + "-库位" + p(i4), 4, id3);
                            leafWhIds.add(id4);
                        }
                    }
                    if (i2 % 10 == 0) c.commit();
                }
                if (i1 % 5 == 0) { c.commit(); System.out.printf("  ... L1=%d/%d%n", i1, L1); }
            }
            c.commit();
        }
    }

    static long insWh(PreparedStatement ps, Connection c, long code, String name, int level, Long parentId) throws SQLException {
        ps.setString(1, "WH" + String.format("%08d", code));
        ps.setString(2, name);
        ps.setInt(3, level);
        if (parentId != null) ps.setLong(4, parentId); else ps.setNull(4, Types.BIGINT);
        ps.setString(5, "联系人-" + name.substring(Math.max(0, name.length()-6)));
        ps.setString(6, "138" + String.format("%08d", R.nextInt(100000000)));
        ps.setString(7, name + " 详细地址");
        ps.executeUpdate();
        try (ResultSet rs = ps.getGeneratedKeys()) { rs.next(); return rs.getLong(1); }
    }

    // ======================== 商品 ========================
    static void genProducts(Connection c) throws SQLException {
        String sql = "INSERT INTO product (code,name,category_id,spec,unit,purchase_price,sale_price,min_stock,max_stock,status) VALUES (?,?,?,?,?,?,?,?,?,1)";
        long code = 1;

        try (PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            for (int cat = 1; cat <= CATS; cat++) {
                String cn = "分类-" + p(cat);
                for (int i = 1; i <= PROD_PER_CAT; i++) {
                    ps.setString(1, "GD" + String.format("%010d", code++));
                    ps.setString(2, cn + "-商品" + p(i) + "-" + WORDS[R.nextInt(WORDS.length)]);
                    ps.setLong(3, cat);
                    ps.setString(4, SPECS[R.nextInt(SPECS.length)]);
                    ps.setString(5, UNITS[R.nextInt(UNITS.length)]);
                    double purchase = 1 + R.nextDouble() * 499;
                    ps.setBigDecimal(6, BigDecimal.valueOf(purchase).setScale(2, RoundingMode.HALF_UP));
                    ps.setBigDecimal(7, BigDecimal.valueOf(purchase * (1.1 + R.nextDouble() * 0.9)).setScale(2, RoundingMode.HALF_UP));
                    ps.setInt(8, 5 + R.nextInt(50));
                    ps.setInt(9, 200 + R.nextInt(500));
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) { rs.next(); productIds.add(rs.getLong(1)); }
                }
                if (cat % 10 == 0) { c.commit(); System.out.printf("  ... %d/%d%n", cat, CATS); }
            }
            c.commit();
        }
    }

    // ======================== 库存 ========================
    static int genInventory(Connection c) throws SQLException {
        String sql = "INSERT INTO inventory (product_id,warehouse_id,quantity,locked_qty,cost_price,batch_no) VALUES (?,?,?,0,?,?)";
        int total = 0, batchSize = 2000, milestone = 100000;
        int nextMilestone = milestone;

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            int batch = 0;
            for (int wi = 0; wi < leafWhIds.size(); wi++) {
                Long whId = leafWhIds.get(wi);
                int count = R.nextInt(INV_MIN, INV_MAX + 1);
                Set<Long> used = new HashSet<>();
                for (int i = 0; i < count; i++) {
                    Long pId;
                    do { pId = productIds.get(R.nextInt(productIds.size())); } while (!used.add(pId));
                    ps.setLong(1, pId);
                    ps.setLong(2, whId);
                    ps.setInt(3, R.nextInt(1, 500));
                    ps.setBigDecimal(4, BigDecimal.valueOf(1 + R.nextDouble() * 499).setScale(2, RoundingMode.HALF_UP));
                    ps.setString(5, "B" + String.format("%06d", R.nextInt(1, 999999)));
                    ps.addBatch();
                    batch++; total++;
                    if (batch >= batchSize) {
                        ps.executeBatch(); c.commit(); batch = 0;
                        if (total >= nextMilestone) {
                            System.out.printf("  ... %d 万条%n", total / 10000);
                            nextMilestone += milestone;
                        }
                    }
                }
                if (wi > 0 && wi % 500 == 0) System.out.printf("  ... 仓库 %d/%d, 库存 %d%n", wi, leafWhIds.size(), total);
            }
            if (batch > 0) { ps.executeBatch(); c.commit(); }
        }
        return total;
    }

    // ======================== 采购单 ========================
    static int[] genPurchaseOrders(Connection c) throws SQLException {
        int orderCount = 0, itemCount = 0, logCount = 0;
        String fmt = "yyyy-MM-dd";
        LocalDate today = LocalDate.now();

        String orderSql = "INSERT INTO purchase_order (order_no,supplier_id,warehouse_id,total_amount,total_quantity,status,operator_id,approver_id,approve_time,order_date) VALUES (?,NULL,?,?,?,1,1,1,?,?)";
        String itemSql = "INSERT INTO purchase_order_item (order_id,product_id,quantity,unit_price,amount,batch_no) VALUES (?,?,?,?,?,?)";
        String logSql  = "INSERT INTO inventory_log (product_id,warehouse_id,batch_no,change_type,change_qty,before_qty,after_qty,unit_price,amount,ref_order_no,operator_id,remark,create_time) VALUES (?,?,?,'PURCHASE_IN',?,0,?,?,?,?,1,'采购入库',?)";

        try (PreparedStatement psItem  = c.prepareStatement(itemSql);
             PreparedStatement psLog   = c.prepareStatement(logSql)) {

            PreparedStatement psOrder = c.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            int batchOrder = 0;

            for (int i = 1; i <= PURCHASE_ORDERS; i++) {
                Long whId = leafWhIds.get(R.nextInt(leafWhIds.size()));
                LocalDate orderDate = today.minusDays(R.nextInt(90));
                String orderNo = "PO" + orderDate.format(DF) + String.format("%06d", i);

                // VALUES (order_no, NULL, warehouse_id, total_amount, total_quantity, 1,1,1, approve_time, order_date)
                psOrder.setString(1, orderNo);
                psOrder.setLong(2, whId);
                psOrder.setBigDecimal(3, BigDecimal.ZERO);
                psOrder.setInt(4, 0);
                psOrder.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now().minusDays(R.nextInt(90))));
                psOrder.setDate(6, java.sql.Date.valueOf(orderDate));
                psOrder.executeUpdate();
                long orderId;
                try (ResultSet rs = psOrder.getGeneratedKeys()) { rs.next(); orderId = rs.getLong(1); }
                orderCount++;

                // 明细
                int items = R.nextInt(ITEMS_MIN, ITEMS_MAX + 1);
                BigDecimal totalAmt = BigDecimal.ZERO;
                int totalQty = 0;
                Set<Long> used = new HashSet<>();

                for (int j = 0; j < items; j++) {
                    Long pId;
                    do { pId = productIds.get(R.nextInt(productIds.size())); } while (!used.add(pId));
                    int qty = R.nextInt(10, 200);
                    BigDecimal price = BigDecimal.valueOf(1 + R.nextDouble() * 499).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal amt = price.multiply(BigDecimal.valueOf(qty));
                    totalAmt = totalAmt.add(amt);
                    totalQty += qty;
                    String batch = "B" + String.format("%06d", R.nextInt(1, 999999));
                    LocalDateTime now = LocalDateTime.now().minusDays(R.nextInt(90));

                    psItem.setLong(1, orderId);
                    psItem.setLong(2, pId);
                    psItem.setInt(3, qty);
                    psItem.setBigDecimal(4, price);
                    psItem.setBigDecimal(5, amt);
                    psItem.setString(6, batch);
                    psItem.addBatch();
                    itemCount++;

                    // 流水
                    psLog.setLong(1, pId);
                    psLog.setLong(2, whId);
                    psLog.setString(3, batch);
                    psLog.setInt(4, qty);
                    psLog.setInt(5, qty);
                    psLog.setBigDecimal(6, price);
                    psLog.setBigDecimal(7, amt);
                    psLog.setString(8, orderNo);
                    psLog.setTimestamp(9, Timestamp.valueOf(now));
                    psLog.addBatch();
                    logCount++;
                }

                // 更新 order 总金额/数量
                try (Statement s = c.createStatement()) {
                    s.executeUpdate(String.format(
                            "UPDATE purchase_order SET total_amount=%.2f, total_quantity=%d, approve_time='%s' WHERE id=%d",
                            totalAmt.doubleValue(), totalQty,
                            LocalDateTime.now().minusDays(R.nextInt(90)).toString().replace('T', ' '),
                            orderId));
                }

                batchOrder++;
                if (batchOrder >= 200) {
                    psItem.executeBatch(); psLog.executeBatch(); c.commit();
                    psItem.clearBatch(); psLog.clearBatch();
                    batchOrder = 0;
                    if (orderCount % 1000 == 0) System.out.printf("  ... %d/%d 单%n", orderCount, PURCHASE_ORDERS);
                }
            }
            psItem.executeBatch(); psLog.executeBatch(); c.commit();
        }
        return new int[]{orderCount, itemCount, logCount};
    }

    // ======================== 销售单 ========================
    static int[] genSalesOrders(Connection c) throws SQLException {
        int orderCount = 0, itemCount = 0, logCount = 0;
        LocalDate today = LocalDate.now();

        String orderSql = "INSERT INTO sales_order (order_no,customer_id,warehouse_id,total_amount,total_quantity,salesman,status,operator_id,approver_id,approve_time,order_date) VALUES (?,NULL,?,?,?,?,1,1,1,?,?)";
        String itemSql = "INSERT INTO sales_order_item (order_id,product_id,quantity,unit_price,amount,batch_no) VALUES (?,?,?,?,?,?)";
        String logSql  = "INSERT INTO inventory_log (product_id,warehouse_id,batch_no,change_type,change_qty,before_qty,after_qty,unit_price,amount,ref_order_no,operator_id,remark,create_time) VALUES (?,?,?,'SALES_OUT',?,0,?,?,?,?,1,'销售出库',?)";
        String[] salesmen = {"张三","李四","王五","赵六","陈七","周八"};

        try (PreparedStatement psItem  = c.prepareStatement(itemSql);
             PreparedStatement psLog   = c.prepareStatement(logSql)) {

            PreparedStatement psOrder = c.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            int batchOrder = 0;

            for (int i = 1; i <= SALES_ORDERS; i++) {
                Long whId = leafWhIds.get(R.nextInt(leafWhIds.size()));
                LocalDate orderDate = today.minusDays(R.nextInt(90));
                String orderNo = "SO" + orderDate.format(DF) + String.format("%06d", i);
                String salesman = salesmen[R.nextInt(salesmen.length)];

                // VALUES (order_no, NULL, warehouse_id, total_amount, total_quantity, salesman, 1,1,1, approve_time, order_date)
                psOrder.setString(1, orderNo);
                psOrder.setLong(2, whId);
                psOrder.setBigDecimal(3, BigDecimal.ZERO);
                psOrder.setInt(4, 0);
                psOrder.setString(5, salesman);
                psOrder.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now().minusDays(R.nextInt(90))));
                psOrder.setDate(7, java.sql.Date.valueOf(orderDate));
                psOrder.executeUpdate();
                long orderId;
                try (ResultSet rs = psOrder.getGeneratedKeys()) { rs.next(); orderId = rs.getLong(1); }
                orderCount++;

                int items = R.nextInt(ITEMS_MIN, ITEMS_MAX + 1);
                BigDecimal totalAmt = BigDecimal.ZERO;
                int totalQty = 0;
                Set<Long> used = new HashSet<>();

                for (int j = 0; j < items; j++) {
                    Long pId;
                    do { pId = productIds.get(R.nextInt(productIds.size())); } while (!used.add(pId));
                    int qty = R.nextInt(1, 50);
                    BigDecimal price = BigDecimal.valueOf(1 + R.nextDouble() * 499).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal amt = price.multiply(BigDecimal.valueOf(qty));
                    totalAmt = totalAmt.add(amt);
                    totalQty += qty;
                    String batch = "B" + String.format("%06d", R.nextInt(1, 999999));
                    LocalDateTime now = LocalDateTime.now().minusDays(R.nextInt(90));

                    psItem.setLong(1, orderId);
                    psItem.setLong(2, pId);
                    psItem.setInt(3, qty);
                    psItem.setBigDecimal(4, price);
                    psItem.setBigDecimal(5, amt);
                    psItem.setString(6, batch);
                    psItem.addBatch();
                    itemCount++;

                    psLog.setLong(1, pId);
                    psLog.setLong(2, whId);
                    psLog.setString(3, batch);
                    psLog.setInt(4, -qty);
                    psLog.setInt(5, qty);
                    psLog.setBigDecimal(6, price);
                    psLog.setBigDecimal(7, amt);
                    psLog.setString(8, orderNo);
                    psLog.setTimestamp(9, Timestamp.valueOf(now));
                    psLog.addBatch();
                    logCount++;
                }

                psOrder.close();
                try (Statement s = c.createStatement()) {
                    s.executeUpdate(String.format(
                            "UPDATE sales_order SET total_amount=%.2f, total_quantity=%d, approve_time='%s' WHERE id=%d",
                            totalAmt.doubleValue(), totalQty,
                            LocalDateTime.now().minusDays(R.nextInt(90)).toString().replace('T', ' '),
                            orderId));
                }
                psOrder = c.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);

                batchOrder++;
                if (batchOrder >= 200) {
                    psItem.executeBatch(); psLog.executeBatch(); c.commit();
                    psItem.clearBatch(); psLog.clearBatch();
                    batchOrder = 0;
                    if (orderCount % 1000 == 0) System.out.printf("  ... %d/%d 单%n", orderCount, SALES_ORDERS);
                }
            }
            psItem.executeBatch(); psLog.executeBatch(); c.commit();
        }
        return new int[]{orderCount, itemCount, logCount};
    }

    static String p(int n) { return n < 10 ? "0" + n : String.valueOf(n); }
}
