-- Carga

-- Dim_Producto
CREATE PROCEDURE dbo.sp_Cargar_Dim_Producto
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dp
    SET
        dp.Producto = idp.Producto,
        dp.Categoria = idp.Categoria,
        dp.Marca = idp.Marca,
        dp.PrecioCosto = idp.PrecioCosto,
        dp.PrecioVentaSugerido = idp.PrecioVentaSugerido,
        dp.FechaActualizacion = GETDATE()
    FROM dbo.Dim_Producto dp
    INNER JOIN dbo.int_Dim_Producto idp
        ON dp.CodigoProducto = idp.CodigoProducto;

    INSERT INTO dbo.Dim_Producto (Producto, Categoria, Marca, PrecioCosto, PrecioVentaSugerido, FechaCreacion)
    SELECT
        idp.Producto,
        idp.Categoria,
        idp.Marca,
        idp.PrecioCosto,
        idp.PrecioVentaSugerido,
        idp.FechaRegistro
    FROM dbo.int_Dim_Producto idp
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Dim_Producto dp
        WHERE dp.CodigoProducto = idp.CodigoProducto
    );
END;
GO

EXEC dbo.sp_Cargar_Dim_Producto

-- Dim Cliente
CREATE PROCEDURE [dbo].[sp_Cargar_Dim_Cliente]
AS
BEGIN
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[Dim_Cliente] 
    (
        [Cliente],
        [Telefono],
        [Mail],
        [Direccion],
        [Localidad],
        [Provincia],
        [CP],
        [FechaRegistro] 
    )
    SELECT 
        [Cliente],
        [Telefono],
        [Mail],
        [Direccion],
        [Localidad],
        [Provincia],
        [CP],
        GETDATE() AS [FechaRegistro] 
    FROM [dbo].[int_Dim_Cliente]
    WHERE NOT EXISTS (
        SELECT 1
        FROM [dbo].[Dim_Cliente] dc
        WHERE dc.[CodigoCliente] = [dbo].[int_Dim_Cliente].[CodigoCliente]
    );

    COMMIT TRANSACTION;
END;
GO

EXEC [dbo].[sp_Cargar_Dim_Cliente]

-- Dim_Tienda
CREATE PROCEDURE sp_Cargar_Dim_Tienda
AS
BEGIN
    DECLARE @FechaActualizacion DATETIME;

    SET @FechaActualizacion = GETDATE();

    INSERT INTO [dbo].[Dim_Tienda] (
        [NombreTienda],
        [Direccion],
        [Localidad],
        [Provincia],
        [CP],
        [TipoTienda],
        [FechaCreacion],
        [FechaActualizacion]
    )
    SELECT 
        [NombreTienda],
        [Direccion],
        [Localidad],
        [Provincia],
        [CP],
        [TipoTienda],
        [FechaRegistro],
        @FechaActualizacion 
    FROM 
        [dbo].[int_Dim_Tienda]
    WHERE 
        NOT EXISTS (
            SELECT 1
            FROM [dbo].[Dim_Tienda] dt
            WHERE dt.[CodigoTienda] = [dbo].[int_Dim_Tienda].[CodigoTienda]
        );

    UPDATE dt
    SET
        dt.[NombreTienda] = it.[NombreTienda],
        dt.[Direccion] = it.[Direccion],
        dt.[Localidad] = it.[Localidad],
        dt.[Provincia] = it.[Provincia],
        dt.[CP] = it.[CP],
        dt.[TipoTienda] = it.[TipoTienda],
        dt.[FechaActualizacion] = @FechaActualizacion
    FROM 
        [dbo].[Dim_Tienda] dt
    JOIN 
        [dbo].[int_Dim_Tienda] it ON dt.[CodigoTienda] = it.[CodigoTienda]
    WHERE
        dt.[FechaActualizacion] < it.[FechaRegistro]; 
END;
GO

EXEC sp_Cargar_Dim_Tienda

-- Fact_Ventas
CREATE PROCEDURE sp_Cargar_Fact_Ventas
AS
BEGIN
    INSERT INTO [dbo].[Fact_Ventas] (
        [FechaVenta], 
        [Cantidad], 
        [PrecioVenta], 
        [FechaRegistro], 
        [CodigoProducto], 
        [CodigoCliente], 
        [CodigoTienda], 
        [Tiempo_Key]
    )
    SELECT 
        iv.[FechaVenta],
        iv.[Cantidad],
        iv.[PrecioVenta],
        GETDATE(), 
        iv.[CodigoProducto],
        iv.[CodigoCliente],
        iv.[CodigoTienda],
        (SELECT TOP 1 [Tiempo_Key]  
         FROM [dbo].[Dim_Tiempo] 
         WHERE [Tiempo_Key] = DAY(iv.[FechaVenta])
        ) AS Tiempo_Key
    FROM 
        [dbo].[int_Fact_Ventas] iv
    WHERE EXISTS (
        SELECT 1 
        FROM [dbo].[Dim_Cliente] dc 
        WHERE dc.CodigoCliente = iv.CodigoCliente
    );  
END;

EXEC sp_Cargar_Fact_Ventas

-- Dim_Tiempo 
CREATE PROCEDURE [dbo].[Sp_Genera_Dim_Tiempo] 
@anio Int 
AS 
BEGIN
    SET NOCOUNT ON;
    SET ARITHABORT OFF;
    SET ARITHIGNORE ON;
    SET DATEFIRST 1;
    SET DATEFORMAT mdy;

    DECLARE @dia smallint;
    DECLARE @mes smallint;
    DECLARE @f_txt varchar(10);
    DECLARE @fecha datetime; 
    DECLARE @key int;
    DECLARE @vacio smallint;
    DECLARE @fin smallint;
    DECLARE @fin_mes int;
    DECLARE @anioperiodicidad int;

    SELECT @dia = 1, @mes = 1;
    SELECT @f_txt = Convert(char(2), @mes) + '/' + Convert(char(2), @dia) + '/' + Convert(char(4), @anio);
    SELECT @fecha = Convert(datetime, @f_txt); -- Cambiado de smalldatetime a datetime
    SELECT @anioperiodicidad = @anio;
    IF (SELECT Count(*) FROM dim_tiempo WHERE anio = @anio) > 0 
    BEGIN
        PRINT 'El año que ingresó ya existe en la tabla';
        PRINT 'Procedimiento CANCELADO.................';
        RETURN 0;
    END;
    SELECT @fin = @anio + 1;
    WHILE (Year(@fecha) < @fin) 
    BEGIN
        SET @f_txt = Convert(char(4), Datepart(yyyy, @fecha)) + 
                     RIGHT('0' + Convert(varchar(2), Datepart(mm, @fecha)), 2) +
                     RIGHT('0' + Convert(varchar(2), Datepart(dd, @fecha)), 2);     
        SET @fin_mes = Day(Dateadd(d, -1, Dateadd(m, 1, Dateadd(d, - Day(@fecha) + 1, @fecha))));     
        INSERT Dim_Tiempo (Tiempo_Key, Anio, Mes, Mes_Nombre, Semestre, Trimestre, Semana_Anio ,Semana_Nro_Mes, Dia, Dia_Nombre, Dia_Semana_Nro)
        SELECT 
            tiempo_key = @fecha,
            anio = Datepart(yyyy, @fecha),
            mes = Datepart(mm, @fecha),
            mes_nombre = CASE Datename(mm, @fecha)
                WHEN 'January' THEN 'Enero'
                WHEN 'February' THEN 'Febrero'
                WHEN 'March' THEN 'Marzo'
                WHEN 'April' THEN 'Abril'
                WHEN 'May' THEN 'Mayo'
                WHEN 'June' THEN 'Junio'
                WHEN 'July' THEN 'Julio'
                WHEN 'August' THEN 'Agosto'
                WHEN 'September' THEN 'Septiembre'
                WHEN 'October' THEN 'Octubre'
                WHEN 'November' THEN 'Noviembre'
                WHEN 'December' THEN 'Diciembre'
                ELSE Datename(mm, @fecha)
            END,
            semestre = CASE WHEN Datepart(mm, @fecha) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
            trimestre = Datepart(qq, @fecha),
            semana_anio = Datepart(wk, @fecha),
            semana_nro_mes = Datepart(wk, @fecha) - Datepart(week, Dateadd(dd, -Day(@fecha)+1, @fecha)) + 1,
            dia = Datepart(dd, @fecha),
            dia_nombre = CASE Datename(dw, @fecha)
                WHEN 'Monday' THEN 'Lunes'
                WHEN 'Tuesday' THEN 'Martes'
                WHEN 'Wednesday' THEN 'Miercoles'
                WHEN 'Thursday' THEN 'Jueves'
                WHEN 'Friday' THEN 'Viernes'
                WHEN 'Saturday' THEN 'Sabado'
                WHEN 'Sunday' THEN 'Domingo'
                ELSE Datename(dw, @fecha)
            END,
            dia_semana_nro = Datepart(dw, @fecha);    
        SELECT @fecha = Dateadd(dd, 1, @fecha);
    END;
END;
GO

EXEC SP_Genera_Dim_Tiempo @anio = 2022
EXEC SP_Genera_Dim_Tiempo @anio = 2023
EXEC SP_Genera_Dim_Tiempo @anio = 2024