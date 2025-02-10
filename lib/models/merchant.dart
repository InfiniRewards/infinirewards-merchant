import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'merchant.freezed.dart';
part 'merchant.g.dart';

@freezed
class Merchant extends HiveObject with _$Merchant {
  Merchant._();

  @HiveType(typeId: 3)
  factory Merchant({
    @HiveField(0) required String address,
    @HiveField(1) required String name,
  }) = _Merchant;

  factory Merchant.fromJson(Map<String, dynamic> json) =>
      _$MerchantFromJson(json);
}
