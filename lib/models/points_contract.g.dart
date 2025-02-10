// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_contract.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PointsContractImplAdapter extends TypeAdapter<_$PointsContractImpl> {
  @override
  final int typeId = 4;

  @override
  _$PointsContractImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$PointsContractImpl(
      address: fields[0] as String,
      name: fields[1] as String,
      metadata: (fields[2] as Map).cast<String, dynamic>(),
      symbol: fields[3] as String,
      decimals: fields[4] as int,
      totalSupply: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, _$PointsContractImpl obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.symbol)
      ..writeByte(4)
      ..write(obj.decimals)
      ..writeByte(5)
      ..write(obj.totalSupply)
      ..writeByte(2)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointsContractImplAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PointsContractImpl _$$PointsContractImplFromJson(Map<String, dynamic> json) =>
    _$PointsContractImpl(
      address: json['address'] as String,
      name: json['name'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      symbol: json['symbol'] as String,
      decimals: (json['decimals'] as num).toInt(),
      totalSupply: (json['totalSupply'] as num).toInt(),
    );

Map<String, dynamic> _$$PointsContractImplToJson(
        _$PointsContractImpl instance) =>
    <String, dynamic>{
      'address': instance.address,
      'name': instance.name,
      'metadata': instance.metadata,
      'symbol': instance.symbol,
      'decimals': instance.decimals,
      'totalSupply': instance.totalSupply,
    };
