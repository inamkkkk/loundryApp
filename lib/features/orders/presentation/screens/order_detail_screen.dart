import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loundryapp/core/theme/white_label_theme.dart';
import 'package:loundryapp/core/utils/currency_formatter.dart';
import 'package:loundryapp/features/orders/domain/models/order_model.dart';
import 'package:loundryapp/features/orders/data/repositories/order_repository.dart';
import 'package:loundryapp/features/orders/data/services/pdf_service.dart';

class OrderDetailScreen extends ConsumerWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: WhiteLabelTheme.backgroundLight,
      appBar: AppBar(
        title: Text("Order #${order.id.substring(0, 5).toUpperCase()}"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: order.isPaid
                    ? WhiteLabelTheme.successGreen.withOpacity(0.1)
                    : WhiteLabelTheme.dangerRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: order.isPaid
                      ? WhiteLabelTheme.successGreen.withOpacity(0.3)
                      : WhiteLabelTheme.dangerRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    order.isPaid ? Iconsax.tick_circle : Iconsax.clock,
                    color: order.isPaid
                        ? WhiteLabelTheme.successGreen
                        : WhiteLabelTheme.dangerRed,
                    size: 32.sp,
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.isPaid ? "Payment Complete" : "Payment Pending",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: order.isPaid
                              ? WhiteLabelTheme.successGreen
                              : WhiteLabelTheme.dangerRed,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(order.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: WhiteLabelTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Customer Details
            _SectionHeader(title: "Customer Info"),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: WhiteLabelTheme.borderGrey),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Iconsax.user,
                    label: "Name",
                    value: order.customerName,
                  ),
                  Divider(height: 24.h, color: WhiteLabelTheme.backgroundLight),
                  _InfoRow(
                    icon: Iconsax.call,
                    label: "Phone",
                    value: order.customerPhone,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Order Items
            _SectionHeader(title: "Items"),
            SizedBox(height: 12.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (c, i) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: WhiteLabelTheme.borderGrey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item.quantity}x ${item.garmentName}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            item.serviceType,
                            style: TextStyle(
                              color: WhiteLabelTheme.textGrey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.format(item.totalDataPrice),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 24.h),

            // Total
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: WhiteLabelTheme.primaryBlack,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  Text(
                    CurrencyFormatter.format(order.totalAmount),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(pdfServiceProvider).generateAndPrintInvoice(order);
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  side: const BorderSide(color: WhiteLabelTheme.primaryBlack),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.printer,
                      size: 20.sp,
                      color: WhiteLabelTheme.primaryBlack,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Print / Share",
                      style: TextStyle(
                        color: WhiteLabelTheme.primaryBlack,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16.w),
            if (!order.isPaid)
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Mark Paid Logic
                    final updated = order.copyWith(isPaid: true);
                    await ref
                        .read(orderRepositoryProvider)
                        .updateOrder(updated);
                    if (context.mounted) {
                      Navigator.pop(context); // Go back
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Order Marked as Paid!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WhiteLabelTheme.successGreen,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.money_tick,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Mark Paid",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: WhiteLabelTheme.textDark,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: WhiteLabelTheme.backgroundLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.sp, color: WhiteLabelTheme.textGrey),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: WhiteLabelTheme.textGrey,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: WhiteLabelTheme.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
