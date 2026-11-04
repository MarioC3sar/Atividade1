/// Tela inicial do aplicativo — controle da coleta de localização.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/servico_localizacao.dart';

class TelaColeta extends StatefulWidget {
  const TelaColeta({super.key});

  @override
  State<TelaColeta> createState() => _TelaColetaState();
}

class _TelaColetaState extends State<TelaColeta> {
  final ServicoLocalizacao _servico = ServicoLocalizacao();
  final RepositorioLocalizacoes _repositorio = RepositorioLocalizacoes();

  bool _estaColetando = false;
  String _mensagem = '';
  StreamSubscription<Position>? _streamSubscription;

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// Inicia a coleta de localização.
  Future<void> _iniciarColeta() async {
    try {
      // Verificar GPS
      final gpsHabilitado = await _servico.verificarGPS();
      if (!gpsHabilitado) {
        if (mounted) {
          _mostrarMensagem('GPS desabilitado. Por favor, habilite o GPS.');
        }
        return;
      }

      // Verificar permissões
      final permissao = await _servico.solicitarPermissoes();
      if (permissao != PermissaoStatus.concedida) {
        if (mounted) {
          if (permissao == PermissaoStatus.negadaPermanentemente) {
            _mostrarMensagem(
              'Permissão negada permanentemente. Abra as configurações para habilitar.',
            );
          } else {
            _mostrarMensagem('Permissão de localização negada.');
          }
        }
        return;
      }

      // Iniciar stream
      final stream = _servico.iniciarColeta();
      _streamSubscription = stream.listen(
        (posicao) async {
          final localizacao = Localizacao(
            latitude: posicao.latitude,
            longitude: posicao.longitude,
            precisao: posicao.accuracy ?? 0.0,
            instante: DateTime.now(),
          );
          await _repositorio.inserir(localizacao);
          if (mounted) {
            _mostrarMensagem(
              'Localização salva: ${posicao.latitude.toStringAsFixed(6)}, '
              '${posicao.longitude.toStringAsFixed(6)}',
            );
          }
        },
        onError: (erro) {
          if (mounted) {
            setState(() {
              _estaColetando = false;
              _mensagem = 'Erro na coleta: $erro';
            });
          }
        },
      );
      _servico.registrarAssinatura(_streamSubscription!);

      if (mounted) {
        setState(() {
          _estaColetando = true;
          _mensagem = 'Coleta iniciada.';
        });
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensagem('Erro ao iniciar coleta: $e');
      }
    }
  }

  /// Para a coleta de localização.
  Future<void> _pararColeta() async {
    try {
      await _servico.pararColeta();
      await _streamSubscription?.cancel();
      _streamSubscription = null;

      if (mounted) {
        setState(() {
          _estaColetando = false;
          _mensagem = 'Coleta parada.';
        });
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensagem('Erro ao parar coleta: $e');
      }
    }
  }

  /// Abre as configurações de permissão do dispositivo.
  Future<void> _abrirConfiguracoes() async {
    await _servico.abrirConfiguracoes();
  }

  /// Navega para a tela de histórico.
  void _irParaHistorico() {
    Navigator.of(context).pushNamed('/historico');
  }

  /// Navega para a tela de mapa.
  void _irParaMapa() {
    Navigator.of(context).pushNamed('/mapa');
  }

  void _mostrarMensagem(String msg) {
    setState(() {
      _mensagem = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localizações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador visual do estado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _estaColetando ? Icons.location_on : Icons.location_off,
                      size: 64,
                      color: _estaColetando ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _estaColetando ? 'Coleta Ativa' : 'Coleta Inativa',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (_mensagem.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _mensagem,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botões de controle
            ElevatedButton.icon(
              onPressed: _estaColetando ? null : _iniciarColeta,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar coleta'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _estaColetando ? _pararColeta : null,
              icon: const Icon(Icons.stop),
              label: const Text('Parar coleta'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Botões de navegação
            OutlinedButton.icon(
              onPressed: _irParaHistorico,
              icon: const Icon(Icons.history),
              label: const Text('Consultar histórico'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _irParaMapa,
              icon: const Icon(Icons.map),
              label: const Text('Ver mapa'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: _abrirConfiguracoes,
              icon: const Icon(Icons.settings),
              label: const Text('Configurações de permissão'),
            ),
          ],
        ),
      ),
    );
  }
}

