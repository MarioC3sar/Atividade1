/// Tela de mapa interativo com localizações salvas.
import 'package:flutter/material.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../widgets/mapa_localizacoes.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final RepositorioLocalizacoes _repositorio = RepositorioLocalizacoes();

  List<Localizacao> _localizacoes = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarLocalizacoes();
  }

  Future<void> _carregarLocalizacoes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await _repositorio.obterUltimas100();
      if (mounted) {
        setState(() {
          _localizacoes = lista;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Erro ao carregar localizações: $e';
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Localizações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregando ? null : _carregarLocalizacoes,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildCorpo(),
    );
  }

  Widget _buildCorpo() {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando mapa...'),
          ],
        ),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarLocalizacoes,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_localizacoes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Nenhuma localização registrada.\n'
                'Inicie a coleta para ver os pontos no mapa.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return MapaLocalizacoes(localizacoes: _localizacoes);
  }
}
