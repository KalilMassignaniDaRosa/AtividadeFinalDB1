USE EmpresaTransporteAereo;

-- 1. Procedure para agendar um novo voo
DELIMITER //
CREATE PROCEDURE sp_agendar_voo(
    IN p_codigo_voo VARCHAR(10),
    IN p_id_aeronave INT,
    IN p_id_origem INT,
    IN p_id_destino INT,
    IN p_distancia_km DOUBLE,
    IN p_partida_prevista DATETIME,
    IN p_chegada_prevista DATETIME,
    OUT p_id_voo INT
)
BEGIN
    -- Verifica se a aeronave está disponível
    DECLARE aeronave_status VARCHAR(20);
    SELECT status INTO aeronave_status FROM Aeronave WHERE id_aeronave = p_id_aeronave;
    
    IF aeronave_status != 'Disponivel' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Aeronave não está disponível para voo';
    END IF;
    
    -- Insere o novo voo
    INSERT INTO Voo (
        id_aeronave, 
        codigo_voo, 
        id_origem, 
        id_destino, 
        distancia_km, 
        partida_prevista, 
        chegada_prevista,
        status
    ) VALUES (
        p_id_aeronave,
        p_codigo_voo,
        p_id_origem,
        p_id_destino,
        p_distancia_km,
        p_partida_prevista,
        p_chegada_prevista,
        'Agendado'
    );
    
    SET p_id_voo = LAST_INSERT_ID();
    
    -- Cria registros de PoltronaVoo para todas as poltronas da aeronave
    INSERT INTO PoltronaVoo (id_voo, id_poltrona, disponivel)
    SELECT p_id_voo, id_poltrona, TRUE
    FROM Poltrona
    WHERE id_aeronave = p_id_aeronave;
END //
DELIMITER ;

-- 2. Procedure para realizar check-in de passageiro
DELIMITER //
CREATE PROCEDURE sp_realizar_checkin(
    IN p_id_reserva INT,
    IN p_id_cliente INT,
    OUT p_sucesso BOOLEAN
)
BEGIN
    DECLARE v_status_reserva VARCHAR(20);
    
    -- Verifica status da reserva
    SELECT status INTO v_status_reserva FROM Reserva WHERE id_reserva = p_id_reserva;
    
    IF v_status_reserva != 'Confirmada' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Reserva não está confirmada para check-in';
    END IF;
    
    -- Atualiza status da reserva para CheckIn
    UPDATE Reserva SET status = 'CheckIn' WHERE id_reserva = p_id_reserva;
    
    SET p_sucesso = TRUE;
END //
DELIMITER ;

-- 3. Procedure para calcular combustível necessário para um voo
DELIMITER //
CREATE PROCEDURE sp_calcular_combustivel(
    IN p_id_voo INT,
    OUT p_combustivel_necesario DOUBLE,
    OUT p_combustivel_disponivel DOUBLE
)
BEGIN
    DECLARE v_distancia DOUBLE;
    DECLARE v_consumo DOUBLE;
    DECLARE v_capacidade_tanque DOUBLE;
    DECLARE v_id_aeronave INT;
    
    -- Obtém dados do voo e aeronave
    SELECT v.distancia_km, a.capacidade_tanque_litros, v.id_aeronave, ta.consumo_combustivel_km_litro
    INTO v_distancia, v_capacidade_tanque, v_id_aeronave, v_consumo
    FROM Voo v
    JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
    JOIN TipoAeronave ta ON a.id_tipo = ta.id_tipo
    WHERE v.id_voo = p_id_voo;
    
    -- Calcula combustível necessário (distância * consumo + 20% de reserva)
    SET p_combustivel_necesario = v_distancia * v_consumo * 1.2;
    
    -- Combustível já carregado
    SELECT combustivel_carregado_litros INTO p_combustivel_disponivel
    FROM Voo WHERE id_voo = p_id_voo;
END //
DELIMITER ;

-- 4. Procedure para atualizar categoria de fidelidade dos clientes
DELIMITER //
CREATE PROCEDURE sp_atualizar_categoria_fidelidade()
BEGIN
    -- Atualiza categorias baseado em milhas acumuladas
    UPDATE Cliente
    SET categoria_fidelidade = 
        CASE 
            WHEN milhas_acumuladas >= 100000 THEN 'Platinum'
            WHEN milhas_acumuladas >= 50000 THEN 'Gold'
            WHEN milhas_acumuladas >= 25000 THEN 'Silver'
            ELSE 'Basic'
        END;
END //
DELIMITER ;

-- 5. Procedure para cancelar um voo
DELIMITER //
CREATE PROCEDURE sp_cancelar_voo(
    IN p_id_voo INT,
    IN p_motivo TEXT
)
BEGIN
    DECLARE v_status_atual VARCHAR(50);
    
    -- Obtém status atual do voo
    SELECT status INTO v_status_atual FROM Voo WHERE id_voo = p_id_voo;
    
    -- Verifica se o voo pode ser cancelado
    IF v_status_atual = 'Cancelado' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Voo já está cancelado';
    END IF;
    
    IF v_status_atual = 'Aterrissado' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Voo já foi concluído e não pode ser cancelado';
    END IF;
    
    -- Atualiza status do voo
    UPDATE Voo 
    SET status = 'Cancelado', 
        status_anterior = v_status_atual
    WHERE id_voo = p_id_voo;
    
    -- Libera o portão se estiver ocupado
    UPDATE Portao p
    JOIN Voo v ON p.id_portao = v.id_portao_embarque
    SET p.status = 'Livre'
    WHERE v.id_voo = p_id_voo AND p.status = 'Ocupado';
    
    -- Atualiza status das reservas associadas
    UPDATE Reserva r
    JOIN AssentoReserva ar ON r.id_reserva = (
        SELECT pr.id_reserva 
        FROM PassageiroReserva pr 
        JOIN AssentoReserva ar ON pr.id_passageiro_reserva = ar.id_passageiro_reserva
        WHERE ar.id_voo = p_id_voo
        LIMIT 1
    )
    SET r.status = 'Cancelada';
    
    -- Registra o motivo no histórico
    INSERT INTO HistoricoStatusVoo (id_voo, status_anterior, status_novo, responsavel)
    VALUES (p_id_voo, v_status_atual, 'Cancelado', CONCAT('Sistema - Motivo: ', p_motivo));
END //
DELIMITER ;