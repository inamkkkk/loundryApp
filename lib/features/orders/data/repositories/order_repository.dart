import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loundryapp/features/orders/domain/models/order_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

class OrderRepository {
  static const String _ordersKey = 'laundry_orders';

  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersJson = prefs.getString(_ordersKey);
    if (ordersJson == null) return [];

    final List<dynamic> decoded = jsonDecode(ordersJson);
    return decoded.map((e) => Order.fromJson(e)).toList();
  }

  Future<void> saveOrder(Order order) async {
    final orders = await getOrders();
    final updatedOrders = [order, ...orders]; // Newest first

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(updatedOrders.map((e) => e.toJson()).toList());
    await prefs.setString(_ordersKey, encoded);
  }

  Future<void> updateOrder(Order updatedOrder) async {
    final orders = await getOrders();
    final updatedOrders = orders
        .map((o) => o.id == updatedOrder.id ? updatedOrder : o)
        .toList();

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(updatedOrders.map((e) => e.toJson()).toList());
    await prefs.setString(_ordersKey, encoded);
  }
}
