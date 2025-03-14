import pandas as pd
import pyodbc
from datetime import datetime

server = 'DESKTOP-749TBSE\\SQLEXPRESS'
database = 'DataShopDW'
conn = pyodbc.connect(f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER=DESKTOP-749TBSE\\SQLEXPRESS;DATABASE=DataShopDW;Trusted_Connection=yes')

def load_to_sql(table_name, file_path, conn):
    df = pd.read_csv(file_path, delimiter=';', encoding='latin1') 

    print(f"Columnas en el archivo CSV: {df.columns}")

    if 'FechaEnvio' in df.columns and 'FechaEntrega' in df.columns:
        df['FechaEnvio'] = pd.to_datetime(df['FechaEnvio'], format='%Y-%m-%d', errors='coerce').dt.strftime('%Y-%m-%d')
        df['FechaEntrega'] = pd.to_datetime(df['FechaEntrega'], format='%Y-%m-%d', errors='coerce').dt.strftime('%Y-%m-%d')

    cursor = conn.cursor()

    if table_name == 'stg_Fact_Entregas':
        for index, row in df.iterrows():
            sql = f"""
            INSERT INTO [dbo].[{table_name}] 
            ([CodigoEntrega], [CodigoProveedor], [CodigoAlmacen], [CodigoEstado], 
            [Proveedor], [Almacen], [Estado], [FechaEnvio], [FechaEntrega])
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
            cursor.execute(sql, 
                row['CodigoEntrega'], row['CodigoProveedor'], row['CodigoAlmacen'], row['CodigoEstado'],
                row['Proveedor'], row['Almacen'], row['Estado'], row.get('FechaEnvio', None), row.get('FechaEntrega', None)
            )

    elif table_name == 'stg_Dim_ProveedorEntrega':
        for index, row in df.iterrows():
            sql = f"""
            INSERT INTO [dbo].[{table_name}] 
            ([CodigoProveedor], [Proveedor], [CostoEstimado])
            VALUES (?, ?, ?)
            """
            cursor.execute(sql, 
                row['CodigoProveedor'], row['Proveedor'], row.get('CostoEstimado', None)
            )

    elif table_name == 'stg_Dim_Almacen':
        for index, row in df.iterrows():
            sql = f"""
            INSERT INTO [dbo].[{table_name}] 
            ([CodigoAlmacen], [Almacen], [Ubicacion])
            VALUES (?, ?, ?)
            """
            cursor.execute(sql, 
                row['CodigoAlmacen'], row['Almacen'], row.get('Ubicacion', None)
            )

    elif table_name == 'stg_Dim_EstadoPedido':
        for index, row in df.iterrows():
            sql = f"""
            INSERT INTO [dbo].[{table_name}] 
            ([CodigoEstado], [Estado])
            VALUES (?, ?)
            """
            cursor.execute(sql, 
                row['CodigoEstado'], row['Estado']
            )

    conn.commit()

load_to_sql('stg_Fact_Entregas', r'C:\Users\Positivo BGH\OneDrive\Escritorio\Python\Quales\Final\Fact_Entregas.csv', conn)
load_to_sql('stg_Dim_ProveedorEntrega', r'C:\Users\Positivo BGH\OneDrive\Escritorio\Python\Quales\Final\Dim_ProveedorEntrega.csv', conn)
load_to_sql('stg_Dim_Almacen', r'C:\Users\Positivo BGH\OneDrive\Escritorio\Python\Quales\Final\Dim_Almacen.csv', conn)
load_to_sql('stg_Dim_EstadoPedido', r'C:\Users\Positivo BGH\OneDrive\Escritorio\Python\Quales\Final\Dim_EstadoPedido.csv', conn)

conn.close()