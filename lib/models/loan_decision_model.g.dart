// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_decision_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanDecisionModelAdapter extends TypeAdapter<LoanDecisionModel> {
  @override
  final int typeId = 2;

  @override
  LoanDecisionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanDecisionModel(
      approved: fields[0] as bool,
      message: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LoanDecisionModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.approved)
      ..writeByte(1)
      ..write(obj.message);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanDecisionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
