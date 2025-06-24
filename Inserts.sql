USE EmpresaTransporteAereo;

-- 1. Paises
INSERT INTO Pais (nome, sigla) VALUES 
('Brasil', 'BRA'),
('Estados Unidos', 'USA'),
('França', 'FRA'),
('Japão', 'JPN');

-- 2. Cidades
INSERT INTO Cidade (nome, id_pais) VALUES 
('São Paulo', 1),
('Rio de Janeiro', 1),
('Nova York', 2),
('Paris', 3),
('Tóquio', 4);

-- 3. Tipos de Aeronave
INSERT INTO TipoAeronave (nome, descricao, comprimento_pista_minimo, consumo_combustivel_km_litro) VALUES 
('Boeing 737', 'Aeronave comercial de médio porte', 2500, 3.5),
('Airbus A320', 'Aeronave comercial de médio porte', 2300, 3.2),
('Embraer E195', 'Jato regional', 1800, 2.8);

-- 4. Classes por Tipo de Aeronave
INSERT INTO ClasseTipoAeronave (id_tipo, classe, quantidade) VALUES 
(1, 'Economica', 150),
(1, 'Executiva', 30),
(2, 'Economica', 140),
(2, 'Executiva', 35),
(3, 'Economica', 100),
(3, 'Executiva', 20);

-- 5. Aeronaves
INSERT INTO Aeronave (id_tipo, codigo_registro, data_fabricacao, capacidade_carga_kg, altitude_maxima_metros, autonomia_km, capacidade_tanque_litros, proxima_manutencao, horas_voo_total, status) VALUES 
(1, 'PR-AAB', '2018-05-15', 20000, 12500, 5000, 30000, '2023-12-01', 5000, 'Disponivel'),
(2, 'PR-BBC', '2019-03-20', 18000, 12000, 4800, 28000, '2023-11-15', 4000, 'Disponivel'),
(3, 'PR-CCD', '2020-01-10', 15000, 11000, 4000, 25000, '2023-10-20', 3000, 'Disponivel');

-- 6. Aeroportos
INSERT INTO Aeroporto (codigo_iata, nome, id_cidade) VALUES 
('GRU', 'Aeroporto Internacional de Guarulhos', 1),
('GIG', 'Aeroporto Internacional do Rio de Janeiro', 2),
('JFK', 'Aeroporto Internacional John F. Kennedy', 3),
('CDG', 'Aeroporto Internacional Charles de Gaulle', 4),
('HND', 'Aeroporto Internacional de Haneda', 5);

-- 7. Terminais
INSERT INTO Terminal (id_aeroporto, codigo_terminal, status) VALUES 
(1, 'T1', 'Operacional'),
(1, 'T2', 'Operacional'),
(2, 'T1', 'Operacional'),
(3, 'T4', 'Operacional'),
(4, 'T2', 'Operacional'),
(5, 'T1', 'Operacional');

-- 8. Portões
INSERT INTO Portao (id_terminal, codigo_portao, status) VALUES 
(1, 'A1', 'Livre'),
(1, 'A2', 'Livre'),
(2, 'B1', 'Livre'),
(3, 'C1', 'Livre'),
(4, 'D1', 'Livre'),
(5, 'E1', 'Livre'),
(6, 'F1', 'Livre');

-- 9. Pistas
INSERT INTO Pista (id_aeroporto, codigo_pista, comprimento_metros, status) VALUES 
(1, '09/27', 3000, 'Operacional'),
(1, '10/28', 3500, 'Operacional'),
(2, '15/33', 3200, 'Operacional'),
(3, '04/22', 4000, 'Operacional'),
(4, '08/26', 3800, 'Operacional'),
(5, '16/34', 3500, 'Operacional');

-- 10. Voos
INSERT INTO Voo (id_aeronave, codigo_voo, id_origem, id_destino, distancia_km, partida_prevista, chegada_prevista, status) VALUES 
(1, 'AZ123', 1, 3, 8000, '2023-10-15 10:00:00', '2023-10-15 18:00:00', 'Agendado'),
(2, 'AZ456', 3, 4, 6000, '2023-10-16 14:00:00', '2023-10-16 20:00:00', 'Agendado'),
(3, 'AZ789', 2, 1, 400, '2023-10-17 08:00:00', '2023-10-17 09:00:00', 'Agendado');

-- 11. Escalas
INSERT INTO Escala (id_voo, id_aeroporto, ordem, partida_prevista, chegada_prevista, status) VALUES 
(1, 2, 1, '2023-10-15 12:00:00', '2023-10-15 13:00:00', 'Prevista');

-- 12. Poltronas (simplificado - apenas algumas para exemplo)
INSERT INTO Poltrona (id_aeronave, codigo, classe, posicao, lado) VALUES 
(1, '1A', 'Executiva', 'Janela', 'Esquerda'),
(1, '1B', 'Executiva', 'Corredor', 'Esquerda'),
(1, '10A', 'Economica', 'Janela', 'Esquerda'),
(1, '10B', 'Economica', 'Meio', 'Esquerda'),
(1, '10C', 'Economica', 'Corredor', 'Esquerda'),
(2, '1A', 'Executiva', 'Janela', 'Esquerda'),
(2, '1B', 'Executiva', 'Corredor', 'Esquerda'),
(3, '1A', 'Executiva', 'Janela', 'Esquerda');

-- 13. Poltronas por Voo (simplificado)
INSERT INTO PoltronaVoo (id_voo, id_poltrona, disponivel) VALUES 
(1, 1, TRUE),
(1, 2, TRUE),
(1, 3, TRUE),
(1, 4, TRUE),
(1, 5, TRUE),
(2, 6, TRUE),
(2, 7, TRUE),
(3, 8, TRUE);

-- 14. Endereços
INSERT INTO Endereco (logradouro, numero, complemento, cep, id_cidade) VALUES 
('Av. Paulista', '1000', 'Apto 101', '01310-100', 1),
('Rua Copacabana', '200', 'Apto 202', '22050-000', 2),
('5th Avenue', '500', 'Suite 300', '10018', 3),
('Champs-Élysées', '75', NULL, '75008', 4);

-- 15. Clientes
INSERT INTO Cliente (documento, tipo_documento, primeiro_nome, sobrenome, data_nascimento, email, telefone, id_endereco, nacionalidade, categoria_fidelidade) VALUES 
('12345678901', 'CPF', 'João', 'Silva', '1980-05-15', 'joao.silva@email.com', '+5511999999999', 1, 'Brasileira', 'Gold'),
('98765432109', 'CPF', 'Maria', 'Santos', '1985-08-20', 'maria.santos@email.com', '+5511888888888', 2, 'Brasileira', 'Silver'),
('11122233344', 'Passaporte', 'John', 'Doe', '1975-03-10', 'john.doe@email.com', '+12125551234', 3, 'Americana', 'Basic'),
('55566677788', 'Passaporte', 'Jean', 'Dupont', '1990-11-25', 'jean.dupont@email.com', '+33123456789', 4, 'Francesa', 'Platinum');

-- 16. Documentos para Crianças (exemplo)
INSERT INTO DocumentoCrianca (id_cliente, tipo_documento, numero, data_emissao, orgao_emissor) VALUES 
(1, 'CertidaoNascimento', '123456789', '2020-01-15', 'Cartório Central');

-- 17. Responsáveis (exemplo)
INSERT INTO Responsavel (id_crianca, id_adulto, parentesco, documento_responsabilidade, data_inicio) VALUES 
(1, 2, 'Mae', 'DOC123', '2020-01-15');

-- 18. Reservas
INSERT INTO Reserva (id_cliente, codigo_reserva, status) VALUES 
(1, 'RES123456', 'Confirmada'),
(2, 'RES654321', 'Confirmada'),
(3, 'RES987654', 'Confirmada');

-- 19. Pagamentos
INSERT INTO Pagamento (id_reserva, valor_total, forma_pagamento, status, data_processamento) VALUES 
(1, 1500.00, 'CartaoCredito', 'Completo', '2023-10-01 15:30:00'),
(2, 2000.00, 'Pix', 'Completo', '2023-10-02 10:15:00'),
(3, 1800.00, 'CartaoCredito', 'Completo', '2023-10-03 14:45:00');

-- 20. Passageiros por Reserva
INSERT INTO PassageiroReserva (id_reserva, id_cliente) VALUES 
(1, 1),
(2, 2),
(3, 3);

-- 21. Assentos Reservados
INSERT INTO AssentoReserva (id_passageiro_reserva, id_voo, id_poltrona_voo) VALUES 
(1, 1, 1),
(2, 2, 6),
(3, 3, 8);

-- 22. Bagagem
INSERT INTO Bagagem (id_assento_reserva, codigo_bagagem, peso_kg, tipo, status) VALUES 
(1, 'BAG123456', 23.50, 'Despachada', 'Despachada'),
(2, 'BAG654321', 18.00, 'Despachada', 'Despachada'),
(3, 'BAG987654', 10.00, 'Mao', 'Despachada');

-- 23. Tripulação
INSERT INTO Tripulante (matricula, primeiro_nome, sobrenome, data_validade_licenca, data_ultimo_treinamento) VALUES 
('T1001', 'Carlos', 'Piloto', '2025-12-31', '2023-06-15'),
('T1002', 'Ana', 'Copiloto', '2024-11-30', '2023-05-20'),
('T2001', 'Roberto', 'Comissario', '2024-10-31', '2023-04-10'),
('T2002', 'Juliana', 'Comissaria', '2024-09-30', '2023-03-05');

-- 24. Habilitação de Veículos
INSERT INTO HabilitacaoVeiculo (id_tripulante, tipo_veiculo) VALUES 
(1, 'Aviao'),
(2, 'Aviao'),
(3, 'Aviao'),
(4, 'Aviao');

-- 25. Tripulação por Voo
INSERT INTO TripulacaoVoo (id_voo, id_tripulante, funcao) VALUES 
(1, 1, 'Comandante'),
(1, 2, 'Copiloto'),
(1, 3, 'Comissario'),
(2, 1, 'Comandante'),
(2, 2, 'Copiloto'),
(2, 4, 'Comissario');

-- 26. Histórico de Status de Voo
INSERT INTO HistoricoStatusVoo (id_voo, status_anterior, status_novo, data_hora_mudanca, responsavel) VALUES 
(1, 'Agendado', 'Embarque', '2023-10-15 09:00:00', 'Sistema'),
(1, 'Embarque', 'Decolado', '2023-10-15 10:05:00', 'Torre de Controle');

-- 27. Manutenções
INSERT INTO ManutencaoAeronave (id_aeronave, data_inicio, data_conclusao, tipo, descricao, custo) VALUES 
(1, '2023-09-01 08:00:00', '2023-09-05 18:00:00', 'Preventiva', 'Manutenção periódica', 50000.00),
(2, '2023-08-15 08:00:00', '2023-08-20 18:00:00', 'Corretiva', 'Troca de peças hidráulicas', 75000.00);