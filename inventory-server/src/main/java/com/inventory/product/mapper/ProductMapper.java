package com.inventory.product.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.inventory.product.entity.Product;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.Collection;
import java.util.List;

@Mapper
public interface ProductMapper extends BaseMapper<Product> {

    @Select("SELECT * FROM product WHERE deleted = 1")
    List<Product> selectDeleted();

    @Select("SELECT COUNT(*) FROM product WHERE code = #{code}")
    int countAllByCode(String code);

    @Select("SELECT code FROM product WHERE code LIKE CONCAT(#{prefix}, '%') ORDER BY code DESC LIMIT 1")
    String selectMaxCodeByPrefix(String prefix);

    /** 绕过 @TableLogic 过滤，用于历史单据补全已作废商品的名字 */
    @Select("<script>SELECT * FROM product WHERE id IN <foreach collection='ids' item='id' open='(' separator=',' close=')'>#{id}</foreach></script>")
    List<Product> selectBatchIdsIgnoreDeleted(@Param("ids") Collection<Long> ids);

    /** 绕过 @TableLogic 过滤，用于从回收站恢复商品 */
    @Select("SELECT * FROM product WHERE id = #{id}")
    Product selectByIdIgnoreDeleted(@Param("id") Long id);
}
