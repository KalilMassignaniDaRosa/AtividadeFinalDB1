-- RELATÓRIOS --
-- Relatório de ocupação por voo
SELECT v.codigo_voo, 
       a1.nome AS origem, 
       a2.nome AS destino,
       COUNT(rp.id_poltrona) as poltronas_ocupadas,
       COUNT(p.id_poltrona) as total_poltronas,
       ROUND(COUNT(rp.id_poltrona) / COUNT(p.id_poltrona) * 100, 2) as ocupacao_percentual,
       v.horario_partida,
       v.status
FROM Voo v
JOIN Aeroporto a1 ON v.id_origem = a1.id_aeroporto
JOIN Aeroporto a2 ON v.id_destino = a2.id_aeroporto
JOIN Poltrona p ON v.id_voo = p.id_voo
LEFT JOIN ReservaPoltrona rp ON p.id_poltrona = rp.id_poltrona
GROUP BY v.id_voo
ORDER BY v.horario_partida;

-- Lista de clientes preferenciais para mala direta
SELECT CONCAT(primeiro_nome, ' ', sobrenome) AS nome_completo,
       email, 
       telefone, 
       preferencia_comunicacao,
       milhas_acumuladas,
       categoria_fidelidade,
       data_ultima_comunicacao
FROM Cliente
WHERE cliente_preferencial = TRUE AND aceita_comunicados = TRUE
ORDER BY milhas_acumuladas DESC;

-- Voos com escalas detalhadas
SELECT v.codigo_voo, 
       a1.nome as origem, 
       a2.nome as destino,
       v.horario_partida,
       v.horario_chegada_previsto,
       COUNT(e.id_escala) as num_escalas,
       GROUP_CONCAT(CONCAT(e.ordem, '. ', ae.nome, ' (', e.horario_chegada_previsto, ' - ', e.horario_partida_previsto, ')') 
                   ORDER BY e.ordem SEPARATOR '\n') as detalhes_escalas
FROM Voo v
JOIN Aeroporto a1 ON v.id_origem = a1.id_aeroporto
JOIN Aeroporto a2 ON v.id_destino = a2.id_aeroporto
LEFT JOIN Escala e ON v.id_voo = e.id_voo
LEFT JOIN Aeroporto ae ON e.id_aeroporto = ae.id_aeroporto
GROUP BY v.id_voo
ORDER BY v.horario_partida;

-- Relatório financeiro por voo
SELECT v.codigo_voo,
       a1.nome AS origem,
       a2.nome AS destino,
       v.horario_partida,
       COUNT(r.id_reserva) AS num_reservas,
       SUM(r.valor_total) AS receita_total,
       AVG(r.valor_total) AS valor_medio,
       ta.nome AS tipo_aeronave,
       a.codigo_aeronave
FROM Voo v
JOIN Aeroporto a1 ON v.id_origem = a1.id_aeroporto
JOIN Aeroporto a2 ON v.id_destino = a2.id_aeroporto
JOIN Aeronave a ON v.id_aeronave = a.id_aeronave
JOIN TipoAeronave ta ON a.id_tipo = ta.id_tipo
LEFT JOIN Reserva r ON v.id_voo = r.id_voo AND r.status != 'Cancelada'
GROUP BY v.id_voo
ORDER BY v.horario_partida;

-- Relatório de utilização de aeronaves
SELECT a.codigo_aeronave,
       ta.nome AS tipo_aeronave,
       COUNT(DISTINCT v.id_voo) AS num_voos,
       SUM(CASE WHEN v.status = 'Aterrissado' THEN 1 ELSE 0 END) AS voos_concluidos,
       SUM(v.duracao_estimada_minutos) AS minutos_voados,
       a.horas_voo,
       a.ultima_manutencao,
       a.proxima_manutencao
FROM Aeronave a
JOIN TipoAeronave ta ON a.id_tipo = ta.id_tipo
LEFT JOIN Voo v ON a.id_aeronave = v.id_aeronave
GROUP BY a.id_aeronave
ORDER BY num_voos DESC;