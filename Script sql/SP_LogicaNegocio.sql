/*
 * NOMBRE DEL SCRIPT: SP_LogicaNegocio.sql
 * DESCRIPCIÓN: Colección de Procedimientos Almacenados (CRUD).
 */

USE GestionHoteleraDB;
GO

-- MÓDULO HOSPEDAJE
CREATE OR ALTER PROCEDURE sp_RegistrarHospedaje
    @NombreComercial NVARCHAR(150),
    @CedulaJuridica NVARCHAR(20),
    @TipoHospedaje NVARCHAR(50),
    @Provincia NVARCHAR(50),
    @Canton NVARCHAR(50),
    @Distrito NVARCHAR(50),
    @SenasExactas NVARCHAR(255),
    @Email NVARCHAR(100)
AS
BEGIN
    INSERT INTO Hospedaje (NombreComercial, CedulaJuridica, TipoHospedaje, Provincia, Canton, Distrito, SenasExactas, CorreoElectronico)
    VALUES (@NombreComercial, @CedulaJuridica, @TipoHospedaje, @Provincia, @Canton, @Distrito, @SenasExactas, @Email);
END
GO

CREATE OR ALTER PROCEDURE sp_ActualizarHospedaje
    @IdHospedaje INT,
    @NombreComercial NVARCHAR(150),
    @CorreoElectronico NVARCHAR(100),
    @SitioWebURL NVARCHAR(255)
AS
BEGIN
    UPDATE Hospedaje
    SET NombreComercial = @NombreComercial,
        CorreoElectronico = @CorreoElectronico,
        SitioWebURL = @SitioWebURL
    WHERE IdHospedaje = @IdHospedaje;
END
GO

CREATE OR ALTER PROCEDURE sp_EliminarHospedaje
    @IdHospedaje INT
AS
BEGIN
    DELETE FROM HospedajeTelefono WHERE IdHospedaje = @IdHospedaje;
    DELETE FROM HospedajeServicio WHERE IdHospedaje = @IdHospedaje;
    DELETE FROM HospedajeRedSocial WHERE IdHospedaje = @IdHospedaje;
    DELETE FROM Hospedaje WHERE IdHospedaje = @IdHospedaje;
END
GO

-- MÓDULO HABITACIONES
CREATE OR ALTER PROCEDURE sp_GestioHabitacion
    @Accion NVARCHAR(20),
    @IdHabitacion INT = NULL,
    @IdTipoHabitacion INT = NULL,
    @NumeroHabitacion NVARCHAR(20) = NULL,
    @Estado NVARCHAR(20) = NULL
AS
BEGIN
    IF @Accion = 'INSERTAR'
    BEGIN
        INSERT INTO Habitacion (IdTipoHabitacion, NumeroHabitacion, Estado)
        VALUES (@IdTipoHabitacion, @NumeroHabitacion, 'Activo');
    END
    ELSE IF @Accion = 'ACTUALIZAR_ESTADO'
    BEGIN
        UPDATE Habitacion
        SET Estado = @Estado
        WHERE IdHabitacion = @IdHabitacion;
    END
END
GO

-- MÓDULO CLIENTES
CREATE OR ALTER PROCEDURE sp_RegistrarCliente
    @Nombre NVARCHAR(100),
    @PrimerApellido NVARCHAR(100),
    @SegundoApellido NVARCHAR(100),
    @FechaNacimiento DATE,
    @TipoIdentificacion NVARCHAR(50),
    @NumeroIdentificacion NVARCHAR(50),
    @PaisResidencia NVARCHAR(100),
    @Email NVARCHAR(150)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Cliente WHERE NumeroIdentificacion = @NumeroIdentificacion)
    BEGIN
        RAISERROR('El cliente ya se encuentra registrado.', 16, 1);
        RETURN;
    END

    INSERT INTO Cliente (Nombre, PrimerApellido, SegundoApellido, FechaNacimiento, TipoIdentificacion, NumeroIdentificacion, PaisResidencia, CorreoElectronico)
    VALUES (@Nombre, @PrimerApellido, @SegundoApellido, @FechaNacimiento, @TipoIdentificacion, @NumeroIdentificacion, @PaisResidencia, @Email);
END
GO

CREATE OR ALTER PROCEDURE sp_ModificarCliente
    @IdCliente INT,
    @Email NVARCHAR(150),
    @PaisResidencia NVARCHAR(100),
    @Provincia NVARCHAR(50)
AS
BEGIN
    UPDATE Cliente
    SET CorreoElectronico = @Email,
        PaisResidencia = @PaisResidencia,
        Provincia = @Provincia
    WHERE IdCliente = @IdCliente;
END
GO

-- MÓDULO OPERACIONES
CREATE OR ALTER PROCEDURE sp_CrearReservacion
    @IdCliente INT,
    @IdHabitacion INT,
    @FechaIngreso DATETIME,
    @FechaSalida DATE,
    @CantPersonas INT
AS
BEGIN
    IF @FechaSalida <= CAST(@FechaIngreso AS DATE)
    BEGIN
        RAISERROR('Error de validación: La fecha de salida debe ser posterior al ingreso.', 16, 1);
        RETURN;
    END

    INSERT INTO Reservacion (IdCliente, IdHabitacion, FechaHoraIngreso, FechaSalida, CantidadPersonas)
    VALUES (@IdCliente, @IdHabitacion, @FechaIngreso, @FechaSalida, @CantPersonas);

    SELECT SCOPE_IDENTITY() AS IdReservaGenerada;
END
GO

CREATE OR ALTER PROCEDURE sp_GenerarFactura
    @IdReservacion INT,
    @MetodoPago NVARCHAR(50)
AS
BEGIN
    DECLARE @PrecioNoche DECIMAL(10,2);
    DECLARE @FechaIn DATETIME;
    DECLARE @FechaOut DATE;
    DECLARE @NumNoches INT;
    DECLARE @Total DECIMAL(18,2);

    SELECT 
        @PrecioNoche = th.PrecioPorNoche,
        @FechaIn = r.FechaHoraIngreso,
        @FechaOut = r.FechaSalida
    FROM Reservacion r
    INNER JOIN Habitacion h ON r.IdHabitacion = h.IdHabitacion
    INNER JOIN TipoHabitacion th ON h.IdTipoHabitacion = th.IdTipoHabitacion
    WHERE r.IdReservacion = @IdReservacion;

    SET @NumNoches = DATEDIFF(DAY, CAST(@FechaIn AS DATE), @FechaOut);
    IF @NumNoches < 1 SET @NumNoches = 1;

    SET @Total = @NumNoches * @PrecioNoche;

    INSERT INTO Factura (IdReservacion, MetodoPago, NumeroNoches, ImporteTotal)
    VALUES (@IdReservacion, @MetodoPago, @NumNoches, @Total);

    SELECT 'Factura generada exitosamente' AS Resultado, @Total AS MontoTotal;
END
GO