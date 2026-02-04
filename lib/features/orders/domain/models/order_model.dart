import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String garmentName, // e.g., "Kurta"
    required String serviceType, // e.g., "Wash & Iron"
    required int quantity,
    required double pricePerUnit,
    required double totalDataPrice, // quantity * pricePerUnit
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String customerName,
    required String customerPhone,
    required List<OrderItem> items,
    required double subTotal,
    required double urgentFee,
    required double totalAmount,
    required bool isPaid,
    required DateTime createdAt,
    @Default(false) bool isUrgent,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
