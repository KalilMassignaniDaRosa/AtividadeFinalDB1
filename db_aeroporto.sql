-- Criação do banco de dados
DROP DATABASE IF EXISTS EmpresaTransporteAereo;
CREATE DATABASE EmpresaTransporteAereo;
USE EmpresaTransporteAereo;

-- Tabela de Tipos de Aeronave
CREATE TABLE TipoAeronave (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT,
    capacidade_maxima INT NOT NULL,
    alcance_km INT,
    fabricante VARCHAR(50)
);

-- Tabela de Aeronaves
CREATE TABLE Aeronave (
    id_aeronave INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo INT NOT NULL,
    codigo_aeronave VARCHAR(20) NOT NULL UNIQUE,
    data_fabricacao DATE,
    ultima_manutencao DATE,
    proxima_manutencao DATE,
    horas_voo INT DEFAULT 0,
    status ENUM('Ativa', 'Manutencao', 'Desativada') DEFAULT 'Ativa',
    FOREIGN KEY (id_tipo) REFERENCES TipoAeronave(id_tipo)
);

-- Tabela de Aeroportos
CREATE TABLE Aeroporto (
    id_aeroporto INT AUTO_INCREMENT PRIMARY KEY,
    codigo_iata VARCHAR(3) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    terminal VARCHAR(20)
);

-- Tabela de Voos
CREATE TABLE Voo (
    id_voo INT AUTO_INCREMENT PRIMARY KEY,
    id_aeronave INT NOT NULL,
    codigo_voo VARCHAR(10) NOT NULL UNIQUE,
    id_origem INT NOT NULL,
    id_destino INT NOT NULL,
    horario_partida DATETIME NOT NULL,
    horario_chegada_previsto DATETIME NOT NULL,
    duracao_estimada_minutos INT NOT NULL,
    horario_chegada_real DATETIME NULL,
    portao_embarque VARCHAR(10),
    status ENUM('Agendado', 'Embarque', 'Decolado', 'EmRota', 'Aterrissado', 'Cancelado', 'Atrasado') NOT NULL,
    status_anterior ENUM('Agendado', 'Embarque', 'Decolado', 'EmRota', 'Aterrissado', 'Cancelado', 'Atrasado') NULL,
    preco_base DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_voo_tempos CHECK (horario_chegada_previsto > horario_partida),
    FOREIGN KEY (id_aeronave) REFERENCES Aeronave(id_aeronave),
    FOREIGN KEY (id_origem) REFERENCES Aeroporto(id_aeroporto),
    FOREIGN KEY (id_destino) REFERENCES Aeroporto(id_aeroporto)
);

-- Tabela de Escalas
CREATE TABLE Escala (
    id_escala INT AUTO_INCREMENT PRIMARY KEY,
    id_voo INT NOT NULL,
    id_aeroporto INT NOT NULL,
    ordem INT NOT NULL,
    horario_partida_previsto DATETIME NOT NULL,
    horario_chegada_previsto DATETIME NOT NULL,
    horario_partida_real DATETIME NULL,
    horario_chegada_real DATETIME NULL,
    tempo_espera_minutos INT,
    status ENUM('Prevista', 'Realizada', 'Cancelada', 'Atrasada') DEFAULT 'Prevista',
    CONSTRAINT chk_escala_ordem CHECK (ordem > 0),
    FOREIGN KEY (id_voo) REFERENCES Voo(id_voo),
    FOREIGN KEY (id_aeroporto) REFERENCES Aeroporto(id_aeroporto),
    UNIQUE (id_voo, ordem)
);

-- Tabela de Poltronas (melhorada com posição direita/esquerda)
CREATE TABLE Poltrona (
    id_poltrona INT AUTO_INCREMENT PRIMARY KEY,
    id_aeronave INT NOT NULL,
    id_voo INT NOT NULL,
    codigo VARCHAR(10) NOT NULL, -- Ex: "12A"
    classe ENUM('Economica', 'Executiva', 'Primeira') NOT NULL,
    localizacao ENUM('Janela-Esquerda', 'Janela-Direita', 'Corredor-Esquerda', 'Corredor-Direita', 'Meio') NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE,
    UNIQUE (id_aeronave, codigo, id_voo),
    FOREIGN KEY (id_aeronave) REFERENCES Aeronave(id_aeronave),
    FOREIGN KEY (id_voo) REFERENCES Voo(id_voo)
);

-- Tabela de Clientes (com mais detalhes para mala direta)
CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    tipo_documento ENUM('CPF', 'Passaporte', 'RG', 'Outro') NOT NULL,
    cpf VARCHAR(14) UNIQUE NULL,
    passaporte VARCHAR(20) UNIQUE NULL,
    primeiro_nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    data_nascimento DATE,
    email VARCHAR(100) UNIQUE,
    telefone VARCHAR(20),
    endereco TEXT,
    cidade VARCHAR(50),
    estado VARCHAR(50),
    pais VARCHAR(50),
    cep VARCHAR(20),
    nacionalidade VARCHAR(50),
    cliente_preferencial BOOLEAN DEFAULT FALSE,
    data_cadastro DATE NOT NULL,
    milhas_acumuladas INT DEFAULT 0,
    aceita_comunicados BOOLEAN DEFAULT TRUE,
    preferencia_comunicacao ENUM('Email', 'SMS', 'Correio', 'WhatsApp'),
    data_ultima_comunicacao DATE,
    categoria_fidelidade ENUM('Basic', 'Silver', 'Gold', 'Platinum') DEFAULT 'Basic',
    CONSTRAINT chk_cliente_documento CHECK (
        (cpf IS NOT NULL) OR 
        (passaporte IS NOT NULL) OR
        (tipo_documento = 'Outro')
    )
);

-- Tabela de Reservas
CREATE TABLE Reserva (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_voo INT NOT NULL,
    data_reserva DATETIME NOT NULL,
    status ENUM('Confirmada', 'Cancelada', 'EmEspera', 'CheckIn') NOT NULL,
    codigo_reserva VARCHAR(20) NOT NULL UNIQUE,
    valor_total DECIMAL(10,2) NOT NULL,
    forma_pagamento ENUM('CartaoCredito', 'Debito', 'Boleto', 'Transferencia', 'Milhas'),
    status_pagamento ENUM('Pendente', 'Completo', 'Reembolsado', 'Falhou') DEFAULT 'Pendente',
    data_checkin DATETIME NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_voo) REFERENCES Voo(id_voo)
);

-- Tabela de Poltronas Reservadas
CREATE TABLE ReservaPoltrona (
    id_reserva_poltrona INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_poltrona INT NOT NULL,
    status ENUM('Reservada', 'Ocupada') NOT NULL DEFAULT 'Reservada',
    UNIQUE (id_reserva, id_poltrona),
    FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva),
    FOREIGN KEY (id_poltrona) REFERENCES Poltrona(id_poltrona)
);

-- Tabela de Bagagem
CREATE TABLE Bagagem (
    id_bagagem INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    codigo_bagagem VARCHAR(20) NOT NULL UNIQUE,
    peso DECIMAL(5,2) NOT NULL,
    tipo ENUM('Mao', 'Despachada') NOT NULL,
    status ENUM('Embarque', 'Despachada', 'Extraviada', 'Entregue') NOT NULL,
    localizacao_atual VARCHAR(100) NULL,
    FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva)
);

-- Tabela de Tripulação
CREATE TABLE Tripulacao (
    id_tripulante INT AUTO_INCREMENT PRIMARY KEY,
    primeiro_nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    funcao ENUM('Piloto', 'CoPiloto', 'Comissario', 'Mecanico') NOT NULL,
    licenca VARCHAR(50),
    data_validade_licenca DATE
);

-- Tabela de Tripulação por Voo
CREATE TABLE TripulacaoVoo (
    id_tripulacao_voo INT AUTO_INCREMENT PRIMARY KEY,
    id_voo INT NOT NULL,
    id_tripulante INT NOT NULL,
    funcao_no_voo VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_voo) REFERENCES Voo(id_voo),
    FOREIGN KEY (id_tripulante) REFERENCES Tripulacao(id_tripulante),
    UNIQUE (id_voo, id_tripulante)
);

-- Tabela de Histórico de Voo (para triggers)
CREATE TABLE HistoricoVoo (
    id_historico INT AUTO_INCREMENT PRIMARY KEY,
    id_voo INT NOT NULL,
    data_alteracao DATETIME NOT NULL,
    status_anterior VARCHAR(50),
    status_novo VARCHAR(50),
    usuario_responsavel VARCHAR(50),
    FOREIGN KEY (id_voo) REFERENCES Voo(id_voo)
);

-- Tabela de Programa de Fidelidade
CREATE TABLE ProgramaFidelidade (
    id_programa INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT,
    milhas_minimas INT NOT NULL,
    beneficios TEXT
);

-- Índices para otimização
CREATE INDEX idx_voo_partida ON Voo(horario_partida);
CREATE INDEX idx_voo_status ON Voo(status);
CREATE INDEX idx_voo_rota ON Voo(id_origem, id_destino);
CREATE INDEX idx_reserva_cliente ON Reserva(id_cliente);
CREATE INDEX idx_reserva_voo ON Reserva(id_voo);
CREATE INDEX idx_reserva_data ON Reserva(data_reserva);
CREATE INDEX idx_cliente_preferencial ON Cliente(cliente_preferencial, aceita_comunicados);



-- VIEWS --
-- View para voos com poltronas disponíveis
CREATE VIEW Vw_VoosComPoltronasDisponiveis AS
SELECT v.codigo_voo, 
       a1.nome AS origem, 
       a2.nome AS destino,
       v.horario_partida,
       COUNT(p.id_poltrona) AS total_poltronas,
       SUM(CASE WHEN p.disponivel = TRUE THEN 1 ELSE 0 END) AS poltronas_disponiveis,
       v.preco_base
FROM Voo v
JOIN Aeroporto a1 ON v.id_origem = a1.id_aeroporto
JOIN Aeroporto a2 ON v.id_destino = a2.id_aeroporto
JOIN Poltrona p ON v.id_voo = p.id_voo
GROUP BY v.id_voo;

-- View para clientes preferenciais para mala direta
CREATE VIEW Vw_ClientesPreferenciais AS
SELECT id_cliente, 
       CONCAT(primeiro_nome, ' ', sobrenome) AS nome_completo,
       email, 
       telefone, 
       preferencia_comunicacao,
       milhas_acumuladas,
       categoria_fidelidade
FROM Cliente
WHERE cliente_preferencial = TRUE AND aceita_comunicados = TRUE;

-- View para voos com escalas
CREATE VIEW Vw_VoosComEscalas AS
SELECT 
    v.codigo_voo, 
    a1.nome as origem, 
    a2.nome as destino,
    v.horario_partida,
    v.horario_chegada_previsto,
    COUNT(e.id_escala) as num_escalas,
    GROUP_CONCAT(
        CONCAT(e.ordem, '. ', ae.nome, ' (', 
        DATE_FORMAT(e.horario_chegada_previsto, '%H:%i'), ' - ', 
        DATE_FORMAT(e.horario_partida_previsto, '%H:%i'), ')') 
        ORDER BY e.ordem SEPARATOR ' | '
    ) as detalhes_escalas
FROM Voo v
JOIN Aeroporto a1 ON v.id_origem = a1.id_aeroporto
JOIN Aeroporto a2 ON v.id_destino = a2.id_aeroporto
LEFT JOIN Escala e ON v.id_voo = e.id_voo
LEFT JOIN Aeroporto ae ON e.id_aeroporto = ae.id_aeroporto
GROUP BY v.id_voo, v.codigo_voo, a1.nome, a2.nome, v.horario_partida, v.horario_chegada_previsto;



-- View para ocupação de aeronaves
CREATE VIEW Vw_OcupacaoAeronaves AS
SELECT a.codigo_aeronave,
       ta.nome AS tipo_aeronave,
       COUNT(DISTINCT v.id_voo) AS num_voos,
       COUNT(DISTINCT CASE WHEN v.status IN ('Embarque', 'Decolado', 'EmRota') THEN v.id_voo END) AS voos_ativos,
       COUNT(DISTINCT rp.id_reserva_poltrona) AS poltronas_ocupadas,
       ta.capacidade_maxima AS capacidade_total,
       ROUND(COUNT(DISTINCT rp.id_reserva_poltrona) / ta.capacidade_maxima * 100, 2) AS ocupacao_percentual
FROM Aeronave a
JOIN TipoAeronave ta ON a.id_tipo = ta.id_tipo
LEFT JOIN Voo v ON a.id_aeronave = v.id_aeronave
LEFT JOIN Poltrona p ON v.id_voo = p.id_voo
LEFT JOIN ReservaPoltrona rp ON p.id_poltrona = rp.id_poltrona
GROUP BY a.id_aeronave;

-- PROCEDURES --
-- Procedure para reserva de poltronas
DELIMITER //
CREATE PROCEDURE Sp_ReservarPoltrona(
    IN p_id_cliente INT,
    IN p_id_voo INT,
    IN p_codigo_poltrona VARCHAR(10),
    IN p_forma_pagamento VARCHAR(20),
    OUT p_resultado VARCHAR(100),
    OUT p_codigo_reserva VARCHAR(20)
)
BEGIN
    DECLARE v_id_poltrona INT;
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_classe VARCHAR(20);
    DECLARE v_valor_final DECIMAL(10,2);
    DECLARE v_codigo_reserva VARCHAR(20);
    
    -- Verifica se a poltrona existe e está disponível
    SELECT p.id_poltrona, v.preco_base, p.classe INTO v_id_poltrona, v_preco, v_classe
    FROM Poltrona p
    JOIN Voo v ON p.id_voo = v.id_voo
    WHERE p.id_voo = p_id_voo AND p.codigo = p_codigo_poltrona AND p.disponivel = TRUE;
    
    IF v_id_poltrona IS NULL THEN
        SET p_resultado = 'Poltrona não disponível';
        SET p_codigo_reserva = NULL;
    ELSE
        -- Calcula valor final (poderia incluir lógica de classe, descontos, etc.)
        SET v_valor_final = CASE 
            WHEN v_classe = 'Primeira' THEN v_preco * 2.5
            WHEN v_classe = 'Executiva' THEN v_preco * 1.8
            ELSE v_preco
        END;
        
        -- Gera código de reserva aleatório
        SET v_codigo_reserva = CONCAT('RES', FLOOR(RAND() * 1000000));
        
        -- Cria a reserva
        INSERT INTO Reserva (id_cliente, id_voo, data_reserva, status, codigo_reserva, valor_total, forma_pagamento, status_pagamento)
        VALUES (p_id_cliente, p_id_voo, NOW(), 'Confirmada', v_codigo_reserva, v_valor_final, p_forma_pagamento, 'Completo');
        
        -- Reserva a poltrona
        INSERT INTO ReservaPoltrona (id_reserva, id_poltrona, status)
        VALUES (LAST_INSERT_ID(), v_id_poltrona, 'Reservada');
        
        -- Atualiza disponibilidade da poltrona
        UPDATE Poltrona SET disponivel = FALSE WHERE id_poltrona = v_id_poltrona;
        
        SET p_resultado = 'Reserva realizada com sucesso';
        SET p_codigo_reserva = v_codigo_reserva;
    END IF;
END //
DELIMITER ;

-- Procedure para check-in automático
DELIMITER //
CREATE PROCEDURE Sp_CheckIn(
    IN p_codigo_reserva VARCHAR(20),
    OUT p_resultado VARCHAR(100)
)
BEGIN
    DECLARE v_id_reserva INT;
    DECLARE v_status VARCHAR(20);
    DECLARE v_id_voo INT;
    DECLARE v_horario_partida DATETIME;
    
    -- Obtém informações da reserva
    SELECT r.id_reserva, r.status, r.id_voo, v.horario_partida 
    INTO v_id_reserva, v_status, v_id_voo, v_horario_partida
    FROM Reserva r
    JOIN Voo v ON r.id_voo = v.id_voo
    WHERE r.codigo_reserva = p_codigo_reserva;
    
    IF v_id_reserva IS NULL THEN
        SET p_resultado = 'Reserva não encontrada';
    ELSEIF v_status != 'Confirmada' THEN
        SET p_resultado = 'Reserva não está confirmada';
    ELSEIF NOW() > v_horario_partida THEN
        SET p_resultado = 'Check-in não permitido após horário de partida';
    ELSEIF NOW() < DATE_SUB(v_horario_partida, INTERVAL 48 HOUR) THEN
        SET p_resultado = 'Check-in só permitido até 48 horas antes do voo';
    ELSE
        -- Atualiza status da reserva
        UPDATE Reserva SET status = 'CheckIn', data_checkin = NOW() 
        WHERE id_reserva = v_id_reserva;
        
        -- Atualiza status das poltronas reservadas
        UPDATE ReservaPoltrona rp
        JOIN Poltrona p ON rp.id_poltrona = p.id_poltrona
        SET rp.status = 'Ocupada'
        WHERE rp.id_reserva = v_id_reserva AND p.id_voo = v_id_voo;
        
        SET p_resultado = 'Check-in realizado com sucesso';
    END IF;
END //
DELIMITER ;


-- TRIGGERS --

-- Trigger para atualizar milhas quando um voo é concluído
DELIMITER //
CREATE TRIGGER Tg_AtualizarMilhas
AFTER UPDATE ON Voo
FOR EACH ROW
BEGIN
    DECLARE milhas INT;
    
    IF NEW.status = 'Aterrissado' AND OLD.status != 'Aterrissado' THEN
        -- Calcula milhas baseadas na distância (simplificado)
        SET milhas = NEW.duracao_estimada_minutos * 2; -- Exemplo: 2 milhas por minuto
        
        -- Atualiza milhas para clientes com reservas confirmadas neste voo
        UPDATE Cliente c
        JOIN Reserva r ON c.id_cliente = r.id_cliente
        SET c.milhas_acumuladas = c.milhas_acumuladas + milhas
        WHERE r.id_voo = NEW.id_voo AND r.status = 'Confirmada';
    END IF;
END//
DELIMITER ;



-- Trigger para registrar histórico de alterações em voos
DELIMITER //
CREATE TRIGGER Tg_RegistrarHistoricoVoo
AFTER UPDATE ON Voo
FOR EACH ROW
BEGIN
    IF NEW.status != OLD.status OR NEW.horario_partida != OLD.horario_partida OR NEW.horario_chegada_previsto != OLD.horario_chegada_previsto THEN
        INSERT INTO HistoricoVoo (id_voo, data_alteracao, status_anterior, status_novo, usuario_responsavel)
        VALUES (NEW.id_voo, NOW(), OLD.status, NEW.status, CURRENT_USER());
    END IF;
END //
DELIMITER ;

-- Trigger para verificar disponibilidade de poltronas antes de reservar
DELIMITER //
CREATE TRIGGER Tg_VerificarDisponibilidadePoltrona
BEFORE INSERT ON ReservaPoltrona
FOR EACH ROW
BEGIN
    DECLARE v_disponivel BOOLEAN;
    
    SELECT disponivel INTO v_disponivel
    FROM Poltrona
    WHERE id_poltrona = NEW.id_poltrona;
    
    IF NOT v_disponivel THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Poltrona não está disponível para reserva';
    END IF;
END //
DELIMITER ;