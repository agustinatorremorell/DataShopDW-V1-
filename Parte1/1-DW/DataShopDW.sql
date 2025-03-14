-- Crear Base de Datos

CREATE DATABASE DataShopDW;

USE DataShopDW; 

CREATE TABLE [dbo].[Dim_Producto] (
  [CodigoProducto] [int] IDENTITY(1,1) NOT NULL,
  [Producto] [nvarchar] (100) NOT NULL,
  [Categoria] [nvarchar] (100) NOT NULL,
  [Marca] [nvarchar] (100) NOT NULL,
  [PrecioCosto] [decimal] (18, 2) NOT NULL,
  [PrecioVentaSugerido] [decimal] (18, 2) NOT NULL,
  [FechaCreacion] [datetime] NOT NULL,
  [FechaActualizacion] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
[CodigoProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
)ON [PRIMARY] 
);

CREATE TABLE [dbo].[Dim_Cliente] (
	[CodigoCliente] [int] IDENTITY(1,1) NOT NULL,
	[Cliente] [nvarchar] (100) NOT NULL,
	[Telefono] [nvarchar] (100) NOT NULL,
	[Mail] [nvarchar] (100) NOT NULL,
	[Direccion] [nvarchar] (200) NOT NULL,
	[Localidad] [nvarchar] (100) NOT NULL,
	[Provincia] [nvarchar] (100) NOT NULL,
	[CP] [nvarchar] (10) NOT NULL,
	[FechaRegistro] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
[CodigoCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
)ON [PRIMARY] 
);

CREATE TABLE [dbo].[Dim_Tienda] (
	[CodigoTienda] [int] IDENTITY(1,1) NOT NULL,
	[NombreTienda] [nvarchar] (100) NOT NULL,
	[Direccion] [nvarchar] (200) NOT NULL,
	[Localidad] [nvarchar] (100) NOT NULL,
	[Provincia] [nvarchar] (100) NOT NULL,
	[CP] [nvarchar] (10) NOT NULL,
	[TipoTienda] [nvarchar] (50) NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaActualizacion] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
[CodigoTienda] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
)ON [PRIMARY] 
);

CREATE TABLE [dbo].[Dim_Tiempo] (
    [Tiempo_Key] [datetime] PRIMARY KEY,
    [Anio] [int],
    [Mes] [int],
    [Mes_Nombre] [varchar](20),
    [Semestre] [int],
    [Trimestre] [int],
    [Semana_Anio] [int],
    [Semana_Nro_Mes] [int],
    [Dia] [int],
    [Dia_Nombre] [varchar](20),
    [Dia_Semana_Nro] [int]
);

CREATE TABLE [dbo].[Fact_Ventas] (
	[FechaVenta] [datetime] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[PrecioVenta] [decimal] (18, 2) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[CodigoProducto] [int] NOT NULL,
	[CodigoCliente] [int] NOT NULL,
	[CodigoTienda] [int] NOT NULL,
	[Tiempo_Key] [datetime] NULL
);


-- Relacionar tablas

ALTER TABLE [dbo].[Fact_Ventas] WITH CHECK ADD FOREIGN KEY([CodigoCliente])
REFERENCES [dbo].[Dim_Cliente] ([CodigoCliente])

ALTER TABLE [dbo].[Fact_Ventas] WITH CHECK ADD FOREIGN KEY([CodigoProducto])
REFERENCES [dbo].[Dim_Producto] ([CodigoProducto])

ALTER TABLE [dbo].[Fact_Ventas] WITH CHECK ADD FOREIGN KEY([CodigoTienda])
REFERENCES [dbo].[Dim_Tienda] ([CodigoTienda])

ALTER TABLE [dbo].[Fact_Ventas] WITH CHECK ADD FOREIGN KEY([Tiempo_Key]) 
REFERENCES [dbo].[Dim_Tiempo] ([Tiempo_Key])


-- Instancia STG (Stage)

CREATE TABLE [dbo].[stg_Dim_Producto] (
	[CodigoProducto] [nvarchar] (255) NULL,
	[Producto] [nvarchar] (255) NULL,
	[Categoria] [nvarchar] (255) NULL,
	[Marca] [nvarchar] (255) NULL,
	[PrecioCosto] [nvarchar] (255) NULL,
	[PrecioVentaSugerido] [nvarchar] (255) NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[stg_Dim_Cliente] (
	[CodigoCliente] [nvarchar] (255) NULL,
	[Cliente] [nvarchar] (255) NULL,
	[Telefono] [nvarchar] (255) NULL,
	[Mail] [nvarchar] (255) NULL,
	[Direccion] [nvarchar] (255) NULL,
	[Localidad] [nvarchar] (255) NULL,
	[Provincia] [nvarchar] (255) NULL,
	[CP] [nvarchar] (255) NULL,	
) ON [PRIMARY]

CREATE TABLE [dbo].[stg_Dim_Tienda] (
	[CodigoTienda] [nvarchar] (255) NULL,
	[NombreTienda] [nvarchar] (255) NULL,
	[Direccion] [nvarchar] (255) NULL,
	[Localidad] [nvarchar] (255) NULL,
	[Provincia] [nvarchar] (255) NULL,
	[CP] [nvarchar] (255) NULL,
	[TipoTienda] [nvarchar] (255) NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[stg_Fact_Ventas] (
	[FechaVenta] [nvarchar] (255) NULL,
	[CodigoProducto] [nvarchar] (255) NULL,
	[Cantidad] [nvarchar] (255) NULL,
	[PrecioVenta] [nvarchar] (255) NULL,
	[CodigoCliente] [nvarchar] (255) NULL,
	[CodigoTienda] [nvarchar] (255) NULL,
) ON [PRIMARY]


-- Instancia INT (Intermedia)

CREATE TABLE [dbo].[int_Dim_Producto](
	[CodigoProducto] [int] NOT NULL,
	[Producto] [nvarchar] (100) NOT NULL,
	[Categoria] [nvarchar] (50) NOT NULL,
	[Marca] [nvarchar] (50) NOT NULL,
	[PrecioCosto] [decimal] (18, 2) NOT NULL,
	[PrecioVentaSugerido] [decimal] (18, 2) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[int_Dim_Cliente] (
	[CodigoCliente] [int] NOT NULL,
	[Cliente] [nvarchar] (100) NOT NULL,
	[Telefono] [nvarchar] (100) NOT NULL,
	[Mail] [nvarchar] (100) NOT NULL,
	[Direccion] [nvarchar] (200) NOT NULL,
	[Localidad] [nvarchar] (100) NOT NULL,
	[Provincia] [nvarchar] (100) NOT NULL,
	[CP] [nvarchar] (10) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[int_Dim_Tienda] (
	[CodigoTienda] [int] NOT NULL,
	[NombreTienda] [nvarchar] (100) NOT NULL,
	[Direccion] [nvarchar] (200) NOT NULL,
	[Localidad] [nvarchar] (100) NOT NULL,
	[Provincia] [nvarchar] (100) NOT NULL,
	[CP] [nvarchar] (10) NOT NULL,
	[TipoTienda] [nvarchar] (255) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[int_Fact_Ventas] (
	[FechaVenta] [datetime] NOT NULL,
	[CodigoProducto] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[PrecioVenta] [decimal] (18, 2) NOT NULL,
	[CodigoCliente] [int] NOT NULL,
	[CodigoTienda] [int] NOT NULL,
) ON [PRIMARY]
