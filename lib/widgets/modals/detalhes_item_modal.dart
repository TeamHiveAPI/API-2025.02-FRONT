import 'package:flutter/material.dart';
import 'base_modals.dart';

class DetalhesItemModal extends StatelessWidget {
  final String nome;
  final String n_ficha;
  final String un_medida;
  final int qtdDisponivel;
  final int qtdReservada;
  final String grupo;

  const DetalhesItemModal({
    super.key,
    required this.nome,
    required this.n_ficha,
    required this.un_medida,
    required this.qtdDisponivel,
    required this.qtdReservada,
    required this.grupo,
  });

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      titulo: "Detalhes do Item",
      conteudo: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Nome
    Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Text(
            "Nome: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(nome),
        ],
      ),
    ),

    // Nº da Ficha
    Row(
      children: [
        Expanded(
          child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 8, right: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              const Text(
                "N° da Ficha: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(n_ficha),
            ],
          ),
        ),
      ),

      // Unidade de Medida
      Expanded(
        child:  Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              const Text(
                "Unidade de Medida: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(un_medida),
            ],
          ),
        ),
      ),
    ],
  ),

    // Quantidade Disponível
    Row(
  children: [
    Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8, right: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            const Text(
              "Qtd. Disponível: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(qtdDisponivel.toString()),
          ],
        ),
      ),
    ),
    Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            const Text(
              "Qtd. Reservada: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(qtdReservada.toString()),
          ],
        ),
      ),
    ),
  ],
),

    // Grupo
    Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Text(
            "Grupo: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(grupo),
        ],
      ),
    ),

    const SizedBox(height: 20),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        iconColor: Colors.white,
        alignment: Alignment.center,
      ),
      onPressed: () {},
      icon: const Icon(Icons.history),
      label: const Text("Ver Histórico de Movimentação"),
    ),
  ],
),

    const SizedBox(height: 10),

    // Linha de botões
    Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            label: const Text("Editar"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.qr_code),
            label: const Text("QR Code"),
          ),
        ),
      ],
    ),
  ],
),

    );
  }
}
