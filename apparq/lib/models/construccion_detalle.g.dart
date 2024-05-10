// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'construccion_detalle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConstruccionDetalleAdapter extends TypeAdapter<ConstruccionDetalle> {
  @override
  final int typeId = 1;

  @override
  ConstruccionDetalle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConstruccionDetalle(
      nombreArchivo: fields[0] as String,
      porcentajes: (fields[1] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, ConstruccionDetalle obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nombreArchivo)
      ..writeByte(1)
      ..write(obj.porcentajes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstruccionDetalleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
