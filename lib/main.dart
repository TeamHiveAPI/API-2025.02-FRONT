import 'package:flutter/material.dart';
import 'screens/cadastrar_item.dart';
import 'screens/escanear_QRCode.dart';
import 'screens/estoque.dart';
import 'screens/historico_item.dart';
import 'screens/historico_pedido.dart';
import 'screens/home.dart';
import 'screens/pedidos.dart';
import 'screens/login.dart';
import 'screens/registrar_pedido.dart';




void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navegação com Roteador',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 18)),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => Home());
          case '/estoque':
            return MaterialPageRoute(builder: (_) => Estoque());
          case '/cadastrar_item':
            return MaterialPageRoute(builder: (_) => CadastrarItem());
          case '/escanear_QRCode':
            return MaterialPageRoute(builder: (_) => EscanearQrcode());
          case '/historico_item':
            return MaterialPageRoute(builder: (_) => HistoricoItem());
          case '/historico_pedido':
            return MaterialPageRoute(builder: (_) => HistoricoPedido());
          case '/pedidos':
            return MaterialPageRoute(builder: (_) => Pedidos());
          case '/login':
            return MaterialPageRoute(builder: (_) => Login());
          case '/registrar_pedido':
            return MaterialPageRoute(builder: (_) => RegistrarPedido());
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Rota não encontrada')),
              ),
            );
        }
      },
    );
  }
}
