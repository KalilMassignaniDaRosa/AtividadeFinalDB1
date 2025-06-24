-- Views atualizadas
-- Formatar CPF (mantida igual)
CREATE OR REPLACE VIEW View_Cliente_CPF_Formatado AS
SELECT 
    id_cliente,
    CASE 
        WHEN LENGTH(documento) = 11 THEN 
            CONCAT(SUBSTRING(documento, 1, 3), '.', 
                   SUBSTRING(documento, 4, 3), '.', 
                   SUBSTRING(documento, 7, 3), '-', 
                   SUBSTRING(documento, 10, 2))
        ELSE documento
    END AS cpf_formatado,
    primeiro_nome,
    sobrenome
FROM Cliente
WHERE tipo_documento = 'CPF';

-- Mostrar capacidade disponível por voo (atualizada)
CREATE OR REPLACE VIEW View_Capacidade_Voo AS
SELECT 
    v.id_voo,
    v.codigo_voo,
    a.capacidade_carga_kg AS capacidade_maxima,
    fn_capacidade_disponivel_com_combustivel(
        v.id_aeronave, 
        v.combustivel_carregado_litros
    ) AS capacidade_disponivel,
    fn_calcular_peso_bagagens_voo(v.id_voo) AS peso_bagagens,
    (fn_capacidade_disponivel_com_combustivel(
        v.id_aeronave, 
        v.combustivel_carregado_litros
    ) - fn_calcular_peso_bagagens_voo(v.id_voo)) AS capacidade_restante,
    a.codigo_registro AS registro_aeronave,
    ta.nome AS tipo_aeronave
FROM Voo v
JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
JOIN TipoAeronave ta ON a.id_tipo = ta.id_tipo;

-- Verificar viagens críticas (atualizada)
CREATE OR REPLACE VIEW View_Voos_Criticos AS
SELECT 
    v.id_voo,
    v.codigo_voo,
    a.codigo_registro,
    CASE 
        WHEN fn_calcular_necessidade_escala(v.id_voo) THEN 'SIM' 
        ELSE 'NÃO' 
    END AS precisa_escala,
    CASE 
        WHEN fn_verificar_combustivel_suficiente(v.id_voo) THEN 'SUFICIENTE' 
        ELSE 'INSUFICIENTE' 
    END AS combustivel,
    CASE 
        WHEN fn_verificar_autonomia_voo(v.id_voo) THEN 'SUFICIENTE' 
        ELSE 'INSUFICIENTE' 
    END AS autonomia,
    v.distancia_km,
    a.autonomia_km,
    v.combustivel_carregado_litros,
    ta.consumo_combustivel_km_litro
FROM Voo v
JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
JOIN TipoAeronave ta ON a.id_tipo = ta.id_tipo;

-- Mostrar detalhes de configuração de aeronaves (atualizada)
CREATE OR REPLACE VIEW View_Configuracao_Aeronave AS
SELECT 
    a.id_aeronave,
    a.codigo_registro,
    ta.nome AS tipo_aeronave,
    cta.classe,
    cta.quantidade AS quantidade_planejada,
    COUNT(p.id_poltrona) AS quantidade_implementada,
    (cta.quantidade - COUNT(p.id_poltrona)) AS diferenca
FROM Aeronave a
JOIN TipoAeronave ta ON a.id_tipo = ta.id_tipo
JOIN ClasseTipoAeronave cta ON ta.id_tipo = cta.id_tipo
LEFT JOIN Poltrona p ON a.id_aeronave = p.id_aeronave AND cta.classe = p.classe
GROUP BY a.id_aeronave, a.codigo_registro, ta.nome, cta.classe, cta.quantidade;

-- Nova view para mostrar voos ativos
CREATE OR REPLACE VIEW View_Voos_Ativos AS
SELECT 
    v.id_voo,
    v.codigo_voo,
    a.codigo_registro,
    ao.codigo_iata AS origem,
    ad.codigo_iata AS destino,
    v.partida_prevista,
    v.chegada_prevista,
    v.status,
    COUNT(DISTINCT ar.id_assento_reserva) AS passageiros_embarcados,
    COUNT(DISTINCT tv.id_tripulante) AS tripulantes
FROM Voo v
JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
JOIN Aeroporto ao ON v.id_origem = ao.id_aeroporto
JOIN Aeroporto ad ON v.id_destino = ad.id_aeroporto
LEFT JOIN AssentoReserva ar ON v.id_voo = ar.id_voo
LEFT JOIN TripulacaoVoo tv ON v.id_voo = tv.id_voo
WHERE v.status IN ('Embarque', 'Decolado', 'Em rota')
GROUP BY v.id_voo, v.codigo_voo, a.codigo_registro, ao.codigo_iata, ad.codigo_iata, 
         v.partida_prevista, v.chegada_prevista, v.status;

-- Nova view para mostrar manutenções pendentes
CREATE OR REPLACE VIEW View_Manutencoes_Pendentes AS
SELECT 
    a.id_aeronave,
    a.codigo_registro,
    ta.nome AS tipo_aeronave,
    a.proxima_manutencao,
    DATEDIFF(a.proxima_manutencao, CURDATE()) AS dias_para_manutencao,
    a.horas_voo_total
FROM Aeronave a
JOIN TipoAeronave ta ON a.id_tipo = ta.id_tipo
WHERE a.proxima_manutencao <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
ORDER BY a.proxima_manutencao;

-- Funções atualizadas
-- Calcular peso total das bagagens em um voo (atualizada)
DELIMITER //
CREATE OR REPLACE FUNCTION fn_calcular_peso_bagagens_voo(p_id_voo INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_peso DECIMAL(10,2);
    
    SELECT COALESCE(SUM(b.peso_kg), 0) INTO total_peso
    FROM Bagagem b
    JOIN AssentoReserva ar ON b.id_assento_reserva = ar.id_assento_reserva
    JOIN PoltronaVoo pv ON ar.id_poltrona_voo = pv.id_poltrona_voo
    WHERE pv.id_voo = p_id_voo AND b.tipo = 'Despachada';
    
    RETURN total_peso;
END //
DELIMITER ;

-- Calcular capacidade disponível considerando combustível (atualizada)
DELIMITER //
CREATE OR REPLACE FUNCTION fn_capacidade_disponivel_com_combustivel(
    p_id_aeronave INT,
    p_combustivel_litros DOUBLE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_capacidade_max DECIMAL(10,2);
    DECLARE v_peso_combustivel DECIMAL(10,2);
    DECLARE v_peso_basico DECIMAL(10,2);
    
    -- Densidade média do combustível de aviação (kg/l)
    DECLARE densidade_combustivel DECIMAL(3,2) DEFAULT 0.8;
    -- Peso básico operacional (incluindo tripulação, equipamentos, etc.)
    DECLARE peso_basico_porcentagem DECIMAL(3,2) DEFAULT 0.15;
    
    SELECT capacidade_carga_kg INTO v_capacidade_max
    FROM Aeronave
    WHERE id_aeronave = p_id_aeronave;
    
    SET v_peso_combustivel = p_combustivel_litros * densidade_combustivel;
    SET v_peso_basico = v_capacidade_max * peso_basico_porcentagem;
    
    RETURN v_capacidade_max - v_peso_combustivel - v_peso_basico;
END //
DELIMITER ;

-- Verificar autonomia vs distância (atualizada)
DELIMITER //
CREATE OR REPLACE FUNCTION fn_verificar_autonomia_voo(p_id_voo INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_autonomia_km DOUBLE;
    DECLARE v_distancia_km DOUBLE;
    DECLARE v_combustivel_litros DOUBLE;
    DECLARE v_consumo_medio DOUBLE;
    DECLARE v_autonomia_com_reserva DOUBLE;
    DECLARE v_altitude_maxima DOUBLE;
    DECLARE v_altitude_necessaria DOUBLE;
    
    SELECT a.autonomia_km, v.distancia_km, v.combustivel_carregado_litros, 
           t.consumo_combustivel_km_litro, a.altitude_maxima_metros
    INTO v_autonomia_km, v_distancia_km, v_combustivel_litros, v_consumo_medio, v_altitude_maxima
    FROM Voo v
    JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
    JOIN TipoAeronave t ON a.id_tipo = t.id_tipo
    WHERE v.id_voo = p_id_voo;
    
    -- Calcular altitude necessária baseada na distância
    SET v_altitude_necessaria = v_distancia_km * 0.3; -- Fórmula simplificada
    
    -- Verificar se a altitude máxima é suficiente
    IF v_altitude_maxima < v_altitude_necessaria THEN
        RETURN FALSE;
    END IF;
    
    -- Considerar reserva de 15% para segurança
    SET v_autonomia_com_reserva = v_autonomia_km * 0.85;
    
    -- Verificar se a autonomia natural com reserva é suficiente
    IF v_autonomia_com_reserva >= v_distancia_km THEN
        RETURN TRUE;
    END IF;
    
    -- Verificar com base no combustível carregado
    IF (v_combustivel_litros / v_consumo_medio) >= v_distancia_km THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END //
DELIMITER ;

-- Calcular necessidade de escala (atualizada)
DELIMITER //
CREATE OR REPLACE FUNCTION fn_calcular_necessidade_escala(p_id_voo INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_autonomia_km DOUBLE;
    DECLARE v_distancia_km DOUBLE;
    DECLARE v_altitude_maxima DOUBLE;
    DECLARE v_altitude_necessaria DOUBLE;
    
    SELECT a.autonomia_km, v.distancia_km, a.altitude_maxima_metros
    INTO v_autonomia_km, v_distancia_km, v_altitude_maxima
    FROM Voo v
    JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
    WHERE v.id_voo = p_id_voo;
    
    -- Calcular altitude necessária baseada na distância
    SET v_altitude_necessaria = v_distancia_km * 0.3; -- Fórmula simplificada
    
    -- Verificar se a altitude máxima é suficiente
    IF v_altitude_maxima < v_altitude_necessaria THEN
        RETURN TRUE;
    END IF;
    
    -- Considerar reserva de 20% para segurança
    IF v_autonomia_km * 0.8 < v_distancia_km THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END //
DELIMITER ;

-- Verificar combustível suficiente (atualizada)
DELIMITER //
CREATE OR REPLACE FUNCTION fn_verificar_combustivel_suficiente(p_id_voo INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_combustivel_litros DOUBLE;
    DECLARE v_distancia_km DOUBLE;
    DECLARE v_consumo_medio DOUBLE;
    DECLARE v_autonomia_combustivel DOUBLE;
    DECLARE v_condicoes_meteorologicas VARCHAR(20);
    
    SELECT v.combustivel_carregado_litros, v.distancia_km, t.consumo_combustivel_km_litro
    INTO v_combustivel_litros, v_distancia_km, v_consumo_medio
    FROM Voo v
    JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
    JOIN TipoAeronave t ON a.id_tipo = t.id_tipo
    WHERE v.id_voo = p_id_voo;
    
    -- Obter condições meteorológicas (simplificado)
    -- Em um sistema real, isso viria de uma API ou tabela de condições climáticas
    SET v_condicoes_meteorologicas = 'Normal'; -- Padrão
    
    -- Ajustar consumo baseado em condições meteorológicas
    CASE v_condicoes_meteorologicas
        WHEN 'Tempestade' THEN SET v_consumo_medio = v_consumo_medio * 1.3;
        WHEN 'Ventos Fortes' THEN SET v_consumo_medio = v_consumo_medio * 1.2;
        WHEN 'Chuva' THEN SET v_consumo_medio = v_consumo_medio * 1.1;
        ELSE SET v_consumo_medio = v_consumo_medio * 1.0;
    END CASE;
    
    -- Calcular autonomia com o combustível carregado
    SET v_autonomia_combustivel = v_combustivel_litros / v_consumo_medio;
    
    -- Considerar reserva de 15% para segurança
    IF v_autonomia_combustivel >= v_distancia_km * 1.15 THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END //
DELIMITER ;

-- Nova função para calcular idade do passageiro
DELIMITER //
CREATE OR REPLACE FUNCTION fn_calcular_idade(p_id_cliente INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_data_nascimento DATE;
    DECLARE v_idade INT;
    
    SELECT data_nascimento INTO v_data_nascimento
    FROM Cliente
    WHERE id_cliente = p_id_cliente;
    
    SET v_idade = TIMESTAMPDIFF(YEAR, v_data_nascimento, CURDATE());
    
    RETURN v_idade;
END //
DELIMITER ;

-- Nova função para verificar se passageiro é criança
DELIMITER //
CREATE OR REPLACE FUNCTION fn_eh_crianca(p_id_cliente INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_idade INT;
    
    SET v_idade = fn_calcular_idade(p_id_cliente);
    
    RETURN v_idade < 12;
END //
DELIMITER ;

-- Triggers atualizados
-- Registrar histórico de status (atualizado)
DELIMITER //
CREATE OR REPLACE TRIGGER trg_historico_status_voo
AFTER UPDATE ON Voo
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO HistoricoStatusVoo (
            id_voo, 
            status_anterior, 
            status_novo, 
            responsavel,
            data_hora_mudanca
        ) VALUES (
            NEW.id_voo,
            OLD.status,
            NEW.status,
            COALESCE(@usuario_atual, 'Sistema'),
            NOW()
        );
    END IF;
    
    -- Atualizar horas de voo da aeronave quando o voo é concluído
    IF NEW.status = 'Aterrissado' AND OLD.status <> 'Aterrissado' THEN
        -- Calcular horas de voo em minutos e converter para horas
        DECLARE v_horas_voo DECIMAL(10,2);
        SET v_horas_voo = TIMESTAMPDIFF(MINUTE, NEW.partida_real, NEW.chegada_real) / 60.0;
        
        UPDATE Aeronave
        SET horas_voo_total = horas_voo_total + v_horas_voo
        WHERE id_aeronave = NEW.id_aeronave;
    END IF;
END //
DELIMITER ;

-- Criar poltronas quando uma nova aeronave é inserida (atualizado)
DELIMITER //
CREATE OR REPLACE TRIGGER trg_criar_poltronas_aeronave
AFTER INSERT ON Aeronave
FOR EACH ROW
BEGIN
    DECLARE v_classe VARCHAR(20);
    DECLARE v_quantidade INT;
    DECLARE v_counter INT DEFAULT 1;
    DECLARE v_fileira INT DEFAULT 1;
    DECLARE v_posicao CHAR;
    DECLARE done BOOLEAN DEFAULT FALSE;
    
    DECLARE cur_classes CURSOR FOR
        SELECT classe, quantidade 
        FROM ClasseTipoAeronave 
        WHERE id_tipo = NEW.id_tipo
        ORDER BY CASE classe
            WHEN 'Luxo' THEN 1
            WHEN 'Primeira' THEN 2
            WHEN 'Executiva' THEN 3
            WHEN 'Economica' THEN 4
            ELSE 5
        END;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_classes;
    
    read_loop: LOOP
        FETCH cur_classes INTO v_classe, v_quantidade;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET v_counter = 1;
        WHILE v_counter <= v_quantidade DO
            -- Determinar posição baseada no contador (padrão 3-3 para econômica, 2-2 para executiva, etc.)
            CASE v_classe
                WHEN 'Economica' THEN
                    SET v_posicao = CASE 
                        WHEN v_counter % 6 IN (1,6) THEN 'Janela'
                        WHEN v_counter % 6 IN (2,5) THEN 'Meio'
                        ELSE 'Corredor'
                    END;
                    SET v_fileira = CEILING(v_counter / 6);
                WHEN 'Executiva' THEN
                    SET v_posicao = CASE 
                        WHEN v_counter % 4 IN (1,4) THEN 'Janela'
                        ELSE 'Corredor'
                    END;
                    SET v_fileira = CEILING(v_counter / 4);
                WHEN 'Primeira' THEN
                    SET v_posicao = 'Corredor'; -- Assumindo que todos têm acesso ao corredor
                    SET v_fileira = CEILING(v_counter / 2);
                WHEN 'Luxo' THEN
                    SET v_posicao = 'Janela'; -- Assumindo que todos têm janela
                    SET v_fileira = v_counter;
            END CASE;
            
            INSERT INTO Poltrona (
                id_aeronave, 
                codigo, 
                classe, 
                posicao, 
                lado
            ) VALUES (
                NEW.id_aeronave,
                CONCAT(
                    CASE v_classe
                        WHEN 'Economica' THEN 'E'
                        WHEN 'Executiva' THEN 'X'
                        WHEN 'Primeira' THEN 'P'
                        WHEN 'Luxo' THEN 'L'
                    END,
                    LPAD(v_fileira, 2, '0'),
                    CASE 
                        WHEN v_classe IN ('Economica', 'Executiva') THEN
                            CASE 
                                WHEN v_counter % 6 IN (1,2,3) THEN 'E' -- Esquerda
                                ELSE 'D' -- Direita
                            END
                        ELSE ''
                    END
                ),
                v_classe,
                v_posicao,
                CASE 
                    WHEN v_classe IN ('Economica', 'Executiva') THEN
                        CASE 
                            WHEN v_counter % 6 IN (1,2,3) THEN 'Esquerda'
                            ELSE 'Direita'
                        END
                    ELSE 'Esquerda' -- Para Primeira e Luxo, não importa tanto
                END
            );
            SET v_counter = v_counter + 1;
        END WHILE;
    END LOOP;
    
    CLOSE cur_classes;
END //
DELIMITER ;

-- Verificar combustível antes de decolar (atualizado)
DELIMITER //
CREATE OR REPLACE TRIGGER trg_verificar_combustivel_decolagem
BEFORE UPDATE ON Voo
FOR EACH ROW
BEGIN
    IF NEW.status = 'Decolado' AND OLD.status <> 'Decolado' THEN
        IF NOT fn_verificar_combustivel_suficiente(NEW.id_voo) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Combustível insuficiente para o voo';
        END IF;
        
        -- Registrar hora real de partida
        IF NEW.partida_real IS NULL THEN
            SET NEW.partida_real = NOW();
        END IF;
    END IF;
    
    -- Registrar hora real de chegada quando o voo é concluído
    IF NEW.status = 'Aterrissado' AND OLD.status <> 'Aterrissado' THEN
        IF NEW.chegada_real IS NULL THEN
            SET NEW.chegada_real = NOW();
        END IF;
    END IF;
END //
DELIMITER ;

-- Atualizar status anterior ao mudar status (mantido igual)
DELIMITER //
CREATE OR REPLACE TRIGGER trg_atualizar_status_anterior
BEFORE UPDATE ON Voo
FOR EACH ROW
SET NEW.status_anterior = OLD.status;
//
DELIMITER ;

-- Novo trigger para verificar idade de crianças em reservas
DELIMITER //
CREATE OR REPLACE TRIGGER trg_verificar_criancas_reserva
BEFORE INSERT ON PassageiroReserva
FOR EACH ROW
BEGIN
    DECLARE v_idade INT;
    DECLARE v_eh_crianca BOOLEAN;
    
    -- Verificar se o passageiro é uma criança
    SET v_idade = fn_calcular_idade(NEW.id_cliente);
    SET v_eh_crianca = v_idade < 12;
    
    -- Se for criança, verificar se tem um responsável associado
    IF v_eh_crianca AND NEW.id_responsavel IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Crianças devem ter um responsável associado na reserva';
    END IF;
    
    -- Se não for criança, garantir que não tem responsável
    IF NOT v_eh_crianca AND NEW.id_responsavel IS NOT NULL THEN
        SET NEW.id_responsavel = NULL;
    END IF;
END //
DELIMITER ;

-- Procedures atualizadas
-- Calcular necessidade de escala e combustível (atualizada)
DELIMITER //
CREATE OR REPLACE PROCEDURE sp_verificar_viagem(p_id_voo INT)
BEGIN
    DECLARE v_necessidade_escala BOOLEAN;
    DECLARE v_combustivel_suficiente BOOLEAN;
    DECLARE v_autonomia_suficiente BOOLEAN;
    DECLARE v_aeronave_disponivel BOOLEAN;
    DECLARE v_tripulacao_completa BOOLEAN;
    
    SET v_necessidade_escala = fn_calcular_necessidade_escala(p_id_voo);
    SET v_combustivel_suficiente = fn_verificar_combustivel_suficiente(p_id_voo);
    SET v_autonomia_suficiente = fn_verificar_autonomia_voo(p_id_voo);
    
    -- Verificar se a aeronave está disponível
    SELECT a.status = 'Disponivel' INTO v_aeronave_disponivel
    FROM Voo v
    JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
    WHERE v.id_voo = p_id_voo;
    
    -- Verificar se a tripulação está completa (pelo menos 1 comandante, 1 copiloto e 2 comissários)
    SELECT COUNT(CASE WHEN funcao = 'Comandante' THEN 1 END) >= 1 AND
           COUNT(CASE WHEN funcao = 'Copiloto' THEN 1 END) >= 1 AND
           COUNT(CASE WHEN funcao = 'Comissario' THEN 1 END) >= 2
    INTO v_tripulacao_completa
    FROM TripulacaoVoo
    WHERE id_voo = p_id_voo;
    
    SELECT 
        v_necessidade_escala AS precisa_escala,
        v_combustivel_suficiente AS combustivel_suficiente,
        v_autonomia_suficiente AS autonomia_suficiente,
        v_aeronave_disponivel AS aeronave_disponivel,
        v_tripulacao_completa AS tripulacao_completa;
END //
DELIMITER ;

-- Nova procedure para agendar manutenção preventiva
DELIMITER //
CREATE OR REPLACE PROCEDURE sp_agendar_manutencao_preventiva(
    p_id_aeronave INT,
    p_tipo_manutencao ENUM('Preventiva', 'Corretiva', 'Programada', 'Emergencial'),
    p_descricao TEXT
)
BEGIN
    DECLARE v_data_manutencao DATE;
    
    -- Agendar para daqui a 30 dias ou 100 horas de voo, o que vier primeiro
    SET v_data_manutencao = DATE_ADD(CURDATE(), INTERVAL 30 DAY);
    
    INSERT INTO ManutencaoAeronave (
        id_aeronave,
        data_inicio,
        tipo,
        descricao,
        status
    ) VALUES (
        p_id_aeronave,
        v_data_manutencao,
        p_tipo_manutencao,
        p_descricao,
        'Agendada'
    );
    
    -- Atualizar a próxima manutenção na aeronave
    UPDATE Aeronave
    SET proxima_manutencao = v_data_manutencao
    WHERE id_aeronave = p_id_aeronave;
END //
DELIMITER ;

-- Nova procedure para atualizar status de voo
DELIMITER //
CREATE OR REPLACE PROCEDURE sp_atualizar_status_voo(
    p_id_voo INT,
    p_novo_status VARCHAR(50)
BEGIN
    DECLARE v_status_atual VARCHAR(50);
    
    -- Verificar se o voo existe
    SELECT status INTO v_status_atual
    FROM Voo
    WHERE id_voo = p_id_voo;
    
    IF v_status_atual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Voo não encontrado';
    END IF;
    
    -- Atualizar o status
    UPDATE Voo
    SET status = p_novo_status
    WHERE id_voo = p_id_voo;
    
    -- Registrar a mudança de status
    INSERT INTO HistoricoStatusVoo (
        id_voo, 
        status_anterior, 
        status_novo, 
        responsavel
    ) VALUES (
        p_id_voo,
        v_status_atual,
        p_novo_status,
        COALESCE(@usuario_atual, 'Sistema')
    );
END //
DELIMITER ;

-- Nova procedure para gerar relatório de ocupação por voo
DELIMITER //
CREATE OR REPLACE PROCEDURE sp_relatorio_ocupacao_voo(
    p_data_inicio DATE,
    p_data_fim DATE)
BEGIN
    SELECT 
        v.id_voo,
        v.codigo_voo,
        a.codigo_registro,
        ao.codigo_iata AS origem,
        ad.codigo_iata AS destino,
        v.partida_prevista,
        COUNT(ar.id_assento_reserva) AS assentos_ocupados,
        COUNT(pv.id_poltrona_voo) AS assentos_totais,
        ROUND(COUNT(ar.id_assento_reserva) / COUNT(pv.id_poltrona_voo) * 100, 2) AS ocupacao_percentual,
        v.status
    FROM Voo v
    JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
    JOIN Aeroporto ao ON v.id_origem = ao.id_aeroporto
    JOIN Aeroporto ad ON v.id_destino = ad.id_aeroporto
    LEFT JOIN PoltronaVoo pv ON v.id_voo = pv.id_voo
    LEFT JOIN AssentoReserva ar ON pv.id_poltrona_voo = ar.id_poltrona_voo
    WHERE DATE(v.partida_prevista) BETWEEN p_data_inicio AND p_data_fim
    GROUP BY v.id_voo, v.codigo_voo, a.codigo_registro, ao.codigo_iata, ad.codigo_iata, 
             v.partida_prevista, v.status
    ORDER BY v.partida_prevista;
END //
DELIMITER ;