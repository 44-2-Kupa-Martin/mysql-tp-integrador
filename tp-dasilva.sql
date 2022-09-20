Ejercicio 
1c
--
DROP FUNCTION IF EXISTS calcular_suma_pagos_cliente;

DELIMITER //

CREATE FUNCTION calcular_suma_pagos_cliente(client_id INT)
RETURNS DECIMAL(65, 2) READS SQL DATA
BEGIN
    DECLARE result DECIMAL(65, 2);
    SELECT SUM(total) INTO result FROM pago WHERE codigo_cliente = client_id;
    RETURN result;
END//

DELIMITER ;
--
