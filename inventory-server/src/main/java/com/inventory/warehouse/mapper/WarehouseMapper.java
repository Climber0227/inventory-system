package com.inventory.warehouse.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.inventory.warehouse.entity.Warehouse;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.Collection;
import java.util.List;

@Mapper
public interface WarehouseMapper extends BaseMapper<Warehouse> {

    @Select("SELECT * FROM warehouse WHERE deleted = 1")
    List<Warehouse> selectDeleted();

    @Select("SELECT COUNT(*) FROM warehouse WHERE code = #{code}")
    int countAllByCode(String code);

    @Select("SELECT code FROM warehouse WHERE code LIKE CONCAT(#{prefix}, '%') ORDER BY code DESC LIMIT 1")
    String selectMaxCodeByPrefix(String prefix);

    @Select("SELECT * FROM warehouse WHERE id = #{id}")
    Warehouse selectAnyById(Long id);

    /** 绕过 @TableLogic 过滤，用于历史单据补全已删除仓库的名字 */
    @Select("<script>SELECT * FROM warehouse WHERE id IN <foreach collection='ids' item='id' open='(' separator=',' close=')'>#{id}</foreach></script>")
    List<Warehouse> selectBatchIdsIgnoreDeleted(@Param("ids") java.util.Collection<Long> ids);
}
