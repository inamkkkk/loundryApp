// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      garmentName: json['garmentName'] as String,
      serviceType: json['serviceType'] as String,
      quantity: (json['quantity'] as num).toInt(),
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      totalDataPrice: (json['totalDataPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'garmentName': instance.garmentName,
      'serviceType': instance.serviceType,
      'quantity': instance.quantity,
      'pricePerUnit': instance.pricePerUnit,
      'totalDataPrice': instance.totalDataPrice,
    };

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
  id: json['id'] as String,
  customerName: json['customerName'] as String,
  customerPhone: json['customerPhone'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  subTotal: (json['subTotal'] as num).toDouble(),
  urgentFee: (json['urgentFee'] as num).toDouble(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  isPaid: json['isPaid'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isUrgent: json['isUrgent'] as bool? ?? false,
);

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'items': instance.items,
      'subTotal': instance.subTotal,
      'urgentFee': instance.urgentFee,
      'totalAmount': instance.totalAmount,
      'isPaid': instance.isPaid,
      'createdAt': instance.createdAt.toIso8601String(),
      'isUrgent': instance.isUrgent,
    };
