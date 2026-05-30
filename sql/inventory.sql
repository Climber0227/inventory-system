/*
 Navicat Premium Dump SQL

 Source Server         : mysql
 Source Server Type    : MySQL
 Source Server Version : 80046 (8.0.46)
 Source Host           : localhost:3306
 Source Schema         : inventory

 Target Server Type    : MySQL
 Target Server Version : 80046 (8.0.46)
 File Encoding         : 65001

 Date: 30/05/2026 01:22:29
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for customer
-- ----------------------------
DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '客户编码',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '客户名称',
  `contact` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地址',
  `status` tinyint NULL DEFAULT 1,
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `deleted` tinyint NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customer
-- ----------------------------
INSERT INTO `customer` VALUES (1, 'CU001', '易迅电子科技', '刘总', '15820000001', '上海市徐汇区漕河泾开发区', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (2, 'CU002', '京东云仓合作商', '陈经理', '15820000002', '上海市嘉定区江桥镇', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (3, 'CU003', '华东师范大学后勤处', '周老师', '15820000003', '上海市闵行区东川路500号', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (4, 'CU004', '上海银行科技部', '林主管', '15820000004', '上海市浦东新区银城中路', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (5, 'CU005', '杭州网易网络公司', '黄采购', '15820000005', '杭州市滨江区网商路599号', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (6, 'CU006', '阿里巴巴西溪园区', '张采购', '15820000006', '杭州市余杭区文一西路969号', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (7, 'CU007', '苏州工业园区管委会', '王主任', '15820000007', '苏州市工业园区现代大道', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (8, 'CU008', '南京大学采购中心', '李老师', '15820000008', '南京市栖霞区仙林大道163号', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (9, 'CU009', '上海第一人民医院', '赵科长', '15820000009', '上海市虹口区海宁路100号', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (10, 'CU010', '百联集团采购部', '何经理', '15820000010', '上海市杨浦区淞沪路', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (11, 'CU011', '盒马鲜生供应链', '孙采购', '15820000011', '上海市浦东新区外高桥', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (12, 'CU012', '上海电信分公司', '钱主任', '15820000012', '上海市普陀区长寿路', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (13, 'CU013', '杭州师范大学', '吴老师', '15820000013', '杭州市余杭区余杭塘路2318号', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (14, 'CU014', '银泰百货采购中心', '郑经理', '15820000014', '杭州市下城区延安路', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `customer` VALUES (15, 'CU015', '拼多多供应链', '王采购', '15820000015', '上海市长宁区娄山关路', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');

-- ----------------------------
-- Table structure for inventory
-- ----------------------------
DROP TABLE IF EXISTS `inventory`;
CREATE TABLE `inventory`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `location_id` bigint NULL DEFAULT NULL COMMENT '库位ID',
  `batch_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '可用库存',
  `locked_qty` int NOT NULL DEFAULT 0 COMMENT '锁定库存',
  `cost_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '加权平均成本价（移动加权平均法）',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_prod_warehouse_loc_batch`(`product_id` ASC, `warehouse_id` ASC, `location_id` ASC, `batch_no` ASC) USING BTREE,
  INDEX `idx_warehouse`(`warehouse_id` ASC) USING BTREE,
  INDEX `idx_product`(`product_id` ASC) USING BTREE,
  INDEX `idx_location`(`location_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 101 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实时库存表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of inventory
-- ----------------------------
INSERT INTO `inventory` VALUES (1, 1, 13, NULL, 'B260301A', 85, 0, 6800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (2, 2, 13, NULL, 'B260305A', 25, 0, 12000.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (3, 3, 13, NULL, 'B260305A', 45, 0, 4200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (4, 7, 13, NULL, 'B260308A', 30, 0, 1800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (5, 8, 13, NULL, 'B260308A', 35, 0, 700.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (6, 9, 13, NULL, 'B260303A', 80, 0, 6500.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (7, 10, 13, NULL, 'B260303A', 60, 0, 5200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (8, 11, 13, NULL, 'B260303A', 55, 0, 3800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (9, 12, 13, NULL, 'B260318A', 15, 0, 7000.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (10, 13, 13, NULL, 'B260318A', 20, 0, 1400.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (11, 14, 13, NULL, 'B260318A', 20, 0, 1800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (12, 15, 13, NULL, 'B260404A', 55, 0, 1000.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (13, 16, 13, NULL, 'B260404A', 55, 0, 2600.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (14, 17, 13, NULL, 'B260307A', 50, 0, 250.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (15, 18, 13, NULL, 'B260307A', 35, 0, 1200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (16, 19, 13, NULL, 'B260310A', 15, 0, 300.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (17, 20, 13, NULL, 'B260310A', 20, 0, 250.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (18, 21, 13, NULL, 'B260326A', 20, 0, 350.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (19, 22, 13, NULL, 'B260326A', 20, 0, 280.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (20, 23, 13, NULL, 'B260406A', 15, 0, 2800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (21, 24, 13, NULL, 'B260406A', 15, 0, 3200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (22, 25, 13, NULL, 'B260416A', 25, 0, 1200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (23, 26, 13, NULL, 'B260416A', 25, 0, 180.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (24, 27, 13, NULL, 'B260312A', 20, 0, 20.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (25, 28, 13, NULL, 'B260312A', 15, 0, 35.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (26, 31, 13, NULL, 'B260314A', 15, 0, 45.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (27, 32, 13, NULL, 'B260314A', 15, 0, 30.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (28, 33, 13, NULL, 'B260329A', 10, 0, 55.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (29, 34, 13, NULL, 'B260329A', 10, 0, 18.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (30, 35, 13, NULL, 'B260301A', 5, 0, 3800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (31, 36, 13, NULL, 'B260305A', 8, 0, 4200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (32, 37, 13, NULL, 'B260315A', 30, 0, 400.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (33, 38, 13, NULL, 'B260315A', 28, 0, 500.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (34, 39, 13, NULL, 'B260330A', 12, 0, 350.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (35, 40, 13, NULL, 'B260330A', 215, 0, 60.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (36, 1, 14, NULL, 'B260301A', 30, 0, 6800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (37, 3, 14, NULL, 'B260305A', 20, 0, 4200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (38, 4, 14, NULL, 'B260410A', 20, 0, 3500.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (39, 9, 14, NULL, 'B260303A', 25, 0, 6500.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (40, 10, 14, NULL, 'B260303A', 15, 0, 5200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (41, 11, 14, NULL, 'B260303A', 25, 0, 3800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (42, 12, 14, NULL, 'B260318A', 10, 0, 7000.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (43, 13, 14, NULL, 'B260318A', 10, 0, 1400.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (44, 15, 14, NULL, 'B260404A', 25, 0, 1000.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (45, 16, 14, NULL, 'B260404A', 20, 0, 2600.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (46, 17, 14, NULL, 'B260307A', 20, 0, 250.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (47, 18, 14, NULL, 'B260307A', 15, 0, 1200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (48, 19, 14, NULL, 'B260310A', 20, 0, 300.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (49, 20, 14, NULL, 'B260310A', 25, 0, 250.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (50, 21, 14, NULL, 'B260326A', 15, 0, 350.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (51, 22, 14, NULL, 'B260326A', 15, 0, 280.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (52, 25, 14, NULL, 'B260416A', 15, 0, 1200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (53, 26, 14, NULL, 'B260416A', 15, 0, 180.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (54, 27, 14, NULL, 'B260312A', 150, 0, 20.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (55, 28, 14, NULL, 'B260312A', 150, 0, 35.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (56, 29, 14, NULL, 'B260328A', 80, 0, 40.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (57, 30, 14, NULL, 'B260328A', 70, 0, 42.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (58, 31, 14, NULL, 'B260314A', 80, 0, 45.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (59, 32, 14, NULL, 'B260314A', 90, 0, 30.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (60, 33, 14, NULL, 'B260329A', 15, 0, 55.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (61, 34, 14, NULL, 'B260329A', 20, 0, 18.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (62, 37, 14, NULL, 'B260315A', 20, 0, 400.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (63, 39, 14, NULL, 'B260330A', 25, 0, 350.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (64, 40, 14, NULL, 'B260330A', 15, 0, 60.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (65, 1, 15, NULL, 'B260301A', 15, 0, 6800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (66, 2, 15, NULL, 'B260305A', 12, 0, 12000.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (67, 3, 15, NULL, 'B260305A', 28, 0, 4200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (68, 4, 15, NULL, 'B260410A', 15, 0, 3500.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (69, 5, 15, NULL, 'B260317A', 18, 0, 3800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (70, 6, 15, NULL, 'B260317A', 15, 0, 2500.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (71, 7, 15, NULL, 'B260308A', 12, 0, 1800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (72, 8, 15, NULL, 'B260308A', 15, 0, 700.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (73, 9, 15, NULL, 'B260303A', 25, 0, 6500.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (74, 10, 15, NULL, 'B260303A', 20, 0, 5200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (75, 11, 15, NULL, 'B260303A', 18, 0, 3800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (76, 19, 15, NULL, 'B260310A', 7, 0, 300.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (77, 20, 15, NULL, 'B260310A', 19, 0, 250.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (78, 21, 15, NULL, 'B260326A', 15, 0, 350.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (79, 22, 15, NULL, 'B260326A', 15, 0, 280.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (80, 23, 15, NULL, 'B260406A', 10, 0, 2800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (81, 24, 15, NULL, 'B260406A', 10, 0, 3200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (82, 25, 15, NULL, 'B260416A', 10, 0, 1200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (83, 27, 15, NULL, 'B260312A', 80, 0, 20.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (84, 28, 15, NULL, 'B260312A', 60, 0, 35.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (85, 29, 15, NULL, 'B260328A', 60, 0, 40.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (86, 30, 15, NULL, 'B260328A', 50, 0, 42.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (87, 31, 15, NULL, 'B260314A', 30, 0, 45.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (88, 33, 15, NULL, 'B260329A', 25, 0, 55.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (89, 35, 15, NULL, 'B260301A', 8, 0, 3800.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (90, 36, 15, NULL, 'B260305A', 12, 0, 4200.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (91, 37, 15, NULL, 'B260315A', 15, 0, 400.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (92, 38, 15, NULL, 'B260429A', 10, 0, 500.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (93, 39, 15, NULL, 'B260330A', 10, 0, 350.00, NULL, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory` VALUES (94, 40, 19, NULL, NULL, 105, 0, 12.00, NULL, '2026-05-15 18:46:25', '2026-05-15 18:46:25');
INSERT INTO `inventory` VALUES (95, 39, 18, NULL, NULL, 60, 0, 8.00, NULL, '2026-05-15 18:46:51', '2026-05-15 18:46:51');
INSERT INTO `inventory` VALUES (96, 40, 18, NULL, NULL, 45, 0, 12.00, NULL, '2026-05-15 18:46:51', '2026-05-15 18:46:51');
INSERT INTO `inventory` VALUES (97, 39, 19, NULL, '1', 207, 0, 350.00, NULL, '2026-05-23 14:16:09', '2026-05-23 14:16:09');
INSERT INTO `inventory` VALUES (98, 39, 19, NULL, '2', 0, 0, 350.00, NULL, '2026-05-23 14:16:24', '2026-05-23 14:16:24');
INSERT INTO `inventory` VALUES (99, 38, 19, NULL, '1', 52, 0, 500.00, NULL, '2026-05-23 14:21:40', '2026-05-23 14:21:40');
INSERT INTO `inventory` VALUES (100, 38, 19, NULL, '2', 51, 0, 500.00, NULL, '2026-05-23 14:21:53', '2026-05-23 14:21:53');

-- ----------------------------
-- Table structure for inventory_log
-- ----------------------------
DROP TABLE IF EXISTS `inventory_log`;
CREATE TABLE `inventory_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `location_id` bigint NULL DEFAULT NULL COMMENT '库位ID',
  `batch_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `change_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '变动类型：PURCHASE_IN/ SALES_OUT/ TRANSFER_IN/ TRANSFER_OUT/ STOCKTAKE/ CANCEL_PURCHASE/ CANCEL_SALES/ CANCEL_TRANSFER/ ADJUSTMENT_IN/ ADJUSTMENT_OUT',
  `change_qty` int NOT NULL COMMENT '变动数量（正=增加，负=减少）',
  `before_qty` int NOT NULL COMMENT '变动前数量',
  `after_qty` int NOT NULL COMMENT '变动后数量',
  `unit_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '单价',
  `amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '金额',
  `ref_order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联单号',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_product`(`product_id` ASC) USING BTREE,
  INDEX `idx_warehouse`(`warehouse_id` ASC) USING BTREE,
  INDEX `idx_change_type`(`change_type` ASC) USING BTREE,
  INDEX `idx_ref_order`(`ref_order_no` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 59 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库存流水表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of inventory_log
-- ----------------------------
INSERT INTO `inventory_log` VALUES (1, 1, 13, NULL, 'B260301A', 'PURCHASE_IN', 30, 0, 30, NULL, NULL, 'PO20260301001', 4, NULL, '2026-03-01 09:00:00');
INSERT INTO `inventory_log` VALUES (2, 9, 13, NULL, 'B260303A', 'PURCHASE_IN', 20, 0, 20, NULL, NULL, 'PO20260303001', 4, NULL, '2026-03-03 09:00:00');
INSERT INTO `inventory_log` VALUES (3, 2, 13, NULL, 'B260305A', 'PURCHASE_IN', 15, 0, 15, NULL, NULL, 'PO20260305001', 4, NULL, '2026-03-05 09:00:00');
INSERT INTO `inventory_log` VALUES (4, 11, 14, NULL, 'B260307A', 'PURCHASE_IN', 30, 0, 30, NULL, NULL, 'PO20260307001', 5, NULL, '2026-03-07 09:00:00');
INSERT INTO `inventory_log` VALUES (5, 7, 13, NULL, 'B260308A', 'PURCHASE_IN', 15, 0, 15, NULL, NULL, 'PO20260308001', 4, NULL, '2026-03-08 09:00:00');
INSERT INTO `inventory_log` VALUES (6, 1, 13, NULL, 'B260301A', 'SALES_OUT', -15, 65, 50, NULL, NULL, 'SO20260301001', 6, NULL, '2026-03-01 14:00:00');
INSERT INTO `inventory_log` VALUES (7, 9, 13, NULL, 'B260303A', 'SALES_OUT', -15, 35, 20, NULL, NULL, 'SO20260301001', 6, NULL, '2026-03-01 14:00:00');
INSERT INTO `inventory_log` VALUES (8, 1, 13, NULL, 'B260301A', 'TRANSFER_OUT', -20, 50, 30, NULL, NULL, 'DB20260301001', 8, NULL, '2026-03-01 16:00:00');
INSERT INTO `inventory_log` VALUES (9, 1, 14, NULL, 'B260301A', 'TRANSFER_IN', 20, 0, 20, NULL, NULL, 'DB20260301001', 8, NULL, '2026-03-01 16:00:00');
INSERT INTO `inventory_log` VALUES (10, 3, 13, NULL, 'B260305A', 'TRANSFER_OUT', -20, 35, 15, NULL, NULL, 'DB20260310001', 8, NULL, '2026-03-10 10:00:00');
INSERT INTO `inventory_log` VALUES (11, 3, 15, NULL, 'B260305A', 'TRANSFER_IN', 20, 0, 20, NULL, NULL, 'DB20260310001', 8, NULL, '2026-03-10 10:00:00');
INSERT INTO `inventory_log` VALUES (12, 1, 13, NULL, 'B260301A', 'ADJUSTMENT_OUT', -2, 80, 78, NULL, NULL, 'TZ20260315001', 1, NULL, '2026-03-15 16:00:00');
INSERT INTO `inventory_log` VALUES (13, 9, 13, NULL, 'B260303A', 'ADJUSTMENT_OUT', -2, 62, 60, NULL, NULL, 'TZ20260315001', 1, NULL, '2026-03-15 16:00:00');
INSERT INTO `inventory_log` VALUES (14, 5, 15, NULL, 'B260317A', 'PURCHASE_IN', 20, 0, 20, NULL, NULL, 'PO20260317001', 4, NULL, '2026-03-17 09:00:00');
INSERT INTO `inventory_log` VALUES (15, 19, 13, NULL, 'B260310A', 'PURCHASE_IN', 25, 0, 25, NULL, NULL, 'PO20260310001', 4, NULL, '2026-03-10 09:00:00');
INSERT INTO `inventory_log` VALUES (16, 10, 15, NULL, 'B260303A', 'PURCHASE_IN', 25, 0, 25, NULL, NULL, 'PO20260320001', 4, NULL, '2026-03-20 09:00:00');
INSERT INTO `inventory_log` VALUES (17, 9, 15, NULL, 'B260303A', 'SALES_OUT', -10, 25, 15, NULL, NULL, 'SO20260310001', 6, NULL, '2026-03-10 14:00:00');
INSERT INTO `inventory_log` VALUES (18, 17, 14, NULL, 'B260307A', 'PURCHASE_IN', 30, 0, 30, NULL, NULL, 'PO20260307001', 5, NULL, '2026-03-07 10:00:00');
INSERT INTO `inventory_log` VALUES (19, 1, 13, NULL, 'B260301A', 'SALES_OUT', -18, 55, 37, NULL, NULL, 'SO20260305001', 6, NULL, '2026-03-05 14:00:00');
INSERT INTO `inventory_log` VALUES (20, 1, 13, NULL, 'B260301A', 'PURCHASE_IN', 35, 37, 72, NULL, NULL, 'PO20260322001', 4, NULL, '2026-03-22 09:00:00');
INSERT INTO `inventory_log` VALUES (21, 27, 14, NULL, 'B260312A', 'PURCHASE_IN', 100, 0, 100, NULL, NULL, 'PO20260312001', 5, NULL, '2026-03-12 09:00:00');
INSERT INTO `inventory_log` VALUES (22, 31, 14, NULL, 'B260314A', 'PURCHASE_IN', 50, 0, 50, NULL, NULL, 'PO20260314001', 5, NULL, '2026-03-14 09:00:00');
INSERT INTO `inventory_log` VALUES (23, 40, 13, NULL, '', 'PURCHASE_IN', 200, 15, 215, 60.00, 12000.00, 'PO202605133002', 1, '采购入库', '2026-05-13 01:13:34');
INSERT INTO `inventory_log` VALUES (24, 19, 15, NULL, 'B260310A', 'SALES_OUT', -8, 15, 7, 499.00, 3992.00, 'SO20260523001', 6, '销售出库(FIFO)', '2026-05-13 01:14:13');
INSERT INTO `inventory_log` VALUES (25, 20, 15, NULL, 'B260310A', 'SALES_OUT', -6, 25, 19, 399.00, 2394.00, 'SO20260523001', 6, '销售出库(FIFO)', '2026-05-13 01:14:13');
INSERT INTO `inventory_log` VALUES (26, 40, 19, NULL, NULL, 'PURCHASE_IN', 50, 0, 50, 12.00, 600.00, 'PO202605155002', 1, '采购入库', '2026-05-15 18:46:25');
INSERT INTO `inventory_log` VALUES (27, 40, 19, NULL, NULL, 'PURCHASE_IN', 50, 50, 100, 12.00, 600.00, 'PO202605155003', 1, '采购入库', '2026-05-15 18:46:50');
INSERT INTO `inventory_log` VALUES (28, 40, 19, NULL, NULL, 'SALES_OUT', -20, 100, 80, 25.00, 500.00, 'SO202605155002', 1, '销售出库(FIFO)', '2026-05-15 18:46:50');
INSERT INTO `inventory_log` VALUES (29, 39, 18, NULL, NULL, 'PURCHASE_IN', 30, 0, 30, 8.00, 240.00, 'PO202605155004', 1, '采购入库', '2026-05-15 18:46:51');
INSERT INTO `inventory_log` VALUES (30, 40, 19, NULL, NULL, 'TRANSFER_OUT', -15, 80, 65, NULL, NULL, 'DB202605155002', 1, '调拨出库', '2026-05-15 18:46:51');
INSERT INTO `inventory_log` VALUES (31, 40, 18, NULL, NULL, 'TRANSFER_IN', 15, 0, 15, NULL, NULL, 'DB202605155002', 1, '调拨入库', '2026-05-15 18:46:51');
INSERT INTO `inventory_log` VALUES (32, 40, 19, NULL, NULL, 'PURCHASE_IN', 10, 65, 75, 15.00, 150.00, 'PO202605155005', 1, '采购入库', '2026-05-15 18:46:51');
INSERT INTO `inventory_log` VALUES (33, 40, 19, NULL, NULL, 'PURCHASE_CANCEL', -10, 75, 65, NULL, NULL, 'PO202605155005', 1, '采购入库取消，回滚库存', '2026-05-15 18:46:51');
INSERT INTO `inventory_log` VALUES (34, 40, 19, NULL, NULL, 'PURCHASE_IN', 50, 65, 115, 12.00, 600.00, 'PO202605155006', 1, '采购入库', '2026-05-15 18:47:14');
INSERT INTO `inventory_log` VALUES (35, 40, 19, NULL, NULL, 'SALES_OUT', -20, 115, 95, 25.00, 500.00, 'SO202605155003', 1, '销售出库(FIFO)', '2026-05-15 18:47:14');
INSERT INTO `inventory_log` VALUES (36, 39, 18, NULL, NULL, 'PURCHASE_IN', 30, 30, 60, 8.00, 240.00, 'PO202605155007', 1, '采购入库', '2026-05-15 18:47:14');
INSERT INTO `inventory_log` VALUES (37, 40, 19, NULL, NULL, 'TRANSFER_OUT', -15, 95, 80, NULL, NULL, 'DB202605155003', 1, '调拨出库', '2026-05-15 18:47:14');
INSERT INTO `inventory_log` VALUES (38, 40, 18, NULL, NULL, 'TRANSFER_IN', 15, 15, 30, NULL, NULL, 'DB202605155003', 1, '调拨入库', '2026-05-15 18:47:14');
INSERT INTO `inventory_log` VALUES (39, 40, 19, NULL, NULL, 'PURCHASE_IN', 10, 80, 90, 15.00, 150.00, 'PO202605155008', 1, '采购入库', '2026-05-15 18:47:14');
INSERT INTO `inventory_log` VALUES (40, 40, 19, NULL, NULL, 'PURCHASE_CANCEL', -10, 90, 80, NULL, NULL, 'PO202605155008', 1, '采购入库取消，回滚库存', '2026-05-15 18:47:14');
INSERT INTO `inventory_log` VALUES (41, 40, 19, NULL, NULL, 'STOCKTAKE', 5, 80, 85, NULL, NULL, 'ST202605150002', 1, '测试盘盈', '2026-05-15 18:52:10');
INSERT INTO `inventory_log` VALUES (42, 40, 19, NULL, NULL, 'PURCHASE_IN', 50, 85, 135, 12.00, 600.00, 'PO202605155012', 1, '采购入库', '2026-05-15 19:04:03');
INSERT INTO `inventory_log` VALUES (43, 40, 19, NULL, NULL, 'SALES_OUT', -20, 135, 115, 25.00, 500.00, 'SO202605155004', 1, '销售出库(FIFO)', '2026-05-15 19:04:03');
INSERT INTO `inventory_log` VALUES (44, 39, 18, NULL, NULL, 'PURCHASE_IN', 30, 60, 90, 8.00, 240.00, 'PO202605155013', 1, '采购入库', '2026-05-15 19:04:03');
INSERT INTO `inventory_log` VALUES (45, 40, 19, NULL, NULL, 'TRANSFER_OUT', -15, 115, 100, NULL, NULL, 'DB202605155004', 1, '调拨出库', '2026-05-15 19:04:03');
INSERT INTO `inventory_log` VALUES (46, 40, 18, NULL, NULL, 'TRANSFER_IN', 15, 30, 45, NULL, NULL, 'DB202605155004', 1, '调拨入库', '2026-05-15 19:04:03');
INSERT INTO `inventory_log` VALUES (47, 40, 19, NULL, NULL, 'PURCHASE_IN', 10, 100, 110, 15.00, 150.00, 'PO202605155014', 1, '采购入库', '2026-05-15 19:04:03');
INSERT INTO `inventory_log` VALUES (48, 40, 19, NULL, NULL, 'PURCHASE_CANCEL', -10, 110, 100, NULL, NULL, 'PO202605155014', 1, '采购入库取消，回滚库存', '2026-05-15 19:04:03');
INSERT INTO `inventory_log` VALUES (49, 40, 19, NULL, NULL, 'STOCKTAKE', 5, 100, 105, NULL, NULL, 'ST202605150003', 1, '测试盘盈', '2026-05-15 19:04:07');
INSERT INTO `inventory_log` VALUES (50, 39, 18, NULL, NULL, 'PURCHASE_CANCEL', -30, 90, 60, NULL, NULL, 'PO202605155013', 1, '采购入库取消，回滚库存', '2026-05-16 07:51:55');
INSERT INTO `inventory_log` VALUES (51, 39, 19, NULL, '1', 'PURCHASE_IN', 100, 0, 100, 350.00, 35000.00, 'PO202605233003', 1, '采购入库', '2026-05-23 14:16:09');
INSERT INTO `inventory_log` VALUES (52, 39, 19, NULL, '2', 'PURCHASE_IN', 100, 0, 100, 350.00, 35000.00, 'PO202605233004', 1, '采购入库', '2026-05-23 14:16:24');
INSERT INTO `inventory_log` VALUES (53, 39, 19, NULL, NULL, 'STOCKTAKE', -95, 200, 105, NULL, NULL, 'ST202605230001', 1, '', '2026-05-23 14:17:21');
INSERT INTO `inventory_log` VALUES (54, 39, 19, NULL, NULL, 'STOCKTAKE', -103, 205, 102, NULL, NULL, 'ST202605230001', 1, '', '2026-05-23 14:17:21');
INSERT INTO `inventory_log` VALUES (55, 38, 19, NULL, '1', 'PURCHASE_IN', 100, 0, 100, 500.00, 50000.00, 'PO202605233005', 1, '采购入库', '2026-05-23 14:21:40');
INSERT INTO `inventory_log` VALUES (56, 38, 19, NULL, '2', 'PURCHASE_IN', 100, 0, 100, 500.00, 50000.00, 'PO202605233006', 1, '采购入库', '2026-05-23 14:21:53');
INSERT INTO `inventory_log` VALUES (57, 38, 19, NULL, NULL, 'STOCKTAKE', -96, 200, 104, NULL, NULL, 'ST202605230002', 1, '', '2026-05-23 14:22:38');
INSERT INTO `inventory_log` VALUES (58, 38, 19, NULL, NULL, 'STOCKTAKE', -1, 104, 103, NULL, NULL, 'ST202605230002', 1, '', '2026-05-23 14:22:38');

-- ----------------------------
-- Table structure for inventory_transfer
-- ----------------------------
DROP TABLE IF EXISTS `inventory_transfer`;
CREATE TABLE `inventory_transfer`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调拨单号',
  `from_warehouse_id` bigint NOT NULL COMMENT '调出仓库ID',
  `to_warehouse_id` bigint NOT NULL COMMENT '调入仓库ID',
  `total_quantity` int NULL DEFAULT 0 COMMENT '调拨总数量',
  `status` tinyint NULL DEFAULT 0 COMMENT '0=草稿 1=已完成 2=已取消 3=已作废 4=待审批',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `approve_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `order_date` date NULL DEFAULT NULL COMMENT '调拨日期',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `deleted` tinyint NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_from_wh`(`from_warehouse_id` ASC) USING BTREE,
  INDEX `idx_to_wh`(`to_warehouse_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库存调拨单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of inventory_transfer
-- ----------------------------
INSERT INTO `inventory_transfer` VALUES (1, 'DB20260301001', 13, 14, 50, 1, 8, NULL, NULL, '2026-03-01', '浦东调松江', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (2, 'DB20260310001', 13, 15, 40, 1, 8, NULL, NULL, '2026-03-10', '浦东调杭州', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (3, 'DB20260320001', 14, 13, 30, 1, 8, NULL, NULL, '2026-03-20', '松江回浦东', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (4, 'DB20260401001', 15, 13, 35, 1, 9, NULL, NULL, '2026-04-01', '杭州调浦东', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (5, 'DB20260410001', 13, 14, 60, 1, 8, NULL, NULL, '2026-04-10', '补货松江', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (6, 'DB20260420001', 14, 15, 25, 1, 8, NULL, NULL, '2026-04-20', '松江调杭州', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (7, 'DB20260501001', 13, 15, 45, 1, 9, NULL, NULL, '2026-05-01', '5月补货杭州', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (8, 'DB20260508001', 15, 13, 30, 1, 9, NULL, NULL, '2026-05-08', '杭州回浦东', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (9, 'DB20260512001', 13, 14, 40, 1, 8, NULL, NULL, '2026-05-12', '浦东调松江', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (10, 'DB20260515001', 14, 13, 20, 1, 8, NULL, NULL, '2026-05-15', '松江回浦东', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (11, 'DB20260520001', 13, 14, 35, 4, 8, NULL, NULL, '2026-05-20', '待审批-浦东调松江', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (12, 'DB20260521001', 13, 15, 50, 4, 9, NULL, NULL, '2026-05-21', '待审批-浦东调杭州', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (13, 'DB20260522001', 14, 15, 30, 4, 8, NULL, NULL, '2026-05-22', '待审批-松江调杭州', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (14, 'DB20260523001', 15, 13, 25, 0, 9, NULL, NULL, '2026-05-23', '草稿-待编辑', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (15, 'DB20260524001', 13, 14, 40, 0, 8, NULL, NULL, '2026-05-24', '草稿-待编辑', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `inventory_transfer` VALUES (16, 'DB202605155002', 19, 18, 15, 1, 1, 1, '2026-05-15 18:46:51', '2026-05-15', NULL, 0, '2026-05-15 18:46:51', '2026-05-15 18:46:51');
INSERT INTO `inventory_transfer` VALUES (17, 'DB202605155003', 19, 18, 15, 1, 1, 1, '2026-05-15 18:47:14', '2026-05-15', NULL, 0, '2026-05-15 18:47:14', '2026-05-15 18:47:14');
INSERT INTO `inventory_transfer` VALUES (18, 'DB202605155004', 19, 18, 15, 1, 1, 1, '2026-05-15 19:04:03', '2026-05-15', NULL, 0, '2026-05-15 19:04:03', '2026-05-15 19:04:03');
INSERT INTO `inventory_transfer` VALUES (19, 'DB202605233002', 19, 15, 200, 3, 1, NULL, NULL, '2026-05-23', ' | 驳回原因: 1 | 作废原因: 1', 0, '2026-05-23 14:20:08', '2026-05-23 14:21:04');
INSERT INTO `inventory_transfer` VALUES (20, 'DB202605233003', 19, 13, 100, 3, 1, NULL, NULL, '2026-05-23', ' | 驳回原因: 1 | 作废原因: 1', 0, '2026-05-23 14:23:13', '2026-05-23 14:28:22');
INSERT INTO `inventory_transfer` VALUES (21, 'DB202605233004', 19, 13, 100, 4, 1, NULL, NULL, '2026-05-23', '', 0, '2026-05-23 14:28:12', '2026-05-23 14:28:12');

-- ----------------------------
-- Table structure for inventory_transfer_item
-- ----------------------------
DROP TABLE IF EXISTS `inventory_transfer_item`;
CREATE TABLE `inventory_transfer_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `transfer_id` bigint NOT NULL COMMENT '调拨单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` int NOT NULL COMMENT '调拨数量',
  `batch_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_transfer`(`transfer_id` ASC) USING BTREE,
  INDEX `idx_product`(`product_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库存调拨明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of inventory_transfer_item
-- ----------------------------
INSERT INTO `inventory_transfer_item` VALUES (1, 1, 1, 20, 'B260301A');
INSERT INTO `inventory_transfer_item` VALUES (2, 1, 9, 15, 'B260303A');
INSERT INTO `inventory_transfer_item` VALUES (3, 1, 7, 15, 'B260308A');
INSERT INTO `inventory_transfer_item` VALUES (4, 2, 3, 20, 'B260305A');
INSERT INTO `inventory_transfer_item` VALUES (5, 2, 10, 20, 'B260303A');
INSERT INTO `inventory_transfer_item` VALUES (6, 3, 17, 15, 'B260307A');
INSERT INTO `inventory_transfer_item` VALUES (7, 3, 19, 15, 'B260310A');
INSERT INTO `inventory_transfer_item` VALUES (8, 4, 5, 18, 'B260317A');
INSERT INTO `inventory_transfer_item` VALUES (9, 4, 6, 17, 'B260317A');
INSERT INTO `inventory_transfer_item` VALUES (10, 5, 1, 25, 'B260301A');
INSERT INTO `inventory_transfer_item` VALUES (11, 5, 2, 20, 'B260305A');
INSERT INTO `inventory_transfer_item` VALUES (12, 5, 11, 15, 'B260303A');
INSERT INTO `inventory_transfer_item` VALUES (13, 6, 31, 15, 'B260314A');
INSERT INTO `inventory_transfer_item` VALUES (14, 6, 32, 10, 'B260314A');
INSERT INTO `inventory_transfer_item` VALUES (15, 7, 9, 25, 'B260303A');
INSERT INTO `inventory_transfer_item` VALUES (16, 7, 10, 20, 'B260303A');
INSERT INTO `inventory_transfer_item` VALUES (17, 8, 5, 15, 'B260317A');
INSERT INTO `inventory_transfer_item` VALUES (18, 8, 6, 15, 'B260317A');
INSERT INTO `inventory_transfer_item` VALUES (19, 9, 1, 20, 'B260301A');
INSERT INTO `inventory_transfer_item` VALUES (20, 9, 3, 20, 'B260305A');
INSERT INTO `inventory_transfer_item` VALUES (21, 10, 17, 10, 'B260307A');
INSERT INTO `inventory_transfer_item` VALUES (22, 10, 19, 10, 'B260310A');
INSERT INTO `inventory_transfer_item` VALUES (23, 11, 7, 18, 'B260308A');
INSERT INTO `inventory_transfer_item` VALUES (24, 11, 13, 17, 'B260318A');
INSERT INTO `inventory_transfer_item` VALUES (25, 12, 9, 25, 'B260303A');
INSERT INTO `inventory_transfer_item` VALUES (26, 12, 11, 25, 'B260303A');
INSERT INTO `inventory_transfer_item` VALUES (27, 13, 31, 15, 'B260314A');
INSERT INTO `inventory_transfer_item` VALUES (28, 13, 34, 15, 'B260314A');
INSERT INTO `inventory_transfer_item` VALUES (29, 14, 5, 15, 'B260317A');
INSERT INTO `inventory_transfer_item` VALUES (30, 14, 6, 10, 'B260317A');
INSERT INTO `inventory_transfer_item` VALUES (31, 15, 1, 20, 'B260301A');
INSERT INTO `inventory_transfer_item` VALUES (32, 15, 2, 20, 'B260305A');
INSERT INTO `inventory_transfer_item` VALUES (33, 16, 40, 15, NULL);
INSERT INTO `inventory_transfer_item` VALUES (34, 17, 40, 15, NULL);
INSERT INTO `inventory_transfer_item` VALUES (35, 18, 40, 15, NULL);
INSERT INTO `inventory_transfer_item` VALUES (36, 19, 39, 200, NULL);
INSERT INTO `inventory_transfer_item` VALUES (37, 20, 38, 100, NULL);
INSERT INTO `inventory_transfer_item` VALUES (38, 21, 38, 100, NULL);

-- ----------------------------
-- Table structure for product
-- ----------------------------
DROP TABLE IF EXISTS `product`;
CREATE TABLE `product`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品编码',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称',
  `category_id` bigint NULL DEFAULT NULL COMMENT '分类ID',
  `spec` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '规格型号',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '单位（个/箱/KG等）',
  `purchase_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '采购参考价',
  `sale_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '销售参考价',
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品图片',
  `min_stock` int NULL DEFAULT 0 COMMENT '最低库存（安全库存）',
  `max_stock` int NULL DEFAULT 0 COMMENT '最高库存',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态 0=停用 1=启用',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '逻辑删除',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE,
  INDEX `idx_category`(`category_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product
-- ----------------------------
INSERT INTO `product` VALUES (1, 'P20260001', 'ThinkPad X1 Carbon', 6, 'i7/16G/512G', '台', 6800.00, 8999.00, NULL, 5, 50, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (2, 'P20260002', 'MacBook Pro 14', 6, 'M3/18G/512G', '台', 12000.00, 14999.00, NULL, 3, 30, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (3, 'P20260003', '联想小新Pro 16', 6, 'R7/16G/1T', '台', 4200.00, 5599.00, NULL, 10, 80, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (4, 'P20260004', '戴尔灵越14', 6, 'i5/16G/512G', '台', 3500.00, 4599.00, NULL, 8, 60, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (5, 'P20260005', '华为MateStation', 7, 'i7/16G/512G', '台', 3800.00, 4999.00, NULL, 5, 40, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (6, 'P20260006', '联想天逸510S', 7, 'i5/8G/256G', '台', 2500.00, 3299.00, NULL, 8, 50, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (7, 'P20260007', '戴尔27寸显示器', 8, '27寸/4K/IPS', '台', 1800.00, 2499.00, NULL, 5, 30, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (8, 'P20260008', '华硕24寸显示器', 8, '24寸/1080P', '台', 700.00, 999.00, NULL, 10, 60, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (9, 'P20260009', 'iPhone 16 Pro', 9, '256G/钛金属', '台', 6500.00, 8999.00, NULL, 10, 80, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (10, 'P20260010', '华为Mate 70 Pro', 9, '512G', '台', 5200.00, 6999.00, NULL, 10, 80, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (11, 'P20260011', '小米15 Pro', 9, '512G', '台', 3800.00, 4999.00, NULL, 15, 100, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (12, 'P20260012', '三星S25 Ultra', 9, '512G', '台', 7000.00, 9699.00, NULL, 5, 40, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (13, 'P20260013', 'AirPods Pro 2', 10, 'USB-C', '个', 1400.00, 1899.00, NULL, 20, 150, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (14, 'P20260014', '索尼WH-1000XM5', 10, '黑色/头戴', '个', 1800.00, 2499.00, NULL, 10, 80, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (15, 'P20260015', '华为FreeBuds Pro 3', 10, '白色', '个', 1000.00, 1399.00, NULL, 15, 100, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (16, 'P20260016', 'Apple Watch S10', 11, '45mm/GPS', '个', 2600.00, 3499.00, NULL, 8, 50, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (17, 'P20260017', '小米手环9 Pro', 11, '黑色', '个', 250.00, 399.00, NULL, 30, 200, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (18, 'P20260018', '华为Watch GT 5', 11, '46mm', '个', 1200.00, 1699.00, NULL, 10, 60, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (19, 'P20260019', '美的电饭煲', 12, '4L/IH加热', '个', 300.00, 499.00, NULL, 20, 100, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (20, 'P20260020', '苏泊尔空气炸锅', 12, '5.5L', '个', 250.00, 399.00, NULL, 15, 80, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (21, 'P20260021', '九阳破壁机', 12, '1.75L', '个', 350.00, 599.00, NULL, 10, 60, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (22, 'P20260022', '格兰仕微波炉', 12, '20L/平板式', '个', 280.00, 429.00, NULL, 15, 80, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (23, 'P20260023', '戴森吸尘器V15', 13, '无线/手持', '个', 2800.00, 3990.00, NULL, 5, 30, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (24, 'P20260024', '科沃斯扫地机X5', 13, '全能版', '个', 3200.00, 4599.00, NULL, 5, 30, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (25, 'P20260025', '小米空气净化器5', 13, '除甲醛', '个', 1200.00, 1799.00, NULL, 8, 50, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (26, 'P20260026', '美的落地扇', 13, '遥控/7叶', '个', 180.00, 299.00, NULL, 20, 120, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (27, 'P20260027', '农夫山泉矿泉水', 14, '550ml*24瓶', '箱', 20.00, 38.00, NULL, 100, 500, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (28, 'P20260028', '可口可乐', 14, '330ml*24罐', '箱', 35.00, 59.00, NULL, 80, 400, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (29, 'P20260029', '东方树叶', 14, '500ml*15瓶', '箱', 40.00, 69.00, NULL, 60, 300, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (30, 'P20260030', '元气森林', 14, '480ml*15瓶', '箱', 42.00, 72.00, NULL, 50, 250, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (31, 'P20260031', '三只松鼠每日坚果', 15, '750g/30包', '箱', 45.00, 79.00, NULL, 40, 200, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (32, 'P20260032', '良品铺子肉脯', 15, '200g*3袋', '袋', 30.00, 55.00, NULL, 30, 150, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (33, 'P20260033', '百草味大礼包', 15, '1.5kg', '箱', 55.00, 99.00, NULL, 20, 100, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (34, 'P20260034', '来伊份综合果干', 15, '500g', '袋', 18.00, 35.00, NULL, 40, 200, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (35, 'P20260035', '华为MatePad Pro', 6, '12.2寸/16G/512G', '台', 3800.00, 4999.00, NULL, 8, 40, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (36, 'P20260036', 'iPad Air M2', 6, '11寸/128G', '台', 4200.00, 5499.00, NULL, 8, 40, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (37, 'P20260037', '罗技MX Master 3S', 1, '无线/静音', '个', 400.00, 599.00, NULL, 20, 100, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (38, 'P20260038', '雷蛇机械键盘', 1, '黑寡妇V4', '个', 500.00, 799.00, NULL, 15, 80, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (39, 'P20260039', '西部数据移动硬盘', 1, '2TB/USB3.0', '个', 350.00, 499.00, NULL, 20, 100, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product` VALUES (40, 'P20260040', '金士顿U盘', 1, '128G/USB3.2', '个', 60.00, 900.00, '/uploads/images/72e4f04fb2c14d4caea0eb8326ba748b.jpg', 50, 300, 1, '', 0, '2026-05-13 01:12:55', '2026-05-15 19:56:56');

-- ----------------------------
-- Table structure for product_category
-- ----------------------------
DROP TABLE IF EXISTS `product_category`;
CREATE TABLE `product_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父分类ID',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态',
  `deleted` tinyint NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_parent`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product_category
-- ----------------------------
INSERT INTO `product_category` VALUES (1, '电脑办公', NULL, 1, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (2, '手机数码', NULL, 2, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (3, '家用电器', NULL, 3, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (4, '食品饮料', NULL, 4, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (5, '日用百货', NULL, 5, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (6, '笔记本电脑', 1, 1, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (7, '台式电脑', 1, 2, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (8, '显示器', 1, 3, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (9, '智能手机', 2, 1, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (10, '耳机音箱', 2, 2, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (11, '智能穿戴', 2, 3, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (12, '厨房电器', 3, 1, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (13, '生活电器', 3, 2, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (14, '饮料冲调', 4, 1, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `product_category` VALUES (15, '零食坚果', 4, 2, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');

-- ----------------------------
-- Table structure for purchase_order
-- ----------------------------
DROP TABLE IF EXISTS `purchase_order`;
CREATE TABLE `purchase_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '入库单号',
  `supplier_id` bigint NULL DEFAULT NULL COMMENT '供应商ID',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `location_id` bigint NULL DEFAULT NULL COMMENT '库位ID',
  `total_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '入库总金额',
  `total_quantity` int NULL DEFAULT 0 COMMENT '入库总数量',
  `status` tinyint NULL DEFAULT 0 COMMENT '状态 0=草稿 1=已入库 2=已取消 3=已作废 4=待审批',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `approve_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `order_date` date NOT NULL COMMENT '入库日期',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `deleted` tinyint NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_supplier`(`supplier_id` ASC) USING BTREE,
  INDEX `idx_warehouse`(`warehouse_id` ASC) USING BTREE,
  INDEX `idx_operator`(`operator_id` ASC) USING BTREE,
  INDEX `idx_order_date`(`order_date` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 105 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '采购入库单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of purchase_order
-- ----------------------------
INSERT INTO `purchase_order` VALUES (1, 'PO20260301001', 1, 13, NULL, 45000.00, 50, 1, 4, NULL, NULL, '2026-03-01', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (2, 'PO20260303001', 2, 13, NULL, 32000.00, 40, 1, 4, NULL, NULL, '2026-03-03', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (3, 'PO20260305001', 4, 13, NULL, 52000.00, 30, 1, 4, NULL, NULL, '2026-03-05', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (4, 'PO20260307001', 5, 14, NULL, 28000.00, 60, 1, 5, NULL, NULL, '2026-03-07', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (5, 'PO20260308001', 3, 13, NULL, 15000.00, 30, 1, 4, NULL, NULL, '2026-03-08', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (6, 'PO20260310001', 7, 13, NULL, 12000.00, 50, 1, 4, NULL, NULL, '2026-03-10', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (7, 'PO20260312001', 8, 14, NULL, 8000.00, 200, 1, 5, NULL, NULL, '2026-03-12', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (8, 'PO20260314001', 9, 14, NULL, 5000.00, 100, 1, 5, NULL, NULL, '2026-03-14', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (9, 'PO20260315001', 10, 13, NULL, 9000.00, 30, 1, 4, NULL, NULL, '2026-03-15', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (10, 'PO20260317001', 1, 15, NULL, 35000.00, 40, 1, 4, NULL, NULL, '2026-03-17', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (11, 'PO20260318001', 6, 13, NULL, 45000.00, 25, 1, 4, NULL, NULL, '2026-03-18', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (12, 'PO20260320001', 2, 15, NULL, 28000.00, 50, 1, 4, NULL, NULL, '2026-03-20', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (13, 'PO20260322001', 3, 14, NULL, 18000.00, 40, 1, 5, NULL, NULL, '2026-03-22', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (14, 'PO20260324001', 4, 15, NULL, 60000.00, 35, 1, 4, NULL, NULL, '2026-03-24', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (15, 'PO20260325001', 5, 13, NULL, 22000.00, 70, 1, 4, NULL, NULL, '2026-03-25', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (16, 'PO20260326001', 7, 14, NULL, 10000.00, 40, 1, 5, NULL, NULL, '2026-03-26', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (17, 'PO20260328001', 8, 15, NULL, 6000.00, 150, 1, 5, NULL, NULL, '2026-03-28', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (18, 'PO20260329001', 9, 13, NULL, 7000.00, 140, 1, 4, NULL, NULL, '2026-03-29', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (19, 'PO20260330001', 10, 14, NULL, 11000.00, 40, 1, 5, NULL, NULL, '2026-03-30', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (20, 'PO20260331001', 1, 15, NULL, 50000.00, 55, 1, 4, NULL, NULL, '2026-03-31', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (21, 'PO20260401001', 2, 13, NULL, 34000.00, 45, 1, 4, NULL, NULL, '2026-04-01', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (22, 'PO20260402001', 3, 15, NULL, 20000.00, 45, 1, 5, NULL, NULL, '2026-04-02', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (23, 'PO20260403001', 4, 14, NULL, 48000.00, 28, 1, 4, NULL, NULL, '2026-04-03', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (24, 'PO20260404001', 5, 13, NULL, 25000.00, 80, 1, 4, NULL, NULL, '2026-04-04', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (25, 'PO20260405001', 6, 15, NULL, 50000.00, 28, 1, 5, NULL, NULL, '2026-04-05', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (26, 'PO20260406001', 7, 13, NULL, 15000.00, 60, 1, 4, NULL, NULL, '2026-04-06', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (27, 'PO20260407001', 8, 14, NULL, 9000.00, 250, 1, 5, NULL, NULL, '2026-04-07', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (28, 'PO20260408001', 9, 13, NULL, 8000.00, 160, 1, 4, NULL, NULL, '2026-04-08', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (29, 'PO20260409001', 10, 15, NULL, 13000.00, 45, 1, 5, NULL, NULL, '2026-04-09', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (30, 'PO20260410001', 1, 14, NULL, 42000.00, 48, 1, 4, NULL, NULL, '2026-04-10', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (31, 'PO20260411001', 2, 13, NULL, 30000.00, 38, 1, 4, NULL, NULL, '2026-04-11', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (32, 'PO20260412001', 3, 15, NULL, 22000.00, 50, 1, 5, NULL, NULL, '2026-04-12', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (33, 'PO20260413001', 4, 14, NULL, 55000.00, 32, 1, 4, NULL, NULL, '2026-04-13', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (34, 'PO20260414001', 5, 13, NULL, 18000.00, 55, 1, 4, NULL, NULL, '2026-04-14', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (35, 'PO20260415001', 6, 15, NULL, 48000.00, 26, 1, 5, NULL, NULL, '2026-04-15', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (36, 'PO20260416001', 7, 14, NULL, 12000.00, 50, 1, 5, NULL, NULL, '2026-04-16', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (37, 'PO20260417001', 8, 13, NULL, 7000.00, 180, 1, 4, NULL, NULL, '2026-04-17', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (38, 'PO20260418001', 9, 15, NULL, 6000.00, 120, 1, 5, NULL, NULL, '2026-04-18', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (39, 'PO20260419001', 10, 13, NULL, 10000.00, 35, 1, 4, NULL, NULL, '2026-04-19', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (40, 'PO20260420001', 1, 15, NULL, 55000.00, 60, 1, 4, NULL, NULL, '2026-04-20', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (41, 'PO20260421001', 2, 13, NULL, 36000.00, 50, 1, 4, NULL, NULL, '2026-04-21', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (42, 'PO20260422001', 3, 14, NULL, 24000.00, 55, 1, 5, NULL, NULL, '2026-04-22', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (43, 'PO20260423001', 4, 15, NULL, 62000.00, 36, 1, 5, NULL, NULL, '2026-04-23', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (44, 'PO20260424001', 5, 13, NULL, 24000.00, 75, 1, 4, NULL, NULL, '2026-04-24', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (45, 'PO20260425001', 6, 14, NULL, 52000.00, 30, 1, 4, NULL, NULL, '2026-04-25', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (46, 'PO20260426001', 7, 15, NULL, 16000.00, 65, 1, 5, NULL, NULL, '2026-04-26', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (47, 'PO20260427001', 8, 13, NULL, 8000.00, 200, 1, 4, NULL, NULL, '2026-04-27', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (48, 'PO20260428001', 9, 14, NULL, 9000.00, 180, 1, 5, NULL, NULL, '2026-04-28', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (49, 'PO20260429001', 10, 15, NULL, 14000.00, 50, 1, 5, NULL, NULL, '2026-04-29', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (50, 'PO20260430001', 1, 13, NULL, 48000.00, 52, 1, 4, NULL, NULL, '2026-04-30', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (51, 'PO20260501001', 2, 14, NULL, 32000.00, 42, 1, 4, NULL, NULL, '2026-05-01', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (52, 'PO20260502001', 3, 13, NULL, 25000.00, 55, 1, 5, NULL, NULL, '2026-05-02', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (53, 'PO20260503001', 4, 15, NULL, 58000.00, 34, 1, 4, NULL, NULL, '2026-05-03', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (54, 'PO20260504001', 5, 14, NULL, 28000.00, 90, 1, 5, NULL, NULL, '2026-05-04', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (55, 'PO20260505001', 6, 13, NULL, 42000.00, 24, 1, 4, NULL, NULL, '2026-05-05', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (56, 'PO20260506001', 7, 15, NULL, 14000.00, 55, 1, 5, NULL, NULL, '2026-05-06', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (57, 'PO20260507001', 8, 13, NULL, 10000.00, 250, 1, 4, NULL, NULL, '2026-05-07', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (58, 'PO20260508001', 9, 14, NULL, 7000.00, 140, 1, 5, NULL, NULL, '2026-05-08', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (59, 'PO20260509001', 10, 15, NULL, 12000.00, 40, 1, 4, NULL, NULL, '2026-05-09', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (60, 'PO20260510001', 1, 13, NULL, 50000.00, 55, 1, 4, NULL, NULL, '2026-05-10', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (61, 'PO20260511001', 2, 14, NULL, 38000.00, 48, 1, 5, NULL, NULL, '2026-05-11', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (62, 'PO20260512001', 3, 13, NULL, 16000.00, 35, 1, 4, NULL, NULL, '2026-05-12', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (63, 'PO20260513001', 4, 15, NULL, 60000.00, 35, 1, 5, NULL, NULL, '2026-05-13', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (64, 'PO20260514001', 5, 13, NULL, 22000.00, 70, 1, 4, NULL, NULL, '2026-05-14', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (65, 'PO20260515001', 6, 14, NULL, 46000.00, 26, 1, 5, NULL, NULL, '2026-05-15', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (66, 'PO20260516001', 7, 13, NULL, 18000.00, 72, 1, 4, NULL, NULL, '2026-05-16', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (67, 'PO20260517001', 8, 15, NULL, 9000.00, 220, 1, 5, NULL, NULL, '2026-05-17', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (68, 'PO20260518001', 9, 14, NULL, 8000.00, 160, 1, 5, NULL, NULL, '2026-05-18', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (69, 'PO20260519001', 10, 13, NULL, 15000.00, 50, 1, 4, NULL, NULL, '2026-05-19', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (70, 'PO20260520001', 1, 15, NULL, 52000.00, 58, 1, 4, NULL, NULL, '2026-05-20', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (71, 'PO20260521001', 2, 13, NULL, 30000.00, 40, 4, 4, NULL, NULL, '2026-05-21', '待审批-笔记本补货', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (72, 'PO20260521002', 4, 14, NULL, 50000.00, 30, 4, 5, NULL, NULL, '2026-05-21', '待审批-苹果产品', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (73, 'PO20260522001', 7, 15, NULL, 20000.00, 80, 4, 5, NULL, NULL, '2026-05-22', '待审批-家电', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (74, 'PO20260522002', 8, 13, NULL, 15000.00, 400, 4, 4, NULL, NULL, '2026-05-22', '待审批-饮料', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (75, 'PO20260523001', 5, 14, NULL, 30000.00, 100, 4, 5, NULL, NULL, '2026-05-23', '待审批-小米手机', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (76, 'PO20260523002', 1, 13, NULL, 126060.00, 41, 4, 4, NULL, NULL, '2026-05-23', '草稿-联想电脑', 0, '2026-05-13 01:12:55', '2026-05-15 19:48:28');
INSERT INTO `purchase_order` VALUES (77, 'PO20260524001', 3, 15, NULL, 244300.00, 10035, 4, 5, NULL, NULL, '2026-05-24', '草稿-戴尔电脑', 0, '2026-05-13 01:12:55', '2026-05-15 19:49:30');
INSERT INTO `purchase_order` VALUES (78, 'PO20260524002', 9, 14, NULL, 12000.00, 250, 4, 5, NULL, NULL, '2026-05-24', '草稿-零食补货', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (79, 'PO20260305002', 2, 13, NULL, 25000.00, 30, 2, 4, NULL, NULL, '2026-03-05', '取消-价格调整', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (80, 'PO20260415002', 6, 15, NULL, 35000.00, 20, 2, 5, NULL, NULL, '2026-04-15', '取消-供应商缺货', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `purchase_order` VALUES (81, 'PO202605133002', 1, 13, NULL, 12000.00, 200, 1, 1, 1, '2026-05-13 01:13:34', '2026-05-12', '', 0, '2026-05-13 01:13:30', '2026-05-13 01:13:30');
INSERT INTO `purchase_order` VALUES (82, 'PO202605155002', 1, 19, NULL, 600.00, 50, 1, 1, 1, '2026-05-15 18:46:25', '2026-05-15', NULL, 0, '2026-05-15 18:46:25', '2026-05-15 18:46:25');
INSERT INTO `purchase_order` VALUES (83, 'PO202605155003', 1, 19, NULL, 600.00, 50, 1, 1, 1, '2026-05-15 18:46:50', '2026-05-15', NULL, 0, '2026-05-15 18:46:50', '2026-05-15 18:46:50');
INSERT INTO `purchase_order` VALUES (84, 'PO202605155004', 1, 18, NULL, 240.00, 30, 1, 1, 1, '2026-05-15 18:46:51', '2026-05-15', NULL, 0, '2026-05-15 18:46:51', '2026-05-15 18:46:51');
INSERT INTO `purchase_order` VALUES (85, 'PO202605155005', 1, 19, NULL, 150.00, 10, 2, 1, 1, '2026-05-15 18:46:51', '2026-05-15', NULL, 0, '2026-05-15 18:46:51', '2026-05-15 18:46:51');
INSERT INTO `purchase_order` VALUES (86, 'PO202605155006', 1, 19, NULL, 600.00, 50, 1, 1, 1, '2026-05-15 18:47:14', '2026-05-15', NULL, 0, '2026-05-15 18:47:14', '2026-05-15 18:47:14');
INSERT INTO `purchase_order` VALUES (87, 'PO202605155007', 1, 18, NULL, 240.00, 30, 1, 1, 1, '2026-05-15 18:47:14', '2026-05-15', NULL, 0, '2026-05-15 18:47:14', '2026-05-15 18:47:14');
INSERT INTO `purchase_order` VALUES (88, 'PO202605155008', 1, 19, NULL, 150.00, 10, 2, 1, 1, '2026-05-15 18:47:14', '2026-05-15', NULL, 0, '2026-05-15 18:47:14', '2026-05-15 18:47:14');
INSERT INTO `purchase_order` VALUES (89, 'PO202605155009', 1, 19, NULL, 20.00, 2, 3, 1, NULL, NULL, '2026-05-15', '作废原因: 测试作废', 0, '2026-05-15 18:49:45', '2026-05-15 18:49:45');
INSERT INTO `purchase_order` VALUES (90, 'PO202605155010', 1, 19, NULL, 10.00, 1, 4, 1, NULL, NULL, '2026-05-15', NULL, 0, '2026-05-15 18:52:10', '2026-05-15 18:52:10');
INSERT INTO `purchase_order` VALUES (91, 'PO202605155011', 1, 19, NULL, 20.00, 2, 3, 1, NULL, NULL, '2026-05-15', '作废原因: 测试作废', 0, '2026-05-15 18:52:10', '2026-05-15 18:52:10');
INSERT INTO `purchase_order` VALUES (92, 'PO202605155012', 1, 19, NULL, 600.00, 50, 1, 1, 1, '2026-05-15 19:04:03', '2026-05-15', NULL, 0, '2026-05-15 19:04:03', '2026-05-15 19:04:03');
INSERT INTO `purchase_order` VALUES (93, 'PO202605155013', 1, 18, NULL, 240.00, 30, 2, 1, 1, '2026-05-15 19:04:03', '2026-05-15', NULL, 0, '2026-05-15 19:04:03', '2026-05-15 19:04:03');
INSERT INTO `purchase_order` VALUES (94, 'PO202605155014', 1, 19, NULL, 150.00, 10, 2, 1, 1, '2026-05-15 19:04:03', '2026-05-15', NULL, 0, '2026-05-15 19:04:03', '2026-05-15 19:04:03');
INSERT INTO `purchase_order` VALUES (95, 'PO202605155015', 1, 19, NULL, 10.00, 1, 4, 1, NULL, NULL, '2026-05-15', NULL, 0, '2026-05-15 19:04:07', '2026-05-15 19:04:07');
INSERT INTO `purchase_order` VALUES (96, 'PO202605155016', 1, 19, NULL, 20.00, 2, 3, 1, NULL, NULL, '2026-05-15', '作废原因: 测试作废', 0, '2026-05-15 19:04:07', '2026-05-15 19:04:07');
INSERT INTO `purchase_order` VALUES (97, 'PO202605155017', 2, 13, NULL, 60000.00, 1000, 4, 4, NULL, NULL, '2026-05-15', '', 0, '2026-05-15 19:56:12', '2026-05-15 19:56:12');
INSERT INTO `purchase_order` VALUES (98, 'PO202605155018', 1, 19, NULL, 0.00, 0, 0, 1, NULL, NULL, '2026-05-15', '', 0, '2026-05-15 20:49:54', '2026-05-15 20:49:54');
INSERT INTO `purchase_order` VALUES (99, 'PO202605155019', 1, 19, NULL, 60.00, 1, 0, 1, NULL, NULL, '2026-05-15', '', 0, '2026-05-15 20:52:45', '2026-05-15 20:52:45');
INSERT INTO `purchase_order` VALUES (100, 'PO202605155020', 1, 19, NULL, 3800.00, 1, 0, 1, NULL, NULL, '2026-05-15', '', 0, '2026-05-15 20:53:12', '2026-05-15 20:53:12');
INSERT INTO `purchase_order` VALUES (101, 'PO202605233003', 1, 19, NULL, 35000.00, 100, 1, 1, 1, '2026-05-23 14:16:09', '2026-05-23', '', 0, '2026-05-23 14:16:07', '2026-05-23 14:16:07');
INSERT INTO `purchase_order` VALUES (102, 'PO202605233004', 1, 19, NULL, 35000.00, 100, 1, 1, 1, '2026-05-23 14:16:24', '2026-05-23', '', 0, '2026-05-23 14:16:22', '2026-05-23 14:16:22');
INSERT INTO `purchase_order` VALUES (103, 'PO202605233005', 1, 19, NULL, 50000.00, 100, 1, 1, 1, '2026-05-23 14:21:40', '2026-05-23', '', 0, '2026-05-23 14:21:37', '2026-05-23 14:21:37');
INSERT INTO `purchase_order` VALUES (104, 'PO202605233006', 1, 19, NULL, 50000.00, 100, 1, 1, 1, '2026-05-23 14:21:53', '2026-05-23', '', 0, '2026-05-23 14:21:51', '2026-05-23 14:21:51');

-- ----------------------------
-- Table structure for purchase_order_item
-- ----------------------------
DROP TABLE IF EXISTS `purchase_order_item`;
CREATE TABLE `purchase_order_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '入库单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` int NOT NULL COMMENT '入库数量',
  `unit_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '单价',
  `amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '金额',
  `batch_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `production_date` date NULL DEFAULT NULL COMMENT '生产日期',
  `expiry_date` date NULL DEFAULT NULL COMMENT '有效期',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_product`(`product_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 190 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '采购入库明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of purchase_order_item
-- ----------------------------
INSERT INTO `purchase_order_item` VALUES (1, 1, 1, 30, 6800.00, 204000.00, 'B260301A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (2, 1, 35, 20, 3800.00, 76000.00, 'B260301A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (3, 2, 9, 20, 6500.00, 130000.00, 'B260303A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (4, 2, 10, 20, 5200.00, 104000.00, 'B260303A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (5, 3, 2, 15, 12000.00, 180000.00, 'B260305A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (6, 3, 36, 15, 4200.00, 63000.00, 'B260305A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (7, 4, 11, 30, 3800.00, 114000.00, 'B260307A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (8, 4, 17, 30, 250.00, 7500.00, 'B260307A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (9, 5, 7, 15, 1800.00, 27000.00, 'B260308A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (10, 5, 8, 15, 700.00, 10500.00, 'B260308A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (11, 6, 19, 25, 300.00, 7500.00, 'B260310A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (12, 6, 20, 25, 250.00, 6250.00, 'B260310A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (13, 7, 27, 100, 20.00, 2000.00, 'B260312A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (14, 7, 28, 100, 35.00, 3500.00, 'B260312A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (15, 8, 31, 50, 45.00, 2250.00, 'B260314A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (16, 8, 32, 50, 30.00, 1500.00, 'B260314A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (17, 9, 37, 15, 400.00, 6000.00, 'B260315A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (18, 9, 38, 15, 500.00, 7500.00, 'B260315A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (19, 10, 5, 20, 3800.00, 76000.00, 'B260317A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (20, 10, 6, 20, 2500.00, 50000.00, 'B260317A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (21, 11, 12, 15, 7000.00, 105000.00, 'B260318A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (22, 11, 13, 10, 1400.00, 14000.00, 'B260318A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (23, 12, 10, 25, 5200.00, 130000.00, 'B260320A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (24, 12, 11, 25, 3800.00, 95000.00, 'B260320A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (25, 13, 7, 20, 1800.00, 36000.00, 'B260322A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (26, 13, 8, 20, 700.00, 14000.00, 'B260322A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (27, 14, 2, 18, 12000.00, 216000.00, 'B260324A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (28, 14, 9, 17, 6500.00, 110500.00, 'B260324A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (29, 15, 17, 40, 250.00, 10000.00, 'B260325A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (30, 15, 18, 30, 1200.00, 36000.00, 'B260325A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (31, 16, 21, 20, 350.00, 7000.00, 'B260326A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (32, 16, 22, 20, 280.00, 5600.00, 'B260326A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (33, 17, 29, 80, 40.00, 3200.00, 'B260328A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (34, 17, 30, 70, 42.00, 2940.00, 'B260328A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (35, 18, 33, 70, 55.00, 3850.00, 'B260329A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (36, 18, 34, 70, 18.00, 1260.00, 'B260329A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (37, 19, 39, 20, 350.00, 7000.00, 'B260330A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (38, 19, 40, 20, 60.00, 1200.00, 'B260330A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (39, 20, 1, 30, 6800.00, 204000.00, 'B260331A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (40, 20, 3, 25, 4200.00, 105000.00, 'B260331A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (41, 21, 9, 25, 6500.00, 162500.00, 'B260401A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (42, 21, 11, 20, 3800.00, 76000.00, 'B260401A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (43, 22, 5, 25, 3800.00, 95000.00, 'B260402A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (44, 22, 6, 20, 2500.00, 50000.00, 'B260402A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (45, 23, 2, 14, 12000.00, 168000.00, 'B260403A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (46, 23, 36, 14, 4200.00, 58800.00, 'B260403A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (47, 24, 15, 40, 1000.00, 40000.00, 'B260404A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (48, 24, 16, 40, 2600.00, 104000.00, 'B260404A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (49, 25, 12, 14, 7000.00, 98000.00, 'B260405A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (50, 25, 14, 14, 1800.00, 25200.00, 'B260405A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (51, 26, 23, 15, 2800.00, 42000.00, 'B260406A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (52, 26, 24, 15, 3200.00, 48000.00, 'B260406A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (53, 27, 27, 130, 20.00, 2600.00, 'B260407A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (54, 27, 28, 120, 35.00, 4200.00, 'B260407A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (55, 28, 31, 80, 45.00, 3600.00, 'B260408A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (56, 28, 34, 80, 18.00, 1440.00, 'B260408A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (57, 29, 37, 25, 400.00, 10000.00, 'B260409A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (58, 29, 40, 20, 60.00, 1200.00, 'B260409A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (59, 30, 3, 28, 4200.00, 117600.00, 'B260410A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (60, 30, 4, 20, 3500.00, 70000.00, 'B260410A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (61, 31, 10, 20, 5200.00, 104000.00, 'B260411A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (62, 31, 11, 18, 3800.00, 68400.00, 'B260411A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (63, 32, 7, 25, 1800.00, 45000.00, 'B260412A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (64, 32, 8, 25, 700.00, 17500.00, 'B260412A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (65, 33, 9, 18, 6500.00, 117000.00, 'B260413A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (66, 33, 12, 14, 7000.00, 98000.00, 'B260413A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (67, 34, 17, 30, 250.00, 7500.00, 'B260414A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (68, 34, 18, 25, 1200.00, 30000.00, 'B260414A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (69, 35, 13, 14, 1400.00, 19600.00, 'B260415A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (70, 35, 14, 12, 1800.00, 21600.00, 'B260415A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (71, 36, 25, 25, 1200.00, 30000.00, 'B260416A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (72, 36, 26, 25, 180.00, 4500.00, 'B260416A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (73, 37, 29, 100, 40.00, 4000.00, 'B260417A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (74, 37, 30, 80, 42.00, 3360.00, 'B260417A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (75, 38, 32, 60, 30.00, 1800.00, 'B260418A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (76, 38, 33, 60, 55.00, 3300.00, 'B260418A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (77, 39, 39, 18, 350.00, 6300.00, 'B260419A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (78, 39, 37, 17, 400.00, 6800.00, 'B260419A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (79, 40, 1, 35, 6800.00, 238000.00, 'B260420A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (80, 40, 2, 25, 12000.00, 300000.00, 'B260420A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (81, 41, 9, 25, 6500.00, 162500.00, 'B260421A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (82, 41, 10, 25, 5200.00, 130000.00, 'B260421A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (83, 42, 3, 30, 4200.00, 126000.00, 'B260422A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (84, 42, 5, 25, 3800.00, 95000.00, 'B260422A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (85, 43, 2, 20, 12000.00, 240000.00, 'B260423A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (86, 43, 36, 16, 4200.00, 67200.00, 'B260423A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (87, 44, 15, 40, 1000.00, 40000.00, 'B260424A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (88, 44, 16, 35, 2600.00, 91000.00, 'B260424A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (89, 45, 12, 16, 7000.00, 112000.00, 'B260425A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (90, 45, 13, 14, 1400.00, 19600.00, 'B260425A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (91, 46, 19, 35, 300.00, 10500.00, 'B260426A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (92, 46, 20, 30, 250.00, 7500.00, 'B260426A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (93, 47, 27, 100, 20.00, 2000.00, 'B260427A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (94, 47, 28, 100, 35.00, 3500.00, 'B260427A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (95, 48, 31, 90, 45.00, 4050.00, 'B260428A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (96, 48, 34, 90, 18.00, 1620.00, 'B260428A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (97, 49, 38, 25, 500.00, 12500.00, 'B260429A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (98, 49, 40, 25, 60.00, 1500.00, 'B260429A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (99, 50, 5, 26, 3800.00, 98800.00, 'B260430A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (100, 50, 6, 26, 2500.00, 65000.00, 'B260430A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (101, 51, 9, 22, 6500.00, 143000.00, 'B260501A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (102, 51, 11, 20, 3800.00, 76000.00, 'B260501A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (103, 52, 7, 28, 1800.00, 50400.00, 'B260502A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (104, 52, 8, 27, 700.00, 18900.00, 'B260502A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (105, 53, 2, 18, 12000.00, 216000.00, 'B260503A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (106, 53, 35, 16, 3800.00, 60800.00, 'B260503A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (107, 54, 17, 50, 250.00, 12500.00, 'B260504A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (108, 54, 18, 40, 1200.00, 48000.00, 'B260504A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (109, 55, 12, 12, 7000.00, 84000.00, 'B260505A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (110, 55, 14, 12, 1800.00, 21600.00, 'B260505A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (111, 56, 21, 30, 350.00, 10500.00, 'B260506A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (112, 56, 22, 25, 280.00, 7000.00, 'B260506A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (113, 57, 29, 130, 40.00, 5200.00, 'B260507A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (114, 57, 30, 120, 42.00, 5040.00, 'B260507A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (115, 58, 33, 70, 55.00, 3850.00, 'B260508A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (116, 58, 34, 70, 18.00, 1260.00, 'B260508A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (117, 59, 37, 20, 400.00, 8000.00, 'B260509A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (118, 59, 39, 20, 350.00, 7000.00, 'B260509A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (119, 60, 1, 30, 6800.00, 204000.00, 'B260510A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (120, 60, 3, 25, 4200.00, 105000.00, 'B260510A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (121, 61, 10, 24, 5200.00, 124800.00, 'B260511A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (122, 61, 11, 24, 3800.00, 91200.00, 'B260511A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (123, 62, 7, 18, 1800.00, 32400.00, 'B260512A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (124, 62, 37, 17, 400.00, 6800.00, 'B260512A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (125, 63, 9, 20, 6500.00, 130000.00, 'B260513A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (126, 63, 36, 15, 4200.00, 63000.00, 'B260513A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (127, 64, 15, 35, 1000.00, 35000.00, 'B260514A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (128, 64, 16, 35, 2600.00, 91000.00, 'B260514A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (129, 65, 13, 14, 1400.00, 19600.00, 'B260515A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (130, 65, 14, 12, 1800.00, 21600.00, 'B260515A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (131, 66, 23, 20, 2800.00, 56000.00, 'B260516A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (132, 66, 25, 20, 1200.00, 24000.00, 'B260516A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (133, 67, 27, 120, 20.00, 2400.00, 'B260517A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (134, 67, 28, 100, 35.00, 3500.00, 'B260517A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (135, 68, 31, 80, 45.00, 3600.00, 'B260518A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (136, 68, 32, 80, 30.00, 2400.00, 'B260518A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (137, 69, 38, 25, 500.00, 12500.00, 'B260519A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (138, 69, 40, 25, 60.00, 1500.00, 'B260519A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (139, 70, 5, 30, 3800.00, 114000.00, 'B260520A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (140, 70, 6, 28, 2500.00, 70000.00, 'B260520A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (141, 71, 1, 20, 6800.00, 136000.00, 'B260521A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (142, 71, 3, 20, 4200.00, 84000.00, 'B260521A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (143, 72, 2, 15, 12000.00, 180000.00, 'B260521B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (144, 72, 36, 15, 4200.00, 63000.00, 'B260521B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (145, 73, 19, 40, 300.00, 12000.00, 'B260522A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (146, 73, 20, 40, 250.00, 10000.00, 'B260522A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (147, 74, 27, 200, 20.00, 4000.00, 'B260522B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (148, 74, 28, 200, 35.00, 7000.00, 'B260522B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (149, 75, 11, 50, 3800.00, 190000.00, 'B260523A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (150, 75, 17, 50, 250.00, 12500.00, 'B260523A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (155, 78, 31, 130, 45.00, 5850.00, 'B260524B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (156, 78, 33, 120, 55.00, 6600.00, 'B260524B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (157, 79, 9, 15, 6500.00, 97500.00, 'B260305B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (158, 79, 10, 15, 5200.00, 78000.00, 'B260305B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (159, 80, 14, 10, 1800.00, 18000.00, 'B260415B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (160, 80, 13, 10, 1400.00, 14000.00, 'B260415B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (161, 81, 40, 200, 60.00, 12000.00, '', NULL, NULL, '');
INSERT INTO `purchase_order_item` VALUES (162, 82, 40, 50, 12.00, 600.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (163, 83, 40, 50, 12.00, 600.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (164, 84, 39, 30, 8.00, 240.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (165, 85, 40, 10, 15.00, 150.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (166, 86, 40, 50, 12.00, 600.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (167, 87, 39, 30, 8.00, 240.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (168, 88, 40, 10, 15.00, 150.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (169, 89, 40, 2, 10.00, 20.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (170, 90, 40, 1, 10.00, 10.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (171, 91, 40, 2, 10.00, 20.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (172, 92, 40, 50, 12.00, 600.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (173, 93, 39, 30, 8.00, 240.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (174, 94, 40, 10, 15.00, 150.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (175, 95, 40, 1, 10.00, 10.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (176, 96, 40, 2, 10.00, 20.00, NULL, NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (177, 76, 5, 20, 3800.00, 76000.00, 'B260523B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (178, 76, 6, 20, 2500.00, 50000.00, 'B260523B', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (179, 76, 40, 1, 60.00, 60.00, '', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (180, 77, 7, 18, 1800.00, 32400.00, 'B260524A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (181, 77, 8, 17, 700.00, 11900.00, 'B260524A', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (182, 77, 27, 10000, 20.00, 200000.00, '', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (183, 97, 40, 1000, 60.00, 60000.00, '', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (184, 99, 40, 1, 60.00, 60.00, '', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (185, 100, 35, 1, 3800.00, 3800.00, '', NULL, NULL, NULL);
INSERT INTO `purchase_order_item` VALUES (186, 101, 39, 100, 350.00, 35000.00, '1', NULL, NULL, '');
INSERT INTO `purchase_order_item` VALUES (187, 102, 39, 100, 350.00, 35000.00, '2', NULL, NULL, '');
INSERT INTO `purchase_order_item` VALUES (188, 103, 38, 100, 500.00, 50000.00, '1', NULL, NULL, '');
INSERT INTO `purchase_order_item` VALUES (189, 104, 38, 100, 500.00, 50000.00, '2', NULL, NULL, '');

-- ----------------------------
-- Table structure for sales_order
-- ----------------------------
DROP TABLE IF EXISTS `sales_order`;
CREATE TABLE `sales_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '出库单号',
  `customer_id` bigint NULL DEFAULT NULL COMMENT '客户ID',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `total_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '出库总金额',
  `total_quantity` int NULL DEFAULT 0 COMMENT '出库总数量',
  `salesman` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售员',
  `external_order_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '外部订单号',
  `status` tinyint NULL DEFAULT 0 COMMENT '0=草稿 1=已出库 2=已取消 3=已作废 4=待审批',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `approve_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `order_date` date NOT NULL COMMENT '出库日期',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `deleted` tinyint NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_customer`(`customer_id` ASC) USING BTREE,
  INDEX `idx_warehouse`(`warehouse_id` ASC) USING BTREE,
  INDEX `idx_operator`(`operator_id` ASC) USING BTREE,
  INDEX `idx_order_date`(`order_date` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 85 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '销售出库单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sales_order
-- ----------------------------
INSERT INTO `sales_order` VALUES (1, 'SO20260301001', 1, 13, 85000.00, 30, '刘销售', NULL, 1, 6, NULL, NULL, '2026-03-01', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (2, 'SO20260303001', 2, 13, 65000.00, 25, '刘销售', NULL, 1, 6, NULL, NULL, '2026-03-03', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (3, 'SO20260305001', 3, 13, 45000.00, 20, '陈销售', NULL, 1, 7, NULL, NULL, '2026-03-05', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (4, 'SO20260307001', 4, 13, 32000.00, 15, '刘销售', NULL, 1, 6, NULL, NULL, '2026-03-07', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (5, 'SO20260308001', 5, 13, 78000.00, 28, '陈销售', NULL, 1, 7, NULL, NULL, '2026-03-08', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (6, 'SO20260310001', 6, 15, 55000.00, 22, '刘销售', NULL, 1, 6, NULL, NULL, '2026-03-10', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (7, 'SO20260312001', 7, 15, 48000.00, 18, '陈销售', NULL, 1, 7, NULL, NULL, '2026-03-12', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (8, 'SO20260314001', 1, 13, 92000.00, 35, '刘销售', NULL, 1, 6, NULL, NULL, '2026-03-14', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (9, 'SO20260315001', 8, 15, 35000.00, 16, '陈销售', NULL, 1, 7, NULL, NULL, '2026-03-15', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (10, 'SO20260317001', 9, 13, 72000.00, 26, '刘销售', NULL, 1, 6, NULL, NULL, '2026-03-17', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (11, 'SO20260318001', 2, 14, 58000.00, 24, '陈销售', NULL, 1, 7, NULL, NULL, '2026-03-18', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (12, 'SO20260320001', 10, 14, 42000.00, 20, '刘销售', NULL, 1, 6, NULL, NULL, '2026-03-20', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (13, 'SO20260322001', 3, 13, 38000.00, 18, '陈销售', NULL, 1, 7, NULL, NULL, '2026-03-22', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (14, 'SO20260324001', 4, 13, 68000.00, 25, '刘销售', NULL, 1, 6, NULL, NULL, '2026-03-24', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (15, 'SO20260325001', 11, 14, 52000.00, 22, '陈销售', NULL, 1, 7, NULL, NULL, '2026-03-25', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (16, 'SO20260326001', 5, 15, 88000.00, 32, '刘销售', NULL, 1, 6, NULL, NULL, '2026-03-26', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (17, 'SO20260328001', 12, 13, 41000.00, 20, '陈销售', NULL, 1, 7, NULL, NULL, '2026-03-28', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (18, 'SO20260329001', 6, 15, 63000.00, 28, '刘销售', NULL, 1, 6, NULL, NULL, '2026-03-29', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (19, 'SO20260330001', 13, 15, 28000.00, 14, '陈销售', NULL, 1, 7, NULL, NULL, '2026-03-30', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (20, 'SO20260331001', 1, 13, 95000.00, 38, '刘销售', NULL, 1, 6, NULL, NULL, '2026-03-31', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (21, 'SO20260401001', 14, 14, 48000.00, 22, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-01', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (22, 'SO20260402001', 2, 13, 72000.00, 28, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-02', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (23, 'SO20260403001', 7, 15, 56000.00, 24, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-03', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (24, 'SO20260404001', 8, 15, 42000.00, 18, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-04', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (25, 'SO20260405001', 3, 13, 38000.00, 16, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-05', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (26, 'SO20260406001', 11, 14, 65000.00, 30, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-06', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (27, 'SO20260407001', 15, 14, 52000.00, 22, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-07', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (28, 'SO20260408001', 4, 13, 78000.00, 30, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-08', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (29, 'SO20260409001', 5, 15, 65000.00, 26, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-09', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (30, 'SO20260410001', 9, 13, 42000.00, 18, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-10', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (31, 'SO20260411001', 10, 14, 58000.00, 24, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-11', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (32, 'SO20260412001', 1, 13, 88000.00, 34, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-12', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (33, 'SO20260413001', 6, 15, 72000.00, 30, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-13', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (34, 'SO20260414001', 2, 13, 55000.00, 22, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-14', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (35, 'SO20260415001', 12, 13, 38000.00, 18, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-15', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (36, 'SO20260416001', 14, 14, 62000.00, 26, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-16', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (37, 'SO20260417001', 3, 13, 48000.00, 20, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-17', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (38, 'SO20260418001', 7, 15, 35000.00, 16, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-18', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (39, 'SO20260419001', 8, 15, 52000.00, 24, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-19', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (40, 'SO20260420001', 11, 14, 68000.00, 28, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-20', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (41, 'SO20260421001', 4, 13, 42000.00, 18, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-21', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (42, 'SO20260422001', 15, 14, 58000.00, 24, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-22', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (43, 'SO20260423001', 5, 15, 72000.00, 30, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-23', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (44, 'SO20260424001', 9, 13, 45000.00, 20, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-24', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (45, 'SO20260425001', 1, 13, 92000.00, 36, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-25', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (46, 'SO20260426001', 6, 15, 68000.00, 28, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-26', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (47, 'SO20260427001', 2, 13, 58000.00, 24, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-27', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (48, 'SO20260428001', 10, 14, 38000.00, 18, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-28', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (49, 'SO20260429001', 13, 15, 45000.00, 20, '陈销售', NULL, 1, 7, NULL, NULL, '2026-04-29', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (50, 'SO20260430001', 3, 13, 72000.00, 28, '刘销售', NULL, 1, 6, NULL, NULL, '2026-04-30', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (51, 'SO20260501001', 14, 14, 52000.00, 22, '陈销售', NULL, 1, 7, NULL, NULL, '2026-05-01', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (52, 'SO20260502001', 1, 13, 85000.00, 32, '刘销售', NULL, 1, 6, NULL, NULL, '2026-05-02', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (53, 'SO20260503001', 7, 15, 48000.00, 20, '陈销售', NULL, 1, 7, NULL, NULL, '2026-05-03', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (54, 'SO20260504001', 4, 13, 62000.00, 26, '刘销售', NULL, 1, 6, NULL, NULL, '2026-05-04', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (55, 'SO20260505001', 11, 14, 58000.00, 24, '陈销售', NULL, 1, 7, NULL, NULL, '2026-05-05', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (56, 'SO20260506001', 5, 15, 72000.00, 30, '刘销售', NULL, 1, 6, NULL, NULL, '2026-05-06', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (57, 'SO20260507001', 2, 13, 42000.00, 18, '陈销售', NULL, 1, 7, NULL, NULL, '2026-05-07', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (58, 'SO20260508001', 8, 15, 38000.00, 16, '刘销售', NULL, 1, 6, NULL, NULL, '2026-05-08', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (59, 'SO20260509001', 9, 13, 65000.00, 26, '刘销售', NULL, 1, 6, NULL, NULL, '2026-05-09', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (60, 'SO20260510001', 12, 13, 52000.00, 22, '陈销售', NULL, 1, 7, NULL, NULL, '2026-05-10', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (61, 'SO20260511001', 3, 13, 48000.00, 20, '刘销售', NULL, 1, 6, NULL, NULL, '2026-05-11', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (62, 'SO20260512001', 15, 14, 58000.00, 24, '陈销售', NULL, 1, 7, NULL, NULL, '2026-05-12', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (63, 'SO20260513001', 6, 15, 65000.00, 28, '刘销售', NULL, 1, 6, NULL, NULL, '2026-05-13', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (64, 'SO20260514001', 10, 14, 42000.00, 18, '陈销售', NULL, 1, 7, NULL, NULL, '2026-05-14', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (65, 'SO20260515001', 1, 13, 88000.00, 34, '刘销售', NULL, 1, 6, NULL, NULL, '2026-05-15', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (66, 'SO20260516001', 14, 14, 52000.00, 22, '陈销售', NULL, 1, 7, NULL, NULL, '2026-05-16', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (67, 'SO20260517001', 4, 13, 72000.00, 28, '刘销售', NULL, 1, 6, NULL, NULL, '2026-05-17', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (68, 'SO20260518001', 7, 15, 48000.00, 20, '陈销售', NULL, 1, 7, NULL, NULL, '2026-05-18', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (69, 'SO20260519001', 2, 13, 58000.00, 24, '刘销售', NULL, 1, 6, NULL, NULL, '2026-05-19', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (70, 'SO20260520001', 11, 14, 65000.00, 28, '陈销售', NULL, 1, 7, NULL, NULL, '2026-05-20', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (71, 'SO20260521001', 3, 13, 35000.00, 15, '刘销售', NULL, 4, 6, NULL, NULL, '2026-05-21', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (72, 'SO20260521002', 5, 15, 52000.00, 22, '陈销售', NULL, 4, 7, NULL, NULL, '2026-05-21', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (73, 'SO20260522001', 1, 13, 68000.00, 26, '刘销售', NULL, 4, 6, NULL, NULL, '2026-05-22', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (74, 'SO20260522002', 9, 13, 42000.00, 18, '陈销售', NULL, 4, 7, NULL, NULL, '2026-05-22', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (75, 'SO20260523001', 8, 15, 32000.00, 14, '刘销售', NULL, 1, 6, 1, '2026-05-13 01:14:13', '2026-05-23', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (76, 'SO20260523002', 4, 13, 28000.00, 12, '陈销售', NULL, 0, 7, NULL, NULL, '2026-05-23', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (77, 'SO20260524001', 12, 13, 38000.00, 16, '刘销售', NULL, 0, 6, NULL, NULL, '2026-05-24', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (78, 'SO20260524002', 10, 14, 25000.00, 10, '陈销售', NULL, 0, 7, NULL, NULL, '2026-05-24', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (79, 'SO20260306001', 2, 13, 32000.00, 14, '刘销售', NULL, 2, 6, NULL, NULL, '2026-03-06', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (80, 'SO20260418002', 7, 15, 28000.00, 12, '陈销售', NULL, 2, 7, NULL, NULL, '2026-04-18', NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sales_order` VALUES (81, 'SO202605155002', 1, 19, 500.00, 20, NULL, NULL, 1, 1, 1, '2026-05-15 18:46:50', '2026-05-15', NULL, 0, '2026-05-15 18:46:50', '2026-05-15 18:46:50');
INSERT INTO `sales_order` VALUES (82, 'SO202605155003', 1, 19, 500.00, 20, NULL, NULL, 1, 1, 1, '2026-05-15 18:47:14', '2026-05-15', NULL, 0, '2026-05-15 18:47:14', '2026-05-15 18:47:14');
INSERT INTO `sales_order` VALUES (83, 'SO202605155004', 1, 19, 500.00, 20, NULL, NULL, 1, 1, 1, '2026-05-15 19:04:03', '2026-05-15', NULL, 0, '2026-05-15 19:04:03', '2026-05-15 19:04:03');
INSERT INTO `sales_order` VALUES (84, 'SO202605155005', 1, 19, 900.00, 1, '', NULL, 0, 1, NULL, NULL, '2026-05-15', '', 0, '2026-05-15 20:53:23', '2026-05-15 20:53:23');

-- ----------------------------
-- Table structure for sales_order_item
-- ----------------------------
DROP TABLE IF EXISTS `sales_order_item`;
CREATE TABLE `sales_order_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '出库单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` int NOT NULL COMMENT '出库数量',
  `unit_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '售价',
  `amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '金额',
  `batch_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_product`(`product_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 165 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '销售出库明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sales_order_item
-- ----------------------------
INSERT INTO `sales_order_item` VALUES (1, 1, 1, 15, 8999.00, 134985.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (2, 1, 9, 15, 8999.00, 134985.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (3, 2, 10, 15, 6999.00, 104985.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (4, 2, 11, 10, 4999.00, 49990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (5, 3, 2, 10, 14999.00, 149990.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (6, 3, 3, 10, 5599.00, 55990.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (7, 4, 7, 8, 2499.00, 19992.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (8, 4, 37, 7, 599.00, 4193.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (9, 5, 1, 18, 8999.00, 161982.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (10, 5, 35, 10, 4999.00, 49990.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (11, 6, 5, 12, 4999.00, 59988.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (12, 6, 6, 10, 3299.00, 32990.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (13, 7, 9, 10, 8999.00, 89990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (14, 7, 12, 8, 9699.00, 77592.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (15, 8, 1, 20, 8999.00, 179980.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (16, 8, 10, 15, 6999.00, 104985.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (17, 9, 3, 8, 5599.00, 44792.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (18, 9, 4, 8, 4599.00, 36792.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (19, 10, 2, 12, 14999.00, 179988.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (20, 10, 36, 14, 5499.00, 76986.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (21, 11, 11, 14, 4999.00, 69986.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (22, 11, 17, 10, 399.00, 3990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (23, 12, 19, 10, 499.00, 4990.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (24, 12, 20, 10, 399.00, 3990.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (25, 13, 27, 10, 38.00, 380.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (26, 13, 28, 8, 59.00, 472.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (27, 14, 9, 15, 8999.00, 134985.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (28, 14, 10, 10, 6999.00, 69990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (29, 15, 31, 12, 79.00, 948.00, 'B260314A', NULL);
INSERT INTO `sales_order_item` VALUES (30, 15, 32, 10, 55.00, 550.00, 'B260314A', NULL);
INSERT INTO `sales_order_item` VALUES (31, 16, 5, 16, 4999.00, 79984.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (32, 16, 6, 16, 3299.00, 52784.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (33, 17, 37, 12, 599.00, 7188.00, 'B260315A', NULL);
INSERT INTO `sales_order_item` VALUES (34, 17, 38, 8, 799.00, 6392.00, 'B260315A', NULL);
INSERT INTO `sales_order_item` VALUES (35, 18, 1, 18, 8999.00, 161982.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (36, 18, 2, 10, 14999.00, 149990.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (37, 19, 7, 8, 2499.00, 19992.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (38, 19, 8, 6, 999.00, 5994.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (39, 20, 3, 20, 5599.00, 111980.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (40, 20, 9, 18, 8999.00, 161982.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (41, 21, 11, 12, 4999.00, 59988.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (42, 21, 15, 10, 1399.00, 13990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (43, 22, 10, 18, 6999.00, 125982.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (44, 22, 12, 10, 9699.00, 96990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (45, 23, 5, 14, 4999.00, 69986.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (46, 23, 6, 10, 3299.00, 32990.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (47, 24, 3, 10, 5599.00, 55990.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (48, 24, 4, 8, 4599.00, 36792.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (49, 25, 13, 8, 1899.00, 15192.00, 'B260318A', NULL);
INSERT INTO `sales_order_item` VALUES (50, 25, 14, 8, 2499.00, 19992.00, 'B260318A', NULL);
INSERT INTO `sales_order_item` VALUES (51, 26, 17, 20, 399.00, 7980.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (52, 26, 18, 10, 1699.00, 16990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (53, 27, 27, 12, 38.00, 456.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (54, 27, 28, 10, 59.00, 590.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (55, 28, 1, 18, 8999.00, 161982.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (56, 28, 2, 12, 14999.00, 179988.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (57, 29, 9, 16, 8999.00, 143984.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (58, 29, 11, 10, 4999.00, 49990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (59, 30, 7, 10, 2499.00, 24990.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (60, 30, 8, 8, 999.00, 7992.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (61, 31, 19, 14, 499.00, 6986.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (62, 31, 20, 10, 399.00, 3990.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (63, 32, 1, 20, 8999.00, 179980.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (64, 32, 3, 14, 5599.00, 78386.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (65, 33, 5, 18, 4999.00, 89982.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (66, 33, 6, 12, 3299.00, 39588.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (67, 34, 10, 12, 6999.00, 83988.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (68, 34, 11, 10, 4999.00, 49990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (69, 35, 37, 10, 599.00, 5990.00, 'B260315A', NULL);
INSERT INTO `sales_order_item` VALUES (70, 35, 39, 8, 499.00, 3992.00, 'B260315A', NULL);
INSERT INTO `sales_order_item` VALUES (71, 36, 15, 14, 1399.00, 19586.00, 'B260404A', NULL);
INSERT INTO `sales_order_item` VALUES (72, 36, 16, 12, 3499.00, 41988.00, 'B260404A', NULL);
INSERT INTO `sales_order_item` VALUES (73, 37, 2, 10, 14999.00, 149990.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (74, 37, 3, 10, 5599.00, 55990.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (75, 38, 27, 8, 38.00, 304.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (76, 38, 28, 8, 59.00, 472.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (77, 39, 31, 14, 79.00, 1106.00, 'B260314A', NULL);
INSERT INTO `sales_order_item` VALUES (78, 39, 33, 10, 99.00, 990.00, 'B260314A', NULL);
INSERT INTO `sales_order_item` VALUES (79, 40, 17, 18, 399.00, 7182.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (80, 40, 18, 10, 1699.00, 16990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (81, 41, 7, 10, 2499.00, 24990.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (82, 41, 37, 8, 599.00, 4792.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (83, 42, 19, 14, 499.00, 6986.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (84, 42, 22, 10, 429.00, 4290.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (85, 43, 5, 18, 4999.00, 89982.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (86, 43, 6, 12, 3299.00, 39588.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (87, 44, 13, 10, 1899.00, 18990.00, 'B260318A', NULL);
INSERT INTO `sales_order_item` VALUES (88, 44, 14, 10, 2499.00, 24990.00, 'B260318A', NULL);
INSERT INTO `sales_order_item` VALUES (89, 45, 9, 20, 8999.00, 179980.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (90, 45, 10, 16, 6999.00, 111984.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (91, 46, 1, 18, 8999.00, 161982.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (92, 46, 2, 10, 14999.00, 149990.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (93, 47, 11, 14, 4999.00, 69986.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (94, 47, 12, 10, 9699.00, 96990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (95, 48, 27, 10, 38.00, 380.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (96, 48, 28, 8, 59.00, 472.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (97, 49, 31, 10, 79.00, 790.00, 'B260314A', NULL);
INSERT INTO `sales_order_item` VALUES (98, 49, 34, 10, 35.00, 350.00, 'B260314A', NULL);
INSERT INTO `sales_order_item` VALUES (99, 50, 3, 16, 5599.00, 89584.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (100, 50, 4, 12, 4599.00, 55188.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (101, 51, 15, 12, 1399.00, 16788.00, 'B260404A', NULL);
INSERT INTO `sales_order_item` VALUES (102, 51, 16, 10, 3499.00, 34990.00, 'B260404A', NULL);
INSERT INTO `sales_order_item` VALUES (103, 52, 1, 18, 8999.00, 161982.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (104, 52, 9, 14, 8999.00, 125986.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (105, 53, 5, 12, 4999.00, 59988.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (106, 53, 6, 8, 3299.00, 26392.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (107, 54, 10, 14, 6999.00, 97986.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (108, 54, 11, 12, 4999.00, 59988.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (109, 55, 17, 14, 399.00, 5586.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (110, 55, 18, 10, 1699.00, 16990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (111, 56, 7, 14, 2499.00, 34986.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (112, 56, 8, 16, 999.00, 15984.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (113, 57, 37, 10, 599.00, 5990.00, 'B260315A', NULL);
INSERT INTO `sales_order_item` VALUES (114, 57, 40, 8, 99.00, 792.00, 'B260315A', NULL);
INSERT INTO `sales_order_item` VALUES (115, 58, 19, 8, 499.00, 3992.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (116, 58, 20, 8, 399.00, 3192.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (117, 59, 2, 12, 14999.00, 179988.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (118, 59, 3, 14, 5599.00, 78386.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (119, 60, 13, 12, 1899.00, 22788.00, 'B260318A', NULL);
INSERT INTO `sales_order_item` VALUES (120, 60, 14, 10, 2499.00, 24990.00, 'B260318A', NULL);
INSERT INTO `sales_order_item` VALUES (121, 61, 27, 12, 38.00, 456.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (122, 61, 28, 8, 59.00, 472.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (123, 62, 31, 14, 79.00, 1106.00, 'B260314A', NULL);
INSERT INTO `sales_order_item` VALUES (124, 62, 32, 10, 55.00, 550.00, 'B260314A', NULL);
INSERT INTO `sales_order_item` VALUES (125, 63, 5, 16, 4999.00, 79984.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (126, 63, 6, 12, 3299.00, 39588.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (127, 64, 19, 10, 499.00, 4990.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (128, 64, 22, 8, 429.00, 3432.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (129, 65, 1, 20, 8999.00, 179980.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (130, 65, 9, 14, 8999.00, 125986.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (131, 66, 15, 12, 1399.00, 16788.00, 'B260404A', NULL);
INSERT INTO `sales_order_item` VALUES (132, 66, 16, 10, 3499.00, 34990.00, 'B260404A', NULL);
INSERT INTO `sales_order_item` VALUES (133, 67, 10, 16, 6999.00, 111984.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (134, 67, 11, 12, 4999.00, 59988.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (135, 68, 3, 10, 5599.00, 55990.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (136, 68, 4, 10, 4599.00, 45990.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (137, 69, 7, 12, 2499.00, 29988.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (138, 69, 8, 12, 999.00, 11988.00, 'B260308A', NULL);
INSERT INTO `sales_order_item` VALUES (139, 70, 17, 18, 399.00, 7182.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (140, 70, 18, 10, 1699.00, 16990.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (141, 71, 1, 8, 8999.00, 71992.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (142, 71, 3, 7, 5599.00, 39193.00, 'B260301A', NULL);
INSERT INTO `sales_order_item` VALUES (143, 72, 5, 12, 4999.00, 59988.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (144, 72, 6, 10, 3299.00, 32990.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (145, 73, 9, 14, 8999.00, 125986.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (146, 73, 10, 12, 6999.00, 83988.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (147, 74, 13, 10, 1899.00, 18990.00, 'B260318A', NULL);
INSERT INTO `sales_order_item` VALUES (148, 74, 14, 8, 2499.00, 19992.00, 'B260318A', NULL);
INSERT INTO `sales_order_item` VALUES (149, 75, 19, 8, 499.00, 3992.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (150, 75, 20, 6, 399.00, 2394.00, 'B260310A', NULL);
INSERT INTO `sales_order_item` VALUES (151, 76, 37, 6, 599.00, 3594.00, 'B260315A', NULL);
INSERT INTO `sales_order_item` VALUES (152, 76, 39, 6, 499.00, 2994.00, 'B260315A', NULL);
INSERT INTO `sales_order_item` VALUES (153, 77, 2, 8, 14999.00, 119992.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (154, 77, 35, 8, 4999.00, 39992.00, 'B260305A', NULL);
INSERT INTO `sales_order_item` VALUES (155, 78, 27, 6, 38.00, 228.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (156, 78, 28, 4, 59.00, 236.00, 'B260312A', NULL);
INSERT INTO `sales_order_item` VALUES (157, 79, 9, 8, 8999.00, 71992.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (158, 79, 10, 6, 6999.00, 41994.00, 'B260303A', NULL);
INSERT INTO `sales_order_item` VALUES (159, 80, 5, 8, 4999.00, 39992.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (160, 80, 6, 4, 3299.00, 13196.00, 'B260317A', NULL);
INSERT INTO `sales_order_item` VALUES (161, 81, 40, 20, 25.00, 500.00, NULL, NULL);
INSERT INTO `sales_order_item` VALUES (162, 82, 40, 20, 25.00, 500.00, NULL, NULL);
INSERT INTO `sales_order_item` VALUES (163, 83, 40, 20, 25.00, 500.00, NULL, NULL);
INSERT INTO `sales_order_item` VALUES (164, 84, 40, 1, 900.00, 900.00, '', NULL);

-- ----------------------------
-- Table structure for stock_adjustment
-- ----------------------------
DROP TABLE IF EXISTS `stock_adjustment`;
CREATE TABLE `stock_adjustment`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调整单号',
  `stock_take_id` bigint NULL DEFAULT NULL COMMENT '关联盘点单ID',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `adjust_type` tinyint NULL DEFAULT 0 COMMENT '0=盘盈 1=盘亏',
  `total_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '调整金额',
  `status` tinyint NULL DEFAULT 0 COMMENT '0=草稿 1=已调整',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `deleted` tinyint NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_stock_take`(`stock_take_id` ASC) USING BTREE,
  INDEX `idx_warehouse`(`warehouse_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库存调整单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of stock_adjustment
-- ----------------------------
INSERT INTO `stock_adjustment` VALUES (1, 'TZ20260315001', 1, 13, 1, 5200.00, 1, 1, 'Q1盘点差异调整', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `stock_adjustment` VALUES (2, 'TZ20260415001', 2, 14, 1, 2800.00, 1, 1, '4月盘点差异调整', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');

-- ----------------------------
-- Table structure for stock_take
-- ----------------------------
DROP TABLE IF EXISTS `stock_take`;
CREATE TABLE `stock_take`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '盘点单号',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `take_type` tinyint NULL DEFAULT 0 COMMENT '0=全盘 1=抽盘',
  `total_items` int NULL DEFAULT 0 COMMENT '盘点商品数',
  `diff_items` int NULL DEFAULT 0 COMMENT '差异商品数',
  `status` tinyint NULL DEFAULT 0 COMMENT '0=盘点中 1=已审核 2=已调整 3=已作废',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '盘点人ID',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `order_date` date NULL DEFAULT NULL COMMENT '盘点日期',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `deleted` tinyint NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_warehouse`(`warehouse_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '盘点单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of stock_take
-- ----------------------------
INSERT INTO `stock_take` VALUES (1, 'CK20260315001', 13, 0, 14, 3, 2, 8, 1, '2026-03-15', 'Q1全盘-已调整', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `stock_take` VALUES (2, 'CK20260415001', 14, 0, 11, 2, 2, 9, 1, '2026-04-15', '4月全盘-已调整', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `stock_take` VALUES (3, 'CK20260430001', 13, 0, 14, 1, 1, 8, 1, '2026-04-30', '4月末盘点-已审核待调整', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `stock_take` VALUES (4, 'CK20260501001', 15, 1, 8, 0, 1, 9, 3, '2026-05-01', '杭州抽盘-已审核', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `stock_take` VALUES (5, 'CK20260515001', 13, 0, 14, 0, 0, 8, NULL, '2026-05-15', '5月中盘点中', 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `stock_take` VALUES (6, 'ST202605130001', 15, 0, 29, 0, 0, 1, NULL, '2026-05-13', NULL, 0, '2026-05-13 04:12:04', '2026-05-13 04:12:04');
INSERT INTO `stock_take` VALUES (7, 'ST202605130002', 13, 0, 35, 0, 0, 1, NULL, '2026-05-12', '', 0, '2026-05-13 04:12:34', '2026-05-13 04:12:34');
INSERT INTO `stock_take` VALUES (8, 'ST202605130003', 19, 0, 0, 0, 0, 1, NULL, '2026-05-12', '', 0, '2026-05-13 04:32:03', '2026-05-13 04:32:03');
INSERT INTO `stock_take` VALUES (9, 'ST202605130004', 13, 0, 35, 0, 0, 1, NULL, '2026-05-12', '', 0, '2026-05-13 04:32:12', '2026-05-13 04:32:12');
INSERT INTO `stock_take` VALUES (10, 'ST202605150001', 19, 0, 1, 0, 2, 1, 1, '2026-05-15', NULL, 0, '2026-05-15 18:49:45', '2026-05-15 18:49:45');
INSERT INTO `stock_take` VALUES (11, 'ST202605150002', 19, 0, 1, 1, 2, 1, 1, '2026-05-15', NULL, 0, '2026-05-15 18:52:10', '2026-05-15 18:52:10');
INSERT INTO `stock_take` VALUES (12, 'ST202605150003', 19, 0, 1, 1, 2, 1, 1, '2026-05-15', NULL, 0, '2026-05-15 19:04:07', '2026-05-15 19:04:07');
INSERT INTO `stock_take` VALUES (13, 'ST202605150004', 19, 0, 1, 0, 0, 1, NULL, '2026-05-15', NULL, 0, '2026-05-15 20:53:34', '2026-05-15 20:53:34');
INSERT INTO `stock_take` VALUES (14, 'ST202605150005', 19, 0, 1, 0, 0, 1, NULL, '2026-05-15', NULL, 0, '2026-05-15 20:54:00', '2026-05-15 20:54:00');
INSERT INTO `stock_take` VALUES (15, 'ST202605230001', 19, 0, 3, 2, 2, 1, 1, '2026-05-23', '', 0, '2026-05-23 14:17:04', '2026-05-23 14:17:04');
INSERT INTO `stock_take` VALUES (16, 'ST202605230002', 19, 0, 4, 2, 2, 1, 1, '2026-05-23', '', 0, '2026-05-23 14:22:25', '2026-05-23 14:22:25');

-- ----------------------------
-- Table structure for stock_take_item
-- ----------------------------
DROP TABLE IF EXISTS `stock_take_item`;
CREATE TABLE `stock_take_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `stock_take_id` bigint NOT NULL COMMENT '盘点单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `location_id` bigint NULL DEFAULT NULL COMMENT '库位ID',
  `batch_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `book_qty` int NOT NULL DEFAULT 0 COMMENT '账面数量',
  `actual_qty` int NOT NULL DEFAULT 0 COMMENT '实盘数量',
  `diff_qty` int NOT NULL DEFAULT 0 COMMENT '差异数量',
  `diff_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '差异原因',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_stock_take`(`stock_take_id` ASC) USING BTREE,
  INDEX `idx_product`(`product_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 171 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '盘点明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of stock_take_item
-- ----------------------------
INSERT INTO `stock_take_item` VALUES (1, 1, 1, NULL, 'B260301A', 80, 78, -2, '盘亏-发货未记账', '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (2, 1, 9, NULL, 'B260303A', 60, 60, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (3, 1, 10, NULL, 'B260303A', 50, 48, -2, '盘亏-样品出库', '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (4, 1, 3, NULL, 'B260305A', 30, 30, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (5, 1, 2, NULL, 'B260305A', 20, 19, -1, '盘亏-破损', '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (6, 1, 7, NULL, 'B260308A', 30, 30, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (7, 1, 8, NULL, 'B260308A', 30, 30, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (8, 1, 19, NULL, 'B260310A', 50, 50, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (9, 1, 20, NULL, 'B260310A', 50, 50, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (10, 1, 13, NULL, 'B260318A', 20, 20, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (11, 1, 14, NULL, 'B260318A', 20, 20, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (12, 1, 17, NULL, 'B260307A', 40, 40, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (13, 1, 37, NULL, 'B260315A', 30, 30, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (14, 1, 38, NULL, 'B260315A', 30, 30, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (15, 2, 1, NULL, 'B260301A', 50, 50, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (16, 2, 9, NULL, 'B260303A', 40, 40, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (17, 2, 11, NULL, 'B260303A', 40, 38, -2, '盘亏-丢失', '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (18, 2, 17, NULL, 'B260307A', 30, 30, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (19, 2, 18, NULL, 'B260307A', 30, 30, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (20, 2, 19, NULL, 'B260310A', 25, 25, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (21, 2, 20, NULL, 'B260310A', 25, 25, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (22, 2, 27, NULL, 'B260312A', 200, 200, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (23, 2, 28, NULL, 'B260312A', 200, 200, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (24, 2, 31, NULL, 'B260314A', 100, 100, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (25, 2, 32, NULL, 'B260314A', 100, 100, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (26, 3, 1, NULL, 'B260301A', 65, 65, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (27, 3, 9, NULL, 'B260303A', 55, 55, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (28, 3, 10, NULL, 'B260303A', 45, 45, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (29, 3, 11, NULL, 'B260303A', 35, 35, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (30, 3, 2, NULL, 'B260305A', 18, 18, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (31, 3, 3, NULL, 'B260305A', 25, 25, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (32, 3, 7, NULL, 'B260308A', 25, 25, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (33, 3, 13, NULL, 'B260318A', 15, 15, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (34, 3, 14, NULL, 'B260318A', 15, 15, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (35, 3, 15, NULL, 'B260404A', 40, 40, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (36, 3, 16, NULL, 'B260404A', 40, 40, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (37, 3, 17, NULL, 'B260307A', 35, 34, -1, '盘亏-不明原因', '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (38, 3, 37, NULL, 'B260315A', 25, 25, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (39, 4, 1, NULL, 'B260301A', 30, 30, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (40, 4, 9, NULL, 'B260303A', 25, 25, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (41, 4, 11, NULL, 'B260303A', 20, 20, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (42, 4, 5, NULL, 'B260317A', 25, 25, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (43, 4, 6, NULL, 'B260317A', 20, 20, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (44, 4, 19, NULL, 'B260310A', 15, 15, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (45, 4, 27, NULL, 'B260312A', 100, 100, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (46, 4, 28, NULL, 'B260312A', 80, 80, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (47, 5, 1, NULL, 'B260301A', 85, 85, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (48, 5, 9, NULL, 'B260303A', 80, 80, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (49, 5, 10, NULL, 'B260303A', 60, 60, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (50, 5, 11, NULL, 'B260303A', 55, 55, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (51, 5, 2, NULL, 'B260305A', 25, 25, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (52, 5, 3, NULL, 'B260305A', 45, 45, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (53, 5, 7, NULL, 'B260308A', 30, 30, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (54, 5, 13, NULL, 'B260318A', 20, 20, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (55, 5, 14, NULL, 'B260318A', 20, 20, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (56, 5, 15, NULL, 'B260404A', 55, 55, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (57, 5, 16, NULL, 'B260404A', 55, 55, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (58, 5, 17, NULL, 'B260307A', 50, 50, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (59, 5, 37, NULL, 'B260315A', 30, 30, 0, NULL, '2026-05-13 01:12:55');
INSERT INTO `stock_take_item` VALUES (60, 6, 1, NULL, 'B260301A', 15, 15, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (61, 6, 2, NULL, 'B260305A', 12, 12, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (62, 6, 3, NULL, 'B260305A', 28, 28, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (63, 6, 4, NULL, 'B260410A', 15, 15, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (64, 6, 5, NULL, 'B260317A', 18, 18, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (65, 6, 6, NULL, 'B260317A', 15, 15, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (66, 6, 7, NULL, 'B260308A', 12, 12, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (67, 6, 8, NULL, 'B260308A', 15, 15, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (68, 6, 9, NULL, 'B260303A', 25, 25, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (69, 6, 10, NULL, 'B260303A', 20, 20, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (70, 6, 11, NULL, 'B260303A', 18, 18, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (71, 6, 19, NULL, 'B260310A', 7, 7, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (72, 6, 20, NULL, 'B260310A', 19, 19, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (73, 6, 21, NULL, 'B260326A', 15, 15, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (74, 6, 22, NULL, 'B260326A', 15, 15, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (75, 6, 23, NULL, 'B260406A', 10, 10, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (76, 6, 24, NULL, 'B260406A', 10, 10, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (77, 6, 25, NULL, 'B260416A', 10, 10, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (78, 6, 27, NULL, 'B260312A', 80, 80, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (79, 6, 28, NULL, 'B260312A', 60, 60, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (80, 6, 29, NULL, 'B260328A', 60, 60, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (81, 6, 30, NULL, 'B260328A', 50, 50, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (82, 6, 31, NULL, 'B260314A', 30, 30, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (83, 6, 33, NULL, 'B260329A', 25, 25, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (84, 6, 35, NULL, 'B260301A', 8, 8, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (85, 6, 36, NULL, 'B260305A', 12, 12, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (86, 6, 37, NULL, 'B260315A', 15, 15, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (87, 6, 38, NULL, 'B260429A', 10, 10, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (88, 6, 39, NULL, 'B260330A', 10, 10, 0, NULL, '2026-05-13 04:12:04');
INSERT INTO `stock_take_item` VALUES (89, 7, 1, NULL, 'B260301A', 85, 85, 0, '', '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (90, 7, 2, NULL, 'B260305A', 25, 25, 0, '', '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (91, 7, 3, NULL, 'B260305A', 45, 45, 0, '', '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (92, 7, 7, NULL, 'B260308A', 30, 30, 0, '', '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (93, 7, 8, NULL, 'B260308A', 35, 35, 0, '', '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (94, 7, 9, NULL, 'B260303A', 80, 80, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (95, 7, 10, NULL, 'B260303A', 60, 60, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (96, 7, 11, NULL, 'B260303A', 55, 55, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (97, 7, 12, NULL, 'B260318A', 15, 15, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (98, 7, 13, NULL, 'B260318A', 20, 20, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (99, 7, 14, NULL, 'B260318A', 20, 20, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (100, 7, 15, NULL, 'B260404A', 55, 55, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (101, 7, 16, NULL, 'B260404A', 55, 55, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (102, 7, 17, NULL, 'B260307A', 50, 50, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (103, 7, 18, NULL, 'B260307A', 35, 35, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (104, 7, 19, NULL, 'B260310A', 15, 15, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (105, 7, 20, NULL, 'B260310A', 20, 20, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (106, 7, 21, NULL, 'B260326A', 20, 20, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (107, 7, 22, NULL, 'B260326A', 20, 20, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (108, 7, 23, NULL, 'B260406A', 15, 15, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (109, 7, 24, NULL, 'B260406A', 15, 15, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (110, 7, 25, NULL, 'B260416A', 25, 25, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (111, 7, 26, NULL, 'B260416A', 25, 25, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (112, 7, 27, NULL, 'B260312A', 20, 20, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (113, 7, 28, NULL, 'B260312A', 15, 15, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (114, 7, 31, NULL, 'B260314A', 15, 15, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (115, 7, 32, NULL, 'B260314A', 15, 15, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (116, 7, 33, NULL, 'B260329A', 10, 10, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (117, 7, 34, NULL, 'B260329A', 10, 10, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (118, 7, 35, NULL, 'B260301A', 5, 5, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (119, 7, 36, NULL, 'B260305A', 8, 8, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (120, 7, 37, NULL, 'B260315A', 30, 30, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (121, 7, 38, NULL, 'B260315A', 28, 28, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (122, 7, 39, NULL, 'B260330A', 12, 12, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (123, 7, 40, NULL, 'B260330A', 215, 215, 0, NULL, '2026-05-13 04:12:34');
INSERT INTO `stock_take_item` VALUES (124, 9, 1, NULL, 'B260301A', 85, 85, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (125, 9, 2, NULL, 'B260305A', 25, 25, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (126, 9, 3, NULL, 'B260305A', 45, 45, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (127, 9, 7, NULL, 'B260308A', 30, 30, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (128, 9, 8, NULL, 'B260308A', 35, 35, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (129, 9, 9, NULL, 'B260303A', 80, 80, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (130, 9, 10, NULL, 'B260303A', 60, 60, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (131, 9, 11, NULL, 'B260303A', 55, 55, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (132, 9, 12, NULL, 'B260318A', 15, 15, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (133, 9, 13, NULL, 'B260318A', 20, 20, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (134, 9, 14, NULL, 'B260318A', 20, 20, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (135, 9, 15, NULL, 'B260404A', 55, 55, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (136, 9, 16, NULL, 'B260404A', 55, 55, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (137, 9, 17, NULL, 'B260307A', 50, 50, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (138, 9, 18, NULL, 'B260307A', 35, 35, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (139, 9, 19, NULL, 'B260310A', 15, 15, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (140, 9, 20, NULL, 'B260310A', 20, 20, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (141, 9, 21, NULL, 'B260326A', 20, 20, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (142, 9, 22, NULL, 'B260326A', 20, 20, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (143, 9, 23, NULL, 'B260406A', 15, 15, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (144, 9, 24, NULL, 'B260406A', 15, 15, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (145, 9, 25, NULL, 'B260416A', 25, 25, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (146, 9, 26, NULL, 'B260416A', 25, 25, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (147, 9, 27, NULL, 'B260312A', 20, 20, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (148, 9, 28, NULL, 'B260312A', 15, 15, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (149, 9, 31, NULL, 'B260314A', 15, 15, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (150, 9, 32, NULL, 'B260314A', 15, 15, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (151, 9, 33, NULL, 'B260329A', 10, 10, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (152, 9, 34, NULL, 'B260329A', 10, 10, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (153, 9, 35, NULL, 'B260301A', 5, 5, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (154, 9, 36, NULL, 'B260305A', 8, 8, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (155, 9, 37, NULL, 'B260315A', 30, 30, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (156, 9, 38, NULL, 'B260315A', 28, 28, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (157, 9, 39, NULL, 'B260330A', 12, 12, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (158, 9, 40, NULL, 'B260330A', 215, 215, 0, NULL, '2026-05-13 04:32:12');
INSERT INTO `stock_take_item` VALUES (159, 10, 40, NULL, NULL, 80, 80, 0, NULL, '2026-05-15 18:49:45');
INSERT INTO `stock_take_item` VALUES (160, 11, 40, NULL, NULL, 80, 85, 5, '测试盘盈', '2026-05-15 18:52:10');
INSERT INTO `stock_take_item` VALUES (161, 12, 40, NULL, NULL, 100, 105, 5, '测试盘盈', '2026-05-15 19:04:07');
INSERT INTO `stock_take_item` VALUES (162, 13, 40, NULL, NULL, 105, 105, 0, NULL, '2026-05-15 20:53:34');
INSERT INTO `stock_take_item` VALUES (163, 14, 40, NULL, NULL, 105, 105, 0, NULL, '2026-05-15 20:54:00');
INSERT INTO `stock_take_item` VALUES (164, 15, 40, NULL, NULL, 105, 105, 0, NULL, '2026-05-23 14:17:04');
INSERT INTO `stock_take_item` VALUES (165, 15, 39, NULL, '1', 100, 105, 5, '', '2026-05-23 14:17:04');
INSERT INTO `stock_take_item` VALUES (166, 15, 39, NULL, '2', 100, 102, 2, '', '2026-05-23 14:17:04');
INSERT INTO `stock_take_item` VALUES (167, 16, 40, NULL, NULL, 105, 105, 0, NULL, '2026-05-23 14:22:25');
INSERT INTO `stock_take_item` VALUES (168, 16, 39, NULL, '1', 207, 207, 0, NULL, '2026-05-23 14:22:25');
INSERT INTO `stock_take_item` VALUES (169, 16, 38, NULL, '1', 100, 104, 4, '', '2026-05-23 14:22:25');
INSERT INTO `stock_take_item` VALUES (170, 16, 38, NULL, '2', 100, 103, 3, '', '2026-05-23 14:22:25');

-- ----------------------------
-- Table structure for supplier
-- ----------------------------
DROP TABLE IF EXISTS `supplier`;
CREATE TABLE `supplier`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '供应商编码',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '供应商名称',
  `contact` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地址',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `deleted` tinyint NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供应商表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of supplier
-- ----------------------------
INSERT INTO `supplier` VALUES (1, 'SP001', '联想（上海）有限公司', '赵经理', '13910000001', '上海市浦东新区张江高科技园区', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `supplier` VALUES (2, 'SP002', '华为技术有限公司', '钱主管', '13910000002', '深圳市龙岗区坂田街道', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `supplier` VALUES (3, 'SP003', '戴尔（中国）有限公司', '孙经理', '13910000003', '上海市黄浦区淮海中路', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `supplier` VALUES (4, 'SP004', '苹果电脑贸易有限公司', '李经理', '13910000004', '上海市浦东新区世纪大道', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `supplier` VALUES (5, 'SP005', '小米通讯技术有限公司', '周主管', '13910000005', '北京市海淀区安宁庄路', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `supplier` VALUES (6, 'SP006', '三星（中国）投资有限公司', '吴经理', '13910000006', '北京市朝阳区望京东路', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `supplier` VALUES (7, 'SP007', '美的集团股份有限公司', '郑主管', '13910000007', '广东省佛山市顺德区北滘镇', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `supplier` VALUES (8, 'SP008', '农夫山泉股份有限公司', '王经理', '13910000008', '浙江省杭州市西湖区', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `supplier` VALUES (9, 'SP009', '三只松鼠股份有限公司', '冯主管', '13910000009', '安徽省芜湖市弋江区', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `supplier` VALUES (10, 'SP010', '华硕电脑股份有限公司', '陈经理', '13910000010', '上海市闵行区虹桥商务区', 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置键',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置值',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '说明',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, 'purchase_order_prefix', 'PO', '入库单前缀', '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_config` VALUES (2, 'sales_order_prefix', 'SO', '出库单前缀', '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_config` VALUES (3, 'stocktake_order_prefix', 'CK', '盘点单前缀', '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_config` VALUES (4, 'transfer_order_prefix', 'DB', '调拨单前缀', '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_config` VALUES (5, 'alert_enabled', 'true', '安全库存预警开关', '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_config` VALUES (6, 'company_name', '众鑫商贸有限公司', '公司名称', '2026-05-13 01:12:55', '2026-05-13 01:12:55');

-- ----------------------------
-- Table structure for sys_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_operation_log`;
CREATE TABLE `sys_operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `operator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人用户名',
  `module` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作模块',
  `action` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作动作',
  `target_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '目标类型',
  `target_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '目标ID',
  `detail` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作详情',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求IP',
  `request_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求URL',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求方法',
  `cost_time` int NULL DEFAULT 0 COMMENT '耗时(ms)',
  `result` tinyint NULL DEFAULT 1 COMMENT '结果 1=成功 0=失败',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_module`(`module` ASC) USING BTREE,
  INDEX `idx_operator`(`operator` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 152 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_operation_log
-- ----------------------------
INSERT INTO `sys_operation_log` VALUES (1, 1, 'admin', 'auth', 'login', 'sys_user', NULL, '管理员登录', NULL, NULL, NULL, 0, 1, '2026-05-24 08:00:00');
INSERT INTO `sys_operation_log` VALUES (2, 4, 'buyer1', 'purchase', 'create', 'purchase_order', NULL, '新增采购单PO20260521001', NULL, NULL, NULL, 0, 1, '2026-05-21 09:00:00');
INSERT INTO `sys_operation_log` VALUES (3, 4, 'buyer1', 'purchase', 'submit', 'purchase_order', NULL, '提交审批PO20260521001', NULL, NULL, NULL, 0, 1, '2026-05-21 09:05:00');
INSERT INTO `sys_operation_log` VALUES (4, 1, 'admin', 'purchase', 'approve', 'purchase_order', NULL, '审核通过PO20260521001', NULL, NULL, NULL, 0, 1, '2026-05-21 09:30:00');
INSERT INTO `sys_operation_log` VALUES (5, 6, 'seller1', 'sales', 'create', 'sales_order', NULL, '新增销售单SO20260521001', NULL, NULL, NULL, 0, 1, '2026-05-21 10:00:00');
INSERT INTO `sys_operation_log` VALUES (6, 6, 'seller1', 'sales', 'submit', 'sales_order', NULL, '提交审批SO20260521001', NULL, NULL, NULL, 0, 1, '2026-05-21 10:05:00');
INSERT INTO `sys_operation_log` VALUES (7, 1, 'admin', 'sales', 'approve', 'sales_order', NULL, '审核通过SO20260521001', NULL, NULL, NULL, 0, 1, '2026-05-21 10:30:00');
INSERT INTO `sys_operation_log` VALUES (8, 8, 'keeper1', 'transfer', 'create', 'inventory_transfer', NULL, '新增调拨单DB20260521001', NULL, NULL, NULL, 0, 1, '2026-05-21 11:00:00');
INSERT INTO `sys_operation_log` VALUES (9, 8, 'keeper1', 'transfer', 'submit', 'inventory_transfer', NULL, '提交审批DB20260521001', NULL, NULL, NULL, 0, 1, '2026-05-21 11:05:00');
INSERT INTO `sys_operation_log` VALUES (10, 1, 'admin', 'transfer', 'approve', 'inventory_transfer', NULL, '审核通过DB20260501001', NULL, NULL, NULL, 0, 1, '2026-05-21 11:30:00');
INSERT INTO `sys_operation_log` VALUES (11, 2, 'manager1', 'stocktake', 'approve', 'stock_take', NULL, '审核通过盘点单CK20260430001', NULL, NULL, NULL, 0, 1, '2026-04-30 16:00:00');
INSERT INTO `sys_operation_log` VALUES (12, 3, 'manager2', 'stocktake', 'approve', 'stock_take', NULL, '审核通过盘点单CK20260501001', NULL, NULL, NULL, 0, 1, '2026-05-01 16:00:00');
INSERT INTO `sys_operation_log` VALUES (13, 1, 'admin', 'product', 'update', 'product', NULL, '修改商品[ThinkPad]价格', NULL, NULL, NULL, 0, 1, '2026-05-20 14:00:00');
INSERT INTO `sys_operation_log` VALUES (14, 4, 'buyer1', 'purchase', 'create', 'purchase_order', NULL, '新增采购单PO20260523002(草稿)', NULL, NULL, NULL, 0, 1, '2026-05-23 14:30:00');
INSERT INTO `sys_operation_log` VALUES (15, 6, 'seller1', 'sales', 'create', 'sales_order', NULL, '新增销售单SO20260523002(草稿)', NULL, NULL, NULL, 0, 1, '2026-05-23 15:00:00');
INSERT INTO `sys_operation_log` VALUES (16, 2, 'manager1', 'inventory', 'query', 'inventory', NULL, '查询库存预警列表', NULL, NULL, NULL, 0, 1, '2026-05-24 09:00:00');
INSERT INTO `sys_operation_log` VALUES (17, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605133002', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 26, 1, '2026-05-13 01:13:30');
INSERT INTO `sys_operation_log` VALUES (18, 1, '系统管理员', '采购入库', '提交', NULL, '81', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/81/submit', 'PUT', 5, 1, '2026-05-13 01:13:30');
INSERT INTO `sys_operation_log` VALUES (19, 1, '系统管理员', '采购入库', '审核', NULL, '81', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/81/approve', 'PUT', 11, 1, '2026-05-13 01:13:34');
INSERT INTO `sys_operation_log` VALUES (20, 1, '系统管理员', '销售出库', '审核', NULL, '75', '审核销售出库', '0:0:0:0:0:0:0:1', '/api/v1/sales-order/75/approve', 'PUT', 12, 1, '2026-05-13 01:14:13');
INSERT INTO `sys_operation_log` VALUES (21, 1, '系统管理员', '仓库', '新增', NULL, '', '新增仓库：WH20260513001', '0:0:0:0:0:0:0:1', '/api/v1/warehouse', 'POST', 46, 1, '2026-05-13 03:58:29');
INSERT INTO `sys_operation_log` VALUES (22, 1, '系统管理员', '库存盘点', '新增', NULL, '', '新增库存盘点：ST202605130001', '192.168.10.162', '/api/v1/stock-take', 'POST', 76, 1, '2026-05-13 04:12:04');
INSERT INTO `sys_operation_log` VALUES (23, 1, '系统管理员', '库存盘点', '新增', NULL, '', '新增库存盘点：ST202605130002', '0:0:0:0:0:0:0:1', '/api/v1/stock-take', 'POST', 36, 1, '2026-05-13 04:12:34');
INSERT INTO `sys_operation_log` VALUES (24, 1, '系统管理员', '库存', 'export', NULL, '', 'export库存', '0:0:0:0:0:0:0:1', '/api/v1/inventory/export', 'GET', 574, 1, '2026-05-13 04:17:24');
INSERT INTO `sys_operation_log` VALUES (25, 1, '系统管理员', '库存盘点', '新增', NULL, '', '新增库存盘点：ST202605130003', '0:0:0:0:0:0:0:1', '/api/v1/stock-take', 'POST', 7, 1, '2026-05-13 04:32:03');
INSERT INTO `sys_operation_log` VALUES (26, 1, '系统管理员', '库存盘点', '新增', NULL, '', '新增库存盘点：ST202605130004', '0:0:0:0:0:0:0:1', '/api/v1/stock-take', 'POST', 41, 1, '2026-05-13 04:32:12');
INSERT INTO `sys_operation_log` VALUES (27, 1, '系统管理员', '库存盘点', 'export', NULL, '', 'export库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/export', 'GET', 2258, 1, '2026-05-13 04:58:20');
INSERT INTO `sys_operation_log` VALUES (28, 1, '系统管理员', '库存盘点', 'export', NULL, '', 'export库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/export', 'GET', 512, 1, '2026-05-13 05:03:36');
INSERT INTO `sys_operation_log` VALUES (29, 1, '系统管理员', '库存盘点', 'export', NULL, '', 'export库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/export', 'GET', 1630, 1, '2026-05-13 05:09:47');
INSERT INTO `sys_operation_log` VALUES (30, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155002', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 24, 1, '2026-05-15 18:46:25');
INSERT INTO `sys_operation_log` VALUES (31, 1, '系统管理员', '采购入库', '提交', NULL, '82', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/82/submit', 'PUT', 5, 1, '2026-05-15 18:46:25');
INSERT INTO `sys_operation_log` VALUES (32, 1, '系统管理员', '采购入库', '审核', NULL, '82', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/82/approve', 'PUT', 10, 1, '2026-05-15 18:46:25');
INSERT INTO `sys_operation_log` VALUES (33, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155003', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 5, 1, '2026-05-15 18:46:50');
INSERT INTO `sys_operation_log` VALUES (34, 1, '系统管理员', '采购入库', '提交', NULL, '83', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/83/submit', 'PUT', 3, 1, '2026-05-15 18:46:50');
INSERT INTO `sys_operation_log` VALUES (35, 1, '系统管理员', '采购入库', '审核', NULL, '83', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/83/approve', 'PUT', 6, 1, '2026-05-15 18:46:50');
INSERT INTO `sys_operation_log` VALUES (36, 1, '系统管理员', '销售出库', '新增', NULL, '', '新增销售出库：SO202605155002', '0:0:0:0:0:0:0:1', '/api/v1/sales-order', 'POST', 10, 1, '2026-05-15 18:46:50');
INSERT INTO `sys_operation_log` VALUES (37, 1, '系统管理员', '销售出库', '提交', NULL, '81', '提交销售出库', '0:0:0:0:0:0:0:1', '/api/v1/sales-order/81/submit', 'PUT', 2, 1, '2026-05-15 18:46:50');
INSERT INTO `sys_operation_log` VALUES (38, 1, '系统管理员', '销售出库', '审核', NULL, '81', '审核销售出库', '0:0:0:0:0:0:0:1', '/api/v1/sales-order/81/approve', 'PUT', 6, 1, '2026-05-15 18:46:50');
INSERT INTO `sys_operation_log` VALUES (39, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155004', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 4, 1, '2026-05-15 18:46:51');
INSERT INTO `sys_operation_log` VALUES (40, 1, '系统管理员', '采购入库', '提交', NULL, '84', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/84/submit', 'PUT', 3, 1, '2026-05-15 18:46:51');
INSERT INTO `sys_operation_log` VALUES (41, 1, '系统管理员', '采购入库', '审核', NULL, '84', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/84/approve', 'PUT', 6, 1, '2026-05-15 18:46:51');
INSERT INTO `sys_operation_log` VALUES (42, 1, '系统管理员', '库存调拨', '新增', NULL, '', '新增库存调拨：DB202605155002', '0:0:0:0:0:0:0:1', '/api/v1/transfer', 'POST', 8, 1, '2026-05-15 18:46:51');
INSERT INTO `sys_operation_log` VALUES (43, 1, '系统管理员', '库存调拨', '提交', NULL, '16', '提交库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/16/submit', 'PUT', 4, 1, '2026-05-15 18:46:51');
INSERT INTO `sys_operation_log` VALUES (44, 1, '系统管理员', '库存调拨', '审核', NULL, '16', '审核库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/16/approve', 'PUT', 11, 1, '2026-05-15 18:46:51');
INSERT INTO `sys_operation_log` VALUES (45, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155005', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 5, 1, '2026-05-15 18:46:51');
INSERT INTO `sys_operation_log` VALUES (46, 1, '系统管理员', '采购入库', '提交', NULL, '85', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/85/submit', 'PUT', 3, 1, '2026-05-15 18:46:51');
INSERT INTO `sys_operation_log` VALUES (47, 1, '系统管理员', '采购入库', '审核', NULL, '85', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/85/approve', 'PUT', 6, 1, '2026-05-15 18:46:51');
INSERT INTO `sys_operation_log` VALUES (48, 1, '系统管理员', '采购入库', '取消', NULL, '85', '取消采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/85/cancel', 'PUT', 7, 1, '2026-05-15 18:46:51');
INSERT INTO `sys_operation_log` VALUES (49, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155006', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 5, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (50, 1, '系统管理员', '采购入库', '提交', NULL, '86', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/86/submit', 'PUT', 2, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (51, 1, '系统管理员', '采购入库', '审核', NULL, '86', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/86/approve', 'PUT', 7, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (52, 1, '系统管理员', '销售出库', '新增', NULL, '', '新增销售出库：SO202605155003', '0:0:0:0:0:0:0:1', '/api/v1/sales-order', 'POST', 5, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (53, 1, '系统管理员', '销售出库', '提交', NULL, '82', '提交销售出库', '0:0:0:0:0:0:0:1', '/api/v1/sales-order/82/submit', 'PUT', 3, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (54, 1, '系统管理员', '销售出库', '审核', NULL, '82', '审核销售出库', '0:0:0:0:0:0:0:1', '/api/v1/sales-order/82/approve', 'PUT', 5, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (55, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155007', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 5, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (56, 1, '系统管理员', '采购入库', '提交', NULL, '87', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/87/submit', 'PUT', 2, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (57, 1, '系统管理员', '采购入库', '审核', NULL, '87', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/87/approve', 'PUT', 7, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (58, 1, '系统管理员', '库存调拨', '新增', NULL, '', '新增库存调拨：DB202605155003', '0:0:0:0:0:0:0:1', '/api/v1/transfer', 'POST', 4, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (59, 1, '系统管理员', '库存调拨', '提交', NULL, '17', '提交库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/17/submit', 'PUT', 2, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (60, 1, '系统管理员', '库存调拨', '审核', NULL, '17', '审核库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/17/approve', 'PUT', 8, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (61, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155008', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 7, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (62, 1, '系统管理员', '采购入库', '提交', NULL, '88', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/88/submit', 'PUT', 4, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (63, 1, '系统管理员', '采购入库', '审核', NULL, '88', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/88/approve', 'PUT', 8, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (64, 1, '系统管理员', '采购入库', '取消', NULL, '88', '取消采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/88/cancel', 'PUT', 6, 1, '2026-05-15 18:47:14');
INSERT INTO `sys_operation_log` VALUES (65, 1, '系统管理员', '库存盘点', '新增', NULL, '', '新增库存盘点：ST202605150001', '0:0:0:0:0:0:0:1', '/api/v1/stock-take', 'POST', 13, 1, '2026-05-15 18:49:45');
INSERT INTO `sys_operation_log` VALUES (66, 1, '系统管理员', '库存盘点', '审核', NULL, '10', '审核库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/10/approve', 'PUT', 2, 1, '2026-05-15 18:49:45');
INSERT INTO `sys_operation_log` VALUES (67, 1, '系统管理员', '库存盘点', '盘点调整', NULL, '10', '盘点调整库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/10/adjust', 'PUT', 5, 1, '2026-05-15 18:49:45');
INSERT INTO `sys_operation_log` VALUES (68, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155009', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 6, 1, '2026-05-15 18:49:45');
INSERT INTO `sys_operation_log` VALUES (69, 1, '系统管理员', '采购入库', '作废', NULL, '89', '作废采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/89/void', 'PUT', 2, 1, '2026-05-15 18:49:45');
INSERT INTO `sys_operation_log` VALUES (70, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155010', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 6, 1, '2026-05-15 18:52:10');
INSERT INTO `sys_operation_log` VALUES (71, 1, '系统管理员', '采购入库', '提交', NULL, '90', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/90/submit', 'PUT', 2, 1, '2026-05-15 18:52:10');
INSERT INTO `sys_operation_log` VALUES (72, 1, '系统管理员', '库存盘点', '新增', NULL, '', '新增库存盘点：ST202605150002', '0:0:0:0:0:0:0:1', '/api/v1/stock-take', 'POST', 8, 1, '2026-05-15 18:52:10');
INSERT INTO `sys_operation_log` VALUES (73, 1, '系统管理员', '库存盘点', '审核', NULL, '11', '审核库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/11/approve', 'PUT', 2, 1, '2026-05-15 18:52:10');
INSERT INTO `sys_operation_log` VALUES (74, 1, '系统管理员', '库存盘点', '盘点调整', NULL, '11', '盘点调整库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/11/adjust', 'PUT', 6, 1, '2026-05-15 18:52:10');
INSERT INTO `sys_operation_log` VALUES (75, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155011', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 4, 1, '2026-05-15 18:52:10');
INSERT INTO `sys_operation_log` VALUES (76, 1, '系统管理员', '采购入库', '作废', NULL, '91', '作废采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/91/void', 'PUT', 2, 1, '2026-05-15 18:52:10');
INSERT INTO `sys_operation_log` VALUES (77, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155012', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 8, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (78, 1, '系统管理员', '采购入库', '提交', NULL, '92', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/92/submit', 'PUT', 4, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (79, 1, '系统管理员', '采购入库', '审核', NULL, '92', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/92/approve', 'PUT', 8, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (80, 1, '系统管理员', '销售出库', '新增', NULL, '', '新增销售出库：SO202605155004', '0:0:0:0:0:0:0:1', '/api/v1/sales-order', 'POST', 5, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (81, 1, '系统管理员', '销售出库', '提交', NULL, '83', '提交销售出库', '0:0:0:0:0:0:0:1', '/api/v1/sales-order/83/submit', 'PUT', 3, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (82, 1, '系统管理员', '销售出库', '审核', NULL, '83', '审核销售出库', '0:0:0:0:0:0:0:1', '/api/v1/sales-order/83/approve', 'PUT', 6, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (83, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155013', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 6, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (84, 1, '系统管理员', '采购入库', '提交', NULL, '93', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/93/submit', 'PUT', 4, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (85, 1, '系统管理员', '采购入库', '审核', NULL, '93', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/93/approve', 'PUT', 10, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (86, 1, '系统管理员', '库存调拨', '新增', NULL, '', '新增库存调拨：DB202605155004', '0:0:0:0:0:0:0:1', '/api/v1/transfer', 'POST', 5, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (87, 1, '系统管理员', '库存调拨', '提交', NULL, '18', '提交库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/18/submit', 'PUT', 3, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (88, 1, '系统管理员', '库存调拨', '审核', NULL, '18', '审核库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/18/approve', 'PUT', 6, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (89, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155014', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 3, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (90, 1, '系统管理员', '采购入库', '提交', NULL, '94', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/94/submit', 'PUT', 3, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (91, 1, '系统管理员', '采购入库', '审核', NULL, '94', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/94/approve', 'PUT', 7, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (92, 1, '系统管理员', '采购入库', '取消', NULL, '94', '取消采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/94/cancel', 'PUT', 9, 1, '2026-05-15 19:04:03');
INSERT INTO `sys_operation_log` VALUES (93, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155015', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 6, 1, '2026-05-15 19:04:07');
INSERT INTO `sys_operation_log` VALUES (94, 1, '系统管理员', '采购入库', '提交', NULL, '95', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/95/submit', 'PUT', 3, 1, '2026-05-15 19:04:07');
INSERT INTO `sys_operation_log` VALUES (95, 1, '系统管理员', '库存盘点', '新增', NULL, '', '新增库存盘点：ST202605150003', '0:0:0:0:0:0:0:1', '/api/v1/stock-take', 'POST', 7, 1, '2026-05-15 19:04:07');
INSERT INTO `sys_operation_log` VALUES (96, 1, '系统管理员', '库存盘点', '审核', NULL, '12', '审核库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/12/approve', 'PUT', 2, 1, '2026-05-15 19:04:07');
INSERT INTO `sys_operation_log` VALUES (97, 1, '系统管理员', '库存盘点', '盘点调整', NULL, '12', '盘点调整库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/12/adjust', 'PUT', 4, 1, '2026-05-15 19:04:07');
INSERT INTO `sys_operation_log` VALUES (98, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155016', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 5, 1, '2026-05-15 19:04:07');
INSERT INTO `sys_operation_log` VALUES (99, 1, '系统管理员', '采购入库', '作废', NULL, '96', '作废采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/96/void', 'PUT', 4, 1, '2026-05-15 19:04:07');
INSERT INTO `sys_operation_log` VALUES (100, 1, '系统管理员', '采购入库', '提交', NULL, '78', '提交采购入库', '192.168.10.38', '/api/v1/purchase-order/78/submit', 'PUT', 9, 1, '2026-05-15 19:46:39');
INSERT INTO `sys_operation_log` VALUES (101, 1, '系统管理员', '采购入库', '提交', NULL, '76', '提交采购入库', '192.168.10.38', '/api/v1/purchase-order/76/submit', 'PUT', 2, 1, '2026-05-15 19:48:28');
INSERT INTO `sys_operation_log` VALUES (102, 1, '系统管理员', '采购入库', '提交', NULL, '77', '提交采购入库', '192.168.10.38', '/api/v1/purchase-order/77/submit', 'PUT', 4, 1, '2026-05-15 19:49:30');
INSERT INTO `sys_operation_log` VALUES (103, 4, '王采购', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155017', '192.168.10.38', '/api/v1/purchase-order', 'POST', 13, 1, '2026-05-15 19:56:12');
INSERT INTO `sys_operation_log` VALUES (104, 4, '王采购', '采购入库', '提交', NULL, '97', '提交采购入库', '192.168.10.38', '/api/v1/purchase-order/97/submit', 'PUT', 4, 1, '2026-05-15 19:56:12');
INSERT INTO `sys_operation_log` VALUES (105, 4, '王采购', '商品', '更新', NULL, '40', '更新商品：金士顿U盘', '192.168.10.38', '/api/v1/product/40', 'PUT', 5, 1, '2026-05-15 19:56:56');
INSERT INTO `sys_operation_log` VALUES (106, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155018', '192.168.10.162', '/api/v1/purchase-order', 'POST', 18, 1, '2026-05-15 20:49:54');
INSERT INTO `sys_operation_log` VALUES (107, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155019', '192.168.10.162', '/api/v1/purchase-order', 'POST', 12, 1, '2026-05-15 20:52:45');
INSERT INTO `sys_operation_log` VALUES (108, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605155020', '192.168.10.162', '/api/v1/purchase-order', 'POST', 14, 1, '2026-05-15 20:53:12');
INSERT INTO `sys_operation_log` VALUES (109, 1, '系统管理员', '销售出库', '新增', NULL, '', '新增销售出库：SO202605155005', '192.168.10.162', '/api/v1/sales-order', 'POST', 27, 1, '2026-05-15 20:53:23');
INSERT INTO `sys_operation_log` VALUES (110, 1, '系统管理员', '库存盘点', '新增', NULL, '', '新增库存盘点：ST202605150004', '192.168.10.162', '/api/v1/stock-take', 'POST', 18, 1, '2026-05-15 20:53:34');
INSERT INTO `sys_operation_log` VALUES (111, 1, '系统管理员', '库存盘点', '新增', NULL, '', '新增库存盘点：ST202605150005', '192.168.10.162', '/api/v1/stock-take', 'POST', 15, 1, '2026-05-15 20:54:00');
INSERT INTO `sys_operation_log` VALUES (112, 1, '系统管理员', 'Barcode', 'getBarcode', NULL, '39', 'getBarcodeBarcode', '0:0:0:0:0:0:0:1', '/api/v1/product/barcode/39', 'GET', 511, 1, '2026-05-16 07:27:28');
INSERT INTO `sys_operation_log` VALUES (113, 1, '系统管理员', 'Barcode', 'getBarcode', NULL, '36', 'getBarcodeBarcode', '0:0:0:0:0:0:0:1', '/api/v1/product/barcode/36', 'GET', 522, 1, '2026-05-16 07:27:28');
INSERT INTO `sys_operation_log` VALUES (114, 1, '系统管理员', 'Barcode', 'getBarcode', NULL, '35', 'getBarcodeBarcode', '0:0:0:0:0:0:0:1', '/api/v1/product/barcode/35', 'GET', 521, 1, '2026-05-16 07:27:28');
INSERT INTO `sys_operation_log` VALUES (115, 1, '系统管理员', 'Barcode', 'getBarcode', NULL, '40', 'getBarcodeBarcode', '0:0:0:0:0:0:0:1', '/api/v1/product/barcode/40', 'GET', 517, 1, '2026-05-16 07:27:28');
INSERT INTO `sys_operation_log` VALUES (116, 1, '系统管理员', 'Barcode', 'getBarcode', NULL, '37', 'getBarcodeBarcode', '0:0:0:0:0:0:0:1', '/api/v1/product/barcode/37', 'GET', 520, 1, '2026-05-16 07:27:28');
INSERT INTO `sys_operation_log` VALUES (117, 1, '系统管理员', 'Barcode', 'getBarcode', NULL, '38', 'getBarcodeBarcode', '0:0:0:0:0:0:0:1', '/api/v1/product/barcode/38', 'GET', 518, 1, '2026-05-16 07:27:28');
INSERT INTO `sys_operation_log` VALUES (118, 1, '系统管理员', '商品', '更新', NULL, '40', '更新商品：P20260040', '0:0:0:0:0:0:0:1', '/api/v1/product/40', 'PUT', 40, 1, '2026-05-16 07:28:55');
INSERT INTO `sys_operation_log` VALUES (119, 8, '周仓管', '采购入库', '取消', NULL, '93', '取消采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/93/cancel', 'PUT', 72, 1, '2026-05-16 07:51:56');
INSERT INTO `sys_operation_log` VALUES (120, 1, '系统管理员', '仓库', '更新', NULL, '19', '更新仓库：WH20260513001', '0:0:0:0:0:0:0:1', '/api/v1/warehouse/19', 'PUT', 27, 1, '2026-05-23 14:03:17');
INSERT INTO `sys_operation_log` VALUES (121, 1, '系统管理员', '仓库', '更新', NULL, '15', '更新仓库：DC200', '0:0:0:0:0:0:0:1', '/api/v1/warehouse/15', 'PUT', 6, 1, '2026-05-23 14:04:47');
INSERT INTO `sys_operation_log` VALUES (122, 1, '系统管理员', '仓库', '更新', NULL, '19', '更新仓库：WH20260513001', '0:0:0:0:0:0:0:1', '/api/v1/warehouse/19', 'PUT', 14, 1, '2026-05-23 14:06:04');
INSERT INTO `sys_operation_log` VALUES (123, 1, '系统管理员', '仓库', '更新', NULL, '15', '更新仓库：DC200', '0:0:0:0:0:0:0:1', '/api/v1/warehouse/15', 'PUT', 5, 1, '2026-05-23 14:06:04');
INSERT INTO `sys_operation_log` VALUES (124, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605233003', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 41, 1, '2026-05-23 14:16:07');
INSERT INTO `sys_operation_log` VALUES (125, 1, '系统管理员', '采购入库', '提交', NULL, '101', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/101/submit', 'PUT', 9, 1, '2026-05-23 14:16:07');
INSERT INTO `sys_operation_log` VALUES (126, 1, '系统管理员', '采购入库', '审核', NULL, '101', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/101/approve', 'PUT', 19, 1, '2026-05-23 14:16:09');
INSERT INTO `sys_operation_log` VALUES (127, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605233004', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 14, 1, '2026-05-23 14:16:22');
INSERT INTO `sys_operation_log` VALUES (128, 1, '系统管理员', '采购入库', '提交', NULL, '102', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/102/submit', 'PUT', 3, 1, '2026-05-23 14:16:22');
INSERT INTO `sys_operation_log` VALUES (129, 1, '系统管理员', '采购入库', '审核', NULL, '102', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/102/approve', 'PUT', 16, 1, '2026-05-23 14:16:24');
INSERT INTO `sys_operation_log` VALUES (130, 1, '系统管理员', '库存盘点', '新增', NULL, '', '新增库存盘点：ST202605230001', '0:0:0:0:0:0:0:1', '/api/v1/stock-take', 'POST', 22, 1, '2026-05-23 14:17:04');
INSERT INTO `sys_operation_log` VALUES (131, 1, '系统管理员', '库存盘点', '审核', NULL, '15', '审核库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/15/approve', 'PUT', 7, 1, '2026-05-23 14:17:16');
INSERT INTO `sys_operation_log` VALUES (132, 1, '系统管理员', '库存盘点', '盘点调整', NULL, '15', '盘点调整库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/15/adjust', 'PUT', 16, 1, '2026-05-23 14:17:21');
INSERT INTO `sys_operation_log` VALUES (133, 1, '系统管理员', '库存调拨', '新增', NULL, '', '新增库存调拨：DB202605233002', '0:0:0:0:0:0:0:1', '/api/v1/transfer', 'POST', 19, 1, '2026-05-23 14:20:08');
INSERT INTO `sys_operation_log` VALUES (134, 1, '系统管理员', '库存调拨', '提交', NULL, '19', '提交库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/19/submit', 'PUT', 5, 1, '2026-05-23 14:20:08');
INSERT INTO `sys_operation_log` VALUES (135, 1, '系统管理员', '库存调拨', '取消', NULL, '19', '取消库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/19/cancel', 'PUT', 7, 1, '2026-05-23 14:21:02');
INSERT INTO `sys_operation_log` VALUES (136, 1, '系统管理员', '库存调拨', '作废', NULL, '19', '作废库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/19/void', 'PUT', 5, 1, '2026-05-23 14:21:04');
INSERT INTO `sys_operation_log` VALUES (137, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605233005', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 21, 1, '2026-05-23 14:21:37');
INSERT INTO `sys_operation_log` VALUES (138, 1, '系统管理员', '采购入库', '提交', NULL, '103', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/103/submit', 'PUT', 5, 1, '2026-05-23 14:21:37');
INSERT INTO `sys_operation_log` VALUES (139, 1, '系统管理员', '采购入库', '审核', NULL, '103', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/103/approve', 'PUT', 14, 1, '2026-05-23 14:21:40');
INSERT INTO `sys_operation_log` VALUES (140, 1, '系统管理员', '采购入库', '新增', NULL, '', '新增采购入库：PO202605233006', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order', 'POST', 11, 1, '2026-05-23 14:21:51');
INSERT INTO `sys_operation_log` VALUES (141, 1, '系统管理员', '采购入库', '提交', NULL, '104', '提交采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/104/submit', 'PUT', 4, 1, '2026-05-23 14:21:51');
INSERT INTO `sys_operation_log` VALUES (142, 1, '系统管理员', '采购入库', '审核', NULL, '104', '审核采购入库', '0:0:0:0:0:0:0:1', '/api/v1/purchase-order/104/approve', 'PUT', 12, 1, '2026-05-23 14:21:53');
INSERT INTO `sys_operation_log` VALUES (143, 1, '系统管理员', '库存盘点', '新增', NULL, '', '新增库存盘点：ST202605230002', '0:0:0:0:0:0:0:1', '/api/v1/stock-take', 'POST', 21, 1, '2026-05-23 14:22:25');
INSERT INTO `sys_operation_log` VALUES (144, 1, '系统管理员', '库存盘点', '审核', NULL, '16', '审核库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/16/approve', 'PUT', 5, 1, '2026-05-23 14:22:36');
INSERT INTO `sys_operation_log` VALUES (145, 1, '系统管理员', '库存盘点', '盘点调整', NULL, '16', '盘点调整库存盘点', '0:0:0:0:0:0:0:1', '/api/v1/stock-take/16/adjust', 'PUT', 15, 1, '2026-05-23 14:22:38');
INSERT INTO `sys_operation_log` VALUES (146, 1, '系统管理员', '库存调拨', '新增', NULL, '', '新增库存调拨：DB202605233003', '0:0:0:0:0:0:0:1', '/api/v1/transfer', 'POST', 13, 1, '2026-05-23 14:23:13');
INSERT INTO `sys_operation_log` VALUES (147, 1, '系统管理员', '库存调拨', '提交', NULL, '20', '提交库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/20/submit', 'PUT', 5, 1, '2026-05-23 14:23:13');
INSERT INTO `sys_operation_log` VALUES (148, 1, '系统管理员', '库存调拨', '取消', NULL, '20', '取消库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/20/cancel', 'PUT', 6, 1, '2026-05-23 14:27:58');
INSERT INTO `sys_operation_log` VALUES (149, 1, '系统管理员', '库存调拨', '新增', NULL, '', '新增库存调拨：DB202605233004', '0:0:0:0:0:0:0:1', '/api/v1/transfer', 'POST', 21, 1, '2026-05-23 14:28:12');
INSERT INTO `sys_operation_log` VALUES (150, 1, '系统管理员', '库存调拨', '提交', NULL, '21', '提交库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/21/submit', 'PUT', 3, 1, '2026-05-23 14:28:12');
INSERT INTO `sys_operation_log` VALUES (151, 1, '系统管理员', '库存调拨', '作废', NULL, '20', '作废库存调拨', '0:0:0:0:0:0:0:1', '/api/v1/transfer/20/void', 'PUT', 3, 1, '2026-05-23 14:28:22');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码（BCrypt）',
  `real_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
  `position` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '职位（如销售员、仓管员、养护工）',
  `role` tinyint NULL DEFAULT 2 COMMENT '角色 1=管理员 2=员工',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态 0=禁用 1=启用',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '逻辑删除',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '$2b$10$vRtfTD91dPMlYs6/5bhNFuT/iuFZOmLJlcaBP.3a/KgncaQ7jK0Vy', '系统管理员', '13800000001', NULL, NULL, '系统管理员', 1, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_user` VALUES (2, 'manager1', '$2b$10$vRtfTD91dPMlYs6/5bhNFuT/iuFZOmLJlcaBP.3a/KgncaQ7jK0Vy', '张经理', '13800000002', NULL, NULL, '仓库经理', 1, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_user` VALUES (3, 'manager2', '$2b$10$vRtfTD91dPMlYs6/5bhNFuT/iuFZOmLJlcaBP.3a/KgncaQ7jK0Vy', '李经理', '13800000003', NULL, NULL, '运营经理', 1, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_user` VALUES (4, 'buyer1', '$2b$10$vRtfTD91dPMlYs6/5bhNFuT/iuFZOmLJlcaBP.3a/KgncaQ7jK0Vy', '王采购', '13800000004', NULL, NULL, '采购员', 2, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_user` VALUES (5, 'buyer2', '$2b$10$vRtfTD91dPMlYs6/5bhNFuT/iuFZOmLJlcaBP.3a/KgncaQ7jK0Vy', '赵采购', '13800000005', NULL, NULL, '采购员', 2, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_user` VALUES (6, 'seller1', '$2b$10$vRtfTD91dPMlYs6/5bhNFuT/iuFZOmLJlcaBP.3a/KgncaQ7jK0Vy', '刘销售', '13800000006', NULL, NULL, '销售员', 2, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_user` VALUES (7, 'seller2', '$2b$10$vRtfTD91dPMlYs6/5bhNFuT/iuFZOmLJlcaBP.3a/KgncaQ7jK0Vy', '陈销售', '13800000007', NULL, NULL, '销售员', 2, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_user` VALUES (8, 'keeper1', '$2b$10$vRtfTD91dPMlYs6/5bhNFuT/iuFZOmLJlcaBP.3a/KgncaQ7jK0Vy', '周仓管', '13800000008', NULL, NULL, '仓管员', 2, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `sys_user` VALUES (9, 'keeper2', '$2b$10$vRtfTD91dPMlYs6/5bhNFuT/iuFZOmLJlcaBP.3a/KgncaQ7jK0Vy', '吴仓管', '13800000009', NULL, NULL, '仓管员', 2, 1, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');

-- ----------------------------
-- Table structure for warehouse
-- ----------------------------
DROP TABLE IF EXISTS `warehouse`;
CREATE TABLE `warehouse`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '仓库编码',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '仓库名称',
  `contact` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '仓库地址',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态 0=停用 1=启用',
  `level` tinyint NULL DEFAULT 4 COMMENT '层级 1-4（1为最高级）',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '上级ID（1级填null）',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `deleted` tinyint NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE,
  INDEX `idx_parent`(`parent_id` ASC) USING BTREE,
  INDEX `idx_level`(`level` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '仓库表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of warehouse
-- ----------------------------
INSERT INTO `warehouse` VALUES (10, 'DC001', '华东仓储中心', NULL, NULL, NULL, 1, 1, NULL, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse` VALUES (11, 'DC010', '上海分中心', NULL, NULL, NULL, 1, 2, 10, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse` VALUES (12, 'DC011', '杭州分中心', NULL, NULL, NULL, 1, 2, 10, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse` VALUES (13, 'DC100', '浦东主仓', '张主管', '13810000001', '上海市浦东新区临港仓储园A区', 1, 4, 16, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse` VALUES (14, 'DC101', '松江分仓', '李主管', '13810000002', '上海市松江区新桥镇仓储路88号', 1, 4, 17, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse` VALUES (15, 'DC200', '杭州总仓', '王主管', '13810000003', '杭州市余杭区仓前街道物流园', 1, 4, 18, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse` VALUES (16, 'DC110', '浦东仓管区', NULL, NULL, NULL, 1, 3, 11, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse` VALUES (17, 'DC111', '松江仓管区', NULL, NULL, NULL, 1, 3, 11, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse` VALUES (18, 'DC210', '余杭仓管区', NULL, NULL, NULL, 1, 3, 12, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse` VALUES (19, 'WH20260513001', '珠江仓库', '', '', '珠江', 1, 1, NULL, '', 0, '2026-05-13 03:58:29', '2026-05-13 03:58:29');

-- ----------------------------
-- Table structure for warehouse_location
-- ----------------------------
DROP TABLE IF EXISTS `warehouse_location`;
CREATE TABLE `warehouse_location`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `warehouse_id` bigint NOT NULL COMMENT '所属仓库ID',
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '库位编码（如 A-01-01）',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '库位名称',
  `capacity` int NULL DEFAULT NULL COMMENT '容量',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态 0=禁用 1=启用',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `deleted` tinyint NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_warehouse_code`(`warehouse_id` ASC, `code` ASC) USING BTREE,
  INDEX `idx_warehouse`(`warehouse_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库位表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of warehouse_location
-- ----------------------------
INSERT INTO `warehouse_location` VALUES (1, 13, 'A-01', 'A区1排', 500, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse_location` VALUES (2, 13, 'A-02', 'A区2排', 500, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse_location` VALUES (3, 13, 'B-01', 'B区1排', 400, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse_location` VALUES (4, 13, 'B-02', 'B区2排', 400, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse_location` VALUES (5, 14, 'A-01', '主排', 600, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse_location` VALUES (6, 14, 'B-01', '次排', 400, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse_location` VALUES (7, 15, 'A-01', 'A区', 800, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse_location` VALUES (8, 15, 'B-01', 'B区', 600, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');
INSERT INTO `warehouse_location` VALUES (9, 15, 'C-01', 'C区冷库', 300, 1, NULL, 0, '2026-05-13 01:12:55', '2026-05-13 01:12:55');

SET FOREIGN_KEY_CHECKS = 1;
