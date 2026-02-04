import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loundryapp/core/theme/white_label_theme.dart';
import 'package:loundryapp/core/utils/currency_formatter.dart';
import 'package:loundryapp/features/orders/presentation/controllers/order_list_controller.dart';
import 'package:loundryapp/features/orders/presentation/screens/order_detail_screen.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(filteredOrdersProvider);
    final filterState = ref.watch(orderFilterProvider);

    return Scaffold(
      backgroundColor: WhiteLabelTheme.backgroundLight,
      appBar: AppBar(
        title: const Text("Orders"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Iconsax.calendar_1, size: 24.sp),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: filterState.monthFilter ?? DateTime.now(),
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                ref
                    .read(orderFilterProvider.notifier)
                    .update((s) => s.copyWith(monthFilter: date));
              }
            },
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          // Calculate Stats
          double paidAmount = 0;
          double pendingAmount = 0;
          int paidCount = 0;
          int pendingCount = 0;

          for (var o in orders) {
            if (o.isPaid) {
              paidAmount += o.totalAmount;
              paidCount++;
            } else {
              pendingAmount += o.totalAmount;
              pendingCount++;
            }
          }

          return Column(
            children: [
              // 1. Stats Dashboard
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: WhiteLabelTheme.surfaceWhite,
                  border: const Border(
                    bottom: BorderSide(color: WhiteLabelTheme.borderGrey),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: "Collected",
                        amount: paidAmount,
                        count: paidCount,
                        color: WhiteLabelTheme.successGreen,
                        icon: Iconsax.wallet_check,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _StatCard(
                        label: "Pending",
                        amount: pendingAmount,
                        count: pendingCount,
                        color: WhiteLabelTheme.dangerRed,
                        icon: Iconsax.timer,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Search Bar
              Padding(
                padding: EdgeInsets.all(16.w),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.search_normal, size: 20.sp),
                    hintText: "Search customer or Order ID",
                    fillColor: WhiteLabelTheme.surfaceWhite,
                  ),
                  onChanged: (val) {
                    ref
                        .read(orderFilterProvider.notifier)
                        .update((s) => s.copyWith(searchQuery: val));
                  },
                ),
              ),

              // 3. List
              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Text(
                          "No Orders Found",
                          style: TextStyle(
                            color: WhiteLabelTheme.textGrey,
                            fontSize: 16.sp,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        itemCount: orders.length,
                        separatorBuilder: (c, i) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return InkWell(
                            onTap: () {
                              // Navigate to Detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderDetailScreen(order: order),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: WhiteLabelTheme.surfaceWhite,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: WhiteLabelTheme.borderGrey,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: order.isPaid
                                              ? WhiteLabelTheme.successGreen
                                                    .withOpacity(0.1)
                                              : WhiteLabelTheme.dangerRed
                                                    .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          order.isPaid
                                              ? Iconsax.tick_circle
                                              : Iconsax.clock,
                                          color: order.isPaid
                                              ? WhiteLabelTheme.successGreen
                                              : WhiteLabelTheme.dangerRed,
                                          size: 24.sp,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.customerName,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.sp,
                                              color: WhiteLabelTheme.textDark,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            "#${order.id.substring(0, 5).toUpperCase()} • ${DateFormat('MMM dd').format(order.createdAt)}",
                                            style: TextStyle(
                                              color: WhiteLabelTheme.textGrey,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyFormatter.format(
                                          order.totalAmount,
                                        ),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          color: WhiteLabelTheme.textDark,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "${order.items.length} Items",
                                        style: TextStyle(
                                          color: WhiteLabelTheme.textGrey,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 8.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            CurrencyFormatter.format(amount),
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: WhiteLabelTheme.textDark,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "$count Orders",
            style: TextStyle(fontSize: 12.sp, color: WhiteLabelTheme.textGrey),
          ),
        ],
      ),
    );
  }
}
