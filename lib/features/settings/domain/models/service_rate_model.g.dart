// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_rate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceRateImpl _$$ServiceRateImplFromJson(Map<String, dynamic> json) =>
    _$ServiceRateImpl(
      id: json['id'] as String,
      garmentName: json['garmentName'] as String,
      serviceType: json['serviceType'] as String,
      price: (json['price'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$ServiceRateImplToJson(_$ServiceRateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'garmentName': instance.garmentName,
      'serviceType': instance.serviceType,
      'price': instance.price,
      'isActive': instance.isActive,
    };
