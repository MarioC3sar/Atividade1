/// Repositório centralizado para operações de localizações no banco SQLite.
import '../database/banco_localizacoes.dart';
import '../../models/localizacao.dart';

class RepositorioLocalizacoes {
  static final RepositorioLocalizacoes _instancia =
      RepositorioLocalizacoes._internal();
  factory RepositorioLocalizacoes() => _instancia;
  RepositorioLocalizacoes._internal();

  final BancoLocalizacoes _banco = BancoLocalizacoes();

  /// Insere uma nova localização no banco de dados.
  Future<int> inserir(Localizacao localizacao) async {
    final db = await _banco.database;
    return await db.insert('localizacoes', localizacao.toMap());
  }

  /// Retorna as últimas 100 localizações, ordenadas da mais recente para a mais antiga.
  Future<List<Localizacao>> obterUltimas100() async {
    final db = await _banco.database;
    final mapas = await db.query(
      'localizacoes',
      orderBy: 'instante DESC',
      limit: 100,
    );
    return mapas.map((m) => Localizacao.fromMap(m)).toList();
  }

  /// Remove todos os registros da tabela, preservando a estrutura do banco.
  Future<int> limparTodos() async {
    final db = await _banco.database;
    final resultado = await db.delete('localizacoes');
    return resultado;
  }
}
