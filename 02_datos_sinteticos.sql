-- ============================================================
-- BASE DE DATOS: TELCOANDINA
-- TALLER I - INSERT DE DATOS SINTÉTICOS
-- ============================================================

-- 1. INSERTAR CLIENTES
INSERT INTO clientes (tipo_documento, numero_documento, nombre, email, direccion) VALUES
('CC', '1053800111', 'Jhosua Ruiz', 'jhosua.ruiz@telco.com', 'Carrera 23 #45-12, Manizales'),
('CC', '1053800222', 'Maria Gomez', 'maria.gomez@gmail.com', 'Calle 50 #12-30, Manizales'),
('NIT', '900123456', 'Tech Solutions SAS', 'contacto@techsolutions.co', 'Av. Santander #65-10, Manizales'),
('CC', '1053800333', 'Carlos Lopez', 'carlos.lopez@yahoo.com', 'Calle 12 #3-15, Pereira'),
('CC', '1053800444', 'Ana Martinez', 'ana.martinez@hotmail.com', 'Carrera 7 #20-40, Armenia');

-- 2. INSERTAR PLANES
INSERT INTO planes (nombre_plan, minutos_incluidos, gigas_incluidas, valor_mensual) VALUES
('Plan Basico Control', 300, 10.00, 35000.00),
('Plan Avanzado Ilimitado', 9999, 50.00, 65000.00),
('Plan Corporativo Premium', 9999, 100.00, 120000.00);

-- 3. INSERTAR LINEAS TELEFONICAS
INSERT INTO lineas_telefonicas (numero_telefono, id_cliente, id_plan, estado, saldo_pendiente) VALUES
('3101234567', 1, 2, 'ACTIVA', 0.00),
('3119876543', 2, 1, 'SUSPENDIDA', 150000.00),
('3124567890', 2, 1, 'SUSPENDIDA', 0.00),
('3150001122', 3, 3, 'ACTIVA', 0.00),
('3187778899', 4, 1, 'RETIRADA', 0.00);

-- 4. INSERTAR CARGOS PENDIENTES
INSERT INTO cargos (id_linea, tipo_cargo, monto, estado_facturacion) VALUES
(1, 'Consumo de Datos Adicionales', 15000.00, 'PENDIENTE'),
(1, 'Cargo Fijo Mensual Plan Avanzado', 65000.00, 'PENDIENTE'),
(2, 'Cargo Fijo Mensual Plan Basico', 35000.00, 'PENDIENTE'),
(4, 'Cargo Fijo Mensual Plan Corporativo', 120000.00, 'PENDIENTE'),
(4, 'Roaming Internacional', 45000.00, 'PENDIENTE');
