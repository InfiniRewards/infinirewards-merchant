import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'points_contract.freezed.dart';
part 'points_contract.g.dart';

@freezed
class PointsContract extends HiveObject with _$PointsContract {
  PointsContract._();

  @HiveType(typeId: 4)
  factory PointsContract({
    @HiveField(0) required String address,
    @HiveField(1) required String name,
    @HiveField(2) required Map<String, dynamic> metadata,
    @HiveField(3) required String symbol,
    @HiveField(4) required int decimals,
    @HiveField(5) required int totalSupply,
  }) = _PointsContract;

  factory PointsContract.fromJson(Map<String, dynamic> json) =>
      _$PointsContractFromJson(json);
}
