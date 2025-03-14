-- Transformacion

-- int_Dim_Producto
CREATE PROCEDURE [dbo].[sp_Cargar_int_Dim_Producto]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[int_Dim_Producto] (
        [CodigoProducto],
        [Producto],
        [Categoria],
        [Marca],
        [PrecioCosto],
        [PrecioVentaSugerido],
        [FechaRegistro]
    )
    SELECT
        CAST(NULLIF(LTRIM(RTRIM([CodigoProducto])), '') AS INT) AS [CodigoProducto],
        LTRIM(RTRIM([Producto])) AS [Producto],
        LTRIM(RTRIM([Categoria])) AS [Categoria],
        LTRIM(RTRIM([Marca])) AS [Marca],
        CAST(NULLIF(LTRIM(RTRIM([PrecioCosto])), '') AS DECIMAL(18, 2)) AS [PrecioCosto],
        CAST(NULLIF(LTRIM(RTRIM([PrecioVentaSugerido])), '') AS DECIMAL(18, 2)) AS [PrecioVentaSugerido],
        GETDATE() AS [FechaRegistro]
    FROM
        [dbo].[stg_Dim_Producto]
    WHERE
        LTRIM(RTRIM([CodigoProducto])) IS NOT NULL 
        AND LTRIM(RTRIM([CodigoProducto])) <> ''
        AND LTRIM(RTRIM([Producto])) IS NOT NULL 
        AND LTRIM(RTRIM([Producto])) <> ''
        AND LTRIM(RTRIM([Categoria])) IS NOT NULL 
        AND LTRIM(RTRIM([Categoria])) <> ''
        AND LTRIM(RTRIM([Marca])) IS NOT NULL 
        AND LTRIM(RTRIM([Marca])) <> ''
        AND LTRIM(RTRIM([PrecioCosto])) IS NOT NULL 
        AND LTRIM(RTRIM([PrecioCosto])) <> ''
        AND LTRIM(RTRIM([PrecioVentaSugerido])) IS NOT NULL 
        AND LTRIM(RTRIM([PrecioVentaSugerido])) <> '';
END;
GO

EXEC [dbo].[sp_Cargar_int_Dim_Producto];

-- int_Dim_Cliente
CREATE PROCEDURE [dbo].[sp_Cargar_int_Dim_Cliente]
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[int_Dim_Cliente] (
            [CodigoCliente],
            [Cliente],
            [Telefono],
            [Mail],
            [Direccion],
            [Localidad],
            [Provincia],
            [CP]
        )
        SELECT
            CAST([CodigoCliente] AS INT) AS [CodigoCliente],
            ISNULL([Cliente], 'Desconocido') AS [Cliente],
            ISNULL([Telefono], 'Sin Teléfono') AS [Telefono],
            ISNULL([Mail], 'Sin Email') AS [Mail],
            ISNULL([Direccion], 'Sin Dirección') AS [Direccion],
            ISNULL([Localidad], 'Sin Localidad') AS [Localidad],
            ISNULL([Provincia], 'Sin Provincia') AS [Provincia],
            ISNULL([CP], 'Sin CP') AS [CP]
        FROM [dbo].[stg_Dim_Cliente]
        WHERE 
            [CodigoCliente] IS NOT NULL
            AND ISNUMERIC([CodigoCliente]) = 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

EXEC [dbo].[sp_Cargar_int_Dim_Cliente];

-- int_Dim_Tienda
CREATE PROCEDURE [dbo].[sp_Cargar_Int_Dim_Tienda]
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[int_Dim_Tienda] (
            [CodigoTienda],
            [NombreTienda],
            [Direccion],
            [Localidad],
            [Provincia],
            [CP],
            [TipoTienda],
            [FechaRegistro]
        )
        SELECT 
            TRY_CAST([CodigoTienda] AS INT) AS [CodigoTienda],
            ISNULL(LEFT([NombreTienda], 100), 'Desconocida') AS [NombreTienda],
            ISNULL(LEFT([Direccion], 200), 'Desconocida') AS [Direccion],
            ISNULL(LEFT([Localidad], 100), 'Desconocida') AS [Localidad],
            ISNULL(LEFT([Provincia], 100), 'Desconocida') AS [Provincia],
            ISNULL(LEFT([CP], 10), '0000') AS [CP],
            ISNULL(LEFT([TipoTienda], 255), 'Desconocido') AS [TipoTienda],
            GETDATE() AS [FechaRegistro]
        FROM [dbo].[stg_Dim_Tienda]
        WHERE 
            TRY_CAST([CodigoTienda] AS INT) IS NOT NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

EXEC [dbo].[sp_Cargar_Int_Dim_Tienda];

-- int_Fact_Ventas
CREATE PROCEDURE [dbo].[sp_Cargar_int_Fact_Ventas]
AS
BEGIN
    INSERT INTO [dbo].[int_Fact_Ventas] (
        [FechaVenta],
        [CodigoProducto],
        [Cantidad],
        [PrecioVenta],
        [CodigoCliente],
        [CodigoTienda]
    )
    SELECT
        CAST([FechaVenta] AS DATETIME) AS [FechaVenta],
        CAST([CodigoProducto] AS INT) AS [CodigoProducto],
        CAST([Cantidad] AS INT) AS [Cantidad],
        CAST([PrecioVenta] AS DECIMAL(18, 2)) AS [PrecioVenta],
        CAST([CodigoCliente] AS INT) AS [CodigoCliente],
        CAST([CodigoTienda] AS INT) AS [CodigoTienda]
    FROM [dbo].[stg_Fact_Ventas]
    WHERE 
        [FechaVenta] IS NOT NULL AND
        [CodigoProducto] IS NOT NULL AND
        [Cantidad] IS NOT NULL AND
        [PrecioVenta] IS NOT NULL AND
        [CodigoCliente] IS NOT NULL AND
        [CodigoTienda] IS NOT NULL;   
END;
GO

EXEC [dbo].[sp_Cargar_int_Fact_Ventas];
