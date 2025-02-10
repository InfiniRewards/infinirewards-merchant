// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collectible_contract.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectibleContractImplAdapter
    extends TypeAdapter<_$CollectibleContractImpl> {
  @override
  final int typeId = 5;

  @override
  _$CollectibleContractImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$CollectibleContractImpl(
      address: fields[0] as String,
      name: fields[1] as String,
      metadata: (fields[2] as Map).cast<String, dynamic>(),
      pointsContract: fields[3] as String,
      tokens: (fields[4] as List).cast<CollectibleToken>(),
    );
  }

  @override
  void write(BinaryWriter writer, _$CollectibleContractImpl obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.pointsContract)
      ..writeByte(2)
      ..write(obj.metadata)
      ..writeByte(4)
      ..write(obj.tokens);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectibleContractImplAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CollectibleTokenImplAdapter extends TypeAdapter<_$CollectibleTokenImpl> {
  @override
  final int typeId = 6;

  @override
  _$CollectibleTokenImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$CollectibleTokenImpl(
      tokenId: fields[0] as BigInt,
      pointsContract: fields[1] as String,
      price: fields[2] as BigInt,
      expiry: fields[3] as int,
      metadata: (fields[4] as Map).cast<String, dynamic>(),
      supply: fields[5] as BigInt,
    );
  }

  @override
  void write(BinaryWriter writer, _$CollectibleTokenImpl obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.tokenId)
      ..writeByte(1)
      ..write(obj.pointsContract)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.expiry)
      ..writeByte(5)
      ..write(obj.supply)
      ..writeByte(4)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectibleTokenImplAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CollectibleContractImpl _$$CollectibleContractImplFromJson(
        Map<String, dynamic> json) =>
    _$CollectibleContractImpl(
      address: json['address'] as String,
      name: json['name'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      pointsContract: json['pointsContract'] as String,
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => CollectibleToken.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CollectibleContractImplToJson(
        _$CollectibleContractImpl instance) =>
    <String, dynamic>{
      'address': instance.address,
      'name': instance.name,
      'metadata': instance.metadata,
      'pointsContract': instance.pointsContract,
      'tokens': instance.tokens,
    };

_$CollectibleTokenImpl _$$CollectibleTokenImplFromJson(
        Map<String, dynamic> json) =>
    _$CollectibleTokenImpl(
      tokenId: BigInt.parse(json['tokenId'] as String),
      pointsContract: json['pointsContract'] as String,
      price: BigInt.parse(json['price'] as String),
      expiry: (json['expiry'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>,
      supply: BigInt.parse(json['supply'] as String),
    );

Map<String, dynamic> _$$CollectibleTokenImplToJson(
        _$CollectibleTokenImpl instance) =>
    <String, dynamic>{
      'tokenId': instance.tokenId.toString(),
      'pointsContract': instance.pointsContract,
      'price': instance.price.toString(),
      'expiry': instance.expiry,
      'metadata': instance.metadata,
      'supply': instance.supply.toString(),
    };
