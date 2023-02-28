// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jieqi_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JieQiModelAdapter extends TypeAdapter<JieQiModel> {
  @override
  final int typeId = 3;

  @override
  JieQiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JieQiModel()
      ..displayName = fields[0] as String
      ..dateTime = fields[1] as DateTime;
  }

  @override
  void write(BinaryWriter writer, JieQiModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.displayName)
      ..writeByte(1)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JieQiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
