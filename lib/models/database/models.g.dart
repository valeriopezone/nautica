// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GridThemeRecordAdapter extends TypeAdapter<GridThemeRecord> {
  @override
  final int typeId = 2;

  @override
  GridThemeRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GridThemeRecord(
      id: fields[0] as int,
      name: fields[1] as String,
      schema: fields[2] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, GridThemeRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.schema);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridThemeRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
