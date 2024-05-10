import 'package:hive/hive.dart';

part 'construccion_detalle.g.dart';

@HiveType(typeId: 1) // Asegúrate de que el typeId sea único
class ConstruccionDetalle {
  @HiveField(0)
  final String nombreArchivo;

  @HiveField(1)
  final List<double> porcentajes;

  ConstruccionDetalle({required this.nombreArchivo, required this.porcentajes});

  Map<String, dynamic> toMap() {
    return {
      'nombreArchivo': nombreArchivo,
      'porcentajes': porcentajes,
    };
  }

  static ConstruccionDetalle fromMap(Map<String, dynamic> map) {
    return ConstruccionDetalle(
      nombreArchivo: map['nombreArchivo'],
      porcentajes: List<double>.from(map['porcentajes']),
    );
  }
}