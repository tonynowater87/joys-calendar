// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarModelAdapter extends TypeAdapter<CalendarModel> {
  @override
  final int typeId = 2;

  @override
  CalendarModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarModel()
      ..displayName = fields[0] as String
      ..dateTime = fields[1] as DateTime
      ..country = fields[2] as String
      ..continuousDays = fields[3] == null ? 0 : fields[3] as int;
  }

  @override
  void write(BinaryWriter writer, CalendarModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.displayName)
      ..writeByte(1)
      ..write(obj.dateTime)
      ..writeByte(2)
      ..write(obj.country)
      ..writeByte(3)
      ..write(obj.continuousDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
