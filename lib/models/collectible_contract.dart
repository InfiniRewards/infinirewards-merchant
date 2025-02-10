import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'collectible_contract.freezed.dart';
part 'collectible_contract.g.dart';

@freezed
class CollectibleContract extends HiveObject with _$CollectibleContract {
  CollectibleContract._();

  @HiveType(typeId: 5)
  factory CollectibleContract({
    @HiveField(0) required String address,
    @HiveField(1) required String name,
    @HiveField(2) required Map<String, dynamic> metadata,
    @HiveField(3) required String pointsContract,
    @HiveField(4) required List<CollectibleToken> tokens,
  }) = _CollectibleContract;

  factory CollectibleContract.fromJson(Map<String, dynamic> json) =>
      _$CollectibleContractFromJson(json);

  bool get isMembership => name.toLowerCase().startsWith('[membership]');
  String get formattedName => name.replaceFirst('[membership]', '').trim();
  String get type => isMembership ? 'membership' : 'voucher';
}

@freezed
class CollectibleToken extends HiveObject with _$CollectibleToken {
  CollectibleToken._();
  @HiveType(typeId: 6)
  factory CollectibleToken({
    @HiveField(0) required BigInt tokenId,
    @HiveField(1) required String pointsContract,
    @HiveField(2) required BigInt price,
    @HiveField(3) required int expiry,
    @HiveField(4) required Map<String, dynamic> metadata,
    @HiveField(5) required BigInt supply,
  }) = _CollectibleToken;

  factory CollectibleToken.fromJson(Map<String, dynamic> json) =>
      _$CollectibleTokenFromJson(json);
}
