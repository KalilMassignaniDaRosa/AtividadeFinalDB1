USE EmpresaTransporteAereo;

-- Functions
DELIMITER //
-- 1. Verificar disponibilidade de aeronave
DROP FUNCTION IF EXISTS fn_aeronave_disponivel//
CREATE FUNCTION fn_aeronave_disponivel(
    p_id_aeronave INT,
    p_data_inicio DATETIME,
    p_data_fim DATETIME
) RETURNS TINYINT(1)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;
    
    -- Verifica se a aeronave está em manutenção
    SELECT COUNT(*) INTO v_count
      FROM Aeronave
     WHERE id_aeronave = p_id_aeronave
       AND status <> 'Disponivel';
    IF v_count > 0 THEN
        RETURN 0;
    END IF;
    
    -- Verifica se a aeronave já tem voos agendados no período
    SELECT COUNT(*) INTO v_count
      FROM Voo
     WHERE id_aeronave = p_id_aeronave
       AND status NOT IN ('Cancelado','Aterrissado')
       AND (
            (partida_prevista BETWEEN p_data_inicio AND p_data_fim)
         OR (chegada_prevista BETWEEN p_data_inicio AND p_data_fim)
         OR (partida_prevista <= p_data_inicio AND chegada_prevista >= p_data_fim)
       );
    
    RETURN IF(v_count = 0, 1, 0);
END//

-- 2. Calcular valor base de uma passagem
DROP FUNCTION IF EXISTS fn_calcular_valor_passagem//
CREATE FUNCTION fn_calcular_valor_passagem(
    p_id_voo INT,
    p_classe ENUM('Economica','Executiva','Primeira','Luxo')
) RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_distancia DOUBLE;
    DECLARE v_fator DECIMAL(3,2);
    
    -- Obtém a distância do voo
    SELECT distancia_km INTO v_distancia
      FROM Voo
     WHERE id_voo = p_id_voo;
    
    -- Define fator de classe
    SET v_fator = CASE p_classe
        WHEN 'Economica' THEN 1.00
        WHEN 'Executiva' THEN 1.80
        WHEN 'Primeira' THEN 3.00
        WHEN 'Luxo' THEN 5.00
        ELSE 1.00
    END;
    
    -- Calcula valor base (R$ 0.50 por km * fator de classe)
    RETURN ROUND(v_distancia * 0.50 * v_fator, 2);
END//

-- 3. Verificar se passageiro é menor de idade
DROP FUNCTION IF EXISTS fn_passageiro_menor_idade//
CREATE FUNCTION fn_passageiro_menor_idade(
    p_id_cliente INT
) RETURNS TINYINT(1)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_data_nascimento DATE;
    DECLARE v_idade INT;
    
    -- Obtém data de nascimento do cliente
    SELECT p.data_nascimento INTO v_data_nascimento
      FROM Cliente c
      JOIN Pessoa p ON c.id_pessoa = p.id_pessoa
     WHERE c.id_cliente = p_id_cliente;
    
    -- Calcula idade
    SET v_idade = TIMESTAMPDIFF(YEAR, v_data_nascimento, CURDATE());
    
    RETURN IF(v_idade < 18, 1, 0);
END//

-- 4. Obter próximo voo de um cliente
DROP FUNCTION IF EXISTS fn_proximo_voo_cliente//
CREATE FUNCTION fn_proximo_voo_cliente(
    p_id_cliente INT
) RETURNS VARCHAR(255)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_result VARCHAR(255);
    
    SELECT CONCAT(
             'Voo ', v.codigo_voo,
             ' de ', a1.nome,
             ' para ', a2.nome,
             ' em ', DATE_FORMAT(v.partida_prevista,'%d/%m/%Y %H:%i')
           )
      INTO v_result
      FROM Voo v
      JOIN AssentoReserva ar ON v.id_voo = ar.id_voo
      JOIN PassageiroReserva pr ON ar.id_passageiro_reserva = pr.id_passageiro_reserva
      JOIN Reserva r ON pr.id_reserva = r.id_reserva
      JOIN Aeroporto a1 ON v.id_origem = a1.id_aeroporto
      JOIN Aeroporto a2 ON v.id_destino = a2.id_aeroporto
     WHERE r.id_cliente = p_id_cliente
       AND v.status IN ('Agendado','Embarque','Atrasado')
       AND v.partida_prevista > NOW()
     ORDER BY v.partida_prevista
     LIMIT 1;
    
    RETURN COALESCE(v_result, 'Nenhum voo agendado');
END//
DELIMITER ;

-- Procedures
-- 1. Agendar um novo voo
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

-- 2. Realizar check-in de passageiro
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

-- 3. Calcular combustível necessário para um voo
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

-- 4. Atualizar categoria de fidelidade dos clientes
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

-- Triggers
-- 1. Atualizar status do portão quando um voo é associado
DELIMITER //
CREATE TRIGGER trg_voo_portao_update
BEFORE UPDATE ON Voo
FOR EACH ROW
BEGIN
    -- Se o portão foi alterado
    IF NEW.id_portao_embarque != OLD.id_portao_embarque THEN
        -- Libera o portão antigo (se existir)
        IF OLD.id_portao_embarque IS NOT NULL THEN
            UPDATE Portao SET status = 'Livre' WHERE id_portao = OLD.id_portao_embarque;
        END IF;
        
        -- Ocupa o novo portão (se existir)
        IF NEW.id_portao_embarque IS NOT NULL THEN
            UPDATE Portao SET status = 'Ocupado' WHERE id_portao = NEW.id_portao_embarque;
        END IF;
    END IF;
END //
DELIMITER ;

-- 2. Registrar mudanças de status de voo
DELIMITER //
CREATE TRIGGER trg_voo_status_change
AFTER UPDATE ON Voo
FOR EACH ROW
BEGIN
    IF NEW.status != OLD.status THEN
        INSERT INTO HistoricoStatusVoo (id_voo, status_anterior, status_novo, responsavel)
        VALUES (NEW.id_voo, OLD.status, NEW.status, 'Sistema');
    END IF;
END //
DELIMITER ;

-- 3. Atualizar horas de voo da aeronave
-- Horas de Voo: Soma as horas de voo na aeronave quando o voo é concluído
DELIMITER //
CREATE TRIGGER trg_voo_horas_voo
AFTER UPDATE ON Voo
FOR EACH ROW
BEGIN
    -- Se o voo foi concluído  e tem dados reais
    IF NEW.status = 'Aterrissado' AND OLD.status != 'Aterrissado' 
       AND NEW.partida_real IS NOT NULL AND NEW.chegada_real IS NOT NULL THEN
        
        -- Calcula a diferença em horas
        SET @horas_voo = TIMESTAMPDIFF(HOUR, NEW.partida_real, NEW.chegada_real);
        
        -- Atualiza o total de horas de voo da aeronave
        UPDATE Aeronave 
        SET horas_voo_total = horas_voo_total + @horas_voo
        WHERE id_aeronave = NEW.id_aeronave;
    END IF;
END //
DELIMITER ;

-- 4. Verificar disponibilidade de poltrona antes de reservar
-- Verifica Assento: Impede reserva se o assento já estiver ocupado
DELIMITER //
CREATE TRIGGER trg_assento_reserva_check
BEFORE INSERT ON AssentoReserva
FOR EACH ROW
BEGIN
    DECLARE poltrona_disponivel BOOLEAN;
    
    -- Verifica se a poltrona está disponível
    SELECT disponivel INTO poltrona_disponivel
    FROM PoltronaVoo
    WHERE id_poltrona_voo = NEW.id_poltrona_voo;
    
    IF NOT poltrona_disponivel THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Poltrona não está disponível para reserva';
    END IF;
END //
DELIMITER ;

-- 5. Atualizar status da poltrona após reserva
-- Bloqueia Assento: Marca o assento como indisponível após a reserva
DELIMITER //
CREATE TRIGGER trg_assento_reserva_update_poltrona
AFTER INSERT ON AssentoReserva
FOR EACH ROW
BEGIN
    -- Marca a poltrona como indisponível
    UPDATE PoltronaVoo
    SET disponivel = FALSE
    WHERE id_poltrona_voo = NEW.id_poltrona_voo;
END //
DELIMITER ;

-- 6. Atualizar milhas do cliente após voo concluído
DELIMITER //
CREATE TRIGGER trg_voo_concluido_milhas
AFTER UPDATE ON Voo
FOR EACH ROW
BEGIN
    -- Se o voo foi concluído
    IF NEW.status = 'Aterrissado' AND OLD.status != 'Aterrissado' THEN
        -- Atualiza milhas para todos os passageiros deste voo
        UPDATE Cliente c
        JOIN PassageiroReserva pr ON c.id_cliente = pr.id_cliente
        JOIN AssentoReserva ar ON pr.id_passageiro_reserva = ar.id_passageiro_reserva
        JOIN Voo v ON ar.id_voo = v.id_voo
        SET c.milhas_acumuladas = c.milhas_acumuladas + (v.distancia_km * 
            CASE 
                WHEN (SELECT classe FROM Poltrona p JOIN PoltronaVoo pv ON p.id_poltrona = pv.id_poltrona WHERE pv.id_poltrona_voo = ar.id_poltrona_voo) = 'Economica' THEN 1.0
                WHEN (SELECT classe FROM Poltrona p JOIN PoltronaVoo pv ON p.id_poltrona = pv.id_poltrona WHERE pv.id_poltrona_voo = ar.id_poltrona_voo) = 'Executiva' THEN 1.5
                WHEN (SELECT classe FROM Poltrona p JOIN PoltronaVoo pv ON p.id_poltrona = pv.id_poltrona WHERE pv.id_poltrona_voo = ar.id_poltrona_voo) = 'Primeira' THEN 2.0
                WHEN (SELECT classe FROM Poltrona p JOIN PoltronaVoo pv ON p.id_poltrona = pv.id_poltrona WHERE pv.id_poltrona_voo = ar.id_poltrona_voo) = 'Luxo' THEN 3.0
            END)
        WHERE v.id_voo = NEW.id_voo;
    END IF;
END //
DELIMITER ;

-- Views
-- 1. Mostrar voos agendados com detalhes
CREATE VIEW vw_voos_agendados AS
SELECT 
    v.id_voo,
    v.codigo_voo,
    a1.nome AS origem,
    a2.nome AS destino,
    v.partida_prevista,
    v.chegada_prevista,
    aer.codigo_registro AS aeronave,
    ta.nome AS tipo_aeronave,
    v.status
FROM Voo v
JOIN Aeroporto a1 ON v.id_origem = a1.id_aeroporto
JOIN Aeroporto a2 ON v.id_destino = a2.id_aeroporto
JOIN Aeronave aer ON v.id_aeronave = aer.id_aeronave
JOIN TipoAeronave ta ON aer.id_tipo = ta.id_tipo
WHERE v.status IN ('Agendado', 'Embarque', 'Atrasado');

-- 2. Mostrar ocupação de voos
CREATE OR REPLACE VIEW vw_ocupacao_voos AS
SELECT 
    v.id_voo,
    v.codigo_voo,
    ao.nome AS origem,
    ad.nome AS destino,
    v.partida_prevista AS partida,
    v.chegada_prevista AS chegada,
    v.status,
    COUNT(ar.id_assento_reserva) AS poltronas_ocupadas,
    COUNT(pv.id_poltrona_voo) AS total_poltronas,
    CONCAT(COUNT(ar.id_assento_reserva), '/', COUNT(pv.id_poltrona_voo)) AS ocupacao_formatada,
    ROUND(COUNT(ar.id_assento_reserva) * 100.0 / COUNT(pv.id_poltrona_voo), 2) AS ocupacao_percentual
FROM Voo v
JOIN Aeroporto ao ON v.id_origem = ao.id_aeroporto
JOIN Aeroporto ad ON v.id_destino = ad.id_aeroporto
LEFT JOIN PoltronaVoo pv ON v.id_voo = pv.id_voo
LEFT JOIN AssentoReserva ar ON pv.id_poltrona_voo = ar.id_poltrona_voo
GROUP BY 
    v.id_voo, 
    v.codigo_voo, 
    ao.nome, 
    ad.nome, 
    v.partida_prevista, 
    v.chegada_prevista, 
    v.status;


-- 3. Mostrar clientes frequentes
CREATE OR REPLACE VIEW vw_clientes_frequentes AS
SELECT
    c.id_cliente,
    CONCAT(p.primeiro_nome, ' ', p.sobrenome) AS nome_completo,
    CONCAT(p.tipo_documento, ' ', p.numero_documento) AS documento,
    c.milhas_acumuladas,
    p.categoria_fidelidade,
    COUNT(r.id_reserva) AS total_reservas
FROM Cliente c
JOIN Pessoa p ON c.id_pessoa = p.id_pessoa
LEFT JOIN Reserva r ON c.id_cliente = r.id_cliente
GROUP BY
    c.id_cliente,
    p.primeiro_nome,
    p.sobrenome,
    p.tipo_documento,
    p.numero_documento,
    c.milhas_acumuladas,
    p.categoria_fidelidade
ORDER BY c.milhas_acumuladas DESC;

-- 4. Mostrar aeronaves em manutenção
CREATE VIEW vw_aeronaves_manutencao AS
SELECT 
    a.id_aeronave,
    a.codigo_registro,
    ta.nome AS tipo_aeronave,
    a.proxima_manutencao,
    a.horas_voo_total,
    m.data_inicio AS manutencao_inicio,
    m.data_conclusao AS manutencao_conclusao,
    m.tipo AS tipo_manutencao
FROM Aeronave a
JOIN TipoAeronave ta ON a.id_tipo = ta.id_tipo
LEFT JOIN ManutencaoAeronave m ON a.id_aeronave = m.id_aeronave AND m.data_conclusao IS NULL
WHERE a.status = 'Em manutencao' OR m.id_manutencao IS NOT NULL;

-- 5. Mostrar disponibilidade de poltronas por voo
CREATE VIEW vw_poltronas_disponiveis AS
SELECT 
    v.id_voo,
    v.codigo_voo,
    p.classe,
    COUNT(CASE WHEN pv.disponivel = TRUE THEN 1 END) AS disponiveis,
    COUNT(pv.id_poltrona_voo) AS total,
    ROUND(COUNT(CASE WHEN pv.disponivel = TRUE THEN 1 END) / COUNT(pv.id_poltrona_voo) * 100, 2) AS percentual_disponivel
FROM Voo v
JOIN PoltronaVoo pv ON v.id_voo = pv.id_voo
JOIN Poltrona p ON pv.id_poltrona = p.id_poltrona
GROUP BY v.id_voo, v.codigo_voo, p.classe;

-- 6. Reservas completas
CREATE OR REPLACE VIEW vw_reservas_completas AS
SELECT 
    r.id_reserva,
    r.codigo_reserva,
    r.status AS reserva_status,
    CONCAT(p.primeiro_nome,' ',p.sobrenome) AS passageiro,
    v.codigo_voo,
    pt.codigo AS poltrona
FROM Reserva r
JOIN PassageiroReserva pr ON r.id_reserva = pr.id_reserva
JOIN Cliente c ON pr.id_cliente = c.id_cliente
JOIN Pessoa p ON c.id_pessoa = p.id_pessoa
JOIN AssentoReserva ar ON pr.id_passageiro_reserva = ar.id_passageiro_reserva
JOIN Voo v ON ar.id_voo = v.id_voo
JOIN PoltronaVoo pv ON ar.id_poltrona_voo = pv.id_poltrona_voo
JOIN Poltrona pt ON pv.id_poltrona = pt.id_poltrona;

-- 7. Partidas e chegadas
CREATE OR REPLACE VIEW vw_voos_formatados AS
SELECT
    v.id_voo,
    v.codigo_voo,
    a1.nome AS origem,
    a2.nome AS destino,
    DATE_FORMAT(v.partida_prevista, '%d/%m/%Y %H:%i') AS partida_sem_segundos,
    DATE_FORMAT(v.chegada_prevista, '%d/%m/%Y %H:%i') AS chegada_sem_segundos,
    v.status
FROM Voo v
JOIN Aeroporto a1 ON v.id_origem = a1.id_aeroporto
JOIN Aeroporto a2 ON v.id_destino = a2.id_aeroporto;

-- Views para exibir ENUM corretamente
-- Status de Voo
CREATE OR REPLACE VIEW vw_enum_voo_status AS
SELECT 
    'Agendado' AS codigo,
    'Voo Agendado' AS descricao
UNION ALL
SELECT 
    'Embarque',
    'Embarque em Andamento'
UNION ALL
SELECT 
    'Decolado',
    'Voo Decolado'
UNION ALL
SELECT 
    'Em rota',
    'Em Rota para o Destino'
UNION ALL
SELECT 
    'Aterrissado',
    'Voo Aterrissado'
UNION ALL
SELECT 
    'Cancelado',
    'Voo Cancelado'
UNION ALL
SELECT 
    'Atrasado',
    'Voo Atrasado';

-- Classes de Poltrona
CREATE OR REPLACE VIEW vw_enum_poltrona_classe AS
SELECT 
    'Economica' AS codigo,
    'Classe Econômica' AS descricao
UNION ALL
SELECT 
    'Executiva',
    'Classe Executiva'
UNION ALL
SELECT 
    'Primeira',
    'Primeira Classe'
UNION ALL
SELECT 
    'Luxo',
    'Classe Luxo';

-- Posições de Poltrona
CREATE OR REPLACE VIEW vw_enum_poltrona_posicao AS
SELECT 
    'Janela' AS codigo,
    'Janela' AS descricao
UNION ALL
SELECT 
    'Corredor',
    'Corredor'
UNION ALL
SELECT 
    'Meio',
    'Poltrona do Meio';

-- Lados de Poltrona
CREATE OR REPLACE VIEW vw_enum_poltrona_lado AS
SELECT 
    'Esquerda' AS codigo,
    'Lado Esquerdo' AS descricao
UNION ALL
SELECT 
    'Direita',
    'Lado Direito';

-- Tipos de Documento
CREATE OR REPLACE VIEW vw_enum_tipo_documento AS
SELECT 
    'CPF' AS codigo,
    'CPF' AS descricao
UNION ALL
SELECT 
    'RG',
    'RG'
UNION ALL
SELECT 
    'Passaporte',
    'Passaporte'
UNION ALL
SELECT 
    'CertidaoNascimento',
    'Certidão de Nascimento';

-- Formas de Pagamento
CREATE OR REPLACE VIEW vw_enum_forma_pagamento AS
SELECT 
    'CartaoCredito' AS codigo,
    'Cartão de Crédito' AS descricao
UNION ALL
SELECT 
    'Debito',
    'Cartão de Débito'
UNION ALL
SELECT 
    'Boleto',
    'Boleto Bancário'
UNION ALL
SELECT 
    'Transferencia',
    'Transferência Bancária'
UNION ALL
SELECT 
    'Pix',
    'PIX'
UNION ALL
SELECT 
    'Dinheiro',
    'Dinheiro';