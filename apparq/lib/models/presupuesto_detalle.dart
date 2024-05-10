import 'package:hive/hive.dart';

part 'presupuesto_detalle.g.dart';

@HiveType(typeId: 0) // Puedes cambiar el typeId si es necesario
class PresupuestoDetalle {
  @HiveField(0)
  final String nombre;
  @HiveField(1) 
  final double total;
  @HiveField(2)
  final String opcion;
  @HiveField(3)
  final String fechaEmision;
  @HiveField(4)
  final String fechaCaducidad;
  @HiveField(5)
  final String nombreEmpresa;
  @HiveField(6)
  final String telefono;
  @HiveField(7) 
  final String domicilio;
  @HiveField(8)
  final String correo;
  @HiveField(9)
  final String contratista;
  @HiveField(10)
  final String telefonoContratista;
  @HiveField(11) 
  final String giroProyecto;
  @HiveField(12)
  final String ubicacionProyecto;
  @HiveField(13)
  final String descripcionProyecto;
  
  PresupuestoDetalle({
    required this.nombre,
    required this.total,
    required this.opcion,
    required this.fechaEmision,
    required this.fechaCaducidad,
    required this.nombreEmpresa,
    required this.telefono,
    required this.domicilio,
    required this.correo,
    required this.contratista,
    required this.telefonoContratista,
    required this.giroProyecto,
    required this.ubicacionProyecto,
    required this.descripcionProyecto,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'total': total,
      'opcion': opcion,
      'fechaEmision': fechaEmision,
      'fechaCaducidad': fechaCaducidad,
      'nombreEmpresa': nombreEmpresa,
      'telefono': telefono,
      'domicilio': domicilio,
      'correo': correo,
      'contratista': contratista,
      'telefonoContratista': telefonoContratista,
      'giroProyecto': giroProyecto,
      'ubicacionProyecto': ubicacionProyecto,
      'descripcionProyecto': descripcionProyecto,
    };
  }

  static PresupuestoDetalle fromMap(Map<String, dynamic> map) {
    return PresupuestoDetalle(
      nombre: map['nombre'],
      total: map['total'],
      opcion: map['opcion'],
      fechaEmision: map['fechaEmision'],
      fechaCaducidad: map['fechaCaducidad'],
      nombreEmpresa: map['nombreEmpresa'],
      telefono: map['telefono'],
      domicilio: map['domicilio'],
      correo: map['correo'],
      contratista: map['contratista'],
      telefonoContratista: map['telefonoContratista'],
      giroProyecto: map['giroProyecto'],
      ubicacionProyecto: map['ubicacionProyecto'],
      descripcionProyecto: map['descripcionProyecto'], 
    );
  }
}