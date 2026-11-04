/// Tela de histórico de localizações salvas.
import 'package:flutter/material.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../widgets/item_localizacao.dart';

class TelaLocalizacoes extends StatefulWidget {
  const TelaLocalizacoes({super.key});

  @override
  State<TelaLocalizacoes> createState() => _TelaLocalizacoesState();
}

class _TelaLocalizacoesState extends State<TelaLocalizacoes> {
  final RepositorioLocalizacoes _repositorio = RepositorioLocalizacoes();

  List<Localizacao> _localizacoes = [];
  bool _carregando = true;
  String? _erro;
  String? _mensagemSucesso;

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

  Future<void> _limparHistorico() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Text(
          'Tem certeza que deseja limpar todo o histórico de localizações? '
          'Esta exclusão é permanente e não pode ser desfeita.\n\n'
          'Se a coleta estiver ativa, novos registros continuarão sendo salvos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Limpar histórico'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _repositorio.limparTodos();
      if (mounted) {
        setState(() {
          _localizacoes = [];
          _mensagemSucesso = 'Histórico limpo com sucesso.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Erro ao limpar histórico: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Localizações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregando ? null : _carregarLocalizacoes,
            tooltip: 'Atualizar',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _localizacoes.isEmpty ? null : _limparHistorico,
            tooltip: 'Limpar histórico',
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
            Text('Carregando localizações...'),
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
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Nenhuma localização registrada.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_mensagemSucesso != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.green.shade100,
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _mensagemSucesso!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _mensagemSucesso = null;
                    });
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _localizacoes.length,
            itemBuilder: (context, index) {
              return ItemLocalizacao(localizacao: _localizacoes[index]);
            },
          ),
        ),
      ],
    );
  }
}
