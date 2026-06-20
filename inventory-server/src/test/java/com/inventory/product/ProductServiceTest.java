package com.inventory.product;

import com.inventory.common.exception.BusinessException;
import com.inventory.inventory.mapper.InventoryMapper;
import com.inventory.product.entity.Product;
import com.inventory.product.mapper.ProductCategoryMapper;
import com.inventory.product.mapper.ProductMapper;
import com.inventory.product.service.ProductService;
import com.inventory.purchase.mapper.PurchaseOrderItemMapper;
import com.inventory.sales.mapper.SalesOrderItemMapper;
import com.inventory.stocktake.mapper.StockTakeItemMapper;
import com.inventory.system.mapper.SysUserMapper;
import com.inventory.transfer.mapper.InventoryTransferItemMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductServiceTest {

    @Mock private ProductMapper productMapper;
    @Mock private InventoryMapper inventoryMapper;
    @Mock private ProductCategoryMapper categoryMapper;
    @Mock private PurchaseOrderItemMapper purchaseOrderItemMapper;
    @Mock private SalesOrderItemMapper salesOrderItemMapper;
    @Mock private InventoryTransferItemMapper transferItemMapper;
    @Mock private StockTakeItemMapper stockTakeItemMapper;
    @Mock private SqlSessionFactory sqlSessionFactory;
    @Mock private SysUserMapper userMapper;

    private ProductService service;

    @BeforeEach
    void setUp() {
        service = new ProductService(productMapper, inventoryMapper, categoryMapper,
                purchaseOrderItemMapper, salesOrderItemMapper, transferItemMapper, stockTakeItemMapper,
                sqlSessionFactory, userMapper);
    }

    @Test
    void save_shouldGenerateCodeAndInsert() {
        Product product = new Product();
        product.setName("测试商品");
        product.setUnit("个");

        // 生成编码时的查询
        when(productMapper.selectMaxCodeByPrefix(anyString())).thenReturn("GD20260429005");
        when(productMapper.countAllByCode(anyString())).thenReturn(0);
        when(productMapper.insert(any())).thenReturn(1);

        service.save(product);

        // 验证：编码被设置，流水号在上次最大基础上+1
        assertNotNull(product.getCode());
        assertTrue(product.getCode().startsWith("GD"));
        assertEquals("GD20260429006", product.getCode()); // 005 + 1 = 006

        verify(productMapper).insert(product);
    }

    @Test
    void save_shouldIncrementSeqWhenCodeExists() {
        Product product = new Product();
        product.setName("测试商品");
        product.setUnit("个");

        when(productMapper.selectMaxCodeByPrefix(anyString())).thenReturn("GD20260429005");
        // 第一个生成的编码 "GD20260429006" 已存在
        when(productMapper.countAllByCode("GD20260429006")).thenReturn(1);
        when(productMapper.countAllByCode("GD20260429007")).thenReturn(0);
        when(productMapper.insert(any())).thenReturn(1);

        service.save(product);

        verify(productMapper).insert(argThat(p ->
                "GD20260429007".equals(p.getCode())));
    }

    @Test
    void delete_shouldThrowWhenInventoryExists() {
        when(inventoryMapper.selectCount(any())).thenReturn(3L);

        BusinessException ex = assertThrows(BusinessException.class, () -> service.delete(1L));
        assertTrue(ex.getMessage().contains("库存记录"));
    }

    @Test
    void delete_shouldThrowWhenPurchaseOrderReferences() {
        when(inventoryMapper.selectCount(any())).thenReturn(0L);
        when(purchaseOrderItemMapper.selectCount(any())).thenReturn(2L);

        BusinessException ex = assertThrows(BusinessException.class, () -> service.delete(1L));
        assertTrue(ex.getMessage().contains("采购入库"));
    }

    @Test
    void delete_shouldSucceedWhenNoReferences() {
        when(inventoryMapper.selectCount(any())).thenReturn(0L);
        when(purchaseOrderItemMapper.selectCount(any())).thenReturn(0L);
        when(salesOrderItemMapper.selectCount(any())).thenReturn(0L);
        when(transferItemMapper.selectCount(any())).thenReturn(0L);
        when(stockTakeItemMapper.selectCount(any())).thenReturn(0L);

        service.delete(1L);

        verify(productMapper).deleteById(1L);
    }
}
