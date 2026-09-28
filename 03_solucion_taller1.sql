-- ============================================================
-- BASE DE DATOS: TELCOANDINA
-- TALLER I - SOLUCIÓN DE PROGRAMACIÓN (FUNCIONES, PROC, TRIGGERS Y CONTROL)
-- ============================================================

-- ------------------------------------------------------------
-- PUNTO 1: FUNCIONES (Función para calcular deuda total)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_calcular_deuda_total(p_id_cliente INT)
RETURNS NUMERIC(12,2) AS $$
DECLARE
    v_deuda_total NUMERIC(12,2) := 0.00;
BEGIN
    SELECT COALESCE(SUM(lt.saldo_pendiente), 0.00)
    INTO v_deuda_total
    FROM lineas_telefonicas lt
    WHERE lt.id_cliente = p_id_cliente;
    
    RETURN v_deuda_total;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de consumo Punto 1:
SELECT fn_calcular_deuda_total(2) AS deuda_cliente_2;


-- ------------------------------------------------------------
-- PUNTO 2: PROCEDIMIENTOS ALMACENADOS (Generar Factura Mensual)
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_generar_factura_mensual(p_id_linea INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_monto_total NUMERIC(12,2) := 0.00;
    v_id_factura INT;
    r_cargo RECORD;
BEGIN
    SELECT COALESCE(SUM(monto), 0.00)
    INTO v_monto_total
    FROM cargos
    WHERE id_linea = p_id_linea AND estado_facturacion = 'PENDIENTE';
    
    IF v_monto_total = 0 THEN
        RAISE NOTICE 'La linea % no tiene cargos pendientes por facturar.', p_id_linea;
        RETURN;
    END IF;
    
    INSERT INTO facturas (id_linea, fecha_emision, fecha_vencimiento, monto_total, estado_pago)
    VALUES (p_id_linea, CURRENT_DATE, CURRENT_DATE + INTERVAL '15 days', v_monto_total, 'PENDIENTE')
    RETURNING id_factura INTO v_id_factura;
    
    FOR r_cargo IN 
        SELECT id_cargo, monto 
        FROM cargos 
        WHERE id_linea = p_id_linea AND estado_facturacion = 'PENDIENTE'
    LOOP
        INSERT INTO detalle_factura (id_factura, id_cargo, subtotal)
        VALUES (v_id_factura, r_cargo.id_cargo, r_cargo.monto);
        
        UPDATE cargos
        SET estado_facturacion = 'FACTURADO'
        WHERE id_cargo = r_cargo.id_cargo;
    END LOOP;
    
    UPDATE lineas_telefonicas
    SET saldo_pendiente = saldo_pendiente + v_monto_total
    WHERE id_linea = p_id_linea;
    
    RAISE NOTICE 'Factura % generada exitosamente para la linea % por valor de %', v_id_factura, p_id_linea, v_monto_total;
END;
$$;

-- Ejemplo de consumo Punto 2:
CALL pr_generar_factura_mensual(1);


-- ------------------------------------------------------------
-- PUNTO 3: TRIGGERS (Auditoría de cambios de estado en líneas)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_trg_auditoria_estado_linea()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.estado IS DISTINCT FROM NEW.estado THEN
        INSERT INTO auditoria_lineas (id_linea, estado_anterior, estado_nuevo, fecha_cambio, usuario)
        VALUES (OLD.id_linea, OLD.estado, NEW.estado, CURRENT_TIMESTAMP, CURRENT_USER);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auditoria_estado_linea ON lineas_telefonicas;

CREATE TRIGGER trg_auditoria_estado_linea
AFTER UPDATE ON lineas_telefonicas
FOR EACH ROW
EXECUTE FUNCTION fn_trg_auditoria_estado_linea();

-- Ejemplo de consumo Punto 3:
UPDATE lineas_telefonicas SET estado = 'SUSPENDIDA' WHERE id_linea = 1;
SELECT * FROM auditoria_lineas;


-- ------------------------------------------------------------
-- PUNTO 4: ESTRUCTURAS DE CONTROL (Reactivación Automática de Línea)
-- ------------------------------------------------------------
DO $$
DECLARE
    v_id_linea INT := 3;
    v_estado VARCHAR(20);
    v_saldo NUMERIC(12,2);
BEGIN
    SELECT estado, saldo_pendiente
    INTO v_estado, v_saldo
    FROM lineas_telefonicas
    WHERE id_linea = v_id_linea;
    
    RAISE NOTICE 'Verificando reactivación para la línea %', v_id_linea;
    
    IF v_estado = 'SUSPENDIDA' AND v_saldo = 0.00 THEN
        UPDATE lineas_telefonicas
        SET estado = 'ACTIVA'
        WHERE id_linea = v_id_linea;
        
        RAISE NOTICE 'ÉXITO: La línea % ha sido reactivada automáticamente.', v_id_linea;
    ELSE
        RAISE NOTICE 'La línea % no cumple las condiciones para reactivación.', v_id_linea;
    END IF;
END $$;
