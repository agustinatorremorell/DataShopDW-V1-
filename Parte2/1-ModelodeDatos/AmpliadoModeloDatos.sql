USE DataShopDW;

CREATE TABLE [dbo].[Fact_Entregas] (
    [CodigoEntrega] [int] IDENTITY(1,1) NOT NULL,
	[CodigoProveedor] [int] NULL,
	[CodigoAlmacen] [int] NULL,
	[CodigoEstado] [int] NULL,
	[Proveedor] [nvarchar] (100) NOT NULL,
	[Almacen] [nvarchar] (100) NOT NULL,
	[Estado] [nvarchar] (100) NOT NULL,
    [FechaEnvio] [datetime] NULL, 
    [FechaEntrega] [datetime] NULL,
    PRIMARY KEY CLUSTERED ([CodigoEntrega] ASC)
);

ALTER TABLE dbo.Fact_Ventas
ADD CodigoEntrega INT NULL;

CREATE TABLE [dbo].[Dim_ProveedorEntrega] (
    [CodigoProveedor] [int] IDENTITY(1,1) NOT NULL,
    [Proveedor] [nvarchar] (100) NOT NULL,
    [CostoEstimado] [decimal](18, 2) NULL, 
    PRIMARY KEY CLUSTERED ([CodigoProveedor] ASC)
);

CREATE TABLE [dbo].[Dim_Almacen] (
    [CodigoAlmacen] [int] IDENTITY(1,1) NOT NULL,
    [Almacen] [nvarchar] (100) NOT NULL,
    [Ubicacion] [nvarchar] (100) NULL, 
    PRIMARY KEY CLUSTERED ([CodigoAlmacen] ASC)
);

CREATE TABLE [dbo].[Dim_EstadoPedido] (
    [CodigoEstado] [int] IDENTITY(1,1) NOT NULL,
    [Estado] [nvarchar] (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([CodigoEstado] ASC)
);

-- Relación entre Ventas y Entrega
ALTER TABLE dbo.Fact_Ventas
ADD CONSTRAINT FK_FactVentas_FactEntregas
FOREIGN KEY (CodigoEntrega) REFERENCES dbo.Fact_Entregas(CodigoEntrega);

-- Relación entre Entrega y Proveedor de Servicios de Entrega
ALTER TABLE [dbo].[Fact_Entregas]
ADD CONSTRAINT FK_Fact_Entregas_Dim_ProveedorEntrega
FOREIGN KEY (CodigoProveedor) REFERENCES [dbo].[Dim_ProveedorEntrega](CodigoProveedor);

-- Relación entre Entrega y Almacén
ALTER TABLE [dbo].[Fact_Entregas]
ADD CONSTRAINT FK_Fact_Entregas_Dim_Almacen
FOREIGN KEY (CodigoAlmacen) REFERENCES [dbo].[Dim_Almacen](CodigoAlmacen);

-- Relación entre Entrega y Estado del Pedido
ALTER TABLE [dbo].[Fact_Entregas]
ADD CONSTRAINT FK_Fact_Entregas_Dim_EstadoPedido
FOREIGN KEY (CodigoEstado) REFERENCES [dbo].[Dim_EstadoPedido](CodigoEstado);

-- Reglas de Negocio

ALTER TABLE Fact_Entregas
ADD FechaEntregaReal DATETIME,
    FechaEntregaEstimada DATETIME,
    DistanciaRecorrida DECIMAL(10, 2);

-- Tiempo de Entrega
ALTER TABLE [dbo].[Fact_Entregas]
ADD [TiempoEntrega] AS DATEDIFF(DAY, [FechaEnvio], [FechaEntregaReal]);

-- Costo Total de La Entrega
ALTER TABLE dbo.Fact_Entregas
ADD CostoTotalEntrega DECIMAL(18, 2) NULL;

CREATE TRIGGER trg_UpdateCostoTotalEntrega
ON dbo.Fact_Entregas
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE fe
    SET CostoTotalEntrega = fe.DistanciaRecorrida * dpe.CostoEstimado
    FROM dbo.Fact_Entregas fe
    INNER JOIN dbo.Dim_ProveedorEntrega dpe
    ON fe.CodigoProveedor = dpe.CodigoProveedor
    WHERE fe.CodigoEntrega IN (SELECT CodigoEntrega FROM inserted);
END;

-- Entregado a Tiempo
ALTER TABLE [dbo].[Fact_Entregas]
ADD [EntregadoATiempo] AS 
    CASE 
        WHEN [FechaEntregaReal] <= [FechaEntregaEstimada] THEN 'Sí'
        ELSE 'No'
    END;

-- Costo por Kilómetro
ALTER TABLE [dbo].[Fact_Entregas]
ADD [CostoPorKilometro] AS 
    CASE 
        WHEN [DistanciaRecorrida] > 0 THEN [CostoTotalEntrega] / [DistanciaRecorrida]
        ELSE NULL
    END;


-- Instancia STG

CREATE TABLE [dbo].[stg_Fact_Entregas] (
    [CodigoEntrega] INT NULL,
    [CodigoProveedor] INT NULL,
    [CodigoAlmacen] INT NULL,
    [CodigoEstado] INT NULL,
    [Proveedor] NVARCHAR(100) NULL,
    [Almacen] NVARCHAR(100) NULL,
    [Estado] NVARCHAR(100) NULL,
    [FechaEnvio] DATETIME NULL,
    [FechaEntrega] DATETIME NULL,
    [CostoTotalEntrega] DECIMAL(18, 2) NULL,
    [FechaEntregaReal] DATETIME NULL,
    [FechaEntregaEstimada] DATETIME NULL,
    [DistanciaRecorrida] DECIMAL(10, 2) NULL,
);

CREATE TABLE [dbo].[stg_Dim_ProveedorEntrega] (
    [CodigoProveedor] INT NULL,
    [Proveedor] NVARCHAR(100) NULL,
    [CostoEstimado] DECIMAL(18, 2) NULL
);

CREATE TABLE [dbo].[stg_Dim_Almacen] (
    [CodigoAlmacen] INT NULL,
    [Almacen] NVARCHAR(100) NULL,
    [Ubicacion] NVARCHAR(100) NULL
);

CREATE TABLE [dbo].[stg_Dim_EstadoPedido] (
    [CodigoEstado] INT NULL,
    [Estado] NVARCHAR(100) NULL
);

-- Instancia INT 

CREATE TABLE [dbo].[int_Fact_Entregas] (
    [CodigoEntrega] INT NOT NULL,
    [CodigoProveedor] INT NOT NULL,
    [CodigoAlmacen] INT NOT NULL,
    [CodigoEstado] INT NOT NULL,
    [Proveedor] NVARCHAR(100) NOT NULL,
    [Almacen] NVARCHAR(100) NOT NULL,
    [Estado] NVARCHAR(100) NOT NULL,
    [FechaEnvio] DATETIME NOT NULL,
    [FechaEntrega] DATETIME NOT NULL,
    [CostoTotalEntrega] DECIMAL(18, 2) NULL,
    [FechaEntregaReal] DATETIME NULL,
    [FechaEntregaEstimada] DATETIME NULL,
    [DistanciaRecorrida] DECIMAL(10, 2) NULL,
    PRIMARY KEY ([CodigoEntrega])
);

CREATE TABLE [dbo].[int_Dim_ProveedorEntrega] (
    [CodigoProveedor] INT NOT NULL,
    [Proveedor] NVARCHAR(100) NOT NULL,
    [CostoEstimado] DECIMAL(18, 2) NULL,
    PRIMARY KEY ([CodigoProveedor])
);

CREATE TABLE [dbo].[int_Dim_Almacen] (
    [CodigoAlmacen] INT NOT NULL,
    [Almacen] NVARCHAR(100) NOT NULL,
    [Ubicacion] NVARCHAR(100) NULL,
    PRIMARY KEY ([CodigoAlmacen])
);

CREATE TABLE [dbo].[int_Dim_EstadoPedido] (
    [CodigoEstado] INT NOT NULL,
    [Estado] NVARCHAR(100) NOT NULL,
    PRIMARY KEY ([CodigoEstado])
);