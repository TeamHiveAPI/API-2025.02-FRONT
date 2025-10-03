-- Atualização das stored procedures para nova estrutura do banco

-- ========================================
-- cancel_pedido_transaction
-- ========================================
CREATE OR REPLACE FUNCTION cancel_pedido_transaction(
  p_pedido_id INTEGER,
  p_motivo_cancelamento TEXT,
  p_responsavel_cancelamento_id INTEGER
) RETURNS VOID AS $$
DECLARE
  v_status INTEGER;
  item_pedido_record RECORD;
BEGIN
  SELECT ped_status INTO v_status
  FROM pedido
  WHERE id = p_pedido_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Pedido não encontrado';
  END IF;

  IF v_status = 3 THEN
    RAISE EXCEPTION 'Pedido já está cancelado';
  END IF;

  IF v_status = 2 THEN
    RAISE EXCEPTION 'Não é possível cancelar pedido já concluído';
  END IF;

  UPDATE pedido
  SET ped_status = 3,
      ped_motivo_cancelamento = p_motivo_cancelamento,
      ped_responsavel_cancelamento_id = p_responsavel_cancelamento_id
  WHERE id = p_pedido_id;

  IF v_status = 1 THEN
    FOR item_pedido_record IN 
      SELECT iped_item_id, iped_qtd_solicitada 
      FROM item_pedido 
      WHERE iped_pedido_id = p_pedido_id
    LOOP
      UPDATE item
      SET it_qtd_reservada = it_qtd_reservada - item_pedido_record.iped_qtd_solicitada
      WHERE id = item_pedido_record.iped_item_id;

      INSERT INTO mov_estoque (mve_item_id, mve_tipo, mve_qtd_movimentada, mve_dados_mov, mve_data_mov)
      VALUES (
        item_pedido_record.iped_item_id,
        'CANCELAMENTO',
        item_pedido_record.iped_qtd_solicitada,
        'Cancelamento do pedido #' || p_pedido_id || ': ' || p_motivo_cancelamento,
        CURRENT_DATE
      );
    END LOOP;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- create_pedido_transaction
-- ========================================
CREATE OR REPLACE FUNCTION create_pedido_transaction(
  p_item_id INTEGER,
  p_usuario_id INTEGER,
  p_setor_id INTEGER,
  p_qtd_solicitada INTEGER,
  p_data_retirada DATE,
  p_status INTEGER
) RETURNS VOID AS $$
DECLARE
  v_qtd_disponivel INTEGER := 0;
  v_qtd_restante INTEGER := p_qtd_solicitada;
  v_pedido_id INTEGER;
  lote_record RECORD;
BEGIN
  SELECT COALESCE(SUM(lot_qtd_atual), 0) INTO v_qtd_disponivel
  FROM lote
  WHERE lot_item_id = p_item_id AND lot_qtd_atual > 0
  ORDER BY lot_data_validade ASC NULLS LAST, lot_data_entrada ASC;

  IF v_qtd_disponivel < p_qtd_solicitada THEN
    RAISE EXCEPTION 'Quantidade insuficiente em estoque. Disponível: %, Solicitado: %', v_qtd_disponivel, p_qtd_solicitada;
  END IF;

  INSERT INTO pedido (
    ped_usuario_id,
    ped_setor_id,
    ped_status,
    ped_data_solicitada,
    ped_data_retirada
  ) VALUES (
    p_usuario_id,
    p_setor_id,
    p_status,
    CURRENT_DATE,
    p_data_retirada
  ) RETURNING id INTO v_pedido_id;

  INSERT INTO item_pedido (
    iped_pedido_id,
    iped_item_id,
    iped_qtd_solicitada
  ) VALUES (
    v_pedido_id,
    p_item_id,
    p_qtd_solicitada
  );

  IF p_data_retirada IS NOT NULL THEN
    FOR lote_record IN 
      SELECT id, lot_qtd_atual
      FROM lote
      WHERE lot_item_id = p_item_id AND lot_qtd_atual > 0
      ORDER BY lot_data_validade ASC NULLS LAST, lot_data_entrada ASC
    LOOP
      EXIT WHEN v_qtd_restante <= 0;
      
      DECLARE
        v_qtd_retirar INTEGER := LEAST(lote_record.lot_qtd_atual, v_qtd_restante);
      BEGIN
        UPDATE lote
        SET lot_qtd_atual = lot_qtd_atual - v_qtd_retirar
        WHERE id = lote_record.id;

        INSERT INTO mov_estoque (mve_item_id, mve_lote_id, mve_tipo, mve_qtd_movimentada, mve_dados_mov, mve_data_mov)
        VALUES (
          p_item_id,
          lote_record.id,
          'SAIDA',
          v_qtd_retirar,
          'Retirada do pedido #' || v_pedido_id,
          CURRENT_DATE
        );

        UPDATE item_pedido
        SET iped_lote_retirado_id = lote_record.id
        WHERE iped_pedido_id = v_pedido_id AND iped_item_id = p_item_id;
        
        v_qtd_restante := v_qtd_restante - v_qtd_retirar;
      END;
    END LOOP;
  ELSE
    UPDATE item
    SET it_qtd_reservada = it_qtd_reservada + p_qtd_solicitada
    WHERE id = p_item_id;

    INSERT INTO mov_estoque (mve_item_id, mve_tipo, mve_qtd_movimentada, mve_dados_mov, mve_data_mov)
    VALUES (
      p_item_id,
      'RESERVA',
      p_qtd_solicitada,
      'Reserva do pedido #' || v_pedido_id,
      CURRENT_DATE
    );
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- finalize_pedido_transaction
-- ========================================
CREATE OR REPLACE FUNCTION finalize_pedido_transaction(
  p_pedido_id INTEGER,
  p_data_retirada DATE
) RETURNS VOID AS $$
DECLARE
  v_status INTEGER;
  v_qtd_restante INTEGER;
  item_pedido_record RECORD;
  lote_record RECORD;
BEGIN
  SELECT ped_status INTO v_status
  FROM pedido
  WHERE id = p_pedido_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Pedido não encontrado';
  END IF;

  IF v_status = 3 THEN
    RAISE EXCEPTION 'Não é possível finalizar pedido cancelado';
  END IF;

  IF v_status = 2 THEN
    RAISE EXCEPTION 'Pedido já está finalizado';
  END IF;

  UPDATE pedido
  SET ped_status = 2,
      ped_data_retirada = p_data_retirada
  WHERE id = p_pedido_id;

  IF v_status = 1 THEN
    FOR item_pedido_record IN
      SELECT iped_item_id, iped_qtd_solicitada 
      FROM item_pedido 
      WHERE iped_pedido_id = p_pedido_id
    LOOP
      UPDATE item
      SET it_qtd_reservada = it_qtd_reservada - item_pedido_record.iped_qtd_solicitada
      WHERE id = item_pedido_record.iped_item_id;
      
      v_qtd_restante := item_pedido_record.iped_qtd_solicitada;

      FOR lote_record IN
        SELECT id, lot_qtd_atual
        FROM lote
        WHERE lot_item_id = item_pedido_record.iped_item_id
        AND lot_qtd_atual > 0
        ORDER BY lot_data_validade ASC NULLS LAST, lot_data_entrada ASC
      LOOP
        EXIT WHEN v_qtd_restante <= 0;
        
        DECLARE
          v_qtd_retirar INTEGER := LEAST(lote_record.lot_qtd_atual, v_qtd_restante);
        BEGIN
          UPDATE lote
          SET lot_qtd_atual = lot_qtd_atual - v_qtd_retirar
          WHERE id = lote_record.id;

          INSERT INTO mov_estoque (mve_item_id, mve_lote_id, mve_tipo, mve_qtd_movimentada, mve_dados_mov, mve_data_mov)
          VALUES (
            item_pedido_record.iped_item_id,
            lote_record.id,
            'SAIDA',
            v_qtd_retirar,
            'Finalização do pedido #' || p_pedido_id,
            p_data_retirada
          );

          UPDATE item_pedido
          SET iped_lote_retirado_id = lote_record.id
          WHERE iped_pedido_id = p_pedido_id
          AND iped_item_id = item_pedido_record.iped_item_id
          AND iped_lote_retirado_id IS NULL;
          
          v_qtd_restante := v_qtd_restante - v_qtd_retirar;
        END;
      END LOOP;
    END LOOP;
  END IF;
END;
$$ LANGUAGE plpgsql;


old ones:
=========================================

cancel_pedido_transaction:
DECLARE
  v_status INTEGER;
  v_qtd_solicitada INTEGER;
  v_id_item INTEGER;
BEGIN
  SELECT status, qtd_solicitada, id_item
  INTO v_status, v_qtd_solicitada, v_id_item
  FROM pedido
  WHERE id_pedido = p_id_pedido;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Pedido não encontrado';
  END IF;

  IF v_status = 3 THEN
    RAISE EXCEPTION 'Pedido já está cancelado';
  END IF;

  IF v_status = 2 THEN
    RAISE EXCEPTION 'Não é possível cancelar pedido já concluído';
  END IF;

  UPDATE pedido
  SET status = 3,
      motivo_cancelamento = p_motivo_cancelamento,
      id_responsavel_cancelamento = p_id_responsavel_cancelamento
  WHERE id_pedido = p_id_pedido;

  IF v_status = 1 THEN
    UPDATE item
    SET qtd_atual = qtd_atual + v_qtd_solicitada,
        qtd_reservada = qtd_reservada - v_qtd_solicitada
    WHERE id_item = v_id_item;
  END IF;
END;

create_pedido_transaction:
BEGIN
  IF (SELECT qtd_atual FROM item WHERE id_item = p_id_item) < p_qtd_solicitada THEN
    RAISE EXCEPTION 'Quantidade insuficiente em estoque';
  END IF;

  INSERT INTO pedido (
    id_item,
    id_usuario,
    id_setor,
    qtd_solicitada,
    data_ped,
    data_ret,
    status
  ) VALUES (
    p_id_item,
    p_id_usuario,
    p_id_setor,
    p_qtd_solicitada,
    CURRENT_DATE,
    p_data_ret,
    p_status
  );

  IF p_data_ret IS NOT NULL THEN
    UPDATE item
    SET qtd_atual = qtd_atual - p_qtd_solicitada
    WHERE id_item = p_id_item;
  ELSE
    UPDATE item
    SET qtd_atual = qtd_atual - p_qtd_solicitada,
        qtd_reservada = qtd_reservada + p_qtd_solicitada
    WHERE id_item = p_id_item;
  END IF;
END;

finalize_pedido_transaction:
DECLARE
  v_status INTEGER;
  v_qtd_solicitada INTEGER;
  v_id_item INTEGER;
BEGIN
  SELECT status, qtd_solicitada, id_item
  INTO v_status, v_qtd_solicitada, v_id_item
  FROM pedido
  WHERE id_pedido = p_id_pedido;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Pedido não encontrado';
  END IF;

  IF v_status = 3 THEN
    RAISE EXCEPTION 'Não é possível finalizar pedido cancelado';
  END IF;

  IF v_status = 2 THEN
    RAISE EXCEPTION 'Pedido já está finalizado';
  END IF;

  UPDATE pedido
  SET status = 2,
      data_ret = p_data_ret
  WHERE id_pedido = p_id_pedido;

  IF v_status = 1 THEN
    UPDATE item
    SET qtd_reservada = qtd_reservada - v_qtd_solicitada
    WHERE id_item = v_id_item;
  END IF;
END;
