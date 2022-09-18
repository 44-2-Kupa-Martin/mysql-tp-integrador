
-- Ej 1a
DROP FUNCTION IF EXISTS calcular_precio_total_pedido;

DELIMITER $$

CREATE FUNCTION calcular_precio_total_pedido(order_id INT)
RETURNS DECIMAL(65, 2) READS SQL DATA
BEGIN
    DECLARE result DECIMAL(65, 2);
    SELECT SUM(cantidad*precio_unidad) INTO result FROM detalle_pedido WHERE codigo_pedido = order_id;
    RETURN result;
END$$

DELIMITER ;

-- Ej 1b

DROP FUNCTION IF EXISTS calcular_suma_pedidos_cliente;

DELIMITER $$

CREATE FUNCTION calcular_suma_pedidos_cliente(client_id INT)
RETURNS DECIMAL(65, 2) READS SQL DATA
BEGIN
    DECLARE result DECIMAL(65, 2);
    SELECT SUM(calcular_precio_total_pedido(codigo_pedido)) INTO result FROM pedido WHERE codigo_cliente = client_id;
    RETURN result;
END$$

DELIMITER ;

--Ej 1d

DROP PROCEDURE IF EXISTS calcular_pagos_pendientes;

DELIMITER $$

CREATE PROCEDURE calcular_pagos_pendientes()
main:BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE client_id INT;
    DECLARE totaDebt DECIMAL(65, 2);
    DECLARE hasPaid DECIMAL(65, 2);
    DECLARE pendingDebt DECIMAL(65, 2);
    DECLARE cur_parseClients CURSOR FOR 
        SELECT codigo_cliente FROM cliente;
    DECLARE CONTINUE HANDLER FOR NOT FOUND 
        SET done= TRUE;

    OPEN cur_parseClients;

    forEach_client: LOOP
        FETCH cur_parseClients INTO client_id;
        IF done THEN
            LEAVE forEach_client;
        END IF;
        SET totaDebt= calcular_suma_pedidos_cliente(client_id);
        SET hasPaid= calcular_suma_pagos_cliente(client_id);
        SET pendingDebt= totaDebt - hasPaid;
        IF pendingDebt > 0 THEN
            INSERT INTO clientes_con_pagos_pendientes (
                id_cliente, 
                suma_total_pedidos, 
                suma_total_pagos, 
                pendiente_de_pago
            ) VALUES (
                client_id,
                totaDebt,
                hasPaid,
                pendingDebt
            );
        END IF;
    END LOOP;

    CLOSE cur_parseClients;
END main$$

DELIMITER ;

-- Ej 4

DROP FUNCTION IF EXISTS cantidad_total_de_productos_vendidos;

DELIMITER $$

CREATE FUNCTION cantidad_total_de_productos_vendidos(product_id VARCHAR(15))
RETURNS INT READS SQL DATA
BEGIN
    DECLARE result INT;
    SELECT SUM(cantidad) INTO result FROM detalle_pedido WHERE codigo_producto LIKE product_id;
    RETURN result;
END$$

DELIMITER ;
