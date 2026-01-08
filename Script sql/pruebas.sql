/*
 * NOMBRE DEL SCRIPT: pruebas.sql
 * CONSULTA DE VERIFICACIÓN INTEGRAL
 * DESCRIPCIÓN: Listado general de todas las tablas para validar persistencia de datos.
*/

USE GestionHoteleraDB;
GO

PRINT '--- TABLA: HOSPEDAJE ---'
SELECT IdHospedaje, NombreComercial, CedulaJuridica, TipoHospedaje FROM Hospedaje;

PRINT '--- TABLA: DETALLES DE HOSPEDAJE (TEL/SERV) ---'
SELECT * FROM HospedajeTelefono;
SELECT * FROM HospedajeServicio;

PRINT '--- TABLA: TIPOS DE HABITACIÓN ---'
SELECT IdTipoHabitacion, Nombre, PrecioPorNoche FROM TipoHabitacion;

PRINT '--- TABLA: HABITACIONES (INVENTARIO) ---'
SELECT * FROM Habitacion;

PRINT '--- TABLA: CLIENTES ---'
SELECT IdCliente, Nombre, PrimerApellido, PaisResidencia FROM Cliente;

PRINT '--- TABLA: RESERVACIONES ---'
SELECT * FROM Reservacion;

PRINT '--- TABLA: FACTURAS ---'
SELECT * FROM Factura;

PRINT '--- TABLA: RECREACIÓN ---'
SELECT * FROM EmpresaRecreacion;
SELECT * FROM ActividadRecreativa;
GO