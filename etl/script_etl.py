# ============================================================
# ARCHIVO: script_etl.py
# DESCRIPCIÓN: Pipeline ETL en Python (Extracción, Transformación y Carga)
# ============================================================

import pandas as pd
from sqlalchemy import create_engine

# 1. Extracción desde Base Transaccional (SQL Server)
engine_src = create_engine("mssql+pyodbc://localhost/DataSaludPeru?driver=SQL+Server")
engine_dw = create_engine("mssql+pyodbc://localhost/DW_DataSaludPeru?driver=SQL+Server")

print("Iniciando proceso ETL DataSalud Perú...")

# Leer datos crudos
df_raw = pd.read_sql("SELECT * FROM AtencionPlanificacion", engine_src)

# 2. Transformación y Limpieza
# S01: Formateo de Ubigeo a 6 dígitos
df_raw['Ubigeo'] = df_raw['Ubigeo'].astype(str).str.zfill(6)

# S02: Normalización de Textos
df_raw['Departamento'] = df_raw['Departamento'].str.upper().str.strip()
df_raw['Provincia'] = df_raw['Provincia'].str.upper().str.strip()
df_raw['Distrito'] = df_raw['Distrito'].str.upper().str.strip()

# S03: Imputación de Insumos nulos
df_raw['InsumoEntregado'] = df_raw['InsumoEntregado'].fillna('SIN INSUMO ESPECIFICADO')

# 3. Carga a Tabla de Hechos DW
df_fact = pd.DataFrame({
    'CantidadInsumo': df_raw['CantidadInsumo'],
    'ConsejeríaBrindada': df_raw['ConsejeríaBrindada'].astype(int),
    'TotalAtenciones': 1
})

df_fact.to_sql('Fact_AtencionesPF', con=engine_dw, if_exists='append', index=False)
print("Carga ETL ejecutada con éxito en el Data Warehouse.")
