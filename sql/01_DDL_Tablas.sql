-- ============================================================
-- PROYECTO: DataSalud Perú - DIRESA La Libertad
-- ARCHIVO: 01_DDL_Tablas.sql
-- DESCRIPCIÓN: Creación de Esquema Transaccional, Roles y Auditoría
-- ============================================================

CREATE DATABASE DataSaludPeru;
GO
USE DataSaludPeru;
GO

-- 1. TABLA BASE: Atenciones de Planificación Familiar
CREATE TABLE AtencionPlanificacion (
    AtencionID INT IDENTITY(1,1) PRIMARY KEY,
    Anio INT NOT NULL,
    Departamento VARCHAR(100) NOT NULL,
    Provincia VARCHAR(100) NOT NULL,
    Distrito VARCHAR(100) NOT NULL,
    Ubigeo VARCHAR(6) NOT NULL,
    EstrategiaPF VARCHAR(150) NOT NULL,
    InsumoEntregado VARCHAR(150) NULL,
    CantidadInsumo INT DEFAULT 0,
    ConsejeríaBrindada BIT NOT NULL DEFAULT 0,
    FechaRegistro DATETIME DEFAULT GETDATE()
);
GO

-- 2. TABLA DE AUDITORÍA (Cumplimiento Ley N.° 29733)
CREATE TABLE LOG_AUDITORIA (
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    AtencionID INT NOT NULL,
    Usuario VARCHAR(100) NOT NULL,
    Accion VARCHAR(50) NOT NULL,
    FechaOperacion DATETIME DEFAULT GETDATE(),
    DetalleAnterior VARCHAR(MAX) NULL
);
GO

-- 3. TRIGGER DE AUDITORÍA AUTOMÁTICA
CREATE TRIGGER trg_AuditoriaAtenciones
ON AtencionPlanificacion
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Auditoría para INSERCIONES
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO LOG_AUDITORIA (AtencionID, Usuario, Accion, DetalleAnterior)
        SELECT AtencionID, SUSER_SNAME(), 'INSERT', 'Nueva atención registrada.'
        FROM inserted;
    END

    -- Auditoría para ELIMINACIONES
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO LOG_AUDITORIA (AtencionID, Usuario, Accion, DetalleAnterior)
        SELECT AtencionID, SUSER_SNAME(), 'DELETE', CONCAT('Ubigeo: ', Ubigeo, ' | Estrategia: ', EstrategiaPF)
        FROM deleted;
    END
END;
GO

-- 4. CONFIGURACIÓN DE ROLES Y SEGURIDAD (ISO/IEC 27001)
CREATE ROLE rol_Administrador;
CREATE ROLE rol_AnalistaDatos;
CREATE ROLE rol_Auditor;
GO

-- Permisos
GRANT CONTROL ON DATABASE::DataSaludPeru TO rol_Administrador;
GRANT SELECT ON AtencionPlanificacion TO rol_AnalistaDatos;
GRANT SELECT ON LOG_AUDITORIA TO rol_Auditor;
DENY UPDATE, DELETE ON LOG_AUDITORIA TO PUBLIC;
GO
