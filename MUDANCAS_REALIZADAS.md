# Resumo das Alterações para Nova Estrutura do Banco de Dados

## 📋 **PRINCIPAIS MUDANÇAS REALIZADAS**

### 1. **SERVICES ATUALIZADOS**

#### **PedidoService (`lib/services/pedido_service.dart`)**
- ✅ Atualizado para trabalhar com as novas tabelas `pedido` e `item_pedido`
- ✅ Consultas ajustadas para relacionamento com `item_pedido` e novos campos
- ✅ Status mantido como INTEGER (`1=pendente`, `2=concluido`, `3=cancelado`)
- ✅ Parâmetros das RPCs atualizados para nova estrutura
- ✅ Campo `ped_responsavel_cancelamento_id` como INTEGER

#### **UserService (`lib/services/user_service.dart`)**
- ✅ Já estava correto com campos `usr_*`

#### **SectorService (`lib/services/sector_service.dart`)**
- ✅ Atualizado para usar `set_nome` e campo `id` ao invés de `id_setor`

#### **GroupService (`lib/services/group_service.dart`)**
- ✅ Atualizado para usar `grp_nome`, `grp_setor_id` e campo `id`

#### **ItemService (`lib/services/item_service.dart`)**
- ✅ Atualizado para usar campos `it_*` e relacionamento com grupo
- ✅ RPC `buscar_itens_por_setor` com parâmetro corrigido

### 2. **WIDGETS ATUALIZADOS**

#### **Tabelas de Dados**
- ✅ **PedidosTable**: Ajustada para estrutura aninhada `item_pedido` e status INTEGER
- ✅ **StockItemsTable**: Usa `it_nome` e `qtd_total_lotes`
- ✅ **RecentMovementsTable**: Mantida (usa dados mock)
- ✅ **LastOrderSummary**: Mantida (usa dados mock)

#### **Modais**
- ✅ **DetalhesPedidoModal**: Atualizado para nova estrutura de dados e status INTEGER
- ✅ **DetalhesUsuarioModal**: Usa campos `usr_*`
- ✅ **DetalhesItemModal**: Usa campos `it_*` e relação com grupo
- ✅ **NovoGrupoModal**: Usa campos `grp_*`

#### **Telas**
- ✅ **NewOrderScreen**: Atualizada para usar novos campos de item

### 3. **STORED PROCEDURES CRIADAS/ATUALIZADAS**

#### **`cancel_pedido_transaction`**
- ✅ Trabalha com tabela `pedido` e campos `ped_*`
- ✅ Status como INTEGER (1, 2, 3)
- ✅ Campo `ped_responsavel_cancelamento_id` como INTEGER
- ✅ Controle de lotes e reservas
- ✅ Registra movimentação de estoque

#### **`create_pedido_transaction`**
- ✅ Cria pedido na tabela `pedido` com status INTEGER
- ✅ Cria registro em `item_pedido`
- ✅ Implementa FIFO para lotes
- ✅ Registra movimentações na tabela `mov_estoque`
- ✅ Controla reservas no item

#### **`finalize_pedido_transaction`**
- ✅ Finaliza pedido e processa saída dos lotes
- ✅ Status como INTEGER
- ✅ Implementa FIFO para retirada
- ✅ Atualiza `item_pedido` com lote usado
- ✅ Registra movimentações

#### **`buscar_itens_por_setor`**
- ✅ Calcula quantidade total pelos lotes
- ✅ Trabalha com relação item → grupo → setor
- ✅ Retorna dados formatados corretamente

### 4. **NOVA ESTRUTURA DE DADOS CORRIGIDA**

#### **Tabelas Principais com Campos Corretos**
- **`pedido`**: `id`, `ped_usuario_id`, `ped_setor_id`, `ped_motivo_cancelamento`, `ped_status` (int4), `ped_dados`, `ped_data_retirada`, `ped_data_solicitada`, `ped_responsavel_cancelamento_id`
- **`item_pedido`**: `iped_pedido_id`, `iped_item_id`, `iped_qtd_solicitada`, `iped_lote_retirado_id`
- **`item`**: `id`, `it_nome`, `it_num_ficha`, `it_unidade`, `it_min_estoque`, `it_controlado`, `it_grupo_id`, `it_ativo`, `it_qtd_reservada`, `it_perecivel`
- **`lote`**: `id`, `lot_item_id`, `lot_codigo`, `lot_data_entrada`, `lot_data_validade`, `lot_fornecedor_id`, `lot_qtd_atual`
- **`mov_estoque`**: `id`, `mve_item_id`, `mve_lote_id`, `mve_tipo`, `mve_qtd_movimentada`, `mve_dados_mov`, `mve_data_mov`
- **`usuario`**: `id`, `usr_nome`, `usr_email`, `usr_nivel_acesso` (int8), `usr_setor_id`, `usr_cpf`, `usr_auth_uid`, `usr_foto_url`
- **`setor`**: `id`, `set_nome`
- **`grupo`**: `id`, `grp_nome`, `grp_setor_id`
- **`fornecedor`**: `id`, `frn_nome`, `frn_cnpj`, `frn_contato`
- **`pedido_compra`**: `id`, `pc_fornecedor_id`, `pc_data_pedido`, `pc_data_prevista_entrega`, `pc_data_entrega`, `pc_status_compra`
- **`item_pedido_compra`**: `ipc_compra_id`, `ipc_item_id`, `ipc_qtd_comprada`

#### **Relacionamentos**
- Pedido → Item através de `item_pedido`
- Item → Grupo → Setor
- Lote → Item (para controle de estoque)
- Movimento → Lote (para rastreabilidade)

### 5. **ARQUIVOS CRIADOS/ATUALIZADOS**
- ✅ `stored_procedures_updated.sql`: Contém todas as stored procedures atualizadas
- ✅ `MUDANCAS_REALIZADAS.md`: Documentação completa das mudanças

## ⚠️ **PRÓXIMOS PASSOS NECESSÁRIOS**

1. **Executar as stored procedures no banco de dados**
2. **Testar todas as funcionalidades**
3. **Implementar telas para gerenciamento de lotes** (se necessário)
4. **Adicionar funcionalidades de compra** (usando `pedido_compra`)
5. **Implementar relatórios de movimentação**

## 🔧 **ESTRUTURA ATUAL VS ANTERIOR**

### **Antes:**
```
pedido: {id_pedido, id_item, id_usuario, qtd_solicitada, status}
item: {id_item, nome, qtd_atual, qtd_reservada}
```

### **Agora:**
```
pedido: {id, ped_usuario_id, ped_setor_id, ped_status (int4), ped_data_*}
item_pedido: {iped_pedido_id, iped_item_id, iped_qtd_solicitada}
item: {id, it_nome, it_qtd_reservada}
lote: {id, lot_item_id, lot_qtd_atual, lot_data_*}
```

### **CAMPOS IMPORTANTES CORRIGIDOS:**
- ✅ `ped_status` é **int4** (1=pendente, 2=concluido, 3=cancelado)
- ✅ `ped_responsavel_cancelamento_id` é **int4** (referência ao usuário)
- ✅ `usr_nivel_acesso` é **int8**
- ✅ Todos os campos seguem o padrão de prefixo correto

Esta nova estrutura permite:
- ✅ Controle por lotes com FIFO
- ✅ Múltiplos itens por pedido (futuro)
- ✅ Rastreabilidade completa
- ✅ Integração com sistema de compras
- ✅ Histórico de movimentações
- ✅ Status numérico para melhor performance