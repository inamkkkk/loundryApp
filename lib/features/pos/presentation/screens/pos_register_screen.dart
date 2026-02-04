import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loundryapp/core/theme/white_label_theme.dart';
import 'package:loundryapp/core/utils/currency_formatter.dart';
import 'package:loundryapp/core/constants/laundry_data.dart';
import 'package:loundryapp/features/orders/presentation/controllers/cart_controller.dart';
import 'package:loundryapp/features/orders/domain/models/order_model.dart'
    as order_model; // Alias to avoid conflict
import 'package:loundryapp/features/settings/presentation/screens/settings_screen.dart'; // for ratesProvider
import 'package:loundryapp/features/settings/domain/models/service_rate_model.dart';
import 'package:loundryapp/features/orders/data/services/pdf_service.dart'; // For printing
import 'package:loundryapp/services/whatsapp_service.dart';
import 'package:loundryapp/core/utils/currency_formatter.dart';

// --- Local State for the Register ---
final posCategoryProvider = StateProvider<String>((ref) => 'Men');

class PosRegisterScreen extends ConsumerWidget {
  const PosRegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(posCategoryProvider);
    final ratesAsync = ref.watch(ratesProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: WhiteLabelTheme.backgroundLight,
      appBar: AppBar(
        title: const Text("Register"),
        // Settings is now in bottom nav, but we can keep quick access or remove.
        // Removing for cleaner UI since it's in nav.
      ),
      body: Column(
        children: [
          // 1. Category Tabs (Horizontal Scroll)
          Container(
            height: 60.h,
            color: WhiteLabelTheme.surfaceWhite,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              children: LaundryData.garmentCategories.keys.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val)
                        ref.read(posCategoryProvider.notifier).state = cat;
                    },
                    selectedColor: WhiteLabelTheme.primaryBlack,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : WhiteLabelTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: WhiteLabelTheme.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : WhiteLabelTheme.borderGrey,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1, color: WhiteLabelTheme.borderGrey),

          // 2. Main Content Area (Grid + Cart Summary)
          Expanded(
            child: Row(
              children: [
                // A. Item Grid (The "Register" Keys)
                Expanded(
                  flex: 3, // Takes up more space
                  child: ratesAsync.when(
                    data: (rates) {
                      final categoryItems =
                          LaundryData.garmentCategories[selectedCategory] ?? [];

                      final filteredRates = rates.where((rate) {
                        return categoryItems.contains(rate.garmentName);
                      }).toList();

                      if (filteredRates.isEmpty) {
                        return Center(
                          child: Text(
                            "No items in ${selectedCategory}",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: EdgeInsets.all(16.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 columns for "Button" feel
                          childAspectRatio: 0.9, // Slightly taller for buttons
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                        ),
                        itemCount: filteredRates.length,
                        itemBuilder: (context, index) {
                          final rate = filteredRates[index];
                          // Find item in cart to get quantity
                          final cartItem = cartState.items.firstWhere(
                            (i) =>
                                i.garmentName == rate.garmentName &&
                                i.serviceType == rate.serviceType,
                            orElse: () => order_model.OrderItem(
                              garmentName: '',
                              serviceType: '',
                              quantity: 0,
                              pricePerUnit: 0,
                              totalDataPrice: 0, // Mock empty
                            ),
                          );

                          return _PosItemTile(
                            rate: rate,
                            quantity: cartItem.quantity,
                            onAdd: () {
                              ref.read(cartProvider.notifier).addItem(rate);
                            },
                            onRemove: () {
                              // Find index in cart to remove
                              final idx = cartState.items.indexOf(cartItem);
                              if (idx != -1) {
                                ref
                                    .read(cartProvider.notifier)
                                    .decreaseQuantity(idx);
                              }
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text("Error loading rates")),
                  ),
                ),
              ],
            ),
          ),

          // 3. Persistent Cart (Bottom Sheet Style but always visible)
          Container(
            decoration: BoxDecoration(
              color: WhiteLabelTheme.surfaceWhite,
              border: const Border(
                top: BorderSide(color: WhiteLabelTheme.borderGrey),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Hug content
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.receipt_1,
                          color: WhiteLabelTheme.textGrey,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Current Sale (${cartState.items.length})",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.format(cartState.totalAmount),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                        color: WhiteLabelTheme.textDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cartState.items.isEmpty
                        ? null
                        : () {
                            _showCheckoutModal(context, ref);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WhiteLabelTheme.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                    ),
                    child: Text(
                      "Charge  ${CurrencyFormatter.format(cartState.totalAmount)}",
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: WhiteLabelTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _PosCheckoutModal(),
    );
  }
}

class _PosItemTile extends StatelessWidget {
  final ServiceRate rate;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _PosItemTile({
    required this.rate,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = quantity > 0;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? WhiteLabelTheme.primaryBlack
            : WhiteLabelTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected
              ? WhiteLabelTheme.primaryBlack
              : WhiteLabelTheme.borderGrey,
        ),
      ),
      child: InkWell(
        onTap: onAdd, // Tap whole tile to add initially
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rate.garmentName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: isSelected
                          ? Colors.white
                          : WhiteLabelTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    rate.serviceType,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: isSelected
                          ? Colors.white70
                          : WhiteLabelTheme.textGrey,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    CurrencyFormatter.format(rate.price),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: isSelected
                          ? Colors.white
                          : WhiteLabelTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls Overlay
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(11.r),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: onRemove,
                      child: Icon(
                        Iconsax.minus,
                        size: 20.sp,
                        color: WhiteLabelTheme.textDark,
                      ),
                    ),
                    Text(
                      "$quantity",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    InkWell(
                      onTap: onAdd,
                      child: Icon(
                        Iconsax.add,
                        size: 20.sp,
                        color: WhiteLabelTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PosCheckoutModal extends ConsumerWidget {
  const _PosCheckoutModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9, // 90% height
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Checkout",
                style: GoogleFonts.outfit(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.close_circle),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          SizedBox(height: 16.h),

          // Customer Info Section
          Text(
            "Customer",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(hintText: "Phone Number"),
                  onChanged: (val) => ref
                      .read(cartProvider.notifier)
                      .setCustomerInfo(cartState.customerName, val),
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(hintText: "Name"),
                  onChanged: (val) => ref
                      .read(cartProvider.notifier)
                      .setCustomerInfo(val, cartState.customerPhone),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          Text(
            "Order Summary",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.separated(
              itemCount: cartState.items.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "${item.quantity}x ${item.garmentName}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(item.serviceType),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(CurrencyFormatter.format(item.totalDataPrice)),
                      IconButton(
                        icon: const Icon(
                          Iconsax.minus_cirlce,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          ref
                              .read(cartProvider.notifier)
                              .decreaseQuantity(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const Divider(),
          SizedBox(height: 16.h),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Due", style: GoogleFonts.outfit(fontSize: 18.sp)),
              Text(
                CurrencyFormatter.format(cartState.totalAmount),
                style: GoogleFonts.outfit(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Pay Button
          ElevatedButton(
            onPressed: () async {
              final order = await ref
                  .read(cartProvider.notifier)
                  .generateOrder();
              if (order != null && context.mounted) {
                Navigator.pop(context); // Close Modal

                // Show Success Dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => _TransactionSuccessDialog(order: order),
                );

                // WHATSAPP PRO-POS INTEGRATION
                // Fire and forget - background send
                if (order.customerPhone.isNotEmpty) {
                  final msg =
                      "Hello ${order.customerName},\n\n"
                      "Thank you for your order at LaundryApp!\n"
                      "Order ID: #${order.id.substring(0, 5).toUpperCase()}\n"
                      "Total: ${CurrencyFormatter.format(order.totalAmount)}\n\n"
                      "We will notify you when it's ready!";
                  WhatsappService.sendReceipt(order.customerPhone, msg);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WhiteLabelTheme.successGreen,
              padding: EdgeInsets.symmetric(vertical: 20.h),
            ),
            child: const Text("Confirm Payment"),
          ),
        ],
      ),
    );
  }
}

class _TransactionSuccessDialog extends ConsumerWidget {
  final order_model.Order order;

  const _TransactionSuccessDialog({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: WhiteLabelTheme.surfaceWhite,
      contentPadding: EdgeInsets.all(24.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: WhiteLabelTheme.successGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.tick_circle,
              color: WhiteLabelTheme.successGreen,
              size: 40,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "Transaction Successful",
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Order #${order.id.substring(0, 5).toUpperCase()}",
            style: TextStyle(color: WhiteLabelTheme.textGrey, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            CurrencyFormatter.format(order.totalAmount),
            style: GoogleFonts.outfit(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: WhiteLabelTheme.textDark,
            ),
          ),
          SizedBox(height: 24.h),

          // Actions
          Row(
            children: [
              Expanded(
                child: _DialogButton(
                  icon: Iconsax.printer,
                  label: "Print",
                  onTap: () {
                    ref.read(pdfServiceProvider).generateAndPrintInvoice(order);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _DialogButton(
                  icon: Iconsax.message,
                  label: "WhatsApp",
                  color: const Color(0xFF25D366),
                  onTap: () {
                    // Reuse print as "Share" for now until specific Whatsapp URL scheme added
                    ref.read(pdfServiceProvider).generateAndPrintInvoice(order);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sharing PDF...")),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "New Order",
                style: TextStyle(color: WhiteLabelTheme.textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _DialogButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = WhiteLabelTheme.primaryBlack,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
