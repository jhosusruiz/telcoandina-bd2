-- ============================================================
-- BASE DE DATOS: TELCOANDINA
-- TALLER I - ESTRUCTURA Y TABLAS DE LA BASE DE DATOS
-- ============================================================

-- Eliminar tablas si existen (para ejecución limpia)
DROP TABLE IF EXISTS detalle_factura CASCADE;
DROP TABLE IF EXISTS facturas CASCADE;
DROP TABLE IF EXISTS cargos CASCADE;
DROP TABLE IF EXISTS auditoria_lineas CASCADE;
DROP TABLE IF EXISTS lineas_telefonicas CASCADE;
DROP TABLE IF EXISTS planes CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

-- 1. TABLA CLIENTES
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    tipo_documento VARCHAR(10) NOT NULL,
    numero_documento VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    direccion TEXT,
    fecha_registro DATE DEFAULT CURRENT_DATE
);

-- 2. TABLA PLANES
CREATE TABLE planes (
    id_plan SERIAL PRIMARY KEY,
    nombre_plan VARCHAR(50) NOT NULL,
    minutos_incluidos INT NOT NULL,
    gigas_incluidas NUMERIC(8,2) NOT NULL,
    valor_mensual NUMERIC(12,2) NOT NULL
);

-- 3. TABLA LINEAS TELEFONICAS
CREATE TABLE lineas_telefonicas (
    id_linea SERIAL PRIMARY KEY,
    numero_telefono VARCHAR(15) UNIQUE NOT NULL,
    id_cliente INT NOT NULL REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    id_plan INT NOT NULL REFERENCES planes(id_plan),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA', 'SUSPENDIDA', 'RETIRADA')),
    fecha_activacion DATE DEFAULT CURRENT_DATE,
    saldo_pendiente NUMERIC(12,2) DEFAULT 0.00
);

-- 4. TABLA AUDITORIA LINEAS
CREATE TABLE auditoria_lineas (
    id_auditoria SERIAL PRIMARY KEY,
    id_linea INT NOT NULL,
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(50) DEFAULT CURRENT_USER
);

-- 5. TABLA CARGOS
CREATE TABLE cargos (
    id_cargo SERIAL PRIMARY KEY,
    id_linea INT NOT NULL REFERENCES lineas_telefonicas(id_linea) ON DELETE CASCADE,
    tipo_cargo VARCHAR(50) NOT NULL,
    monto NUMERIC(12,2) NOT NULL,
    fecha_cargo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_facturacion VARCHAR(20) DEFAULT 'PENDIENTE' CHECK (estado_facturacion IN ('PENDIENTE', 'FACTURADO'))
);

-- 6. TABLA FACTURAS
CREATE TABLE facturas (
    id_factura SERIAL PRIMARY KEY,
    id_linea INT NOT NULL REFERENCES lineas_telefonicas(id_linea) ON DELETE CASCADE,
    fecha_emision DATE DEFAULT CURRENT_DATE,
    fecha_vencimiento DATE NOT NULL,
    monto_total NUMERIC(12,2) DEFAULT 0.00,
    estado_pago VARCHAR(20) DEFAULT 'PENDIENTE' CHECK (estado_pago IN ('PENDIENTE', 'PAGADA', 'MORA'))
);

-- 7. TABLA DETALLE FACTURA
CREATE TABLE detalle_factura (
    id_detalle SERIAL PRIMARY KEY,
    id_factura INT NOT NULL REFERENCES facturas(id_factura) ON DELETE CASCADE,
    id_cargo INT NOT NULL REFERENCES cargos(id_cargo),
    subtotal NUMERIC(12,2) NOT NULL
);
