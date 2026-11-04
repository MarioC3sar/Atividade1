/// Serviço responsável por preparar o armazenamento local das imagens do mapa.
///
/// Garante que o diretório de cache existe e fornece o caminho para o mapa.
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CacheMapa {
  static final CacheMapa _instancia = CacheMapa._internal();
  factory CacheMapa() => _instancia;
  CacheMapa._internal();

  Directory? _cacheDirectory;

  /// Retorna o diretório de cache do mapa, criando-o se necessário.
  Future<Directory> getCacheDirectory() async {
    _cacheDirectory ??= await _prepararDiretorio();
    return _cacheDirectory!;
  }

  Future<Directory> _prepararDiretorio() async {
    final appDir = await getApplicationCacheDirectory();
    final mapaDir = Directory('${appDir.path}/mapa');

    if (!await mapaDir.exists()) {
      await mapaDir.create(recursive: true);
    }

    return mapaDir;
  }

  /// Retorna o caminho completo do diretório de cache.
  Future<String> getCachePath() async {
    final dir = await getCacheDirectory();
    return dir.path;
  }

  /// Limpa o cache de imagens do mapa.
  Future<void> limparCache() async {
    final dir = _cacheDirectory;
    if (dir != null && await dir.exists()) {
      await dir.delete(recursive: true);
      _cacheDirectory = null;
    }
  }

  /// Retorna o tamanho aproximado do cache em bytes.
  Future<int> tamanhoDoCache() async {
    final dir = _cacheDirectory;
    if (dir == null || !await dir.exists()) return 0;

    int tamanhoTotal = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        tamanhoTotal += await entity.length();
      }
    }
    return tamanhoTotal;
  }
}
