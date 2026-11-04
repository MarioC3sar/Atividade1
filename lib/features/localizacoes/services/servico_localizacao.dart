/// Serviço responsável por gerenciar GPS, permissões e stream contínuo de localização.
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

/// Resultado da verificação de permissões de localização.
enum PermissaoStatus { concedida, negada, negadaPermanentemente }

class ServicoLocalizacao {
  static final ServicoLocalizacao _instancia = ServicoLocalizacao._internal();
  factory ServicoLocalizacao() => _instancia;
  ServicoLocalizacao._internal();

  StreamSubscription<Position>? _streamSubscription;
  bool _estaColetando = false;

  /// Retorna `true` se a coleta está ativa.
  bool get estaColetando => _estaColetando;

  /// Verifica se o serviço de localização (GPS) está habilitado.
  Future<bool> verificarGPS() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Solicita as permissões de localização e retorna o status.
  Future<PermissaoStatus> solicitarPermissoes() async {
    final status = await Geolocator.checkPermission();

    if (status == LocationPermission.always || status == LocationPermission.whileInUse) {
      return PermissaoStatus.concedida;
    }

    final solicitada = await Geolocator.requestPermission();

    if (solicitada == LocationPermission.always || solicitada == LocationPermission.whileInUse) {
      return PermissaoStatus.concedida;
    } else if (solicitada == LocationPermission.deniedForever) {
      return PermissaoStatus.negadaPermanentemente;
    } else {
      return PermissaoStatus.negada;
    }
  }

  /// Abre as configurações do dispositivo para o usuário habilitar permissões.
  Future<void> abrirConfiguracoes() async {
    await Geolocator.openAppSettings();
  }

  /// Inicia a coleta contínua de localização.
  ///
  /// Retorna um [Stream] de [Position] com intervalo de 20 segundos e alta precisão.
  /// Lança [Exception] se o GPS estiver desabilitado ou permissão negada.
  Stream<Position> iniciarColeta() {
    if (_estaColetando) {
      throw StateError('A coleta já está em execução.');
    }

    var configuracoes = AndroidSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
      intervalDuration: const Duration(seconds: 20),
    );

    _estaColetando = true;
    return Geolocator.getPositionStream(locationSettings: configuracoes)
        .handleError((error) {
      _estaColetando = false;
      throw Exception('Erro ao obter localização: $error');
    });
  }

  /// Para a coleta contínua de localização e cancela a assinatura do stream.
  Future<void> pararColeta() async {
    if (!_estaColetando) return;

    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _estaColetando = false;
  }

  /// Registra uma assinatura do stream para que possa ser cancelada corretamente.
  void registrarAssinatura(StreamSubscription<Position> subscription) {
    _streamSubscription = subscription;
  }

  /// Verifica o status atual da conectividade.
  Future<List<ConnectivityResult>> verificarConectividade() async {
    final connectivity = Connectivity();
    return await connectivity.checkConnectivity();
  }

  /// Libera todos os recursos do serviço.
  Future<void> liberar() async {
    await pararColeta();
  }
}
