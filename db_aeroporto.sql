-- Criação do banco de dados
DROP DATABASE IF EXISTS EmpresaTransporteAereo;
CREATE DATABASE EmpresaTransporteAereo;
USE EmpresaTransporteAereo;

-- Tabela de Tipos de Aeronave
CREATE TABLE TipoAeronave (
    id_tipo INT AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT,
    comprimento_pista DOUBLE NOT NULL,
    CONSTRAINT pk_tipo_aeronave PRIMARY KEY (id_tipo)
);

-- Tabela de Aeronaves
CREATE TABLE Aeronave (
    id_aeronave INT AUTO_INCREMENT,
    id_tipo INT NOT NULL,
    codigo_aeronave VARCHAR(20) NOT NULL UNIQUE,
    data_fabricacao DATE NOT NULL,
    lotacao_maxima INT NOT NULL,
    capacidade_maxima DOUBLE NOT NULL,
    -- fazer calculo com comustivel
    capacidade_efetiva DOUBLE NOT NULL,
    altitude_maxima DOUBLE NOT NULL,
    ultima_manutencao DATE NOT NULL,
    -- quantos km por kilo/litro de combustivel
    autonomia DOUBLE NOT NULL,
    capacidade_tanque DOUBLE NOT NULL,
    tanque_atual DOUBLE NOT NULL,
    proxima_manutencao DATE NOT NULL,
    seguro BOOL,
    -- quantas horas já voou
    horas_voo INT DEFAULT 0,
    status ENUM('Disponivel', 'Em manutencao', 'Desativada') DEFAULT 'Disponivel',
    CONSTRAINT pk_aeronave PRIMARY KEY (id_aeronave)
);

-- Tabela de Aeroportos
CREATE TABLE Aeroporto (
    id_aeroporto INT AUTO_INCREMENT,
    codigo_iata VARCHAR(3) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    terminal VARCHAR(20),
    CONSTRAINT pk_aeroporto PRIMARY KEY (id_aeroporto)
);

-- fazer ligação com terminais
CREATE TABLE Terminal(
	id_terminal INT AUTO_INCREMENT,
    codigo VARCHAR(20) NOT NULL,
    id_voo INT NOT NULL,
    status_terminal ENUM('Disponivel', 'Indisponivel') DEFAULT 'Indisponivel',
    CONSTRAINT pk_termina PRIMARY KEY (id_terminal)
);

-- Tabela de Pistas
CREATE TABLE Pista(
	id_pista INT AUTO_INCREMENT,
    descricao TEXT NOT NULL,
    comprimento DOUBLE NOT NULL,
    largura DOUBLE NOT NULL,
    status_pista ENUM('Disponivel', 'Indisponivel') DEFAULT 'Indisponivel',
    ultima_manutencao DATE NOT NULL,
    proxima_manutencao DATE NOT NULL,
    CONSTRAINT pk_pista PRIMARY KEY (id_pista)
);

-- Tabela de Voos
CREATE TABLE Voo (
    id_voo INT AUTO_INCREMENT,
    id_aeronave INT NOT NULL,
    codigo_voo VARCHAR(10) NOT NULL UNIQUE,
    id_origem INT NOT NULL,
    id_destino INT NOT NULL,
    distancia_voo DOUBLE NOT NULL,
    escala BOOL NOT NULL,
    tipo_voo ENUM('Nacional', 'Internacional') NOT NULL,
    horario_partida DATETIME NOT NULL,
    horario_chegada_previsto DATETIME NOT NULL,
    duracao_estimada_minutos INT NOT NULL,
    horario_chegada_real DATETIME NULL,
    portao_embarque VARCHAR(10),
    status_atual ENUM('Agendado', 'Embarque', 'Decolado', 'Em rota', 'Aterrissado', 'Cancelado', 'Atrasado') NULL,
    status_anterior ENUM('Agendado', 'Embarque', 'Decolado', 'EmRota', 'Aterrissado', 'Cancelado', 'Atrasado') NOT NULL,
    CONSTRAINT pk_voo PRIMARY KEY (id_voo)
);

-- Tabela de Escalas
CREATE TABLE Escala (
    id_escala INT AUTO_INCREMENT,
    id_voo INT NOT NULL,
    id_aeroporto INT NOT NULL,
    ordem INT NOT NULL,
    horario_partida_previsto DATETIME NOT NULL,
    horario_chegada_previsto DATETIME NOT NULL,
    horario_partida_real DATETIME NULL,
    horario_chegada_real DATETIME NULL,
    tempo_espera_minutos INT,
    status ENUM('Prevista', 'Realizada', 'Cancelada', 'Atrasada') DEFAULT 'Prevista',
    UNIQUE (id_voo, ordem),
    CONSTRAINT pk_escala PRIMARY KEY (id_escala)
);

-- Tabela de Poltronas
CREATE TABLE Poltrona (
    id_poltrona INT AUTO_INCREMENT,
    id_aeronave INT NOT NULL,
    id_voo INT NOT NULL,
    codigo VARCHAR(10) NOT NULL, 
    classe ENUM('Economica', 'Executiva', 'Primeira') NOT NULL,
    localizacao ENUM('Janela-Esquerda', 'Janela-Direita', 'Corredor-Esquerda', 'Corredor-Direita', 'Meio') NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE,
    UNIQUE (id_aeronave, codigo, id_voo),
    CONSTRAINT pk_poltrona PRIMARY KEY (id_poltrona)
);

-- Tabela de Clientes
CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT,
    cpf VARCHAR(14) UNIQUE NULL,
    passaporte VARCHAR(20) UNIQUE NULL,
    primeiro_nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    data_nascimento DATE NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefone VARCHAR(20),
    endereco TEXT,
    cidade VARCHAR(50),
    estado VARCHAR(50),
    pais VARCHAR(50),
    cep VARCHAR(20),
    nacionalidade VARCHAR(50),
    data_cadastro DATE NOT NULL,
	milhas_acumuladas INT DEFAULT 0,
    aceita_comunicados BOOLEAN DEFAULT TRUE,
    preferencia_comunicacao ENUM('Email', 'SMS', 'Correio', 'WhatsApp'),
    data_ultima_comunicacao DATE,
    categoria_fidelidade ENUM('Basic', 'Silver', 'Gold', 'Platinum') DEFAULT 'Basic',
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente)
);

-- Tabela de Reservas
CREATE TABLE Reserva (
    id_reserva INT AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_voo INT NOT NULL,
    data_reserva DATETIME NOT NULL,
    status ENUM('Confirmada', 'Cancelada', 'Em espera', 'CheckIn') NOT NULL,
    codigo_reserva VARCHAR(20) NOT NULL UNIQUE,
    valor_total DOUBLE NOT NULL,
    forma_pagamento ENUM('Cartao de credito', 'Debito', 'Boleto', 'Transferencia', 'Pix','Dinheiro'),
    status_pagamento ENUM('Pendente', 'Completo', 'Reembolsado', 'Falhou') DEFAULT 'Pendente',
    data_checkin DATETIME,
    data_checkout DATETIME,
    CONSTRAINT pk_reserva PRIMARY KEY (id_reserva)
);

-- Tabela de Poltronas Reservadas
CREATE TABLE ReservaPoltrona (
    id_reserva_poltrona INT AUTO_INCREMENT,
    id_reserva INT NOT NULL,
    id_poltrona INT NOT NULL,
    status ENUM('Reservada', 'Ocupada') NOT NULL DEFAULT 'Reservada',
    UNIQUE (id_reserva, id_poltrona),
    CONSTRAINT pk_reserva_poltrona PRIMARY KEY (id_reserva_poltrona)
);

-- Tabela de Bagagem
CREATE TABLE Bagagem (
    id_bagagem INT AUTO_INCREMENT,
    id_reserva INT NOT NULL,
    codigo_bagagem VARCHAR(20) NOT NULL UNIQUE,
    peso DOUBLE NOT NULL,
    tipo ENUM('Mão', 'Despachada') NOT NULL,
    status ENUM('Embarque', 'Despachada', 'Extraviada', 'Entregue') NOT NULL,
    localizacao_atual VARCHAR(100) NULL,
    CONSTRAINT pk_bagagem PRIMARY KEY (id_bagagem)
);

-- Tabela de Tripulante
CREATE TABLE Tripulante (
    id_tripulante INT AUTO_INCREMENT,
    primeiro_nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    funcao ENUM('Piloto', 'Copiloto', 'Comissário', 'Engenheiro') NOT NULL,
    licenca VARCHAR(50),
    data_validade_licenca DATE,
    CONSTRAINT pk_tripulante PRIMARY KEY (id_tripulante)
);

-- Tabela de Tripulação por Voo
CREATE TABLE TripulacaoVoo (
    id_tripulacao_voo INT AUTO_INCREMENT,
    id_voo INT NOT NULL,
    id_tripulante INT NOT NULL,
    CONSTRAINT pk_tripulacao_voo PRIMARY KEY (id_tripulacao_voo)
);

-- Tabela de Histórico de Voo
CREATE TABLE HistoricoVoo (
    id_historico INT AUTO_INCREMENT,
    id_voo INT NOT NULL,
    -- ex: ver  voo atrasados
    status_anterior VARCHAR(50),
    status_novo VARCHAR(50),
	CONSTRAINT pk_historico_voo PRIMARY KEY (id_historico)
);