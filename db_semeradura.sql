-- Inserção de dados (SEEDS)
-- Tipos de Aeronave
INSERT INTO TipoAeronave (nome, descricao, capacidade_maxima, alcance_km, fabricante) VALUES
('Boeing 737-800', 'Aeronave comercial de médio alcance', 189, 5765, 'Boeing'),
('Airbus A320', 'Aeronave comercial de médio alcance', 180, 6150, 'Airbus'),
('Embraer E195', 'Jato regional', 122, 3700, 'Embraer');

-- Aeronaves
INSERT INTO Aeronave (id_tipo, codigo_aeronave, data_fabricacao, ultima_manutencao, proxima_manutencao, horas_voo, status) VALUES
(1, 'PP-XTA', '2018-05-15', '2023-10-20', '2024-04-20', 12500, 'Ativa'),
(2, 'PP-XTB', '2019-03-22', '2023-11-15', '2024-05-15', 9800, 'Ativa'),
(3, 'PP-XTC', '2020-08-10', '2023-12-05', '2024-06-05', 6500, 'Ativa');

-- Aeroportos
INSERT INTO Aeroporto (codigo_iata, nome, cidade, pais, terminal) VALUES
('GRU', 'Aeroporto Internacional de São Paulo/Guarulhos', 'São Paulo', 'Brasil', '2'),
('GIG', 'Aeroporto Internacional do Rio de Janeiro/Galeão', 'Rio de Janeiro', 'Brasil', '1'),
('JFK', 'Aeroporto Internacional John F. Kennedy', 'Nova Iorque', 'Estados Unidos', '4'),
('MIA', 'Aeroporto Internacional de Miami', 'Miami', 'Estados Unidos', 'D');

-- Voos
INSERT INTO Voo (id_aeronave, codigo_voo, id_origem, id_destino, horario_partida, horario_chegada_previsto, duracao_estimada_minutos, portao_embarque, status, preco_base) VALUES
(1, 'LA1234', 1, 2, '2024-03-20 08:00:00', '2024-03-20 09:30:00', 90, '15', 'Agendado', 500.00),
(2, 'LA5678', 2, 3, '2024-03-21 22:00:00', '2024-03-22 06:30:00', 510, '25', 'Agendado', 2500.00),
(3, 'LA9012', 1, 4, '2024-03-22 10:30:00', '2024-03-22 18:45:00', 495, '12', 'Agendado', 1800.00);

-- Poltronas (com localização melhorada)
INSERT INTO Poltrona (id_aeronave, id_voo, codigo, classe, localizacao, disponivel) VALUES
-- Boeing 737-800 (id_aeronave = 1) no voo LA1234 (id_voo = 1)
(1, 1, '1A', 'Primeira', 'Janela-Esquerda', TRUE),
(1, 1, '1B', 'Primeira', 'Corredor-Direita', TRUE),
(1, 1, '2A', 'Executiva', 'Janela-Esquerda', TRUE),
(1, 1, '2B', 'Executiva', 'Corredor-Direita', TRUE),
(1, 1, '10A', 'Economica', 'Janela-Esquerda', TRUE),
(1, 1, '10B', 'Economica', 'Meio', TRUE),
(1, 1, '10C', 'Economica', 'Corredor-Direita', TRUE);

-- Escalas
INSERT INTO Escala (id_voo, id_aeroporto, ordem, horario_partida_previsto, horario_chegada_previsto, tempo_espera_minutos, status) VALUES
(2, 4, 1, '2024-03-21 22:00:00', '2024-03-22 04:00:00', 90, 'Prevista'),
(2, 4, 2, '2024-03-22 05:30:00', '2024-03-22 06:30:00', NULL, 'Prevista');

-- Clientes (com mais dados para mala direta)
INSERT INTO Cliente (tipo_documento, cpf, passaporte, primeiro_nome, sobrenome, data_nascimento, email, telefone, endereco, cidade, estado, pais, cep, nacionalidade, cliente_preferencial, data_cadastro, milhas_acumuladas, aceita_comunicados, preferencia_comunicacao, data_ultima_comunicacao, categoria_fidelidade) VALUES
('CPF', '123.456.789-00', NULL, 'João', 'Silva', '1985-05-15', 'joao.silva@email.com', '+5511987654321', 'Rua A, 123', 'São Paulo', 'SP', 'Brasil', '01234-567', 'Brasileira', TRUE, '2020-02-10', 15000, TRUE, 'Email', '2024-02-01', 'Gold'),
('Passaporte', NULL, 'AB123456', 'Maria', 'Santos', '1990-08-22', 'maria.santos@email.com', '+5511912345678', 'Avenida B, 456', 'Rio de Janeiro', 'RJ', 'Brasil', '04567-890', 'Brasileira', FALSE, '2021-05-15', 5000, TRUE, 'WhatsApp', '2024-01-15', 'Basic'),
('CPF', '987.654.321-00', 'CD789012', 'Carlos', 'Oliveira', '1978-11-30', 'carlos.oliveira@email.com', '+5521987654321', 'Rua C, 789', 'Belo Horizonte', 'MG', 'Brasil', '03015-200', 'Brasileira', TRUE, '2019-10-20', 25000, FALSE, 'SMS', '2023-12-20', 'Platinum');

-- Tripulação
INSERT INTO Tripulacao (primeiro_nome, sobrenome, funcao, licenca, data_validade_licenca) VALUES
('Pedro', 'Almeida', 'Piloto', 'ATP-12345', '2025-12-31'),
('Ana', 'Costa', 'CoPiloto', 'CPL-67890', '2024-11-30'),
('Luiza', 'Fernandes', 'Comissario', 'CMS-54321', '2026-05-15');

-- Tripulação por Voo
INSERT INTO TripulacaoVoo (id_voo, id_tripulante, funcao_no_voo) VALUES
(1, 1, 'Comandante'),
(1, 2, 'Co-piloto'),
(1, 3, 'Chefe de Cabine');

-- Programa de Fidelidade
INSERT INTO ProgramaFidelidade (nome, descricao, milhas_minimas, beneficios) VALUES
('Basic', 'Nível inicial', 0, 'Acumulação de milhas'),
('Silver', 'Nível intermediário', 10000, 'Prioridade no check-in, bagagem extra'),
('Gold', 'Nível avançado', 25000, 'Acesso a salas VIP, upgrade prioritário'),
('Platinum', 'Nível premium', 50000, 'Upgrade garantido quando disponível, assistência pessoal');

-- Reservas
INSERT INTO Reserva (id_cliente, id_voo, data_reserva, status, codigo_reserva, valor_total, forma_pagamento, status_pagamento, data_checkin) VALUES
(1, 1, '2024-03-15 10:30:00', 'Confirmada', 'RES123456', 550.00, 'CartaoCredito', 'Completo', NULL),
(2, 2, '2024-03-16 14:45:00', 'Confirmada', 'RES789012', 2750.00, 'Milhas', 'Completo', NULL),
(3, 3, '2024-03-17 09:15:00', 'EmEspera', 'RES345678', 1980.00, 'CartaoCredito', 'Pendente', NULL);

-- Poltronas Reservadas
INSERT INTO ReservaPoltrona (id_reserva, id_poltrona, status) VALUES
(1, 1, 'Reservada'),
(2, 3, 'Reservada'),
(3, 5, 'Reservada');

-- Bagagens
INSERT INTO Bagagem (id_reserva, codigo_bagagem, peso, tipo, status, localizacao_atual) VALUES
(1, 'BAG123456', 23.5, 'Despachada', 'Despachada', 'Porão - Setor A'),
(2, 'BAG789012', 12.0, 'Mao', 'Embarque', 'Cabine - Compartimento superior'),
(2, 'BAG345678', 18.0, 'Despachada', 'Despachada', 'Esteira de desembarque - Terminal D');