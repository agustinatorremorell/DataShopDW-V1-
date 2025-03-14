-- Transformacion

-- int_Fact_Entregas
CREATE PROCEDURE [dbo].[Sp_CargaintFactEntregas]
AS
BEGIN
    DECLARE @CodigoEntrega INT,
            @CodigoProveedor INT,
            @CodigoAlmacen INT,
            @CodigoEstado INT,
            @Proveedor NVARCHAR(100),
            @Almacen NVARCHAR(100),
            @Estado NVARCHAR(100),
            @FechaEnvio DATETIME,
            @FechaEntrega DATETIME,
            @CostoTotalEntrega DECIMAL(18, 2),
            @FechaEntregaReal DATETIME,
            @FechaEntregaEstimada DATETIME,
            @DistanciaRecorrida DECIMAL(10, 2);

    DECLARE fact_cursor CURSOR FOR
    SELECT CodigoEntrega, CodigoProveedor, CodigoAlmacen, CodigoEstado,
           Proveedor, Almacen, Estado, FechaEnvio, FechaEntrega,
           CostoTotalEntrega, FechaEntregaReal, FechaEntregaEstimada, DistanciaRecorrida
    FROM [dbo].[stg_Fact_Entregas];

    OPEN fact_cursor;

    FETCH NEXT FROM fact_cursor INTO @CodigoEntrega, @CodigoProveedor, @CodigoAlmacen, @CodigoEstado,
                                     @Proveedor, @Almacen, @Estado, @FechaEnvio, @FechaEntrega,
                                     @CostoTotalEntrega, @FechaEntregaReal, @FechaEntregaEstimada, @DistanciaRecorrida;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM [dbo].[int_Fact_Entregas] WHERE CodigoEntrega = @CodigoEntrega)
        BEGIN
            INSERT INTO [dbo].[int_Fact_Entregas]
            (
                [CodigoEntrega], [CodigoProveedor], [CodigoAlmacen], [CodigoEstado],
                [Proveedor], [Almacen], [Estado], [FechaEnvio], [FechaEntrega],
                [CostoTotalEntrega], [FechaEntregaReal], [FechaEntregaEstimada], [DistanciaRecorrida]
            )
            VALUES
            (
                @CodigoEntrega, @CodigoProveedor, @CodigoAlmacen, @CodigoEstado,
                @Proveedor, @Almacen, @Estado, @FechaEnvio, @FechaEntrega,
                @CostoTotalEntrega, @FechaEntregaReal, @FechaEntregaEstimada, @DistanciaRecorrida
            );
        END

        FETCH NEXT FROM fact_cursor INTO @CodigoEntrega, @CodigoProveedor, @CodigoAlmacen, @CodigoEstado,
                                         @Proveedor, @Almacen, @Estado, @FechaEnvio, @FechaEntrega,
                                         @CostoTotalEntrega, @FechaEntregaReal, @FechaEntregaEstimada, @DistanciaRecorrida;
    END

    CLOSE fact_cursor;
    DEALLOCATE fact_cursor;
END;

EXEC [dbo].[Sp_CargaintFactEntregas];

-- int_Dim_ProveedorEntrega
CREATE PROCEDURE [dbo].[Sp_CargaintDimProveedorEntrega]
AS
BEGIN
    DECLARE @CodigoProveedor INT,
            @Proveedor NVARCHAR(100),
            @CostoEstimado DECIMAL(18, 2);

    DECLARE proveedor_cursor CURSOR FOR
    SELECT CodigoProveedor, Proveedor, CostoEstimado
    FROM [dbo].[stg_Dim_ProveedorEntrega];

    OPEN proveedor_cursor;

    FETCH NEXT FROM proveedor_cursor INTO @CodigoProveedor, @Proveedor, @CostoEstimado;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM [dbo].[int_Dim_ProveedorEntrega] WHERE CodigoProveedor = @CodigoProveedor)
        BEGIN
            INSERT INTO [dbo].[int_Dim_ProveedorEntrega]
            (
                [CodigoProveedor], [Proveedor], [CostoEstimado]
            )
            VALUES
            (
                @CodigoProveedor, @Proveedor, @CostoEstimado
            );
        END

        FETCH NEXT FROM proveedor_cursor INTO @CodigoProveedor, @Proveedor, @CostoEstimado;
    END

    CLOSE proveedor_cursor;
    DEALLOCATE proveedor_cursor;
END;

EXEC [dbo].[Sp_CargaintDimProveedorEntrega];

-- int_Dim_Almacen
CREATE PROCEDURE [dbo].[Sp_CargaintDimAlmacen]
AS
BEGIN
    DECLARE @CodigoAlmacen INT,
            @Almacen NVARCHAR(100),
            @Ubicacion NVARCHAR(100);

    DECLARE almacen_cursor CURSOR FOR
    SELECT CodigoAlmacen, Almacen, Ubicacion
    FROM [dbo].[stg_Dim_Almacen];

    OPEN almacen_cursor;

    FETCH NEXT FROM almacen_cursor INTO @CodigoAlmacen, @Almacen, @Ubicacion;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM [dbo].[int_Dim_Almacen] WHERE CodigoAlmacen = @CodigoAlmacen)
        BEGIN
            INSERT INTO [dbo].[int_Dim_Almacen]
            (
                [CodigoAlmacen], [Almacen], [Ubicacion]
            )
            VALUES
            (
                @CodigoAlmacen, @Almacen, @Ubicacion
            );
        END

        FETCH NEXT FROM almacen_cursor INTO @CodigoAlmacen, @Almacen, @Ubicacion;
    END

    CLOSE almacen_cursor;
    DEALLOCATE almacen_cursor;
END;

EXEC [dbo].[Sp_CargaintDimAlmacen];

-- int_Dim_EstadoPedido
CREATE PROCEDURE [dbo].[Sp_CargaintDimEstadoPedido]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[int_Dim_EstadoPedido] ([CodigoEstado], [Estado])
    SELECT DISTINCT
        [CodigoEstado], 
        [Estado]
    FROM 
        [dbo].[stg_Dim_EstadoPedido] AS stg
    WHERE 
        [CodigoEstado] IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 
            FROM [dbo].[int_Dim_EstadoPedido] AS intDim
            WHERE intDim.[CodigoEstado] = stg.[CodigoEstado]
        );

END;

EXEC [dbo].[Sp_CargaintDimEstadoPedido];