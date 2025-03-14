import pyodbc
import csv

db_config = {
    'driver': 'ODBC Driver 17 for SQL Server',
    'server': 'DESKTOP-749TBSE\\SQLEXPRESS',
    'database': 'DataShop2024'
}

connection_string = (
    f"DRIVER={{{db_config['driver']}}};"
    f"SERVER={db_config['server']};"
    f"DATABASE={db_config['database']};"
    "Trusted_Connection=yes;"
)

def cargar_csv_a_tabla(csv_path, table_name, insert_query, expected_columns):
    try:
        with pyodbc.connect(connection_string) as conn:
            cursor = conn.cursor()
            print(f"Conexión exitosa para cargar datos en {table_name}")

            cursor.execute(f"TRUNCATE TABLE {table_name}")
            print(f"Tabla {table_name} truncada")

            with open(csv_path, mode='r', encoding='utf-8') as file:
                csv_reader = csv.reader(file, delimiter=';')
                header = next(csv_reader) 
                if len(header) != expected_columns:
                    raise ValueError(f"El archivo {csv_path} no tiene las columnas esperadas ({expected_columns}).")

                for row in csv_reader:
                    if len(row) != expected_columns:
                        print(f"Fila omitida por formato incorrecto: {row}")
                        continue
                    cursor.execute(insert_query, row)
            conn.commit()
            print(f"Datos insertados correctamente en {table_name}")

    except FileNotFoundError:
        print(f"Error: Archivo {csv_path} no encontrado")
    except pyodbc.Error as e:
        print(f"Error al conectar o insertar datos: {e}")
    except Exception as ex:
        print(f"Ocurrió un error inesperado: {ex}")

archivos_y_tablas = [
    {
        "csv_path": r"C:\Users\Positivo BGH\OneDrive\Escritorio\Python\DimCliente.csv",
        "table_name": "stg_Dim_Cliente",
        "insert_query": """
            INSERT INTO stg_Dim_Cliente (CodigoCliente, Cliente, Telefono, Mail, Direccion, Localidad, Provincia, CP)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """,
        "expected_columns": 8
    },
    {
        "csv_path": r"C:\Users\Positivo BGH\OneDrive\Escritorio\Python\DimProducto.csv",
        "table_name": "stg_Dim_Producto",
        "insert_query": """
            INSERT INTO stg_Dim_Producto (CodigoProducto, Producto, Categoria, Marca, PrecioCosto, PrecioVentaSugerido)
            VALUES (?, ?, ?, ?, ?, ?)
        """,
        "expected_columns": 6
    },
    {
        "csv_path": r"C:\Users\Positivo BGH\OneDrive\Escritorio\Python\DimTienda.csv",
        "table_name": "stg_Dim_Tienda",
        "insert_query": """
            INSERT INTO stg_Dim_Tienda (CodigoTienda, NombreTienda, Direccion, Localidad, Provincia, CP, TipoTienda)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        "expected_columns": 7
    },
    {
        "csv_path": r"C:\Users\Positivo BGH\OneDrive\Escritorio\Python\FactVentas.csv",
        "table_name": "stg_Fact_Ventas",
        "insert_query": """
            INSERT INTO stg_Fact_Ventas (FechaVenta, CodigoProducto, Cantidad, PrecioVenta, CodigoCliente, CodigoTienda)
            VALUES (?, ?, ?, ?, ?, ?)
        """,
        "expected_columns": 6
    }
]

for config in archivos_y_tablas:
    cargar_csv_a_tabla(
        config['csv_path'],
        config['table_name'],
        config['insert_query'],
        config['expected_columns']
    )
