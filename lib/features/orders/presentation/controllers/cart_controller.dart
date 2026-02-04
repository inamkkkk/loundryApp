import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:loundryapp/features/orders/domain/models/order_model.dart';
import 'package:loundryapp/features/settings/domain/models/service_rate_model.dart';
import 'package:loundryapp/features/orders/data/repositories/order_repository.dart';

// State to hold the current draft order
class CartState {
  final List<OrderItem> items;
  final String customerName;
  final String customerPhone;
  final bool isUrgent;
  final double urgentFeePercentage; // e.g. 0.20 for 20%

  const CartState({
    this.items = const [],
    this.customerName = '',
    this.customerPhone = '',
    this.isUrgent = false,
    this.urgentFeePercentage = 0.20,
  });

  CartState copyWith({
    List<OrderItem>? items,
    String? customerName,
    String? customerPhone,
    bool? isUrgent,
    double? urgentFeePercentage,
  }) {
    return CartState(
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      isUrgent: isUrgent ?? this.isUrgent,
      urgentFeePercentage: urgentFeePercentage ?? this.urgentFeePercentage,
    );
  }

  double get subTotal =>
      items.fold(0, (sum, item) => sum + item.totalDataPrice);

  double get totalAmount {
    double total = subTotal;
    if (isUrgent) {
      total += total * urgentFeePercentage;
    }
    return total;
  }
}

final cartProvider = StateNotifierProvider<CartController, CartState>((ref) {
  return CartController(ref.read(orderRepositoryProvider));
});

class CartController extends StateNotifier<CartState> {
  final OrderRepository _orderRepository;

  CartController(this._orderRepository) : super(const CartState());

  void setCustomerInfo(String name, String phone) {
    state = state.copyWith(customerName: name, customerPhone: phone);
  }

  void toggleUrgent(bool value) {
    state = state.copyWith(isUrgent: value);
  }

  void addItem(ServiceRate rate) {
    // Check if item already exists
    final existingIndex = state.items.indexWhere(
      (item) =>
          item.garmentName == rate.garmentName &&
          item.serviceType == rate.serviceType,
    );

    List<OrderItem> newItems;
    if (existingIndex != -1) {
      // Increment quantity
      final existingItem = state.items[existingIndex];
      final newItem = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
        totalDataPrice: (existingItem.quantity + 1) * existingItem.pricePerUnit,
      );
      newItems = [...state.items];
      newItems[existingIndex] = newItem;
    } else {
      // Add new item
      newItems = [
        ...state.items,
        OrderItem(
          garmentName: rate.garmentName,
          serviceType: rate.serviceType,
          quantity: 1,
          pricePerUnit: rate.price,
          totalDataPrice: rate.price,
        ),
      ];
    }
    state = state.copyWith(items: newItems);
  }

  void removeItem(int index) {
    final newItems = [...state.items];
    newItems.removeAt(index);
    state = state.copyWith(items: newItems);
  }

  void decreaseQuantity(int index) {
    final existingItem = state.items[index];
    if (existingItem.quantity > 1) {
      final newItem = existingItem.copyWith(
        quantity: existingItem.quantity - 1,
        totalDataPrice: (existingItem.quantity - 1) * existingItem.pricePerUnit,
      );
      final newItems = [...state.items];
      newItems[index] = newItem;
      state = state.copyWith(items: newItems);
    } else {
      removeItem(index);
    }
  }

  Future<Order?> generateOrder() async {
    if (state.items.isEmpty || state.customerName.isEmpty) return null;

    final order = Order(
      id: const Uuid().v4(),
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      items: state.items,
      subTotal: state.subTotal,
      urgentFee: state.isUrgent
          ? state.subTotal * state.urgentFeePercentage
          : 0,
      totalAmount: state.totalAmount,
      isPaid: false,
      createdAt: DateTime.now(),
      isUrgent: state.isUrgent,
    );

    await _orderRepository.saveOrder(order);

    // Clear cart (optional, or keep for next similar order?)
    // keeping customer info might be annoying, let's clear all
    state = const CartState();

    return order;
  }
}
