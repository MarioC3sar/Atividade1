/// Modelo que representa uma localização geográfica coletada pelo aplicativo.
class Localizacao {
  final int? id;
  final double latitude;
  final double longitude;
  final double precisao;
  final DateTime instante;

  const Localizacao({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.instante,
  });

  /// Converte o objeto em um mapa para armazenamento no SQLite.
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'precisao': precisao,
      'instante': instante.toUtc().toIso8601String(),
    };
  }

  /// Cria um [Localizacao] a partir de um mapa retornado pelo SQLite.
  factory Localizacao.fromMap(Map<String, dynamic> map) {
    return Localizacao(
      id: map['id'] as int?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      precisao: map['precisao'] as double,
      instante: DateTime.parse(map['instante'] as String).toLocal(),
    );
  }

  /// Converte o objeto para JSON.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'latitude': latitude.toStringAsFixed(6),
      'longitude': longitude.toStringAsFixed(6),
      'precisao': precisao.toStringAsFixed(1),
      'instante': instante.toIso8601String(),
    };
  }

  /// Cria um [Localizacao] a partir de JSON.
  factory Localizacao.fromJson(Map<String, dynamic> json) {
    return Localizacao(
      id: json['id'] as int?,
      latitude: double.parse(json['latitude'] as String),
      longitude: double.parse(json['longitude'] as String),
      precisao: double.parse(json['precisao'] as String),
      instante: DateTime.parse(json['instante'] as String),
    );
  }

  @override
  String toString() {
    return 'Localizacao(id: $id, lat: ${latitude.toStringAsFixed(6)}, '
        'lon: ${longitude.toStringAsFixed(6)}, '
        'precisao: ${precisao.toStringAsFixed(1)}m, '
        'instante: $instante)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Localizacao &&
        other.id == id &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.precisao == precisao &&
        other.instante == instante;
  }

  @override
  int get hashCode {
    return Object.hash(id, latitude, longitude, precisao, instante);
  }
}
