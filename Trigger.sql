USE EmpresaTransporteAereo;

-- 1. Trigger para atualizar status do portão quando um voo é associado
DELIMITER //
CREATE TRIGGER trg_voo_portao_update
BEFORE UPDATE ON Voo
FOR EACH ROW
BEGIN
    -- Se o portão foi alterado
    IF NEW.id_portao_embarque != OLD.id_portao_embarque THEN
        -- Libera o portão antigo (se existir)
        IF OLD.id_portao_embarque IS NOT NULL THEN
            UPDATE Portao SET status = 'Livre' WHERE id_portao = OLD.id_portao_embarque;
        END IF;
        
        -- Ocupa o novo portão (se existir)
        IF NEW.id_portao_embarque IS NOT NULL THEN
            UPDATE Portao SET status = 'Ocupado' WHERE id_portao = NEW.id_portao_embarque;
        END IF;
    END IF;
END //
DELIMITER ;

-- 2. Trigger para registrar mudanças de status de voo
DELIMITER //
CREATE TRIGGER trg_voo_status_change
AFTER UPDATE ON Voo
FOR EACH ROW
BEGIN
    IF NEW.status != OLD.status THEN
        INSERT INTO HistoricoStatusVoo (id_voo, status_anterior, status_novo, responsavel)
        VALUES (NEW.id_voo, OLD.status, NEW.status, 'Sistema');
    END IF;
END //
DELIMITER ;

-- 3. Trigger para atualizar horas de voo da aeronave
DELIMITER //
CREATE TRIGGER trg_voo_horas_voo
AFTER UPDATE ON Voo
FOR EACH ROW
BEGIN
    -- Se o voo foi concluído (status 'Aterrissado') e tem dados reais
    IF NEW.status = 'Aterrissado' AND OLD.status != 'Aterrissado' 
       AND NEW.partida_real IS NOT NULL AND NEW.chegada_real IS NOT NULL THEN
        
        -- Calcula a diferença em horas
        SET @horas_voo = TIMESTAMPDIFF(HOUR, NEW.partida_real, NEW.chegada_real);
        
        -- Atualiza o total de horas de voo da aeronave
        UPDATE Aeronave 
        SET horas_voo_total = horas_voo_total + @horas_voo
        WHERE id_aeronave = NEW.id_aeronave;
    END IF;
END //
DELIMITER ;

-- 4. Trigger para verificar disponibilidade de poltrona antes de reservar
DELIMITER //
CREATE TRIGGER trg_assento_reserva_check
BEFORE INSERT ON AssentoReserva
FOR EACH ROW
BEGIN
    DECLARE poltrona_disponivel BOOLEAN;
    
    -- Verifica se a poltrona está disponível
    SELECT disponivel INTO poltrona_disponivel
    FROM PoltronaVoo
    WHERE id_poltrona_voo = NEW.id_poltrona_voo;
    
    IF NOT poltrona_disponivel THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Poltrona não está disponível para reserva';
    END IF;
END //
DELIMITER ;

-- 5. Trigger para atualizar status da poltrona após reserva
DELIMITER //
CREATE TRIGGER trg_assento_reserva_update_poltrona
AFTER INSERT ON AssentoReserva
FOR EACH ROW
BEGIN
    -- Marca a poltrona como indisponível
    UPDATE PoltronaVoo
    SET disponivel = FALSE
    WHERE id_poltrona_voo = NEW.id_poltrona_voo;
END //
DELIMITER ;

-- 6. Trigger para atualizar milhas do cliente após voo concluído
DELIMITER //
CREATE TRIGGER trg_voo_concluido_milhas
AFTER UPDATE ON Voo
FOR EACH ROW
BEGIN
    -- Se o voo foi concluído (status 'Aterrissado')
    IF NEW.status = 'Aterrissado' AND OLD.status != 'Aterrissado' THEN
        -- Atualiza milhas para todos os passageiros deste voo
        UPDATE Cliente c
        JOIN PassageiroReserva pr ON c.id_cliente = pr.id_cliente
        JOIN AssentoReserva ar ON pr.id_passageiro_reserva = ar.id_passageiro_reserva
        JOIN Voo v ON ar.id_voo = v.id_voo
        SET c.milhas_acumuladas = c.milhas_acumuladas + (v.distancia_km * 
            CASE 
                WHEN (SELECT classe FROM Poltrona p JOIN PoltronaVoo pv ON p.id_poltrona = pv.id_poltrona WHERE pv.id_poltrona_voo = ar.id_poltrona_voo) = 'Economica' THEN 1.0
                WHEN (SELECT classe FROM Poltrona p JOIN PoltronaVoo pv ON p.id_poltrona = pv.id_poltrona WHERE pv.id_poltrona_voo = ar.id_poltrona_voo) = 'Executiva' THEN 1.5
                WHEN (SELECT classe FROM Poltrona p JOIN PoltronaVoo pv ON p.id_poltrona = pv.id_poltrona WHERE pv.id_poltrona_voo = ar.id_poltrona_voo) = 'Primeira' THEN 2.0
                WHEN (SELECT classe FROM Poltrona p JOIN PoltronaVoo pv ON p.id_poltrona = pv.id_poltrona WHERE pv.id_poltrona_voo = ar.id_poltrona_voo) = 'Luxo' THEN 3.0
            END)
        WHERE v.id_voo = NEW.id_voo;
    END IF;
END //
DELIMITER ;