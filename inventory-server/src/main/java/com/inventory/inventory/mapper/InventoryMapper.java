package com.inventory.inventory.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.inventory.inventory.entity.Inventory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface InventoryMapper extends BaseMapper<Inventory> {

    /** 按仓库聚合库存统计（12K 行 vs 144 万行全量加载） */
    @Select("SELECT warehouse_id, SUM(quantity) AS total_qty, SUM(cost_price * quantity) AS total_amt FROM inventory GROUP BY warehouse_id")
    List<Map<String, Object>> selectWarehouseStats();

    /** 按商品聚合库存总量（2K 行 vs 全量扫描）*/
    @Select("SELECT product_id, SUM(quantity) AS total_qty FROM inventory GROUP BY product_id")
    List<Map<String, Object>> selectProductStats();

    /** 按仓库+商品聚合库存 */
    @Select("<script>SELECT product_id, SUM(quantity) AS total_qty FROM inventory WHERE product_id IN " +
            "<foreach collection='ids' item='id' open='(' separator=',' close=')'>#{id}</foreach>" +
            " GROUP BY product_id</script>")
    List<Map<String, Object>> selectProductStatsByIds(@org.apache.ibatis.annotations.Param("ids") java.util.Set<Long> ids);

    /** 按仓库+商品聚合库存（限制仓库） */
    @Select("<script>SELECT product_id, SUM(quantity) AS total_qty FROM inventory WHERE product_id IN " +
            "<foreach collection='ids' item='id' open='(' separator=',' close=')'>#{id}</foreach>" +
            " AND warehouse_id = #{warehouseId} GROUP BY product_id</script>")
    List<Map<String, Object>> selectProductStatsByIdsAndWarehouse(@org.apache.ibatis.annotations.Param("ids") java.util.Set<Long> ids,
                                                                   @org.apache.ibatis.annotations.Param("warehouseId") Long warehouseId);
}
