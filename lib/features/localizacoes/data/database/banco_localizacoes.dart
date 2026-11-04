/// Gerencia a criação e o acesso ao banco de dados SQLite de localizações.
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BancoLocalizacoes {
  static final BancoLocalizacoes _instancia = BancoLocalizacoes._internal();
  factory BancoLocalizacoes() => _instancia;
  BancoLocalizacoes._internal();

  Database? _database;

  /// Retorna a instância do [Database], inicializando-a se necessário.
  Future<Database> get database async {
    _database ??= await _inicializarBanco();
    return _database!;
  }

  Future<Database> _inicializarBanco() async {
    final dbPath = await getDatabasesPath();
    final caminho = join(dbPath, 'localizacoes.db');

    final db = await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE localizacoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            precisao REAL NOT NULL,
            instante TEXT NOT NULL
          )
        ''');
      },
    );

    return db;
  }

  /// Fecha a conexão com o banco de dados.
  Future<void> fechar() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
