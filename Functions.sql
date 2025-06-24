USE EmpresaTransporteAereo;

-- 1. Function para verificar disponibilidade de aeronave
DELIMITER //
CREATE FUNCTION fn_aeronave_disponivel(
    p_id_aeronave INT,
    p_data_inicio DATETIME,
    p_data_fim DATETIME
) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_count INT;
    
    -- Verifica se a aeronave está em manutenção
    SELECT COUNT(*) INTO v_count
    FROM Aeronave
    WHERE id_aeronave = p_id_aeronave AND status != 'Disponivel';
    
    IF v_count > 0 THEN
        RETURN FALSE;
    END IF;
    
    -- Verifica se a aeronave já tem voos agendados no período
    SELECT COUNT(*) INTO v_count
    FROM Voo
    WHERE id_aeronave = p_id_aeronave
    AND (
        (partida_prevista BETWEEN p_data_inicio AND p_data_fim)
        OR (chegada_prevista BETWEEN p_data_inicio AND p_data_fim)
        OR (partida_prevista <= p_data_inicio AND chegada_prevista >= p_data_fim)
    ) AND status NOT IN ('Cancelado', 'Aterrissado');
    
    RETURN v_count = 0;
END //
DELIMITER ;

-- 2. Function para calcular valor base de uma passagem
DELIMITER //
CREATE FUNCTION fn_calcular_valor_passagem(
    p_id_voo INT,
    p_classe VARCHAR(20)
) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_distancia DOUBLE;
    DECLARE v_valor_base DECIMAL(10,2);
    DECLARE v_fator_classe DECIMAL(3,2);
    
    -- Obtém a distância do voo
    SELECT distancia_km INTO v_distancia FROM Voo WHERE id_voo = p_id_voo;
    
    -- Define fator de classe
    SET v_fator_classe = 
        CASE p_classe
            WHEN 'Economica' THEN 1.0
            WHEN 'Executiva' THEN 1.8
            WHEN 'Primeira' THEN 3.0
            WHEN 'Luxo' THEN 5.0
            ELSE 1.0
        END;
    
    -- Calcula valor base (R$ 0.50 por km * fator de classe)
    SET v_valor_base = v_distancia * 0.50 * v_fator_classe;
    
    RETURN v_valor_base;
END //
DELIMITER ;

-- 3. Function para verificar se passageiro é menor de idade
DELIMITER //
CREATE FUNCTION fn_passageiro_menor_idade(
    p_id_cliente INT
) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_data_nascimento DATE;
    DECLARE v_idade INT;
    
    -- Obtém data de nascimento do cliente
    SELECT data_nascimento INTO v_data_nascimento
    FROM Cliente
    WHERE id_cliente = p_id_cliente;
    
    -- Calcula idade
    SET v_idade = TIMESTAMPDIFF(YEAR, v_data_nascimento, CURDATE());
    
    RETURN v_idade < 18;
END //
DELIMITER ;

-- 4. Function para obter próximo voo de um cliente
DELIMITER //
CREATE FUNCTION fn_proximo_voo_cliente(
    p_id_cliente INT
) RETURNS VARCHAR(100)
READS SQL DATA
BEGIN
    DECLARE v_result VARCHAR(100);
    
    SELECT CONCAT('Voo ', v.codigo_voo, ' de ', a1.nome, ' para ', a2.nome, 
                 ' em ', DATE_FORMAT(v.partida_prevista, '%d/%m/%Y %H:%i'))
    INTO v_result
    FROM Voo v
    JOIN AssentoReserva ar ON v.id_voo = ar.id_voo
    JOIN PassageiroReserva pr ON ar.id_passageiro_reserva = pr.id_passageiro_reserva
    JOIN Reserva r ON pr.id_reserva = r.id_reserva
    JOIN Aeroporto a1 ON v.id_origem = a1.id_aeroporto
    JOIN Aeroporto a2 ON v.id_destino = a2.id_aeroporto
    WHERE r.id_cliente = p_id_cliente
    AND v.status IN ('Agendado', 'Embarque', 'Atrasado')
    AND v.partida_prevista > NOW()
    ORDER BY v.partida_prevista ASC
    LIMIT 1;
    
    RETURN IFNULL(v_result, 'Nenhum voo agendado');
END //
DELIMITER ;