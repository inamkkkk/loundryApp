import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loundryapp/features/orders/domain/models/order_model.dart';
import 'package:loundryapp/features/orders/data/repositories/order_repository.dart';

// Filter state
class OrderFilterState {
  final String searchQuery; // Name or ID
  final DateTime? monthFilter; // Filter by month/year

  const OrderFilterState({this.searchQuery = '', this.monthFilter});

  OrderFilterState copyWith({String? searchQuery, DateTime? monthFilter}) {
    return OrderFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      monthFilter: monthFilter ?? this.monthFilter,
    );
  }
}

// Controller for filters
final orderFilterProvider = StateProvider<OrderFilterState>(
  (ref) => const OrderFilterState(),
);

// Provider for filtered orders
final filteredOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  // Re-fetch when needed. In real app might want a stream or cached provider.
  // For simplicity, we fetch all and filter in memory.
  final allOrders = await repository.getOrders();
  final filter = ref.watch(orderFilterProvider);

  return allOrders.where((order) {
    // 1. Text Search
    final matchesQuery =
        filter.searchQuery.isEmpty ||
        order.customerName.toLowerCase().contains(
          filter.searchQuery.toLowerCase(),
        ) ||
        order.id.toLowerCase().contains(filter.searchQuery.toLowerCase()) ||
        order.customerPhone.contains(filter.searchQuery);

    // 2. Month Filter
    bool matchesMonth = true;
    if (filter.monthFilter != null) {
      matchesMonth =
          order.createdAt.year == filter.monthFilter!.year &&
          order.createdAt.month == filter.monthFilter!.month;
    }

    return matchesQuery && matchesMonth;
  }).toList();
});

// Calculate Monthly Revenue
final monthlyRevenueProvider = Provider<Map<String, double>>((ref) {
  final ordersState = ref.watch(filteredOrdersProvider);

  return ordersState.maybeWhen(
    data: (orders) {
      double total = 0;
      double unpaid = 0;
      for (final order in orders) {
        total += order.totalAmount;
        if (!order.isPaid) unpaid += order.totalAmount;
      }
      return {'total': total, 'unpaid': unpaid};
    },
    orElse: () => {'total': 0.0, 'unpaid': 0.0},
  );
});
