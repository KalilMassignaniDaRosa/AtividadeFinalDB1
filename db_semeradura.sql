USE EmpresaTransporteAereo;

-- 1. Países
INSERT INTO Pais (nome, sigla) VALUES 
('Brasil', 'BRA'),
('Estados Unidos', 'USA'),
('França', 'FRA'),
('Japão', 'JPN'),
('Reino Unido', 'GBR'),
('Canadá', 'CAN'),
('Alemanha', 'DEU'),
('Austrália', 'AUS'),
('China', 'CHN'),
('Índia', 'IND'),
('México', 'MEX'),
('Itália', 'ITA'),
('Espanha', 'ESP'),
('Coreia do Sul', 'KOR'),
('Argentina', 'ARG'),
('África do Sul', 'ZAF');

-- 2. Cidades
INSERT INTO Cidade (nome, id_pais) VALUES 
('São Paulo', 1),
('Rio de Janeiro', 1),
('Nova York', 2),
('Paris', 3),
('Tóquio', 4),
('Londres', 5),
('Toronto', 6),
('Berlim', 7),
('Sydney', 8),
('Pequim', 9),
('Mumbai', 10),
('Cidade do México', 11),
('Roma', 12),
('Madri', 13),
('Seul', 14),
('Buenos Aires', 15),
('Cidade do Cabo', 16),
('Frankfurt', 7),
('Melbourne', 8),
('Xangai', 9),
('Delhi', 10),
('Monterrey', 11);

-- 3. Tipos de Aeronave
INSERT INTO TipoAeronave (nome, descricao, comprimento_pista_minimo, consumo_combustivel_km_litro) VALUES 
('Boeing 737', 'Aeronave comercial de médio porte', 2500, 3.5),
('Airbus A320', 'Aeronave comercial de médio porte', 2300, 3.2),
('Embraer E195', 'Jato regional', 1800, 2.8),
('Boeing 777', 'Aeronave de longo alcance', 3000, 4.0),
('Airbus A380', 'Aeronave de grande porte', 3500, 5.0),
('Cessna 172', 'Aeronave de pequeno porte', 800, 1.5),
('Boeing 747', 'Aeronave wide-body', 3200, 4.5),
('Airbus A350', 'Aeronave moderna de longo alcance', 2800, 3.8);

-- 4. Classes por Tipo de Aeronave
INSERT INTO ClasseTipoAeronave (id_tipo, classe, quantidade) VALUES 
(1, 'Economica', 150),
(1, 'Executiva', 30),
(2, 'Economica', 140),
(2, 'Executiva', 35),
(3, 'Economica', 100),
(3, 'Executiva', 20),
(4, 'Economica', 300),
(4, 'Executiva', 50),
(4, 'Primeira', 20),
(5, 'Economica', 500),
(5, 'Executiva', 100),
(5, 'Primeira', 50),
(5, 'Luxo', 10),
(6, 'Economica', 3),
(7, 'Economica', 400),
(7, 'Executiva', 70),
(7, 'Primeira', 30),
(8, 'Economica', 250),
(8, 'Executiva', 40),
(8, 'Primeira', 15);

-- 5. Aeronaves
INSERT INTO Aeronave (id_tipo, codigo_registro, data_fabricacao, capacidade_carga_kg, altitude_maxima_metros, autonomia_km, capacidade_tanque_litros, proxima_manutencao, horas_voo_total, status) VALUES 
(1, 'PR-AAB', '2018-05-15', 20000, 12500, 5000, 30000, '2025-12-01', 5000, 'Disponivel'),
(1, 'PR-AAA', '2017-06-10', 21000, 12500, 5500, 31000, '2025-12-01', 5200, 'Disponivel'),
(2, 'PR-BBC', '2019-03-20', 18000, 12000, 4800, 28000, '2025-11-15', 4000, 'Disponivel'),
(2, 'PR-BBB', '2018-04-22', 19000, 12000, 5200, 29000, '2025-11-15', 4800, 'Disponivel'),
(3, 'PR-CCD', '2020-01-10', 15000, 11000, 4000, 25000, '2025-10-20', 3000, 'Disponivel'),
(3, 'PR-CCC', '2019-09-05', 16000, 11000, 4000, 26000, '2025-10-20', 3200, 'Disponivel'),
(4, 'PR-XYZ', '2015-08-20', 35000, 13000, 12000, 50000, '2025-01-10', 8000, 'Disponivel'),
(5, 'PR-ABC', '2016-11-15', 45000, 14000, 15000, 60000, '2025-02-15', 6500, 'Disponivel'),
(6, 'PR-DEF', '2021-03-05', 500, 4000, 500, 200, '2025-03-20', 200, 'Disponivel'),
(7, 'PR-GHI', '2014-07-10', 40000, 13500, 13000, 55000, '2025-04-25', 9000, 'EmManutencao'),
(8, 'PR-JKL', '2019-09-25', 30000, 12500, 11000, 45000, '2025-05-30', 4500, 'Disponivel'),
(4, 'PR-MNO', '2017-12-01', 34000, 13000, 11800, 49000, '2025-06-05', 7000, 'Disponivel');

-- 6. Aeroportos
INSERT INTO Aeroporto (codigo_iata, nome, id_cidade) VALUES 
('GRU', 'Aeroporto Internacional de Guarulhos', 1),
('GIG', 'Aeroporto Internacional do Rio de Janeiro', 2),
('JFK', 'Aeroporto Internacional John F. Kennedy', 3),
('CDG', 'Aeroporto Internacional Charles de Gaulle', 4),
('HND', 'Aeroporto Internacional de Haneda', 5),
('BER', 'Aeroporto de Berlim-Brandemburgo', 8),
('SYD', 'Aeroporto Internacional de Sydney', 9),
('PEK', 'Aeroporto Internacional de Pequim', 10),
('BOM', 'Aeroporto Internacional de Chhatrapati Shivaji', 11),
('MEX', 'Aeroporto Internacional da Cidade do México', 12),
('FCO', 'Aeroporto Leonardo da Vinci-Fiumicino', 13),
('MAD', 'Aeroporto Adolfo Suárez Madrid-Barajas', 14),
('ICN', 'Aeroporto Internacional de Incheon', 15),
('EZE', 'Aeroporto Internacional de Ezeiza', 16),
('CPT', 'Aeroporto Internacional da Cidade do Cabo', 17);

-- 7. Terminais
INSERT INTO Terminal (id_aeroporto, codigo_terminal, status) VALUES 
(1, 'T1', 'Operacional'),
(1, 'T2', 'Operacional'),
(2, 'T1', 'Operacional'),
(3, 'T4', 'Operacional'),
(4, 'T2', 'Operacional'),
(5, 'T1', 'Operacional'),
(6, 'T3', 'Operacional'),
(7, 'T1', 'Operacional'),
(8, 'T2', 'Operacional'),
(9, 'T1', 'Operacional'),
(10, 'T2', 'Operacional'),
(11, 'T3', 'Operacional'),
(12, 'T1', 'Operacional'),
(13, 'T2', 'Operacional'),
(14, 'T1', 'Operacional'),
(15, 'T2', 'Operacional');

-- 8. Portões
INSERT INTO Portao (id_terminal, codigo_portao, status) VALUES 
(1, 'A1', 'Livre'),
(1, 'A2', 'Livre'),
(2, 'B1', 'Livre'),
(3, 'C1', 'Livre'),
(4, 'D1', 'Livre'),
(5, 'E1', 'Livre'),
(6, 'F1', 'Livre'),
(7, 'A3', 'Livre'),
(8, 'B2', 'Livre'),
(9, 'C2', 'Ocupado'),
(10, 'D2', 'Livre'),
(11, 'E2', 'Livre'),
(12, 'F2', 'Livre'),
(13, 'G1', 'Livre'),
(14, 'H1', 'Livre'),
(15, 'I1', 'Ocupado'),
(16, 'J1', 'Livre');

-- 9. Pistas
INSERT INTO Pista (id_aeroporto, codigo_pista, comprimento_metros, status) VALUES 
(1, '09/27', 3000, 'Operacional'),
(1, '10/28', 3500, 'Operacional'),
(2, '15/33', 3200, 'Operacional'),
(3, '04/22', 4000, 'Operacional'),
(4, '08/26', 3800, 'Operacional'),
(5, '16/34', 3500, 'Operacional'),
(6, '07/25', 3400, 'Operacional'),
(7, '16/34', 3800, 'Operacional'),
(8, '05/23', 4000, 'Operacional'),
(9, '12/30', 3500, 'Operacional'),
(10, '09/27', 3700, 'Operacional'),
(11, '14/32', 3600, 'Operacional'),
(12, '06/24', 3900, 'Operacional'),
(13, '10/28', 4100, 'Operacional'),
(14, '08/26', 3300, 'Operacional'),
(15, '13/31', 3500, 'Manutencao');

-- 10. Voos
INSERT INTO Voo (id_aeronave, codigo_voo, id_origem, id_destino, distancia_km, partida_prevista, chegada_prevista, status) VALUES 
(1, 'AZ123', 1, 3, 8000, '2023-10-15 10:00:00', '2023-10-15 18:00:00', 'Agendado'),
(2, 'AZ456', 3, 4, 6000, '2023-10-16 14:00:00', '2023-10-16 20:00:00', 'Agendado'),
(3, 'AZ789', 2, 1, 400, '2023-10-17 08:00:00', '2023-10-17 09:00:00', 'Agendado'),
(4, 'AZ100', 1, 3, 8000, '2025-07-10 10:00:00', '2025-07-10 18:00:00', 'Agendado'),
(5, 'AZ200', 3, 4, 6000, '2025-07-11 14:00:00', '2025-07-11 20:00:00', 'Agendado'),
(6, 'AZ300', 2, 1, 400, '2025-07-12 08:00:00', '2025-07-12 09:00:00', 'Agendado'),
(7, 'AZ901', 6, 8, 14000, '2025-07-15 08:00:00', '2025-07-15 23:00:00', 'Agendado'),
(8, 'AZ902', 10, 7, 11000, '2025-07-16 12:00:00', '2025-07-17 01:00:00', 'Agendado'),
(9, 'AZ903', 11, 12, 300, '2025-07-17 09:00:00', '2025-07-17 09:45:00', 'Agendado'),
(10, 'AZ904', 13, 14, 8000, '2025-07-18 14:00:00', '2025-07-18 23:00:00', 'Agendado'),
(11, 'AZ905', 15, 6, 9500, '2025-07-19 06:00:00', '2025-07-19 17:00:00', 'Agendado'),
(12, 'AZ906', 8, 10, 13000, '2025-07-20 10:00:00', '2025-07-21 00:00:00', 'Agendado');

-- 11. Escalas
INSERT INTO Escala (id_voo, id_aeroporto, ordem, partida_prevista, chegada_prevista, status) VALUES 
(7, 7, 1, '2025-07-15 14:00:00', '2025-07-15 15:00:00', 'Prevista'),
(8, 9, 1, '2025-07-16 18:00:00', '2025-07-16 19:00:00', 'Prevista'),
(10, 11, 1, '2025-07-18 18:00:00', '2025-07-18 19:00:00', 'Prevista'),
(12, 6, 1, '2025-07-20 16:00:00', '2025-07-20 17:00:00', 'Prevista');

-- 12. Poltronas
INSERT INTO Poltrona (id_aeronave, codigo, classe, posicao, lado) VALUES 
(1, '1A', 'Executiva', 'Janela', 'Esquerda'),
(1, '1B', 'Executiva', 'Corredor', 'Esquerda'),
(1, '10A', 'Economica', 'Janela', 'Esquerda'),
(1, '10B', 'Economica', 'Meio', 'Esquerda'),
(1, '10C', 'Economica', 'Corredor', 'Esquerda'),
(2, '1A', 'Executiva', 'Janela', 'Esquerda'),
(2, '1B', 'Executiva', 'Corredor', 'Esquerda'),
(3, '1A', 'Executiva', 'Janela', 'Esquerda'),
(4, '1A', 'Executiva', 'Janela', 'Esquerda'),
(4, '1B', 'Executiva', 'Corredor', 'Esquerda'),
(4, '10A', 'Economica', 'Janela', 'Esquerda'),
(5, '1A', 'Executiva', 'Janela', 'Esquerda'),
(6, '1A', 'Economica', 'Janela', 'Esquerda'), -- Ajustado para Economica (Cessna 172 só tem Economica)
(7, '2A', 'Primeira', 'Janela', 'Direita'),
(7, '2B', 'Primeira', 'Corredor', 'Direita'),
(8, '3A', 'Luxo', 'Janela', 'Esquerda'),
(8, '20C', 'Economica', 'Corredor', 'Direita'),
(9, '1C', 'Economica', 'Corredor', 'Esquerda'),
(10, '5A', 'Primeira', 'Janela', 'Esquerda'),
(11, '15B', 'Executiva', 'Meio', 'Direita'),
(12, '10D', 'Economica', 'Janela', 'Direita');

-- 13. Poltronas por Voo
INSERT INTO PoltronaVoo (id_voo, id_poltrona, disponivel) VALUES 
(1, 1, TRUE),
(1, 2, TRUE),
(1, 3, TRUE),
(1, 4, TRUE),
(1, 5, TRUE),
(2, 6, TRUE),
(2, 7, TRUE),
(3, 8, TRUE),
(4, 9, TRUE),
(4, 10, TRUE),
(4, 11, TRUE),
(5, 12, TRUE),
(6, 13, TRUE),
(7, 14, TRUE),
(7, 15, TRUE),
(8, 16, TRUE),
(8, 17, FALSE),
(9, 18, TRUE),
(10, 19, TRUE),
(11, 20, TRUE),
(12, 21, TRUE); -- Ajustado para TRUE para permitir reserva

-- 14. Endereços
INSERT INTO Endereco (logradouro, numero, complemento, cep, id_cidade) VALUES 
('Av. Paulista', '1000', 'Apto 101', '01310-100', 1),
('Rua Copacabana', '200', 'Apto 202', '22050-000', 2),
('5th Avenue', '500', 'Suite 300', '10018', 3),
('Champs-Élysées', '75', NULL, '75008', 4),
('Unter den Linden', '10', 'Apto 5', '10117', 8),
('George Street', '250', NULL, '2000', 9),
('Changan Avenue', '88', 'Bloco B', '100006', 10),
('Marine Drive', '15', 'Apto 301', '400020', 11),
('Avenida Reforma', '500', NULL, '06600', 12),
('Via del Corso', '320', 'Apto 12', '00186', 13),
('Calle Gran Vía', '45', NULL, '28013', 14),
('Gangnam-daero', '123', 'Apto 1001', '06236', 15);

-- 15. Pessoas
INSERT INTO Pessoa (
    primeiro_nome, sobrenome, data_nascimento,
    tipo_documento, numero_documento,
    email, telefone, nacionalidade,
    data_cadastro, categoria_fidelidade,
    aceita_marketing, preferencia_comunicacao
) VALUES 
('João', 'Silva', '1980-05-15', 'Cpf', '12345678901', 'joao.silva@email.com', '+5511999999999', 'Brasileira', '2023-01-01', 'Gold', TRUE, 'Email'),
('Maria', 'Santos', '1985-08-20', 'Cpf', '98765432109', 'maria.santos@email.com', '+5511888888888', 'Brasileira', '2023-01-01', 'Silver', TRUE, 'WhatsApp'),
('John', 'Doe', '1975-03-10', 'Passaporte', 'X11122233', 'john.doe@email.com', '+12125551234', 'Americana', '2023-01-01', 'Basic', FALSE, 'Sms'),
('Jean', 'Dupont', '1990-11-25', 'Passaporte', 'F44455566', 'jean.dupont@email.com', '+33123456789', 'Francesa', '2023-01-01', 'Platinum', TRUE, 'Email'),
('Anna', 'Schmidt', '1988-04-12', 'Passaporte', 'DE1234567', 'anna.schmidt@email.com', '+493012345678', 'Alemã', '2023-02-01', 'Silver', TRUE, 'Email'),
('Liam', 'Wilson', '1992-07-19', 'Passaporte', 'AU9876543', 'liam.wilson@email.com', '+61298765432', 'Australiana', '2023-03-01', 'Gold', FALSE, 'Sms'),
('Zhang', 'Wei', '1985-09-30', 'Passaporte', 'CN4567891', 'zhang.wei@email.com', '+8613912345678', 'Chinesa', '2023-04-01', 'Platinum', TRUE, 'WhatsApp'),
('Priya', 'Patel', '1990-12-05', 'Passaporte', 'IN1122334', 'priya.patel@email.com', '+919876543210', 'Indiana', '2023-05-01', 'Basic', TRUE, 'Email'),
('Carlos', 'Lopez', '1983-03-15', 'Passaporte', 'MX5566778', 'carlos.lopez@email.com', '+525512345678', 'Mexicana', '2023-06-01', 'Gold', FALSE, 'Sms'),
('Giulia', 'Rossi', '1995-06-22', 'Passaporte', 'IT9988776', 'giulia.rossi@email.com', '+390612345678', 'Italiana', '2023-07-01', 'Silver', TRUE, 'WhatsApp'),
('Sofia', 'Gomez', '1987-11-10', 'Passaporte', 'ES3344556', 'sofia.gomez@email.com', '+349123456789', 'Espanhola', '2023-08-01', 'Platinum', TRUE, 'Email'),
('Min-ho', 'Kim', '1993-01-25', 'Passaporte', 'KR6677889', 'minho.kim@email.com', '+821012345678', 'Sul-coreana', '2023-09-01', 'Basic', FALSE, 'Sms');

-- 16. Clientes
INSERT INTO Cliente (id_pessoa, milhas_acumuladas) VALUES 
(1, 35000),
(2, 25000),
(3, 15000),
(4, 80000),
(5, 20000),
(6, 45000),
(7, 60000),
(8, 10000),
(9, 30000),
(10, 25000),
(11, 70000),
(12, 15000);

-- 17. Documentos para Crianças
INSERT INTO DocumentoCrianca (id_pessoa, tipo_documento, numero, data_emissao, orgao_emissor) VALUES 
(1, 'CertidaoNascimento', '123456789', '2020-01-15', 'Cartório Central'),
(5, 'Passaporte', 'DE1234568', '2020-05-10', 'Consulado Alemão'),
(9, 'Passaporte', 'MX5566779', '2019-08-15', 'Secretaria de Relações Exteriores');

-- 18. Responsáveis
INSERT INTO Responsavel (id_crianca, id_adulto, parentesco, documento_responsabilidade, data_inicio) VALUES 
(1, 2, 'Mae', 'DOC123', '2020-01-15'),
(5, 6, 'Tutor', 'DOC456', '2020-05-10'),
(9, 10, 'Pai', 'DOC789', '2019-08-15');

-- 19. Reservas
INSERT INTO Reserva (id_cliente, codigo_reserva, status) VALUES 
(1, 'RES123456', 'Confirmada'),
(2, 'RES654321', 'Confirmada'),
(3, 'RES987654', 'Confirmada'),
(4, 'RES1000', 'Confirmada'),
(5, 'RES2001', 'Confirmada'),
(6, 'RES2002', 'EmEspera'),
(7, 'RES2003', 'Cancelada'),
(8, 'RES2004', 'CheckIn'),
(9, 'RES2005', 'Confirmada'),
(10, 'RES2006', 'Confirmada');

-- 20. Pagamentos
INSERT INTO Pagamento (id_reserva, valor_total, forma_pagamento, status, data_processamento) VALUES 
(1, 1500.00, 'CartaoCredito', 'Completo', '2023-10-01 15:30:00'),
(2, 2000.00, 'Pix', 'Completo', '2023-10-02 10:15:00'),
(3, 1800.00, 'CartaoCredito', 'Completo', '2023-10-03 14:45:00'),
(4, 1500.00, 'CartaoCredito', 'Completo', '2025-07-01 09:00:00'),
(5, 2500.00, 'Transferencia', 'Completo', '2025-07-01 10:00:00'),
(6, 3000.00, 'Boleto', 'Pendente', NULL),
(7, 1800.00, 'Pix', 'Reembolsado', '2025-07-02 15:00:00'),
(8, 2200.00, 'CartaoCredito', 'Completo', '2025-07-03 09:30:00'),
(9, 2700.00, 'Dinheiro', 'Completo', '2025-07-04 11:00:00'),
(10, 1900.00, 'Debito', 'Completo', '2025-07-05 14:00:00');

-- 21. Passageiros por Reserva
INSERT INTO PassageiroReserva (id_reserva, id_cliente) VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- 22. Assentos Reservados
INSERT INTO AssentoReserva (id_passageiro_reserva, id_voo, id_poltrona_voo) VALUES 
(1, 1, 1),
(2, 2, 6),
(3, 3, 8),
(4, 4, 9),
(5, 7, 14),
(6, 8, 16),
(7, 9, 18),
(8, 10, 19),
(9, 11, 20),
(10, 12, 21); -- Corrigido de 22 para 21

-- 23. Bagagem
INSERT INTO Bagagem (id_assento_reserva, codigo_bagagem, peso_kg, tipo, status) VALUES 
(1, 'BAG123456', 23.50, 'Despachada', 'Despachada'),
(2, 'BAG654321', 18.00, 'Despachada', 'Despachada'),
(3, 'BAG987654', 10.00, 'Mao', 'Despachada'),
(4, 'BAG0001', 23.5, 'Despachada', 'Despachada'),
(5, 'BAG2001', 25.00, 'Despachada', 'Transito'),
(6, 'BAG2002', 12.00, 'Mao', 'Entregue'),
(7, 'BAG2003', 20.50, 'Despachada', 'Extraviada'),
(8, 'BAG2004', 22.00, 'Despachada', 'Despachada'),
(9, 'BAG2005', 15.00, 'Mao', 'Entregue'),
(10, 'BAG2006', 28.00, 'Despachada', 'Transito');

-- 24. Tripulação
INSERT INTO Tripulante (id_pessoa, data_validade_licenca, data_ultimo_treinamento) VALUES 
(1, '2025-12-31', '2023-06-15'),
(2, '2024-11-30', '2023-05-20'),
(3, '2024-10-31', '2023-04-10'),
(4, '2024-09-30', '2023-03-05'),
(5, '2026-01-15', '2024-01-10'),
(6, '2025-12-20', '2024-02-15'),
(7, '2025-11-25', '2024-03-20'),
(8, '2025-10-30', '2024-04-25');

-- 25. Habilitação de Veículos
INSERT INTO HabilitacaoVeiculo (id_tripulante, tipo_veiculo) VALUES 
(1, 'Aviao'),
(2, 'Aviao'),
(3, 'Aviao'),
(4, 'Aviao'),
(5, 'Jato'),
(6, 'Aviao'),
(7, 'TurboHelice'),
(8, 'Helicoptero');

-- 26. Tripulação por Voo
INSERT INTO TripulacaoVoo (id_voo, id_tripulante, funcao) VALUES 
(1, 1, 'Comandante'),
(1, 2, 'Copiloto'),
(1, 3, 'Comissario'),
(2, 1, 'Comandante'),
(2, 2, 'Copiloto'),
(2, 4, 'Comissario'),
(4, 1, 'Comandante'),
(4, 2, 'Copiloto'),
(4, 3, 'Comissario'),
(5, 1, 'Comandante'),
(5, 2, 'Copiloto'),
(7, 5, 'Comandante'),
(7, 6, 'Copiloto'),
(8, 7, 'Comandante'),
(8, 8, 'Comissario'),
(9, 5, 'Comandante'),
(10, 6, 'Copiloto');

-- 27. Histórico de Status de Voo
INSERT INTO HistoricoStatusVoo (id_voo, status_anterior, status_novo, data_hora_mudanca, responsavel) VALUES 
(1, 'Agendado', 'Embarque', '2023-10-15 09:00:00', 'Sistema'),
(1, 'Embarque', 'Decolado', '2023-10-15 10:05:00', 'TorreDeControle'),
(4, 'Agendado', 'Embarque', '2025-07-10 09:00:00', 'Sistema'),
(4, 'Embarque', 'Decolado', '2025-07-10 10:05:00', 'TorreDeControle'),
(7, 'Agendado', 'Embarque', '2025-07-15 07:00:00', 'Sistema'),
(8, 'Agendado', 'Atrasado', '2025-07-16 11:00:00', 'ControleDeTrafego'),
(10, 'Agendado', 'Cancelado', '2025-07-18 12:00:00', 'Operacoes');

-- 28. Manutenções
INSERT INTO ManutencaoAeronave (id_aeronave, data_inicio, data_conclusao, tipo, descricao, custo) VALUES 
(1, '2023-09-01 08:00:00', '2023-09-05 18:00:00', 'Preventiva', 'Manutenção periódica', 50000.00),
(2, '2023-08-15 08:00:00', '2023-08-20 18:00:00', 'Corretiva', 'Troca de peças hidráulicas', 75000.00),
(4, '2025-06-01 08:00:00', '2025-06-05 18:00:00', 'Preventiva', 'Revisão geral', 50000.00),
(5, '2025-05-15 08:00:00', '2025-05-20 18:00:00', 'Corretiva', 'Troca de peças', 75000.00),
(7, '2025-04-25 09:00:00', '2025-04-30 17:00:00', 'Programada', 'Revisão de motores', 60000.00),
(8, '2025-05-01 08:00:00', NULL, 'Emergencial', 'Falha hidráulica', 85000.00),
(9, '2025-03-15 10:00:00', '2025-03-16 18:00:00', 'Corretiva', 'Troca de pneus', 20000.00);