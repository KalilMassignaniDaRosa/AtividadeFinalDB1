USE EmpresaTransporteAereo;

-- Listar todos os voos agendados
SELECT v.codigo_voo, a1.nome AS origem, a2.nome AS destino, 
       v.partida_prevista, v.chegada_prevista, v.status
FROM Voo v
JOIN Aeroporto a1 ON v.id_origem = a1.id_aeroporto
JOIN Aeroporto a2 ON v.id_destino = a2.id_aeroporto
WHERE v.status = 'Agendado';

-- Listar aeronaves disponíveis
SELECT a.codigo_registro, t.nome AS tipo_aeronave, a.status
FROM Aeronave a
JOIN TipoAeronave t ON a.id_tipo = t.id_tipo
WHERE a.status = 'Disponivel';

-- Listar clientes Platinum
SELECT CONCAT(primeiro_nome, ' ', sobrenome) AS nome_completo, 
       email, telefone, milhas_acumuladas
FROM Cliente
WHERE categoria_fidelidade = 'Platinum';


-- Detalhes de reservas com passageiros
SELECT r.codigo_reserva, r.status, 
       CONCAT(c.primeiro_nome, ' ', c.sobrenome) AS passageiro,
       v.codigo_voo, p.codigo AS poltrona
FROM Reserva r
JOIN PassageiroReserva pr ON r.id_reserva = pr.id_reserva
JOIN Cliente c ON pr.id_cliente = c.id_cliente
JOIN AssentoReserva ar ON pr.id_passageiro_reserva = ar.id_passageiro_reserva
JOIN Voo v ON ar.id_voo = v.id_voo
JOIN PoltronaVoo pv ON ar.id_poltrona_voo = pv.id_poltrona_voo
JOIN Poltrona p ON pv.id_poltrona = p.id_poltrona;

-- Bagagens por voo
SELECT v.codigo_voo, b.codigo_bagagem, b.peso_kg, b.tipo, b.status
FROM Bagagem b
JOIN AssentoReserva ar ON b.id_assento_reserva = ar.id_assento_reserva
JOIN Voo v ON ar.id_voo = v.id_voo;


-- Tripulação designada para voos
SELECT v.codigo_voo, 
       CONCAT(t.primeiro_nome, ' ', t.sobrenome) AS tripulante,
       tv.funcao
FROM TripulacaoVoo tv
JOIN Voo v ON tv.id_voo = v.id_voo
JOIN Tripulante t ON tv.id_tripulante = t.id_tripulante
ORDER BY v.codigo_voo, tv.funcao;

-- Status de portões por aeroporto
SELECT a.nome AS aeroporto, t.codigo_terminal, p.codigo_portao, p.status
FROM Portao p
JOIN Terminal t ON p.id_terminal = t.id_terminal
JOIN Aeroporto a ON t.id_aeroporto = a.id_aeroporto
ORDER BY a.nome, t.codigo_terminal, p.codigo_portao;

-- Manutenções de aeronaves
SELECT a.codigo_registro, m.tipo, 
       m.data_inicio, m.data_conclusao, m.custo
FROM ManutencaoAeronave m
JOIN Aeronave a ON m.id_aeronave = a.id_aeronave
ORDER BY m.data_inicio DESC;


-- Ocupação de voos (poltronas disponíveis vs ocupadas)
SELECT v.codigo_voo, 
       COUNT(pv.id_poltrona_voo) AS total_poltronas,
       SUM(CASE WHEN pv.disponivel = FALSE THEN 1 ELSE 0 END) AS ocupadas,
       ROUND((SUM(CASE WHEN pv.disponivel = FALSE THEN 1 ELSE 0 END) / COUNT(pv.id_poltrona_voo)) * 100, 2) AS ocupacao_percentual
FROM Voo v
JOIN PoltronaVoo pv ON v.id_voo = pv.id_voo
GROUP BY v.codigo_voo;

-- Receita por forma de pagamento
SELECT forma_pagamento, 
       COUNT(*) AS total_pagamentos,
       SUM(valor_total) AS receita_total
FROM Pagamento
GROUP BY forma_pagamento
ORDER BY receita_total DESC;

-- Voos por aeronave (horas de voo)
SELECT a.codigo_registro, t.nome AS tipo_aeronave,
       COUNT(v.id_voo) AS total_voos,
       a.horas_voo_total
FROM Aeronave a
JOIN TipoAeronave t ON a.id_tipo = t.id_tipo
LEFT JOIN Voo v ON a.id_aeronave = v.id_aeronave
GROUP BY a.id_aeronave
ORDER BY a.horas_voo_total DESC;

-- Voos internacionais (com escalas se houver)
SELECT v.codigo_voo, 
       pa1.nome AS pais_origem, ci1.nome AS cidade_origem,
       pa2.nome AS pais_destino, ci2.nome AS cidade_destino,
       GROUP_CONCAT(ci3.nome ORDER BY e.ordem SEPARATOR ' -> ') AS escalas
FROM Voo v
JOIN Aeroporto ao ON v.id_origem = ao.id_aeroporto
JOIN Cidade ci1 ON ao.id_cidade = ci1.id_cidade
JOIN Pais pa1 ON ci1.id_pais = pa1.id_pais
JOIN Aeroporto ad ON v.id_destino = ad.id_aeroporto
JOIN Cidade ci2 ON ad.id_cidade = ci2.id_cidade
JOIN Pais pa2 ON ci2.id_pais = pa2.id_pais
LEFT JOIN Escala e ON v.id_voo = e.id_voo
LEFT JOIN Aeroporto ae ON e.id_aeroporto = ae.id_aeroporto
LEFT JOIN Cidade ci3 ON ae.id_cidade = ci3.id_cidade
WHERE pa1.id_pais != pa2.id_pais
GROUP BY v.id_voo;

-- Histórico completo de um voo específico
SELECT v.codigo_voo, h.status_anterior, h.status_novo, 
       h.data_hora_mudanca, h.responsavel
FROM HistoricoStatusVoo h
JOIN Voo v ON h.id_voo = v.id_voo
WHERE v.codigo_voo = 'AZ123'
ORDER BY h.data_hora_mudanca;

-- Comparação de valores entre classes para o mesmo voo
SELECT 
    'Economica' AS classe,
    fn_calcular_valor_passagem(1, 'Economica') AS valor
UNION ALL
SELECT 
    'Executiva' AS classe,
    fn_calcular_valor_passagem(1, 'Executiva')
UNION ALL
SELECT 
    'Primeira' AS classe,
    fn_calcular_valor_passagem(1, 'Primeira');
    
-- Listagem de voos com preços para diferentes classes
SELECT 
    v.id_voo,
    v.codigo_voo,
    a1.nome AS origem,
    a2.nome AS destino,
    v.distancia_km,
    fn_calcular_valor_passagem(v.id_voo, 'Economica') AS economica,
    fn_calcular_valor_passagem(v.id_voo, 'Executiva') AS executiva
FROM Voo v
JOIN Aeroporto a1 ON v.id_origem = a1.id_aeroporto
JOIN Aeroporto a2 ON v.id_destino = a2.id_aeroporto
WHERE v.status = 'Agendado';