import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:async';

class PrevisaoException implements Exception {
  final String message;
  PrevisaoException(this.message);
  @override
  String toString() => message;
}

class PrevisaoService {
  String _apiIp = "";
  http.Client _client = http.Client();

  void setApiIp(String ip) {
    _apiIp = ip;
  }

  String get _apiLocalUrl => "http://$_apiIp:8000";

  void cancelCurrentRequest() {
    _client.close();
    _client = http.Client();
  }

  Future<bool> _checkHostConnection() async {
    if (_apiIp.isEmpty) {
      throw PrevisaoException(
        "Nenhum endereço IP foi fornecido. Configure-o no ícone de configurações.",
      );
    }
    try {
      final socket = await Socket.connect(
        _apiIp,
        8000,
        timeout: const Duration(seconds: 3),
      );
      await socket.close();
      return true;
    } catch (e) {
      throw PrevisaoException(
        "Não foi possível conectar ao IP fornecido na porta 8000. Verifique se o IP está correto e se o servidor está rodando.",
      );
    }
  }

  Future<int> _fetchEstoqueAtual(int itemId) async {
    try {
      final response = await Supabase.instance.client
          .from('lote')
          .select('lot_qtd_atual')
          .eq('lot_item_id', itemId)
          .eq('lot_ativo', true);

      if (response.isEmpty) {
        return 0;
      }

      int estoqueTotal = 0;
      for (var lote in response) {
        estoqueTotal += (lote['lot_qtd_atual'] as num).toInt();
      }
      return estoqueTotal;
    } catch (e) {
      throw PrevisaoException("Falha ao buscar estoque no Supabase: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchDemandaPrevista(int itemId) async {
    final uri = Uri.parse('$_apiLocalUrl/gerar-previsao?item_id=$itemId');
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 60));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['previsao']);
    } else {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['erro'] ?? "Erro desconhecido da API";

      if (errorMessage.contains("movimentações suficientes")) {
        throw PrevisaoException(
          "Este item não possui movimentações o suficiente para poder gerar uma previsão confiável.",
        );
      }

      throw PrevisaoException("O item selecionado não possui movimentações o suficiente para gerar uma previsão confiável.");
    }
  }

  List<FlSpot> _calcularGraficoInventario(
    int estoqueInicial,
    List<Map<String, dynamic>> demandaPrevista,
  ) {
    final List<FlSpot> spots = [];
    double estoqueCalculado = estoqueInicial.toDouble();

    spots.add(
      FlSpot(
        DateTime.now().millisecondsSinceEpoch.toDouble(),
        estoqueCalculado,
      ),
    );

    for (var dia in demandaPrevista) {
      try {
        final data = DateTime.parse(dia['ds']);
        final demandaDoDia = (dia['yhat'] as num).toDouble();

        estoqueCalculado -= demandaDoDia;

        spots.add(
          FlSpot(data.millisecondsSinceEpoch.toDouble(), estoqueCalculado),
        );
      } catch (e) {
        print("Erro ao parsear dados no cálculo do gráfico: $e");
      }
    }

    return spots;
  }

  Future<(int estoque, List<FlSpot> spots)> buscarPrevisaoHibrida(
    int itemId,
  ) async {
    try {
      await _checkHostConnection();

      final results = await Future.wait([
        _fetchEstoqueAtual(itemId),
        _fetchDemandaPrevista(itemId),
      ]);

      final int estoque = results[0] as int;
      final List<Map<String, dynamic>> demanda =
          results[1] as List<Map<String, dynamic>>;

      final List<FlSpot> spots = _calcularGraficoInventario(estoque, demanda);

      return (estoque, spots);
    } on http.ClientException catch (e) {
      if (e.message.contains('Connection closed')) {
        throw PrevisaoException("Você cancelou a requisição da previsão.");
      }
      throw PrevisaoException(
          "Não foi possível conectar ao servidor. Verifique o IP ou se o servidor está rodando.");
    } on SocketException catch (_) {
      throw PrevisaoException(
          "Não foi possível conectar ao servidor. Verifique se o IP está correto e se o servidor da API está rodando.");
    } on TimeoutException catch (_) {
      throw PrevisaoException(
          "Tempo esgotado. O servidor no IP fornecido não respondeu a tempo.");
    } on PrevisaoException {
      rethrow; 
    } catch (e) {
      print("Erro não tratado no PrevisaoService: $e");
      throw PrevisaoException("Ocorreu um erro inesperado. Tente novamente.");
    }
  }

  Future<Map<String, dynamic>> buscarConsumoPorSetor() async {
    try {
      await _checkHostConnection();

      final uri = Uri.parse('$_apiLocalUrl/gerar-consumo-setor');
      final response = await _client.get(uri).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = errorData['erro'] ?? "Erro desconhecido da API de consumo";
        throw PrevisaoException(errorMessage);
      }
    } on http.ClientException catch (e) {
      if (e.message.contains('Connection closed')) {
        throw PrevisaoException("Operação cancelada pelo usuário.");
      }
      throw PrevisaoException("Não foi possível conectar ao servidor. Verifique o IP ou se o servidor está rodando.");
    } on SocketException catch (_) {
      throw PrevisaoException("Não foi possível conectar ao servidor. Verifique se o IP está correto e se o servidor da API está rodando.");
    } on TimeoutException catch (_) {
      throw PrevisaoException("Tempo esgotado. O servidor no IP fornecido não respondeu a tempo.");
    } on PrevisaoException {
      rethrow;
    } catch (e) {
      print("Erro não tratado no buscarConsumoPorSetor: $e");
      throw PrevisaoException("Ocorreu um erro inesperado. Tente novamente.");
    }
  }
}
