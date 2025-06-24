USE EmpresaTransporteAereo;


-- 1. View para mostrar voos agendados com detalhes
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

-- 2. View para mostrar ocupação de voos
CREATE VIEW vw_ocupacao_voos AS
SELECT 
    v.id_voo,
    v.codigo_voo,
    COUNT(ar.id_assento_reserva) AS poltronas_ocupadas,
    COUNT(pv.id_poltrona_voo) AS total_poltronas,
    ROUND((COUNT(ar.id_assento_reserva) / COUNT(pv.id_poltrona_voo) * 100, 2) AS ocupacao_percentual
FROM Voo v
LEFT JOIN PoltronaVoo pv ON v.id_voo = pv.id_voo
LEFT JOIN AssentoReserva ar ON pv.id_poltrona_voo = ar.id_poltrona_voo
GROUP BY v.id_voo, v.codigo_voo;

-- 3. View para mostrar clientes frequentes
CREATE VIEW vw_clientes_frequentes AS
SELECT 
    c.id_cliente,
    CONCAT(c.primeiro_nome, ' ', c.sobrenome) AS nome_completo,
    c.documento,
    c.milhas_acumuladas,
    c.categoria_fidelidade,
    COUNT(r.id_reserva) AS total_reservas
FROM Cliente c
LEFT JOIN Reserva r ON c.id_cliente = r.id_cliente
GROUP BY c.id_cliente, c.primeiro_nome, c.sobrenome, c.documento, c.milhas_acumuladas, c.categoria_fidelidade
ORDER BY c.milhas_acumuladas DESC;

-- 4. View para mostrar aeronaves em manutenção
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

-- 5. View para mostrar disponibilidade de poltronas por voo
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