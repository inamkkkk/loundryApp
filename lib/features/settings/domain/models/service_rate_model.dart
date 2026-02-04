import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_rate_model.freezed.dart';
part 'service_rate_model.g.dart';

@freezed
class ServiceRate with _$ServiceRate {
  const factory ServiceRate({
    required String id,
    required String garmentName,
    required String serviceType, // e.g., "Wash & Iron", "Dry Clean"
    required double price,
    @Default(true) bool isActive,
  }) = _ServiceRate;

  factory ServiceRate.fromJson(Map<String, dynamic> json) =>
      _$ServiceRateFromJson(json);
}
