-- ============================================================
-- ARCHIVO: 03_DW_DataWarehouse.sql
-- DESCRIPCIÓN: Esquema Dimensional Ralph Kimball (Data Warehouse)
-- ============================================================

CREATE DATABASE DW_DataSaludPeru;
GO
USE DW_DataSaludPeru;
GO

-- DIMENSIÓN TIEMPO
CREATE TABLE Dim_Tiempo (
    TiempoID INT IDENTITY(1,1) PRIMARY KEY,
    Anio INT NOT NULL,
    Trimestre INT NOT NULL,
    Mes INT NOT NULL
);

-- DIMENSIÓN UBICACIÓN
CREATE TABLE Dim_Ubicacion (
    UbicacionID INT IDENTITY(1,1) PRIMARY KEY,
    Departamento VARCHAR(100) NOT NULL,
    Provincia VARCHAR(100) NOT NULL,
    Distrito VARCHAR(100) NOT NULL,
    Ubigeo VARCHAR(6) NOT NULL
);

-- DIMENSIÓN ESTRATEGIA
CREATE TABLE Dim_EstrategiaPF (
    EstrategiaID INT IDENTITY(1,1) PRIMARY KEY,
    NombreEstrategia VARCHAR(150) NOT NULL,
    InsumoEntregado VARCHAR(150) NULL
);

-- TABLA DE HECHOS: ATENCIONES
CREATE TABLE Fact_AtencionesPF (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    TiempoID INT FOREIGN KEY REFERENCES Dim_Tiempo(TiempoID),
    UbicacionID INT FOREIGN KEY REFERENCES Dim_Ubicacion(UbicacionID),
    EstrategiaID INT FOREIGN KEY REFERENCES Dim_EstrategiaPF(EstrategiaID),
    CantidadInsumo INT NOT NULL DEFAULT 0,
    ConsejeríaBrindada INT NOT NULL DEFAULT 0,
    TotalAtenciones INT NOT NULL DEFAULT 1
);
GO
