USE EmpresaTransporteAereo;

-- 1. Listar todos os voos agendados
SELECT
    codigo_voo,
    origem,
    destino,
    partida_sem_segundos AS partida_prevista,
    chegada_sem_segundos AS chegada_prevista,
    status
FROM vw_voos_formatados
WHERE status = 'Agendado';

-- 2. Listar aeronaves disponíveis
SELECT 
    a.codigo_registro, 
    t.nome AS tipo_aeronave
FROM Aeronave a
JOIN TipoAeronave t ON a.id_tipo = t.id_tipo
WHERE fn_aeronave_disponivel(a.id_aeronave, NOW(), DATE_ADD(NOW(), INTERVAL 1 HOUR)) = 1;

-- 3. Listar clientes Platinum
SELECT 
    CONCAT(p.primeiro_nome, ' ', p.sobrenome) AS nome_completo,
    p.email,
    p.telefone,
    c.milhas_acumuladas,
    p.categoria_fidelidade
FROM Cliente c
JOIN Pessoa p ON c.id_pessoa = p.id_pessoa
WHERE p.categoria_fidelidade = 'Platinum';

-- 4. Reservas completas
SELECT 
    r.codigo_reserva,
    r.reserva_status,
    r.passageiro,
    r.codigo_voo,
    r.poltrona
FROM vw_reservas_completas r;

-- 5. Bagagens por voo
SELECT 
    v.codigo_voo,
    b.codigo_bagagem,
    b.peso_kg,
    b.tipo,
    b.status
FROM Bagagem b
JOIN AssentoReserva ar ON b.id_assento_reserva = ar.id_assento_reserva
JOIN Voo v ON ar.id_voo = v.id_voo;

-- 6. Tripulação designada
SELECT 
    v.codigo_voo,
    CONCAT(p.primeiro_nome,' ',p.sobrenome) AS tripulante,
    tv.funcao
FROM TripulacaoVoo tv
JOIN Voo v ON tv.id_voo = v.id_voo
JOIN Tripulante tr ON tv.id_tripulante = tr.id_tripulante
JOIN Pessoa p ON tr.id_pessoa = p.id_pessoa
ORDER BY v.codigo_voo, tv.funcao;

-- 7. Status de portões por aeroporto
SELECT 
    a.nome AS aeroporto,
    t.codigo_terminal,
    p.codigo_portao,
    p.status
FROM Portao p
JOIN Terminal t ON p.id_terminal = t.id_terminal
JOIN Aeroporto a ON t.id_aeroporto = a.id_aeroporto
ORDER BY a.nome, t.codigo_terminal, p.codigo_portao;

-- 8. Manutenções de aeronaves
SELECT 
    a.codigo_registro,
    m.tipo,
    m.data_inicio,
    m.data_conclusao,
    m.custo
FROM ManutencaoAeronave m
JOIN Aeronave a ON m.id_aeronave = a.id_aeronave
ORDER BY m.data_inicio DESC;

-- 9. Ocupação de voos
SELECT 
    codigo_voo,
    origem,
    destino,
    partida,
    chegada,
    status,
    ocupacao_formatada
FROM vw_ocupacao_voos;

-- 10. Receita por forma de pagamento
SELECT 
    forma_pagamento,
    COUNT(*) AS total_pagamentos,
    SUM(valor_total) AS receita_total
FROM Pagamento
GROUP BY forma_pagamento
ORDER BY receita_total DESC;

-- 11. Voos por aeronave
SELECT 
    a.codigo_registro,
    t.nome AS tipo_aeronave,
    COUNT(v.id_voo) AS total_voos,
    a.horas_voo_total,
    fn_aeronave_disponivel(a.id_aeronave, NOW(), NOW()) AS disponivel_agora
FROM Aeronave a
JOIN TipoAeronave t ON a.id_tipo = t.id_tipo
LEFT JOIN Voo v ON a.id_aeronave = v.id_aeronave
GROUP BY a.id_aeronave
ORDER BY a.horas_voo_total DESC;

-- 12. Voos internacionais com escalas
SELECT
    v.codigo_voo,
    pa1.nome AS pais_origem,
    ci1.nome AS cidade_origem,
    pa2.nome AS pais_destino,
    ci2.nome AS cidade_destino,
    COALESCE(
      (SELECT GROUP_CONCAT(ci3.nome ORDER BY e.ordem SEPARATOR ' -> ')
       FROM Escala e
       JOIN Aeroporto ae ON e.id_aeroporto = ae.id_aeroporto
       JOIN Cidade ci3 ON ae.id_cidade = ci3.id_cidade
       WHERE e.id_voo = v.id_voo),
      'Sem escalas'
    ) AS escalas,
    v.status
FROM Voo v
JOIN Aeroporto ao  ON v.id_origem   = ao.id_aeroporto
JOIN Cidade ci1 ON ao.id_cidade = ci1.id_cidade
JOIN Pais pa1 ON ci1.id_pais  = pa1.id_pais
JOIN Aeroporto ad  ON v.id_destino  = ad.id_aeroporto
JOIN Cidade ci2 ON ad.id_cidade = ci2.id_cidade
JOIN Pais pa2 ON ci2.id_pais  = pa2.id_pais
WHERE pa1.id_pais <> pa2.id_pais;

-- 13. Histórico completo de um voo específico
SELECT 
    v.codigo_voo,
    hs.status_anterior,
    hs.status_novo,
    hs.data_hora_mudanca,
    hs.responsavel
FROM HistoricoStatusVoo hs
JOIN Voo v ON hs.id_voo = v.id_voo
WHERE v.codigo_voo = 'AZ100'
ORDER BY hs.data_hora_mudanca;

-- 14. Preços por classe para cada voo agendado
SELECT
    v.id_voo,
    v.codigo_voo,
    fn_calcular_valor_passagem(v.id_voo,'Economica') AS preco_economica,
    fn_calcular_valor_passagem(v.id_voo,'Executiva')  AS preco_executiva,
    fn_calcular_valor_passagem(v.id_voo,'Primeira') AS preco_primeira,
    fn_calcular_valor_passagem(v.id_voo,'Luxo') AS preco_luxo
FROM Voo v
WHERE v.status = 'Agendado';