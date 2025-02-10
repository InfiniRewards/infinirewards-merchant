// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collectible_contract.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CollectibleContract _$CollectibleContractFromJson(Map<String, dynamic> json) {
  return _CollectibleContract.fromJson(json);
}

/// @nodoc
mixin _$CollectibleContract {
  @HiveField(0)
  String get address => throw _privateConstructorUsedError;
  @HiveField(1)
  String get name => throw _privateConstructorUsedError;
  @HiveField(2)
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  @HiveField(3)
  String get pointsContract => throw _privateConstructorUsedError;
  @HiveField(4)
  List<CollectibleToken> get tokens => throw _privateConstructorUsedError;

  /// Serializes this CollectibleContract to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollectibleContract
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectibleContractCopyWith<CollectibleContract> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectibleContractCopyWith<$Res> {
  factory $CollectibleContractCopyWith(
          CollectibleContract value, $Res Function(CollectibleContract) then) =
      _$CollectibleContractCopyWithImpl<$Res, CollectibleContract>;
  @useResult
  $Res call(
      {@HiveField(0) String address,
      @HiveField(1) String name,
      @HiveField(2) Map<String, dynamic> metadata,
      @HiveField(3) String pointsContract,
      @HiveField(4) List<CollectibleToken> tokens});
}

/// @nodoc
class _$CollectibleContractCopyWithImpl<$Res, $Val extends CollectibleContract>
    implements $CollectibleContractCopyWith<$Res> {
  _$CollectibleContractCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectibleContract
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? name = null,
    Object? metadata = null,
    Object? pointsContract = null,
    Object? tokens = null,
  }) {
    return _then(_value.copyWith(
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      pointsContract: null == pointsContract
          ? _value.pointsContract
          : pointsContract // ignore: cast_nullable_to_non_nullable
              as String,
      tokens: null == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as List<CollectibleToken>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CollectibleContractImplCopyWith<$Res>
    implements $CollectibleContractCopyWith<$Res> {
  factory _$$CollectibleContractImplCopyWith(_$CollectibleContractImpl value,
          $Res Function(_$CollectibleContractImpl) then) =
      __$$CollectibleContractImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String address,
      @HiveField(1) String name,
      @HiveField(2) Map<String, dynamic> metadata,
      @HiveField(3) String pointsContract,
      @HiveField(4) List<CollectibleToken> tokens});
}

/// @nodoc
class __$$CollectibleContractImplCopyWithImpl<$Res>
    extends _$CollectibleContractCopyWithImpl<$Res, _$CollectibleContractImpl>
    implements _$$CollectibleContractImplCopyWith<$Res> {
  __$$CollectibleContractImplCopyWithImpl(_$CollectibleContractImpl _value,
      $Res Function(_$CollectibleContractImpl) _then)
      : super(_value, _then);

  /// Create a copy of CollectibleContract
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? name = null,
    Object? metadata = null,
    Object? pointsContract = null,
    Object? tokens = null,
  }) {
    return _then(_$CollectibleContractImpl(
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      pointsContract: null == pointsContract
          ? _value.pointsContract
          : pointsContract // ignore: cast_nullable_to_non_nullable
              as String,
      tokens: null == tokens
          ? _value._tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as List<CollectibleToken>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 5)
class _$CollectibleContractImpl extends _CollectibleContract {
  _$CollectibleContractImpl(
      {@HiveField(0) required this.address,
      @HiveField(1) required this.name,
      @HiveField(2) required final Map<String, dynamic> metadata,
      @HiveField(3) required this.pointsContract,
      @HiveField(4) required final List<CollectibleToken> tokens})
      : _metadata = metadata,
        _tokens = tokens,
        super._();

  factory _$CollectibleContractImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectibleContractImplFromJson(json);

  @override
  @HiveField(0)
  final String address;
  @override
  @HiveField(1)
  final String name;
  final Map<String, dynamic> _metadata;
  @override
  @HiveField(2)
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  @HiveField(3)
  final String pointsContract;
  final List<CollectibleToken> _tokens;
  @override
  @HiveField(4)
  List<CollectibleToken> get tokens {
    if (_tokens is EqualUnmodifiableListView) return _tokens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tokens);
  }

  @override
  String toString() {
    return 'CollectibleContract(address: $address, name: $name, metadata: $metadata, pointsContract: $pointsContract, tokens: $tokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectibleContractImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.pointsContract, pointsContract) ||
                other.pointsContract == pointsContract) &&
            const DeepCollectionEquality().equals(other._tokens, _tokens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      address,
      name,
      const DeepCollectionEquality().hash(_metadata),
      pointsContract,
      const DeepCollectionEquality().hash(_tokens));

  /// Create a copy of CollectibleContract
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectibleContractImplCopyWith<_$CollectibleContractImpl> get copyWith =>
      __$$CollectibleContractImplCopyWithImpl<_$CollectibleContractImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectibleContractImplToJson(
      this,
    );
  }
}

abstract class _CollectibleContract extends CollectibleContract {
  factory _CollectibleContract(
          {@HiveField(0) required final String address,
          @HiveField(1) required final String name,
          @HiveField(2) required final Map<String, dynamic> metadata,
          @HiveField(3) required final String pointsContract,
          @HiveField(4) required final List<CollectibleToken> tokens}) =
      _$CollectibleContractImpl;
  _CollectibleContract._() : super._();

  factory _CollectibleContract.fromJson(Map<String, dynamic> json) =
      _$CollectibleContractImpl.fromJson;

  @override
  @HiveField(0)
  String get address;
  @override
  @HiveField(1)
  String get name;
  @override
  @HiveField(2)
  Map<String, dynamic> get metadata;
  @override
  @HiveField(3)
  String get pointsContract;
  @override
  @HiveField(4)
  List<CollectibleToken> get tokens;

  /// Create a copy of CollectibleContract
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectibleContractImplCopyWith<_$CollectibleContractImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CollectibleToken _$CollectibleTokenFromJson(Map<String, dynamic> json) {
  return _CollectibleToken.fromJson(json);
}

/// @nodoc
mixin _$CollectibleToken {
  @HiveField(0)
  BigInt get tokenId => throw _privateConstructorUsedError;
  @HiveField(1)
  String get pointsContract => throw _privateConstructorUsedError;
  @HiveField(2)
  BigInt get price => throw _privateConstructorUsedError;
  @HiveField(3)
  int get expiry => throw _privateConstructorUsedError;
  @HiveField(4)
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  @HiveField(5)
  BigInt get supply => throw _privateConstructorUsedError;

  /// Serializes this CollectibleToken to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollectibleToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectibleTokenCopyWith<CollectibleToken> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectibleTokenCopyWith<$Res> {
  factory $CollectibleTokenCopyWith(
          CollectibleToken value, $Res Function(CollectibleToken) then) =
      _$CollectibleTokenCopyWithImpl<$Res, CollectibleToken>;
  @useResult
  $Res call(
      {@HiveField(0) BigInt tokenId,
      @HiveField(1) String pointsContract,
      @HiveField(2) BigInt price,
      @HiveField(3) int expiry,
      @HiveField(4) Map<String, dynamic> metadata,
      @HiveField(5) BigInt supply});
}

/// @nodoc
class _$CollectibleTokenCopyWithImpl<$Res, $Val extends CollectibleToken>
    implements $CollectibleTokenCopyWith<$Res> {
  _$CollectibleTokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectibleToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tokenId = null,
    Object? pointsContract = null,
    Object? price = null,
    Object? expiry = null,
    Object? metadata = null,
    Object? supply = null,
  }) {
    return _then(_value.copyWith(
      tokenId: null == tokenId
          ? _value.tokenId
          : tokenId // ignore: cast_nullable_to_non_nullable
              as BigInt,
      pointsContract: null == pointsContract
          ? _value.pointsContract
          : pointsContract // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as BigInt,
      expiry: null == expiry
          ? _value.expiry
          : expiry // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      supply: null == supply
          ? _value.supply
          : supply // ignore: cast_nullable_to_non_nullable
              as BigInt,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CollectibleTokenImplCopyWith<$Res>
    implements $CollectibleTokenCopyWith<$Res> {
  factory _$$CollectibleTokenImplCopyWith(_$CollectibleTokenImpl value,
          $Res Function(_$CollectibleTokenImpl) then) =
      __$$CollectibleTokenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) BigInt tokenId,
      @HiveField(1) String pointsContract,
      @HiveField(2) BigInt price,
      @HiveField(3) int expiry,
      @HiveField(4) Map<String, dynamic> metadata,
      @HiveField(5) BigInt supply});
}

/// @nodoc
class __$$CollectibleTokenImplCopyWithImpl<$Res>
    extends _$CollectibleTokenCopyWithImpl<$Res, _$CollectibleTokenImpl>
    implements _$$CollectibleTokenImplCopyWith<$Res> {
  __$$CollectibleTokenImplCopyWithImpl(_$CollectibleTokenImpl _value,
      $Res Function(_$CollectibleTokenImpl) _then)
      : super(_value, _then);

  /// Create a copy of CollectibleToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tokenId = null,
    Object? pointsContract = null,
    Object? price = null,
    Object? expiry = null,
    Object? metadata = null,
    Object? supply = null,
  }) {
    return _then(_$CollectibleTokenImpl(
      tokenId: null == tokenId
          ? _value.tokenId
          : tokenId // ignore: cast_nullable_to_non_nullable
              as BigInt,
      pointsContract: null == pointsContract
          ? _value.pointsContract
          : pointsContract // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as BigInt,
      expiry: null == expiry
          ? _value.expiry
          : expiry // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      supply: null == supply
          ? _value.supply
          : supply // ignore: cast_nullable_to_non_nullable
              as BigInt,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 6)
class _$CollectibleTokenImpl extends _CollectibleToken {
  _$CollectibleTokenImpl(
      {@HiveField(0) required this.tokenId,
      @HiveField(1) required this.pointsContract,
      @HiveField(2) required this.price,
      @HiveField(3) required this.expiry,
      @HiveField(4) required final Map<String, dynamic> metadata,
      @HiveField(5) required this.supply})
      : _metadata = metadata,
        super._();

  factory _$CollectibleTokenImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectibleTokenImplFromJson(json);

  @override
  @HiveField(0)
  final BigInt tokenId;
  @override
  @HiveField(1)
  final String pointsContract;
  @override
  @HiveField(2)
  final BigInt price;
  @override
  @HiveField(3)
  final int expiry;
  final Map<String, dynamic> _metadata;
  @override
  @HiveField(4)
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  @HiveField(5)
  final BigInt supply;

  @override
  String toString() {
    return 'CollectibleToken(tokenId: $tokenId, pointsContract: $pointsContract, price: $price, expiry: $expiry, metadata: $metadata, supply: $supply)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectibleTokenImpl &&
            (identical(other.tokenId, tokenId) || other.tokenId == tokenId) &&
            (identical(other.pointsContract, pointsContract) ||
                other.pointsContract == pointsContract) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.expiry, expiry) || other.expiry == expiry) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.supply, supply) || other.supply == supply));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tokenId, pointsContract, price,
      expiry, const DeepCollectionEquality().hash(_metadata), supply);

  /// Create a copy of CollectibleToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectibleTokenImplCopyWith<_$CollectibleTokenImpl> get copyWith =>
      __$$CollectibleTokenImplCopyWithImpl<_$CollectibleTokenImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectibleTokenImplToJson(
      this,
    );
  }
}

abstract class _CollectibleToken extends CollectibleToken {
  factory _CollectibleToken(
      {@HiveField(0) required final BigInt tokenId,
      @HiveField(1) required final String pointsContract,
      @HiveField(2) required final BigInt price,
      @HiveField(3) required final int expiry,
      @HiveField(4) required final Map<String, dynamic> metadata,
      @HiveField(5) required final BigInt supply}) = _$CollectibleTokenImpl;
  _CollectibleToken._() : super._();

  factory _CollectibleToken.fromJson(Map<String, dynamic> json) =
      _$CollectibleTokenImpl.fromJson;

  @override
  @HiveField(0)
  BigInt get tokenId;
  @override
  @HiveField(1)
  String get pointsContract;
  @override
  @HiveField(2)
  BigInt get price;
  @override
  @HiveField(3)
  int get expiry;
  @override
  @HiveField(4)
  Map<String, dynamic> get metadata;
  @override
  @HiveField(5)
  BigInt get supply;

  /// Create a copy of CollectibleToken
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectibleTokenImplCopyWith<_$CollectibleTokenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
