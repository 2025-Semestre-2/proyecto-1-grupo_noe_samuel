/*
 * NOMBRE DEL SCRIPT: DDL_GestionHotelera.sql
 * DESCRIPCIÓN: Script DDL (Data Definition Language) para la creación del esquema
 * de base de datos del proyecto de Gestión Hotelera y Recreación.
 * MOTOR DE BASE DE DATOS: Microsoft SQL Server 2022
 */

-- ==========================================================================================
-- 1. CREACIÓN DEL CONTENEDOR DE BASE DE DATOS
-- ==========================================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'GestionHoteleraDB')
BEGIN
    CREATE DATABASE GestionHoteleraDB;
END
GO

USE GestionHoteleraDB;
GO

-- ==========================================================================================
-- 2. MÓDULO DE GESTIÓN DE HOSPEDAJES (PROVEEDORES)
-- ==========================================================================================

/*
 * TABLA: Hospedaje
 * DESCRIPCIÓN: Entidad fuerte que almacena la información corporativa y de ubicación
 * de los establecimientos de hospedaje.
 */
CREATE TABLE Hospedaje (
    IdHospedaje INT IDENTITY(1,1),
    NombreComercial NVARCHAR(150) NOT NULL,
    CedulaJuridica NVARCHAR(20) NOT NULL,
    TipoHospedaje NVARCHAR(50) NOT NULL,
    Provincia NVARCHAR(50) NOT NULL,
    Canton NVARCHAR(50) NOT NULL,
    Distrito NVARCHAR(50) NOT NULL,
    Barrio NVARCHAR(50),
    SenasExactas NVARCHAR(255),
    ReferenciaGPS NVARCHAR(100),
    CorreoElectronico NVARCHAR(100) NOT NULL,
    SitioWebURL NVARCHAR(255),
    
    CONSTRAINT PK_Hospedaje PRIMARY KEY (IdHospedaje),
    CONSTRAINT UQ_Hospedaje_Cedula UNIQUE (CedulaJuridica),
    CONSTRAINT CK_Hospedaje_Tipo CHECK (TipoHospedaje IN ('Hotel', 'Hostal', 'Casa', 'Departamento', 'Cuarto compartido', 'Cabaña'))
);

/*
 * TABLA: HospedajeTelefono
 * DESCRIPCIÓN: Entidad débil para normalizar la relación 1:N de números telefónicos.
 * Permite registrar múltiples contactos por hotel.
 */
CREATE TABLE HospedajeTelefono (
    IdTelefono INT IDENTITY(1,1),
    IdHospedaje INT NOT NULL,
    NumeroTelefono NVARCHAR(20) NOT NULL,
    CodigoPais NVARCHAR(5) DEFAULT '+506',
    
    CONSTRAINT PK_HospedajeTelefono PRIMARY KEY (IdTelefono),
    CONSTRAINT FK_HospedajeTelefono_Hospedaje FOREIGN KEY (IdHospedaje) REFERENCES Hospedaje(IdHospedaje)
);

/*
 * TABLA: HospedajeRedSocial
 * DESCRIPCIÓN: Almacena los enlaces a plataformas digitales del establecimiento.
 */
CREATE TABLE HospedajeRedSocial (
    IdRedSocial INT IDENTITY(1,1),
    IdHospedaje INT NOT NULL,
    NombrePlataforma NVARCHAR(50) NOT NULL,
    EnlaceURL NVARCHAR(255) NOT NULL,
    
    CONSTRAINT PK_HospedajeRedSocial PRIMARY KEY (IdRedSocial),
    CONSTRAINT FK_HospedajeRedSocial_Hospedaje FOREIGN KEY (IdHospedaje) REFERENCES Hospedaje(IdHospedaje),
    CONSTRAINT CK_RedSocial_Plataforma CHECK (NombrePlataforma IN ('Facebook', 'Instagram', 'Youtube', 'Tiktok', 'Airbnb', 'Threads', 'X'))
);

/*
 * TABLA: HospedajeServicio
 * DESCRIPCIÓN: Catálogo de amenidades generales ofrecidas por el hotel.
 */
CREATE TABLE HospedajeServicio (
    IdServicio INT IDENTITY(1,1),
    IdHospedaje INT NOT NULL,
    NombreServicio NVARCHAR(100) NOT NULL,
    
    CONSTRAINT PK_HospedajeServicio PRIMARY KEY (IdServicio),
    CONSTRAINT FK_HospedajeServicio_Hospedaje FOREIGN KEY (IdHospedaje) REFERENCES Hospedaje(IdHospedaje)
);

-- ==========================================================================================
-- 3. MÓDULO DE GESTIÓN DE HABITACIONES (INVENTARIO)
-- ==========================================================================================

/*
 * TABLA: TipoHabitacion
 * DESCRIPCIÓN: Define las categorías o clases de habitaciones disponibles, actuando como
 * plantilla para las unidades físicas.
 */
CREATE TABLE TipoHabitacion (
    IdTipoHabitacion INT IDENTITY(1,1),
    IdHospedaje INT NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(MAX),
    TipoCama NVARCHAR(50) NOT NULL,
    PrecioPorNoche DECIMAL(10, 2) NOT NULL,
    
    CONSTRAINT PK_TipoHabitacion PRIMARY KEY (IdTipoHabitacion),
    CONSTRAINT FK_TipoHabitacion_Hospedaje FOREIGN KEY (IdHospedaje) REFERENCES Hospedaje(IdHospedaje),
    CONSTRAINT CK_TipoHabitacion_Cama CHECK (TipoCama IN ('Individual', 'Queen', 'King'))
);

/*
 * TABLA: HabitacionComodidad
 * DESCRIPCIÓN: Lista detallada de equipamiento específico por tipo de habitación.
 */
CREATE TABLE HabitacionComodidad (
    IdComodidad INT IDENTITY(1,1),
    IdTipoHabitacion INT NOT NULL,
    Descripcion NVARCHAR(100) NOT NULL,
    
    CONSTRAINT PK_HabitacionComodidad PRIMARY KEY (IdComodidad),
    CONSTRAINT FK_HabitacionComodidad_Tipo FOREIGN KEY (IdTipoHabitacion) REFERENCES TipoHabitacion(IdTipoHabitacion)
);

/*
 * TABLA: HabitacionFoto
 * DESCRIPCIÓN: Almacena las rutas o referencias a las imágenes de los tipos de habitación.
 */
CREATE TABLE HabitacionFoto (
    IdFoto INT IDENTITY(1,1),
    IdTipoHabitacion INT NOT NULL,
    UrlFoto NVARCHAR(MAX) NOT NULL,
    
    CONSTRAINT PK_HabitacionFoto PRIMARY KEY (IdFoto),
    CONSTRAINT FK_HabitacionFoto_Tipo FOREIGN KEY (IdTipoHabitacion) REFERENCES TipoHabitacion(IdTipoHabitacion)
);

/*
 * TABLA: Habitacion
 * DESCRIPCIÓN: Representa la unidad física (inventario) disponible para reservación.
 */
CREATE TABLE Habitacion (
    IdHabitacion INT IDENTITY(1,1),
    IdTipoHabitacion INT NOT NULL,
    NumeroHabitacion NVARCHAR(20) NOT NULL,
    Estado NVARCHAR(20) DEFAULT 'Activo',
    
    CONSTRAINT PK_Habitacion PRIMARY KEY (IdHabitacion),
    CONSTRAINT FK_Habitacion_Tipo FOREIGN KEY (IdTipoHabitacion) REFERENCES TipoHabitacion(IdTipoHabitacion),
    CONSTRAINT CK_Habitacion_Estado CHECK (Estado IN ('Activo', 'Inactivo'))
);

-- ==========================================================================================
-- 4. MÓDULO DE GESTIÓN DE CLIENTES
-- ==========================================================================================

/*
 * TABLA: Cliente
 * DESCRIPCIÓN: Almacena los datos personales y demográficos de los huéspedes.
 */
CREATE TABLE Cliente (
    IdCliente INT IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    PrimerApellido NVARCHAR(100) NOT NULL,
    SegundoApellido NVARCHAR(100),
    FechaNacimiento DATE NOT NULL,
    TipoIdentificacion NVARCHAR(50) NOT NULL,
    NumeroIdentificacion NVARCHAR(50) NOT NULL,
    PaisResidencia NVARCHAR(100) NOT NULL,
    Provincia NVARCHAR(50),
    Canton NVARCHAR(50),
    Distrito NVARCHAR(50),
    CorreoElectronico NVARCHAR(150) NOT NULL,
    
    CONSTRAINT PK_Cliente PRIMARY KEY (IdCliente),
    CONSTRAINT UQ_Cliente_Identificacion UNIQUE (NumeroIdentificacion),
    CONSTRAINT CK_Cliente_TipoId CHECK (TipoIdentificacion IN ('Pasaporte', 'DIMEX', 'Cedula Nacional', 'Otro'))
);

/*
 * TABLA: ClienteTelefono
 * DESCRIPCIÓN: Permite el registro de múltiples números de contacto por cliente.
 */
CREATE TABLE ClienteTelefono (
    IdTelefonoCliente INT IDENTITY(1,1),
    IdCliente INT NOT NULL,
    NumeroTelefono NVARCHAR(20) NOT NULL,
    CodigoPais NVARCHAR(5) DEFAULT '+506',
    
    CONSTRAINT PK_ClienteTelefono PRIMARY KEY (IdTelefonoCliente),
    CONSTRAINT FK_ClienteTelefono_Cliente FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
);

-- ==========================================================================================
-- 5. MÓDULO DE OPERACIONES (RESERVAS Y FACTURACIÓN)
-- ==========================================================================================

/*
 * TABLA: Reservacion
 * DESCRIPCIÓN: Entidad transaccional que vincula un cliente con una habitación en un periodo determinado.
 */
CREATE TABLE Reservacion (
    IdReservacion INT IDENTITY(1,1),
    IdCliente INT NOT NULL,
    IdHabitacion INT NOT NULL,
    FechaHoraIngreso DATETIME NOT NULL,
    FechaSalida DATE NOT NULL,
    CantidadPersonas INT NOT NULL DEFAULT 1,
    PoseeVehiculo BIT NOT NULL DEFAULT 0,
    
    CONSTRAINT PK_Reservacion PRIMARY KEY (IdReservacion),
    CONSTRAINT FK_Reservacion_Cliente FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente),
    CONSTRAINT FK_Reservacion_Habitacion FOREIGN KEY (IdHabitacion) REFERENCES Habitacion(IdHabitacion)
);

/*
 * TABLA: Factura
 * DESCRIPCIÓN: Registro fiscal de la transacción generada a partir de una reserva.
 */
CREATE TABLE Factura (
    IdFactura INT IDENTITY(1,1),
    IdReservacion INT NOT NULL,
    FechaEmision DATETIME NOT NULL DEFAULT GETDATE(),
    MetodoPago NVARCHAR(50) NOT NULL,
    NumeroNoches INT NOT NULL,
    ImporteTotal DECIMAL(18, 2) NOT NULL,
    
    CONSTRAINT PK_Factura PRIMARY KEY (IdFactura),
    CONSTRAINT UQ_Factura_Reservacion UNIQUE (IdReservacion),
    CONSTRAINT FK_Factura_Reservacion FOREIGN KEY (IdReservacion) REFERENCES Reservacion(IdReservacion),
    CONSTRAINT CK_Factura_Pago CHECK (MetodoPago IN ('Efectivo', 'Tarjeta de Credito'))
);

-- ==========================================================================================
-- 6. MÓDULO DE GESTIÓN DE RECREACIÓN (TURISMO)
-- ==========================================================================================

/*
 * TABLA: EmpresaRecreacion
 * DESCRIPCIÓN: Entidad independiente para proveedores de servicios turísticos.
 */
CREATE TABLE EmpresaRecreacion (
    IdEmpresaRecreacion INT IDENTITY(1,1),
    NombreEmpresa NVARCHAR(150) NOT NULL,
    CedulaJuridica NVARCHAR(50) NOT NULL,
    CorreoElectronico NVARCHAR(100) NOT NULL,
    Telefono NVARCHAR(20) NOT NULL,
    NombreContacto NVARCHAR(100) NOT NULL,
    Provincia NVARCHAR(50) NOT NULL,
    Canton NVARCHAR(50) NOT NULL,
    Distrito NVARCHAR(50) NOT NULL,
    SenasExactas NVARCHAR(255),
    
    CONSTRAINT PK_EmpresaRecreacion PRIMARY KEY (IdEmpresaRecreacion),
    CONSTRAINT UQ_EmpresaRecreacion_Cedula UNIQUE (CedulaJuridica)
);

/*
 * TABLA: ActividadRecreativa
 * DESCRIPCIÓN: Catálogo de servicios ofrecidos por las empresas de recreación.
 */
CREATE TABLE ActividadRecreativa (
    IdActividad INT IDENTITY(1,1),
    IdEmpresaRecreacion INT NOT NULL,
    TipoActividad NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(MAX),
    Precio DECIMAL(10, 2) NOT NULL,
    
    CONSTRAINT PK_ActividadRecreativa PRIMARY KEY (IdActividad),
    CONSTRAINT FK_ActividadRecreativa_Empresa FOREIGN KEY (IdEmpresaRecreacion) REFERENCES EmpresaRecreacion(IdEmpresaRecreacion)
);
GO