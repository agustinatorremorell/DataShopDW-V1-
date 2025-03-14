# DataShopDW-V1-
Proyecto Final - Capacitacion: Análisis de Datos y Gestión de la Información, QualesGroup.

## Descripción

El proyecto se enfoca en la creación de un Data Warehouse (DW), el desarrollo de un proceso ETL en SQL y Python, y la construcción de un dashboard en Power BI.

## 📌 Estructura del Proyecto

El proyecto se divide en dos fases:

### Fase 1: Creación del Data Warehouse.

1. **Creación del DW: `DataShopDW` y Modelado de datos** que incluye las siguientes tablas:
    - `Dim_Cliente`
    - `Dim_Producto`
    - `Dim_Tienda`
    - `Dim_Tiempo`
    - `Fact_Ventas`
    - Tablas `stg_` e `int_` para la carga de datos.
2. Proceso **ETL**:
   - Extracción en Python.
   - Transformación y carga: Mediante Stored Procedure en SQL.
3. **Dashboard** en Power BI:

### Fase 2: Ampliado del Modelo de Datos

1. **Ampliación del modelo** con nuevas tablas:
    - `Fact_Entregas`
    - `Dim_ProveedorEntrega`
    - `Dim_Almacen`
    - `Dim_EstadoPedido`
    - Tablas `stg_` e `int_`
2. **Nuevas métricas y relaciones:**
    - Cálculo de tiempo de entrega.
    - Costos asociados a las entregas.
    - Indicadores de cumplimiento de plazos.
3. **Proceso ETL** actualizado: Incorporación de datos en las nuevas tablas.
4. **Dashboard final** en Power BI.

## 📁 Contenido del Repositorio

  - 📂 **Parte1/** → Scripts para la creación, carga del Data Warehouse y Dashboard.
      - 📂 DW/ → Diagrama y Script SQL DataShop.
      - 📂 ScriptsETL/ → Script para la Extracción en SQL, Scripts para la Transformación y Carga en Python.
      - 📂 Visualizacion/ → Archivo PBIX del Dashboard y capturas de pantalla del Dashboard.
  - 📂 **Parte2/** → Scripts para el ampliado del modelo de datos, carga de las nuevas tablas y Dashboard final.
      - 📂 DW/ → Diagrama Completo de DW: DataShop y Script SQL Ampliado del Modelo de Datos DataShop.
      - 📂 ScriptsETL/ → Script para la Extracción en SQL, Scripts para la Transformación y Carga en Python.
      - 📂 Visualizacion/ → Archivo PBIX del Dashboard Final y Completo y capturas de pantalla del Dashboard.
  - 📈 **Archivo Excel** → Datos crudos.
  - 📄 **README.md** → Detalles del proyecto.
