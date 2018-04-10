CREATE PROCEDURE MovimientoInventario ( @id_producto int, @cantidad int)
AS
  UPDATE producto SET unidades =
  (SELECT  sum(unidades+@cantidad)FROM producto WHERE id = @id_producto)
   WHERE id = @id_producto; 


EXEC MovimientoInventario 1,15

/* ************************************************ */

CREATE PROCEDURE Facturar ( @compraProducto int)
AS
 DECLARE @precioProducto float
 DECLARE @id_producto float
 DECLARE @cantidad float

  SELECT @id_producto= id_producto,@cantidad=unidades
FROM compra_producto WHERE id=@compraProducto;

 SELECT @precioProducto= precio
FROM producto WHERE id=@id_producto

insert into  factura(id_compra_producto,fecha,impuesto,precio)  
values(@compraProducto,(SELECT GETDATE()),0.13,@cantidad*@precioProducto) 

EXEC Facturar 1

/* ************************************************ */
CREATE PROCEDURE OrdenesCompra
AS
DECLARE @producto int
DECLARE @cantidad_deseada_existencia int 
DECLARE @cantidad int 
DECLARE @proveedor int 
DECLARE ProdInfo CURSOR FOR SELECT p.id,p.cantidad,p.cantidad_deseada_existencia,pr.id as proveedor FROM producto p,proveedor pr
WHERE p.id=pr.id_producto and (cantidad =0) or (cantidad < cantidad_minima_existencia)
OPEN ProdInfo
FETCH NEXT FROM ProdInfo INTO @producto,@cantidad,@cantidad_deseada_existencia,@proveedor
WHILE @@fetch_status = 0
BEGIN

	INSERT INTO compra_producto
           (unidades
           ,id_producto
           ,id_proveedor)
     VALUES
           (@cantidad-@cantidad_deseada_existencia
           ,@producto
           ,@proveedor)

    PRINT @producto +'-'+ @cantidad +'-'+@cantidad_deseada_existencia +'-'+ @proveedor
    FETCH NEXT FROM ProdInfo INTO @producto,@cantidad,@cantidad_deseada_existencia,@proveedor
END
CLOSE ProdInfo
DEALLOCATE ProdInfo

UPDATE producto SET cantidad =0 WHERE id IN (1,2,3)
EXEC OrdenesCompra

/* ************************************************ */


CREATE FUNCTION TotalProducto(@producto int, @proveedor int)  
RETURNS int   
AS   
-- Returns the stock level for the product.  
BEGIN  
    DECLARE @sumatoria int;  
    SELECT @sumatoria = SUM(p.cantidad)   
    FROM producto p,proveedor pr
	WHERE p.id=pr.id_producto and p.id= @producto and pr.id= @proveedor
    RETURN @sumatoria;  
END;

SELECT p.nombre,pr.nombre,dbo.TotalProducto(p.id,pr.id)  
    FROM producto p,proveedor pr
	WHERE p.id=pr.id_producto


