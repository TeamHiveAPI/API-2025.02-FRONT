-- Script para inserir dados de odontologia na tabela 'item'
-- Baseado na estrutura existente de farmácia e almoxarifado

-- Primeiro, vamos inserir alguns grupos para odontologia (se não existirem)
-- Assumindo que existe uma tabela 'grupo' com campos: id_grupo, nome, id_setor

-- Inserir grupos para odontologia (setor 3)
INSERT INTO grupo (nome, id_setor) VALUES 
('Instrumentos Cirúrgicos', 3),
('Anestésicos', 3),
('Materiais Restauradores', 3),
('Preventivos', 3),
('EPI', 3),
('Antissépticos', 3),
('Curativos', 3),
('Higiene Bucal', 3),
('Radiologia', 3),
('Proteção', 3),
('Materiais de Moldagem', 3)
ON CONFLICT DO NOTHING;

-- Inserir itens de odontologia na tabela 'item'
-- Estrutura da tabela item: id_item, nome, num_ficha, unidade, qtd_atual, qtd_reservada, min_estoque, id_grupo, id_setor, ativo, data_validade, controlado

INSERT INTO item (nome, num_ficha, unidade, qtd_atual, qtd_reservada, min_estoque, id_grupo, id_setor, ativo, data_validade, controlado) VALUES
-- Instrumentos Cirúrgicos
('Broca Carbide 330', 1, 'Unidade', 150, 25, 10, (SELECT id_grupo FROM grupo WHERE nome = 'Instrumentos Cirúrgicos' AND id_setor = 3 LIMIT 1), 3, true, NULL, false),
('Seringa Carpule 1.8ml', 4, 'Unidade', 200, 40, 20, (SELECT id_grupo FROM grupo WHERE nome = 'Instrumentos Cirúrgicos' AND id_setor = 3 LIMIT 1), 3, true, NULL, false),
('Agulha 30G', 5, 'Unidade', 500, 100, 50, (SELECT id_grupo FROM grupo WHERE nome = 'Instrumentos Cirúrgicos' AND id_setor = 3 LIMIT 1), 3, true, NULL, false),

-- Anestésicos
('Anestésico Lidocaína 2%', 2, 'Ampola', 80, 15, 5, (SELECT id_grupo FROM grupo WHERE nome = 'Anestésicos' AND id_setor = 3 LIMIT 1), 3, true, '2025-12-31', true),

-- Materiais Restauradores
('Resina Composta A2', 3, 'Cartucho', 45, 8, 3, (SELECT id_grupo FROM grupo WHERE nome = 'Materiais Restauradores' AND id_setor = 3 LIMIT 1), 3, true, '2025-06-30', false),
('Cimento de Ionômero de Vidro', 6, 'Cartucho', 30, 30, 2, (SELECT id_grupo FROM grupo WHERE nome = 'Materiais Restauradores' AND id_setor = 3 LIMIT 1), 3, true, '2025-08-15', false),

-- Preventivos
('Flúor Gel 1.23%', 7, 'Tubo', 25, 5, 3, (SELECT id_grupo FROM grupo WHERE nome = 'Preventivos' AND id_setor = 3 LIMIT 1), 3, true, '2025-10-20', false),

-- EPI
('Máscara Cirúrgica N95', 8, 'Unidade', 300, 50, 100, (SELECT id_grupo FROM grupo WHERE nome = 'EPI' AND id_setor = 3 LIMIT 1), 3, true, NULL, false),
('Luvas de Procedimento', 9, 'Par', 1000, 200, 200, (SELECT id_grupo FROM grupo WHERE nome = 'EPI' AND id_setor = 3 LIMIT 1), 3, true, NULL, false),

-- Antissépticos
('Álcool 70% 500ml', 10, 'Frasco', 60, 12, 10, (SELECT id_grupo FROM grupo WHERE nome = 'Antissépticos' AND id_setor = 3 LIMIT 1), 3, true, '2026-01-15', false),
('Peróxido de Hidrogênio 3%', 11, 'Frasco', 40, 8, 5, (SELECT id_grupo FROM grupo WHERE nome = 'Antissépticos' AND id_setor = 3 LIMIT 1), 3, true, '2025-09-30', false),

-- Curativos
('Gaze Estéril 5x5cm', 12, 'Pacote', 200, 30, 50, (SELECT id_grupo FROM grupo WHERE nome = 'Curativos' AND id_setor = 3 LIMIT 1), 3, true, '2025-11-10', false),
('Algodão Hidrófilo', 13, 'Pacote', 80, 15, 20, (SELECT id_grupo FROM grupo WHERE nome = 'Curativos' AND id_setor = 3 LIMIT 1), 3, true, '2025-12-05', false),

-- Higiene Bucal
('Escova de Dentes Macia', 14, 'Unidade', 150, 25, 30, (SELECT id_grupo FROM grupo WHERE nome = 'Higiene Bucal' AND id_setor = 3 LIMIT 1), 3, true, NULL, false),
('Fio Dental', 15, 'Unidade', 120, 20, 25, (SELECT id_grupo FROM grupo WHERE nome = 'Higiene Bucal' AND id_setor = 3 LIMIT 1), 3, true, NULL, false),
('Enxaguante Bucal Antisséptico', 16, 'Frasco', 35, 7, 5, (SELECT id_grupo FROM grupo WHERE nome = 'Higiene Bucal' AND id_setor = 3 LIMIT 1), 3, true, '2025-07-20', false),

-- Radiologia
('Radiografia Periapical', 17, 'Filme', 200, 40, 50, (SELECT id_grupo FROM grupo WHERE nome = 'Radiologia' AND id_setor = 3 LIMIT 1), 3, true, '2025-12-31', false),
('Radiografia Panorâmica', 18, 'Filme', 100, 20, 25, (SELECT id_grupo FROM grupo WHERE nome = 'Radiologia' AND id_setor = 3 LIMIT 1), 3, true, '2025-12-31', false),

-- Proteção
('Protetor Bucal', 19, 'Unidade', 50, 10, 10, (SELECT id_grupo FROM grupo WHERE nome = 'Proteção' AND id_setor = 3 LIMIT 1), 3, true, NULL, false),

-- Materiais de Moldagem
('Cera de Modelagem', 20, 'Barra', 25, 5, 3, (SELECT id_grupo FROM grupo WHERE nome = 'Materiais de Moldagem' AND id_setor = 3 LIMIT 1), 3, true, '2025-08-30', false)
ON CONFLICT DO NOTHING;

-- Verificar se os dados foram inseridos
-- SELECT * FROM item WHERE id_setor = 3;
-- SELECT * FROM grupo WHERE id_setor = 3;
