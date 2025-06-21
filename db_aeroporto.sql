-- Criação do banco de dados
DROP DATABASE IF EXISTS EmpresaTransporteAereo;
CREATE DATABASE EmpresaTransporteAereo;
USE EmpresaTransporteAereo;

-- 1. Tabelas de Suporte Geográfico 
CREATE TABLE Pais (
    id_pais INT AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL UNIQUE,
    sigla VARCHAR(3) NOT NULL UNIQUE,
    CONSTRAINT pk_pais PRIMARY KEY (id_pais)
);

CREATE TABLE Cidade (
    id_cidade INT AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    id_pais INT NOT NULL,
    CONSTRAINT pk_cidade PRIMARY KEY (id_cidade),
    CONSTRAINT fk_cidade_pais FOREIGN KEY (id_pais) REFERENCES Pais(id_pais)
);

-- 2. Tipos de Aeronave 
CREATE TABLE TipoAeronave (
    id_tipo INT AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    comprimento_pista_minimo DOUBLE NOT NULL,
    consumo_combustivel_km_litro DOUBLE NOT NULL,
    CONSTRAINT pk_tipo_aeronave PRIMARY KEY (id_tipo)
);

-- 3. Classes por Tipo de Aeronave
CREATE TABLE ClasseTipoAeronave (
    id_classe_tipo INT AUTO_INCREMENT,
    id_tipo INT NOT NULL,
    classe ENUM('Economica', 'Executiva', 'Primeira', 'Luxo') NOT NULL,
    quantidade INT NOT NULL,
    CONSTRAINT pk_classe_tipo PRIMARY KEY (id_classe_tipo),
    CONSTRAINT fk_classe_tipo FOREIGN KEY (id_tipo) REFERENCES TipoAeronave(id_tipo),
    CONSTRAINT unq_tipo_classe UNIQUE (id_tipo, classe)
);

-- 4. Aeronaves
CREATE TABLE Aeronave (
    id_aeronave INT AUTO_INCREMENT,
    id_tipo INT NOT NULL,
    codigo_registro VARCHAR(20) NOT NULL UNIQUE,
    data_fabricacao DATE NOT NULL,
    capacidade_carga_kg DOUBLE NOT NULL,
    altitude_maxima_metros DOUBLE NOT NULL,
    autonomia_km DOUBLE NOT NULL,
    capacidade_tanque_litros DOUBLE NOT NULL,
    proxima_manutencao DATE NOT NULL,
    horas_voo_total INT DEFAULT 0,
    status ENUM('Disponivel', 'Em manutencao', 'Desativada') DEFAULT 'Disponivel',
    CONSTRAINT pk_aeronave PRIMARY KEY (id_aeronave),
    CONSTRAINT fk_aeronave_tipo FOREIGN KEY (id_tipo) REFERENCES TipoAeronave(id_tipo)
);

-- 5. Aeroportos
CREATE TABLE Aeroporto (
    id_aeroporto INT AUTO_INCREMENT,
    codigo_iata VARCHAR(3) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    id_cidade INT NOT NULL,
    CONSTRAINT pk_aeroporto PRIMARY KEY (id_aeroporto),
    CONSTRAINT fk_aeroporto_cidade FOREIGN KEY (id_cidade) REFERENCES Cidade(id_cidade)
);

-- 6. Infraestrutura Aeroportuária
CREATE TABLE Terminal (
    id_terminal INT AUTO_INCREMENT,
    id_aeroporto INT NOT NULL,
    codigo_terminal VARCHAR(10) NOT NULL,
    status ENUM('Operacional', 'Manutencao', 'Desativado') DEFAULT 'Operacional',
    CONSTRAINT pk_terminal PRIMARY KEY (id_terminal),
    CONSTRAINT fk_terminal_aeroporto FOREIGN KEY (id_aeroporto) REFERENCES Aeroporto(id_aeroporto),
    CONSTRAINT unq_aeroporto_terminal UNIQUE (id_aeroporto, codigo_terminal)
);

CREATE TABLE Portao (
    id_portao INT AUTO_INCREMENT,
    id_terminal INT NOT NULL,
    codigo_portao VARCHAR(10) NOT NULL,
    status ENUM('Livre', 'Ocupado', 'Manutencao') DEFAULT 'Livre',
    CONSTRAINT pk_portao PRIMARY KEY (id_portao),
    CONSTRAINT fk_portao_terminal FOREIGN KEY (id_terminal) REFERENCES Terminal(id_terminal),
    CONSTRAINT unq_terminal_portao UNIQUE (id_terminal, codigo_portao)
);

CREATE TABLE Pista (
    id_pista INT AUTO_INCREMENT,
    id_aeroporto INT NOT NULL,
    codigo_pista VARCHAR(10) NOT NULL,
    comprimento_metros DOUBLE NOT NULL,
    status ENUM('Operacional', 'Interditada','Manutencao') DEFAULT 'Operacional',
    CONSTRAINT pk_pista PRIMARY KEY (id_pista),
    CONSTRAINT fk_pista_aeroporto FOREIGN KEY (id_aeroporto) REFERENCES Aeroporto(id_aeroporto),
    CONSTRAINT unq_aeroporto_pista UNIQUE (id_aeroporto, codigo_pista)
);

-- 7. Voos
CREATE TABLE Voo (
    id_voo INT AUTO_INCREMENT,
    id_aeronave INT NOT NULL,
    codigo_voo VARCHAR(10) NOT NULL UNIQUE,
    id_origem INT NOT NULL,
    id_destino INT NOT NULL,
    distancia_km DOUBLE NOT NULL,
    partida_prevista DATETIME NOT NULL,
    chegada_prevista DATETIME NOT NULL,
    partida_real DATETIME,
    chegada_real DATETIME,
    id_portao_embarque INT,
    combustivel_carregado_litros DOUBLE DEFAULT 0,
    status ENUM('Agendado', 'Embarque', 'Decolado', 'Em rota', 'Aterrissado', 'Cancelado', 'Atrasado') DEFAULT 'Agendado',
    status_anterior VARCHAR(50) DEFAULT NULL,
    CONSTRAINT pk_voo PRIMARY KEY (id_voo),
    CONSTRAINT fk_voo_aeronave FOREIGN KEY (id_aeronave) REFERENCES Aeronave(id_aeronave),
    CONSTRAINT fk_voo_origem FOREIGN KEY (id_origem) REFERENCES Aeroporto(id_aeroporto),
    CONSTRAINT fk_voo_destino FOREIGN KEY (id_destino) REFERENCES Aeroporto(id_aeroporto),
    CONSTRAINT fk_voo_portao FOREIGN KEY (id_portao_embarque) REFERENCES Portao(id_portao),
    CONSTRAINT chk_partida CHECK (partida_prevista < chegada_prevista)
);

-- 8. Escalas 
CREATE TABLE Escala (
    id_escala INT AUTO_INCREMENT,
    id_voo INT NOT NULL,
    id_aeroporto INT NOT NULL,
    ordem INT NOT NULL,
    partida_prevista DATETIME NOT NULL,
    chegada_prevista DATETIME NOT NULL,
    partida_real DATETIME,
    chegada_real DATETIME,
    status ENUM('Prevista', 'Realizada', 'Cancelada', 'Atrasada') DEFAULT 'Prevista',
    CONSTRAINT pk_escala PRIMARY KEY (id_escala),
    CONSTRAINT fk_escala_voo FOREIGN KEY (id_voo) REFERENCES Voo(id_voo),
    CONSTRAINT fk_escala_aeroporto FOREIGN KEY (id_aeroporto) REFERENCES Aeroporto(id_aeroporto),
    CONSTRAINT unq_voo_ordem UNIQUE (id_voo, ordem),
    CONSTRAINT chk_escala_order CHECK (ordem > 0)
);

-- 9. Configuração de Poltronas 
CREATE TABLE Poltrona (
    id_poltrona INT AUTO_INCREMENT,
    id_aeronave INT NOT NULL,
    codigo VARCHAR(10) NOT NULL,
    classe ENUM('Economica', 'Executiva', 'Primeira', 'Luxo') NOT NULL,
    posicao ENUM('Janela', 'Corredor', 'Meio') NOT NULL,
    lado ENUM('Esquerda', 'Direita') NOT NULL,
    CONSTRAINT pk_poltrona PRIMARY KEY (id_poltrona),
    CONSTRAINT fk_poltrona_aeronave FOREIGN KEY (id_aeronave) REFERENCES Aeronave(id_aeronave),
    CONSTRAINT unq_aeronave_poltrona UNIQUE (id_aeronave, codigo)
);

-- 10. Disponibilidade por Voo
CREATE TABLE PoltronaVoo (
    id_poltrona_voo INT AUTO_INCREMENT,
    id_voo INT NOT NULL,
    id_poltrona INT NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_poltrona_voo PRIMARY KEY (id_poltrona_voo),
    CONSTRAINT fk_poltronavoo_voo FOREIGN KEY (id_voo) REFERENCES Voo(id_voo),
    CONSTRAINT fk_poltronavoo_poltrona FOREIGN KEY (id_poltrona) REFERENCES Poltrona(id_poltrona),
    CONSTRAINT unq_voo_poltrona UNIQUE (id_voo, id_poltrona)
);

-- 11. Endereços 
CREATE TABLE Endereco (
    id_endereco INT AUTO_INCREMENT,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(10),
    complemento VARCHAR(50),
    cep VARCHAR(10) NOT NULL,
    id_cidade INT NOT NULL,
    CONSTRAINT pk_endereco PRIMARY KEY (id_endereco),
    CONSTRAINT fk_endereco_cidade FOREIGN KEY (id_cidade) REFERENCES Cidade(id_cidade)
);

-- 12. Clientes
CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT,
    documento VARCHAR(20) NOT NULL UNIQUE,
    tipo_documento ENUM('CPF', 'Passaporte', 'RG', 'Certidao') NOT NULL,
    primeiro_nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    data_nascimento DATE NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefone VARCHAR(20),
    id_endereco INT,
    nacionalidade VARCHAR(50),
    data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE),
    milhas_acumuladas INT DEFAULT 0,
    aceita_marketing BOOLEAN DEFAULT TRUE,
    preferencia_comunicacao ENUM('Email', 'SMS', 'Correio', 'WhatsApp'),
    categoria_fidelidade ENUM('Basic', 'Silver', 'Gold', 'Platinum') DEFAULT 'Basic',
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT fk_cliente_endereco FOREIGN KEY (id_endereco) REFERENCES Endereco(id_endereco),
    CONSTRAINT chk_idade CHECK (TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE()) > 0)
);

-- 13. Documentos para Crianças
CREATE TABLE DocumentoCrianca (
    id_documento INT AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    tipo_documento ENUM('CertidaoNascimento', 'RG', 'Passaporte') NOT NULL,
    numero VARCHAR(50) NOT NULL,
    data_emissao DATE NOT NULL,
    orgao_emissor VARCHAR(50),
    CONSTRAINT pk_documento PRIMARY KEY (id_documento),
    CONSTRAINT fk_documento_cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT unq_cliente_tipo UNIQUE (id_cliente, tipo_documento)
);

-- 14. Responsáveis
CREATE TABLE Responsavel (
    id_responsavel INT AUTO_INCREMENT,
    id_crianca INT NOT NULL,
    id_adulto INT NOT NULL,
    parentesco ENUM('Pai', 'Mae', 'Tutor', 'ResponsavelLegal') NOT NULL,
    documento_responsabilidade VARCHAR(50) NOT NULL,
    data_inicio DATE NOT NULL,
    data_termino DATE,
    CONSTRAINT pk_responsavel PRIMARY KEY (id_responsavel),
    CONSTRAINT fk_responsavel_crianca FOREIGN KEY (id_crianca) REFERENCES Cliente(id_cliente),
    CONSTRAINT fk_responsavel_adulto FOREIGN KEY (id_adulto) REFERENCES Cliente(id_cliente),
    CONSTRAINT chk_datas CHECK (data_inicio <= COALESCE(data_termino, '9999-12-31'))
);

-- 15. Reservas 
CREATE TABLE Reserva (
    id_reserva INT AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    data_reserva DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    codigo_reserva VARCHAR(20) NOT NULL UNIQUE,
    status ENUM('Confirmada', 'Cancelada', 'Em espera', 'CheckIn') NOT NULL,
    CONSTRAINT pk_reserva PRIMARY KEY (id_reserva),
    CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

-- 16. Pagamentos
CREATE TABLE Pagamento (
    id_pagamento INT AUTO_INCREMENT,
    id_reserva INT NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    forma_pagamento ENUM('CartaoCredito', 'Debito', 'Boleto', 'Transferencia', 'Pix','Dinheiro') NOT NULL,
    status ENUM('Pendente', 'Completo', 'Reembolsado', 'Falhou') DEFAULT 'Pendente',
    data_processamento DATETIME,
    CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
    CONSTRAINT fk_pagamento_reserva FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva)
);

-- 17. Passageiros por Reserva 
CREATE TABLE PassageiroReserva (
    id_passageiro_reserva INT AUTO_INCREMENT,
    id_reserva INT NOT NULL,
    id_cliente INT NOT NULL,
    id_responsavel INT,
    CONSTRAINT pk_passageiro_reserva PRIMARY KEY (id_passageiro_reserva),
    CONSTRAINT fk_passageiro_reserva FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva),
    CONSTRAINT fk_passageiro_cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT fk_passageiro_responsavel FOREIGN KEY (id_responsavel) REFERENCES Responsavel(id_responsavel),
    CONSTRAINT unq_reserva_cliente UNIQUE (id_reserva, id_cliente)
);

-- 18. Assentos Reservados
CREATE TABLE AssentoReserva (
    id_assento_reserva INT AUTO_INCREMENT,
    id_passageiro_reserva INT NOT NULL,
    id_voo INT NOT NULL,
    id_poltrona_voo INT NOT NULL,
    CONSTRAINT pk_assento_reserva PRIMARY KEY (id_assento_reserva),
    CONSTRAINT fk_assento_passageiro FOREIGN KEY (id_passageiro_reserva) REFERENCES PassageiroReserva(id_passageiro_reserva),
    CONSTRAINT fk_assento_voo FOREIGN KEY (id_voo) REFERENCES Voo(id_voo),
    CONSTRAINT fk_assento_poltrona FOREIGN KEY (id_poltrona_voo) REFERENCES PoltronaVoo(id_poltrona_voo),
    CONSTRAINT unq_voo_poltrona UNIQUE (id_voo, id_poltrona_voo)
);

-- 19. Bagagem
CREATE TABLE Bagagem (
    id_bagagem INT AUTO_INCREMENT,
    id_assento_reserva INT NOT NULL,
    codigo_bagagem VARCHAR(20) NOT NULL UNIQUE,
    peso_kg DECIMAL(5,2) NOT NULL,
    tipo ENUM('Mao', 'Despachada') NOT NULL,
    status ENUM('Despachada', 'Transito', 'Entregue', 'Extraviada') NOT NULL,
    localizacao_atual VARCHAR(100),
    data_hora_status DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_bagagem PRIMARY KEY (id_bagagem),
    CONSTRAINT fk_bagagem_assento FOREIGN KEY (id_assento_reserva) REFERENCES AssentoReserva(id_assento_reserva),
    CONSTRAINT chk_peso CHECK (peso_kg > 0)
);

-- 20. Tripulação 
CREATE TABLE Tripulante (
    id_tripulante INT AUTO_INCREMENT,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    primeiro_nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    data_validade_licenca DATE NOT NULL,
    data_ultimo_treinamento DATE NOT NULL,
    CONSTRAINT pk_tripulante PRIMARY KEY (id_tripulante),
    CONSTRAINT chk_validade_licenca CHECK (data_validade_licenca > CURRENT_DATE)
);

-- 21. Habilitação de Veículos para Tripulantes
CREATE TABLE HabilitacaoVeiculo (
    id_habilitacao INT AUTO_INCREMENT,
    id_tripulante INT NOT NULL,
    tipo_veiculo ENUM('Aviao', 'Helicoptero', 'Jato', 'TurboHelice') NOT NULL,
    CONSTRAINT pk_habilitacao PRIMARY KEY (id_habilitacao),
    CONSTRAINT fk_habilitacao_tripulante FOREIGN KEY (id_tripulante) REFERENCES Tripulante(id_tripulante),
    CONSTRAINT unq_tripulante_veiculo UNIQUE (id_tripulante, tipo_veiculo)
);

-- 22. Tripulação por Voo
CREATE TABLE TripulacaoVoo (
    id_tripulacao_voo INT AUTO_INCREMENT,
    id_voo INT NOT NULL,
    id_tripulante INT NOT NULL,
    funcao ENUM('Comandante', 'Copiloto', 'Comissario', 'Mecanico', 'Medico') NOT NULL,
    CONSTRAINT pk_tripulacao_voo PRIMARY KEY (id_tripulacao_voo),
    CONSTRAINT fk_tripulacao_voo FOREIGN KEY (id_voo) REFERENCES Voo(id_voo),
    CONSTRAINT fk_tripulacao_tripulante FOREIGN KEY (id_tripulante) REFERENCES Tripulante(id_tripulante),
    CONSTRAINT unq_voo_tripulante UNIQUE (id_voo, id_tripulante)
);

-- 23. Histórico de Status de Voo 
CREATE TABLE HistoricoStatusVoo (
    id_historico INT AUTO_INCREMENT,
    id_voo INT NOT NULL,
    status_anterior VARCHAR(50) NOT NULL,
    status_novo VARCHAR(50) NOT NULL,
    data_hora_mudanca DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responsavel VARCHAR(100) NOT NULL,
    CONSTRAINT pk_historico PRIMARY KEY (id_historico),
    CONSTRAINT fk_historico_voo FOREIGN KEY (id_voo) REFERENCES Voo(id_voo)
);

-- 24. Manutenções
CREATE TABLE ManutencaoAeronave (
    id_manutencao INT AUTO_INCREMENT,
    id_aeronave INT NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_conclusao DATETIME,
    tipo ENUM('Preventiva', 'Corretiva', 'Programada', 'Emergencial') NOT NULL,
    descricao TEXT,
    custo DECIMAL(10,2),
    CONSTRAINT pk_manutencao PRIMARY KEY (id_manutencao),
    CONSTRAINT fk_manutencao_aeronave FOREIGN KEY (id_aeronave) REFERENCES Aeronave(id_aeronave),
    CONSTRAINT chk_datas_manutencao CHECK (data_inicio <= COALESCE(data_conclusao, '9999-12-31'))
);

-- Views
-- Formatar CPF
CREATE VIEW View_Cliente_CPF_Formatado AS
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

-- Mostrar capacidade disponível por voo
CREATE VIEW View_Capacidade_Voo AS
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
    ) - fn_calcular_peso_bagagens_voo(v.id_voo)) AS capacidade_restante
FROM Voo v
JOIN Aeronave a ON v.id_aeronave = a.id_aeronave;

-- Verificar viagens críticas
CREATE VIEW View_Voos_Criticos AS
SELECT 
    v.id_voo,
    v.codigo_voo,
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
    END AS autonomia
FROM Voo v;

-- Mostrar detalhes de configuração de aeronaves
CREATE VIEW View_Configuracao_Aeronave AS
SELECT 
    a.id_aeronave,
    a.codigo_registro,
    ta.nome AS tipo_aeronave,
    cta.classe,
    cta.quantidade AS quantidade_planejada,
    COUNT(p.id_poltrona) AS quantidade_implementada
FROM Aeronave a
JOIN TipoAeronave ta ON a.id_tipo = ta.id_tipo
JOIN ClasseTipoAeronave cta ON ta.id_tipo = cta.id_tipo
LEFT JOIN Poltrona p ON a.id_aeronave = p.id_aeronave AND cta.classe = p.classe
GROUP BY a.id_aeronave, cta.classe;

-- Funções
-- Calcular peso total das bagagens em um voo
DELIMITER //
CREATE FUNCTION fn_calcular_peso_bagagens_voo(p_id_voo INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_peso DECIMAL(10,2);
    
    SELECT COALESCE(SUM(b.peso_kg), 0) INTO total_peso
    FROM Bagagem b
    JOIN AssentoReserva ar ON b.id_assento_reserva = ar.id_assento_reserva
    JOIN PoltronaVoo pv ON ar.id_poltrona_voo = pv.id_poltrona_voo
    WHERE pv.id_voo = p_id_voo;
    
    RETURN total_peso;
END //
DELIMITER ;

-- Calcular capacidade disponível considerando combustível
DELIMITER //
CREATE FUNCTION fn_capacidade_disponivel_com_combustivel(
    p_id_aeronave INT,
    p_combustivel_litros DOUBLE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_capacidade_max DECIMAL(10,2);
    DECLARE v_peso_combustivel DECIMAL(10,2);
    
    -- Densidade média do combustível de aviação (kg/l)
    DECLARE densidade_combustivel DECIMAL(3,2) DEFAULT 0.8;
    
    SELECT capacidade_carga_kg INTO v_capacidade_max
    FROM Aeronave
    WHERE id_aeronave = p_id_aeronave;
    
    SET v_peso_combustivel = p_combustivel_litros * densidade_combustivel;
    
    RETURN v_capacidade_max - v_peso_combustivel;
END //
DELIMITER ;

-- Verificar autonomia vs distância
DELIMITER //
CREATE FUNCTION fn_verificar_autonomia_voo(p_id_voo INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_autonomia_km DOUBLE;
    DECLARE v_distancia_km DOUBLE;
    DECLARE v_combustivel_litros DOUBLE;
    DECLARE v_consumo_medio DOUBLE;
    DECLARE v_autonomia_com_reserva DOUBLE;
    
    SELECT a.autonomia_km, v.distancia_km, v.combustivel_carregado_litros, t.consumo_combustivel_km_litro
    INTO v_autonomia_km, v_distancia_km, v_combustivel_litros, v_consumo_medio
    FROM Voo v
    JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
    JOIN TipoAeronave t ON a.id_tipo = t.id_tipo
    WHERE v.id_voo = p_id_voo;
    
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

-- Calcular necessidade de escala
DELIMITER //
CREATE FUNCTION fn_calcular_necessidade_escala(p_id_voo INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_autonomia_km DOUBLE;
    DECLARE v_distancia_km DOUBLE;
    
    SELECT a.autonomia_km, v.distancia_km
    INTO v_autonomia_km, v_distancia_km
    FROM Voo v
    JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
    WHERE v.id_voo = p_id_voo;
    
    -- Considerar reserva de 20% para segurança
    IF v_autonomia_km * 0.8 < v_distancia_km THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END //
DELIMITER ;

-- Verificar combustível suficiente
DELIMITER //
CREATE FUNCTION fn_verificar_combustivel_suficiente(p_id_voo INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_combustivel_litros DOUBLE;
    DECLARE v_distancia_km DOUBLE;
    DECLARE v_consumo_medio DOUBLE;
    DECLARE v_autonomia_combustivel DOUBLE;
    
    SELECT v.combustivel_carregado_litros, v.distancia_km, t.consumo_combustivel_km_litro
    INTO v_combustivel_litros, v_distancia_km, v_consumo_medio
    FROM Voo v
    JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
    JOIN TipoAeronave t ON a.id_tipo = t.id_tipo
    WHERE v.id_voo = p_id_voo;
    
    -- Calcular autonomia com o combustível carregado
    SET v_autonomia_combustivel = v_combustivel_litros / v_consumo_medio;
    
    -- Considerar reserva de 15% para segurança
    IF v_autonomia_combustivel >= v_distancia_km * 1.15 THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END //
DELIMITER ;

-- Calcular peso máximo permitido considerando combustível
DELIMITER //
CREATE FUNCTION fn_calcular_peso_maximo_permitido(
    p_id_voo INT
) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_capacidade_disponivel DECIMAL(10,2);
    DECLARE v_peso_bagagens DECIMAL(10,2);
    DECLARE v_peso_passageiros DECIMAL(10,2);
    
    -- Capacidade disponível considerando combustível
    SELECT fn_capacidade_disponivel_com_combustivel(v.id_aeronave, v.combustivel_carregado_litros)
    INTO v_capacidade_disponivel
    FROM Voo v
    WHERE v.id_voo = p_id_voo;
    
    -- Peso total das bagagens
    SET v_peso_bagagens = fn_calcular_peso_bagagens_voo(p_id_voo);
    
    -- Estimativa de peso dos passageiros (75kg por passageiro)
    SELECT COUNT(pr.id_passageiro_reserva) * 75
    INTO v_peso_passageiros
    FROM PassageiroReserva pr
    JOIN AssentoReserva ar ON pr.id_passageiro_reserva = ar.id_passageiro_reserva
    JOIN PoltronaVoo pv ON ar.id_poltrona_voo = pv.id_poltrona_voo
    WHERE pv.id_voo = p_id_voo;
    
    RETURN v_capacidade_disponivel - v_peso_bagagens - v_peso_passageiros;
END //
DELIMITER ;

-- Triggers
-- Registrar histórico de status
DELIMITER //
CREATE TRIGGER trg_historico_status_voo
AFTER UPDATE ON Voo
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO HistoricoStatusVoo (
            id_voo, 
            status_anterior, 
            status_novo, 
            responsavel
        ) VALUES (
            NEW.id_voo,
            OLD.status,
            NEW.status,
            'Sistema'
        );
    END IF;
END //
DELIMITER ;

-- Criar poltronas quando uma nova aeronave é inserida
DELIMITER //
CREATE TRIGGER trg_criar_poltronas_aeronave
AFTER INSERT ON Aeronave
FOR EACH ROW
BEGIN
    DECLARE v_classe VARCHAR(20);
    DECLARE v_quantidade INT;
    DECLARE v_counter INT DEFAULT 1;
    DECLARE done BOOLEAN DEFAULT FALSE;
    
    DECLARE cur_classes CURSOR FOR
        SELECT classe, quantidade 
        FROM ClasseTipoAeronave 
        WHERE id_tipo = NEW.id_tipo;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_classes;
    
    read_loop: LOOP
        FETCH cur_classes INTO v_classe, v_quantidade;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET v_counter = 1;
        WHILE v_counter <= v_quantidade DO
            INSERT INTO Poltrona (
                id_aeronave, 
                codigo, 
                classe, 
                posicao, 
                lado
            ) VALUES (
                NEW.id_aeronave,
                CONCAT(v_classe, '-', LPAD(v_counter, 3, '0')),
                v_classe,
                CASE 
                    WHEN v_counter % 6 IN (1,2) THEN 'Janela'
                    WHEN v_counter % 6 IN (3,4) THEN 'Meio'
                    ELSE 'Corredor'
                END,
                CASE 
                    WHEN v_counter % 2 = 0 THEN 'Direita' 
                    ELSE 'Esquerda'
                END
            );
            SET v_counter = v_counter + 1;
        END WHILE;
    END LOOP;
    
    CLOSE cur_classes;
END //
DELIMITER ;

-- Verificar combustível antes de decolar
DELIMITER //
CREATE TRIGGER trg_verificar_combustivel_decolagem
BEFORE UPDATE ON Voo
FOR EACH ROW
BEGIN
    IF NEW.status = 'Decolado' AND OLD.status <> 'Decolado' THEN
        IF NOT fn_verificar_combustivel_suficiente(NEW.id_voo) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Combustível insuficiente para o voo';
        END IF;
    END IF;
END //
DELIMITER ;

-- Atualizar status anterior ao mudar status
DELIMITER //
CREATE TRIGGER trg_atualizar_status_anterior
BEFORE UPDATE ON Voo
FOR EACH ROW
SET NEW.status_anterior = OLD.status;
//
DELIMITER ;

-- Procedures
-- Calcular necessidade de escala e combustível
DELIMITER //
CREATE PROCEDURE sp_verificar_viagem(p_id_voo INT)
BEGIN
    DECLARE v_necessidade_escala BOOLEAN;
    DECLARE v_combustivel_suficiente BOOLEAN;
    DECLARE v_autonomia_suficiente BOOLEAN;
    
    SET v_necessidade_escala = fn_calcular_necessidade_escala(p_id_voo);
    SET v_combustivel_suficiente = fn_verificar_combustivel_suficiente(p_id_voo);
    SET v_autonomia_suficiente = fn_verificar_autonomia_voo(p_id_voo);
    
    SELECT 
        v_necessidade_escala AS precisa_escala,
        v_combustivel_suficiente AS combustivel_suficiente,
        v_autonomia_suficiente AS autonomia_suficiente;
END //
DELIMITER ;