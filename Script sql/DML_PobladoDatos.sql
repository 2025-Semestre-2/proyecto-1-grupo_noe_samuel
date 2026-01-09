/*
 * NOMBRE DEL SCRIPT: DML_PobladoDatos.sql
 * DESCRIPCIÓN: Script DML y alineado con los requisitos
 */

USE GestionHoteleraDB;
GO

-- ==========================================================================================
-- 1. LIMPIEZA
-- ==========================================================================================
DELETE FROM Factura;
DELETE FROM Reservacion;
DELETE FROM ClienteTelefono;
DELETE FROM Cliente;
DELETE FROM Habitacion;
DELETE FROM HabitacionComodidad;
DELETE FROM HabitacionFoto;
DELETE FROM TipoHabitacion;
DELETE FROM HospedajeServicio;
DELETE FROM HospedajeRedSocial;
DELETE FROM HospedajeTelefono;
DELETE FROM Hospedaje;
DELETE FROM ActividadRecreativa;
DELETE FROM EmpresaRecreacion;

DBCC CHECKIDENT ('Hospedaje', RESEED, 0);
DBCC CHECKIDENT ('Cliente', RESEED, 0);
DBCC CHECKIDENT ('EmpresaRecreacion', RESEED, 0);
GO

-- ==========================================================================================
-- 2. HOSPEDAJE
-- ==========================================================================================
PRINT '>>> Cargando Hospedaje...'
INSERT INTO Hospedaje (NombreComercial, CedulaJuridica, TipoHospedaje, Provincia, Canton, Distrito, SenasExactas, CorreoElectronico)
VALUES ('Hotel Caribe Sur', '3-101-123456', 'Hotel', 'Limón', 'Talamanca', 'Cahuita', 'Frente a Playa Negra, 200m Sur', 'reservas@caribesur.cr');

DECLARE @IdHotel INT = SCOPE_IDENTITY();

INSERT INTO HospedajeTelefono (IdHospedaje, NumeroTelefono) VALUES (@IdHotel, '2750-0001');
INSERT INTO HospedajeTelefono (IdHospedaje, NumeroTelefono) VALUES (@IdHotel, '8899-5566');
INSERT INTO HospedajeServicio (IdHospedaje, NombreServicio) VALUES (@IdHotel, 'Piscina'), (@IdHotel, 'Wifi'), (@IdHotel, 'Desayuno');

-- ==========================================================================================
-- 3. HABITACIONES
-- ==========================================================================================
PRINT '>>> Cargando Habitaciones...'
INSERT INTO TipoHabitacion (IdHospedaje, Nombre, Descripcion, TipoCama, PrecioPorNoche)
VALUES 
(@IdHotel, 'Suite Vista Mar', 'Vista al mar Caribe', 'King', 120.00),
(@IdHotel, 'Estándar Jardín', 'Acceso a zonas verdes', 'Queen', 75.00);

DECLARE @IdTipoSuite INT = (SELECT IdTipoHabitacion FROM TipoHabitacion WHERE Nombre = 'Suite Vista Mar');
DECLARE @IdTipoStd INT = (SELECT IdTipoHabitacion FROM TipoHabitacion WHERE Nombre = 'Estándar Jardín');

INSERT INTO Habitacion (IdTipoHabitacion, NumeroHabitacion, Estado)
VALUES (@IdTipoSuite, '101', 'Activo'), (@IdTipoSuite, '102', 'Activo'), (@IdTipoStd, '201', 'Activo'), (@IdTipoStd, '202', 'Inactivo');

-- ==========================================================================================
-- 4. CLIENTES
-- ==========================================================================================
PRINT '>>> Cargando Clientes...'
INSERT INTO Cliente (Nombre, PrimerApellido, SegundoApellido, FechaNacimiento, TipoIdentificacion, NumeroIdentificacion, PaisResidencia, CorreoElectronico)
VALUES ('Juan', 'Pérez', 'Rodríguez', '1990-05-15', 'Cedula Nacional', '1-1111-1111', 'Costa Rica', 'juan.perez@email.com');

INSERT INTO Cliente (Nombre, PrimerApellido, SegundoApellido, FechaNacimiento, TipoIdentificacion, NumeroIdentificacion, PaisResidencia, CorreoElectronico)
VALUES ('Sarah', 'Connor', 'Smith', '1985-08-20', 'Pasaporte', 'P-987654321', 'Estados Unidos', 'sarah.c@email.com');

-- ==========================================================================================
-- 5. RECREACIÓN
-- ==========================================================================================
PRINT '>>> Cargando Recreación...'

INSERT INTO EmpresaRecreacion (NombreEmpresa, CedulaJuridica, NombreContacto, Telefono, CorreoElectronico, Provincia, Canton, Distrito, SenasExactas)
VALUES ('Tours Tortuguero S.A.', '3-102-654321', 'María González', '2799-1234', 'info@tourstortuguero.com', 'Limón', 'Pococí', 'Colorado', 'Muelle principal de Moín');

DECLARE @IdEmpresaRec INT = SCOPE_IDENTITY();

INSERT INTO ActividadRecreativa (IdEmpresaRecreacion, TipoActividad, Descripcion, Precio)
VALUES 
(@IdEmpresaRec, 'Tour en Bote', 'Recorrido de 2 horas', 35.00),
(@IdEmpresaRec, 'Kayak Aventura', 'Alquiler por 3 horas', 25.00);

PRINT '>>> Carga finalizada.'
GO