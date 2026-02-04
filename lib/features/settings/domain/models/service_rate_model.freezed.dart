// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_rate_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ServiceRate _$ServiceRateFromJson(Map<String, dynamic> json) {
  return _ServiceRate.fromJson(json);
}

/// @nodoc
mixin _$ServiceRate {
  String get id => throw _privateConstructorUsedError;
  String get garmentName => throw _privateConstructorUsedError;
  String get serviceType =>
      throw _privateConstructorUsedError; // e.g., "Wash & Iron", "Dry Clean"
  double get price => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this ServiceRate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceRate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceRateCopyWith<ServiceRate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceRateCopyWith<$Res> {
  factory $ServiceRateCopyWith(
    ServiceRate value,
    $Res Function(ServiceRate) then,
  ) = _$ServiceRateCopyWithImpl<$Res, ServiceRate>;
  @useResult
  $Res call({
    String id,
    String garmentName,
    String serviceType,
    double price,
    bool isActive,
  });
}

/// @nodoc
class _$ServiceRateCopyWithImpl<$Res, $Val extends ServiceRate>
    implements $ServiceRateCopyWith<$Res> {
  _$ServiceRateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceRate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? garmentName = null,
    Object? serviceType = null,
    Object? price = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            garmentName: null == garmentName
                ? _value.garmentName
                : garmentName // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceType: null == serviceType
                ? _value.serviceType
                : serviceType // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServiceRateImplCopyWith<$Res>
    implements $ServiceRateCopyWith<$Res> {
  factory _$$ServiceRateImplCopyWith(
    _$ServiceRateImpl value,
    $Res Function(_$ServiceRateImpl) then,
  ) = __$$ServiceRateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String garmentName,
    String serviceType,
    double price,
    bool isActive,
  });
}

/// @nodoc
class __$$ServiceRateImplCopyWithImpl<$Res>
    extends _$ServiceRateCopyWithImpl<$Res, _$ServiceRateImpl>
    implements _$$ServiceRateImplCopyWith<$Res> {
  __$$ServiceRateImplCopyWithImpl(
    _$ServiceRateImpl _value,
    $Res Function(_$ServiceRateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServiceRate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? garmentName = null,
    Object? serviceType = null,
    Object? price = null,
    Object? isActive = null,
  }) {
    return _then(
      _$ServiceRateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        garmentName: null == garmentName
            ? _value.garmentName
            : garmentName // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceType: null == serviceType
            ? _value.serviceType
            : serviceType // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceRateImpl implements _ServiceRate {
  const _$ServiceRateImpl({
    required this.id,
    required this.garmentName,
    required this.serviceType,
    required this.price,
    this.isActive = true,
  });

  factory _$ServiceRateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceRateImplFromJson(json);

  @override
  final String id;
  @override
  final String garmentName;
  @override
  final String serviceType;
  // e.g., "Wash & Iron", "Dry Clean"
  @override
  final double price;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'ServiceRate(id: $id, garmentName: $garmentName, serviceType: $serviceType, price: $price, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceRateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.garmentName, garmentName) ||
                other.garmentName == garmentName) &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, garmentName, serviceType, price, isActive);

  /// Create a copy of ServiceRate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceRateImplCopyWith<_$ServiceRateImpl> get copyWith =>
      __$$ServiceRateImplCopyWithImpl<_$ServiceRateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceRateImplToJson(this);
  }
}

abstract class _ServiceRate implements ServiceRate {
  const factory _ServiceRate({
    required final String id,
    required final String garmentName,
    required final String serviceType,
    required final double price,
    final bool isActive,
  }) = _$ServiceRateImpl;

  factory _ServiceRate.fromJson(Map<String, dynamic> json) =
      _$ServiceRateImpl.fromJson;

  @override
  String get id;
  @override
  String get garmentName;
  @override
  String get serviceType; // e.g., "Wash & Iron", "Dry Clean"
  @override
  double get price;
  @override
  bool get isActive;

  /// Create a copy of ServiceRate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceRateImplCopyWith<_$ServiceRateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
