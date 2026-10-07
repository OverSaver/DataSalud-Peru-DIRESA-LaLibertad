-- ============================================================
-- ARCHIVO: 02_Stored_Procedures.sql
-- DESCRIPCIÓN: Procedimientos Almacenados y Funciones
-- ============================================================

USE DataSaludPeru;
GO

-- 1. SP PARA INSERTAR ATENCIÓN CON SAVEPOINT Y MANEJO DE ERRORES (S05/P03)
CREATE PROCEDURE sp_InsertarAtencion
    @Anio INT,
    @Departamento VARCHAR(100),
    @Provincia VARCHAR(100),
    @Distrito VARCHAR(100),
    @Ubigeo VARCHAR(6),
    @EstrategiaPF VARCHAR(150),
    @InsumoEntregado VARCHAR(150),
    @CantidadInsumo INT,
    @ConsejeríaBrindada BIT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    SAVE TRANSACTION PuntoGuardado_Atencion;

    BEGIN TRY
        -- Validar año coherente
        IF @Anio < 2000 OR @Anio > YEAR(GETDATE())
            RAISERROR('Año fuera del rango permitido.', 16, 1);

        INSERT INTO AtencionPlanificacion (Anio, Departamento, Provincia, Distrito, Ubigeo, EstrategiaPF, InsumoEntregado, CantidadInsumo, ConsejeríaBrindada)
        VALUES (@Anio, @Departamento, @Provincia, @Distrito, @Ubigeo, @EstrategiaPF, @InsumoEntregado, @CantidadInsumo, @ConsejeríaBrindada);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION PuntoGuardado_Atencion;
        COMMIT TRANSACTION; -- Cierra la transacción limpia
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- 2. FUNCIÓN PARA FORMATEAR UBIGEO Y COMPLEMENTAR S01
CREATE FUNCTION fn_FormatearUbigeo (@UbigeoRaw VARCHAR(10))
RETURNS VARCHAR(6)
AS
BEGIN
    RETURN RIGHT('000000' + LTRIM(RTRIM(@UbigeoRaw)), 6);
END;
GO
