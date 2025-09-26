import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:http/http.dart' as http;

class DetalhesPedidoModal extends StatelessWidget {
  final String Item_nome;
  final String Num_ped;
  final DateTime Data_ret; 
  final String Qnt_ped;

  const DetalhesPedidoModal({
    super.key,
    required this.Item_nome,
    required this.Num_ped,
    required this.Data_ret,
    required this.Qnt_ped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ITEM REQUISITADO
        _buildDetailItem("ITEM REQUISITADO", Item_nome),
        const SizedBox(height: 12),

        // Nº DO PEDIDO + DATA DE RETIRADA
        Row(
          children: [
            Expanded(child: _buildDetailItem("Nº DO PEDIDO", Num_ped)),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem("DATA DE RETIRADA", Data_ret.toString().split(' ')[0])), // Formata a data para exibir apenas a parte da data
          ],
        ),
        const SizedBox(height: 12),

        // QTD SOLICITADA
        _buildDetailItem("QTD. SOLICITADA", Qnt_ped),
        const SizedBox(height: 24),

        // BOTÕES
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "finalizar Pedido",
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('finalizar Pedido'),
                        content: const Text('Deseja realmente finalizar este pedido?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(); 
                            },
                            child: const Text('Voltar'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await finalizarPedido(Num_ped); 
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Pedido finalizado com sucesso!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              } catch (e) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erro ao finalizar pedido: $e',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red, // fundo vermelho
                                ),
                              );
                              }
                            },
                            child: const Text('Confirmar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                secondary: true,
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: "Cancelar Pedido",
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Cancelar Pedido'),
                        content: const Text('Deseja realmente cancelar este pedido?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(); 
                            },
                            child: const Text('Voltar'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // Aqui é onde você chama seu backend
                              try {
                                await cancelarPedido(Num_ped); 
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: const Text('Pedido cancelado com sucesso!'), backgroundColor: Colors.green),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao cancelar pedido: $e'), backgroundColor: Colors.red),
                                );
                              }
                            },
                            child: const Text('Confirmar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                secondary: true,
                isFullWidth: true,
              ),
            ),

          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: text80,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: text40,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


Future<void> cancelarPedido(String numPed) async {
  final response = await http.delete(
    Uri.parse('https://jlykzxqlscmbduraczcy.supabase.co/pedidos/$numPed'),
  );

  if (response.statusCode != 200) {
    throw Exception('Erro ao cancelar pedido');
  }
}


Future<void> finalizarPedido(String numPed) async {
  print('Finalizando pedido: $numPed');
}
