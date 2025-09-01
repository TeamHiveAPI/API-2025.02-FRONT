import 'package:flutter/material.dart';
import '../widgets/buttons/botao_roteador.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela 1 - Home'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BotaoRoteador(
            texto: 'Ir para a tela de estoque',
            icone: Icons.arrow_forward,
            cor: Colors.indigo,
            onPressed: () {
              Navigator.pushNamed(context, '/estoque');
            },
          ),
          SizedBox(height: 20), 
          BotaoRoteador(
            texto: 'login',
            icone: Icons.password,
            cor: Colors.green,
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
          SizedBox(height: 20), 
          BotaoRoteador(
            texto: 'cadastro de item',
            icone: Icons.password,
            cor: Colors.green,
            onPressed: () {
              Navigator.pushNamed(context, '/cadastrar_item');
            },
          ),
          SizedBox(height: 20), 
          BotaoRoteador(
            texto: 'escanear QRCode',
            icone: Icons.password,
            cor: Colors.green,
            onPressed: () {
              Navigator.pushNamed(context, '/escanear_QRCode');
            },
          ),
          SizedBox(height: 20), 
          BotaoRoteador(
            texto: 'histórico do item',
            icone: Icons.password,
            cor: Colors.green,
            onPressed: () {
              Navigator.pushNamed(context, '/historico_item');
            },
          ),
          SizedBox(height: 20), 
          BotaoRoteador(
            texto: 'histórico do pedido',
            icone: Icons.password,
            cor: Colors.green,
            onPressed: () {
              Navigator.pushNamed(context, '/historico_pedido');
            },
          ),
          SizedBox(height: 20), 
          BotaoRoteador(
            texto: 'pedidos',
            icone: Icons.password,
            cor: Colors.green,
            onPressed: () {
              Navigator.pushNamed(context, '/pedidos');
            },
          ),
          SizedBox(height: 20), 
          BotaoRoteador(
            texto: 'registrar pedido',
            icone: Icons.password,
            cor: Colors.green,
            onPressed: () {
              Navigator.pushNamed(context, '/registrar_pedido');
            },
          ),
        ],
      ),
    );
  }
}
