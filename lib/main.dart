import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistema_almox/core/theme/colors.dart';
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navegação com Roteador',
      theme: ThemeData(
        textTheme: GoogleFonts.ubuntuSansTextTheme(Theme.of(context).textTheme),

        colorScheme: ColorScheme.fromSeed(seedColor: brandBlue),

        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          floatingLabelStyle: TextStyle(
            color: brandBlue,
            fontWeight: FontWeight.w600,
          ),
        ),

        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: text80,
          selectionColor: text80,
          selectionHandleColor: text80,
        ),
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
              builder: (_) =>
                  Scaffold(body: Center(child: Text('Rota não encontrada'))),
            );
        }
      },
    );
  }
}
