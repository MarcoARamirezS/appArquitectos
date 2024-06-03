// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presupuesto_detalle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresupuestoDetalleAdapter extends TypeAdapter<PresupuestoDetalle> {
  @override
  final int typeId = 0;

  @override
  PresupuestoDetalle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PresupuestoDetalle(
      nombre: fields[0] as String,
      total: fields[1] as double,
      opcion: fields[2] as String,
      fechaEmision: fields[3] as String,
      fechaCaducidad: fields[4] as String,
      nombreEmpresa: fields[5] as String,
      telefono: fields[6] as String,
      domicilio: fields[7] as String,
      correo: fields[8] as String,
      contratista: fields[9] as String,
      telefonoContratista: fields[10] as String,
      giroProyecto: fields[11] as String,
      ubicacionProyecto: fields[12] as String,
      descripcionProyecto: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PresupuestoDetalle obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.total)
      ..writeByte(2)
      ..write(obj.opcion)
      ..writeByte(3)
      ..write(obj.fechaEmision)
      ..writeByte(4)
      ..write(obj.fechaCaducidad)
      ..writeByte(5)
      ..write(obj.nombreEmpresa)
      ..writeByte(6)
      ..write(obj.telefono)
      ..writeByte(7)
      ..write(obj.domicilio)
      ..writeByte(8)
      ..write(obj.correo)
      ..writeByte(9)
      ..write(obj.contratista)
      ..writeByte(10)
      ..write(obj.telefonoContratista)
      ..writeByte(11)
      ..write(obj.giroProyecto)
      ..writeByte(12)
      ..write(obj.ubicacionProyecto)
      ..writeByte(13)
      ..write(obj.descripcionProyecto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresupuestoDetalleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
