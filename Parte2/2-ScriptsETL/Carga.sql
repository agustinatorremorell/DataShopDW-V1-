-- Carga

-- Dim_ProveedorEntrega
CREATE PROCEDURE dbo.Sp_CargaDimProveedorEntrega
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Dim_ProveedorEntrega (Proveedor, CostoEstimado)
    SELECT Proveedor, CostoEstimado
    FROM dbo.int_Dim_ProveedorEntrega;

    PRINT 'Datos cargados correctamente a Dim_ProveedorEntrega';
END;

EXEC dbo.Sp_CargaDimProveedorEntrega;

-- Dim_Almacen
CREATE PROCEDURE dbo.Sp_CargaDimAlmacen
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Dim_Almacen (Almacen, Ubicacion)
    SELECT Almacen, Ubicacion
    FROM dbo.int_Dim_Almacen;

    PRINT 'Datos cargados correctamente a Dim_Almacen';
END;

EXEC dbo.Sp_CargaDimAlmacen;

-- Dim_EstadoPedido
CREATE PROCEDURE dbo.Sp_CargaDimEstadoPedido
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Dim_EstadoPedido (Estado)
    SELECT Estado
    FROM dbo.int_Dim_EstadoPedido;

    PRINT 'Datos cargados correctamente a Dim_EstadoPedido';
END;

EXEC dbo.Sp_CargaDimEstadoPedido;

-- Fact_Entregas
CREATE PROCEDURE dbo.Sp_CargaFactEntregas
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO dbo.Fact_Entregas
        (
            CodigoProveedor,
            CodigoAlmacen,
            CodigoEstado,
            Proveedor,
            Almacen,
            Estado,
            FechaEnvio,
            FechaEntrega,
            CostoTotalEntrega,
            FechaEntregaReal,
            FechaEntregaEstimada,
            DistanciaRecorrida
        )
        SELECT 
            i.CodigoProveedor,
            i.CodigoAlmacen,
            i.CodigoEstado,
            i.Proveedor,
            i.Almacen,
            i.Estado,
            i.FechaEnvio,
            i.FechaEntrega,
            i.CostoTotalEntrega,
            i.FechaEntregaReal,
            i.FechaEntregaEstimada,
            i.DistanciaRecorrida
        FROM dbo.int_Fact_Entregas i
        LEFT JOIN dbo.Fact_Entregas f ON i.CodigoEntrega = f.CodigoEntrega

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;

EXEC Sp_CargaFactEntregas;