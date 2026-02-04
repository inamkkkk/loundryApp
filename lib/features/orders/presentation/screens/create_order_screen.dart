import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loundryapp/core/theme/app_theme.dart';
import 'package:loundryapp/core/utils/currency_formatter.dart';
import 'package:loundryapp/core/widgets/primary_button.dart';
import 'package:loundryapp/features/orders/presentation/controllers/cart_controller.dart';
import 'package:loundryapp/features/settings/domain/models/service_rate_model.dart';
import 'package:loundryapp/features/settings/presentation/screens/settings_screen.dart'; // For ratesProvider
import 'package:loundryapp/core/widgets/slide_in_fade.dart';

// Local state for category selection
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

class CreateOrderScreen extends ConsumerWidget {
  const CreateOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(ratesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _HeaderSection(),
            SizedBox(height: 24.h),
            _CategoryFilter(
              selectedCategory: selectedCategory,
              onSelect: (val) =>
                  ref.read(selectedCategoryProvider.notifier).state = val,
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ratesAsync.when(
                data: (rates) {
                  // Filter rates based on category
                  final filteredRates = selectedCategory == 'All'
                      ? rates
                      : rates
                            .where((r) => r.serviceType == selectedCategory)
                            .toList();

                  if (filteredRates.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.box_remove,
                            size: 48.sp,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "No items found",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                    ),
                    itemCount: filteredRates.length,
                    itemBuilder: (context, index) {
                      return SlideInFade(
                        index: index,
                        child: _PremiumGarmentCard(
                          rate: filteredRates[index],
                          onTap: () => ref
                              .read(cartProvider.notifier)
                              .addItem(filteredRates[index]),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Error: $e")),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: cartState.items.isNotEmpty
          ? const _PremiumCartSummary()
          : null,
    );
  }
}

class _HeaderSection extends ConsumerWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Iconsax.arrow_left_2),
              ),
              Text(
                "New Order",
                style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 48.w), // Balance
            ],
          ),
          SizedBox(height: 20.h),

          // Quick Customer Inputs
          Row(
            children: [
              Expanded(
                child: _MinimalInput(
                  icon: Iconsax.user,
                  hint: "Customer Name",
                  initialValue: cartState.customerName,
                  onChanged: (val) => ref
                      .read(cartProvider.notifier)
                      .setCustomerInfo(val, cartState.customerPhone),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _MinimalInput(
                  icon: Iconsax.call,
                  hint: "Phone",
                  isNumber: true,
                  initialValue: cartState.customerPhone,
                  onChanged: (val) => ref
                      .read(cartProvider.notifier)
                      .setCustomerInfo(cartState.customerName, val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MinimalInput extends StatefulWidget {
  final IconData icon;
  final String hint;
  final bool isNumber;
  final ValueChanged<String> onChanged;
  final String initialValue;

  const _MinimalInput({
    required this.icon,
    required this.hint,
    required this.onChanged,
    required this.initialValue,
    this.isNumber = false,
  });

  @override
  State<_MinimalInput> createState() => _MinimalInputState();
}

class _MinimalInputState extends State<_MinimalInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Icon(widget.icon, size: 18.sp, color: AppTheme.textGrey),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: widget.isNumber
                  ? TextInputType.phone
                  : TextInputType.text,
              style: TextStyle(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  const _CategoryFilter({
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ["All", "Wash & Iron", "Dry Clean", "Iron Only"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: InkWell(
              onTap: () => onSelect(cat),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PremiumGarmentCard extends StatelessWidget {
  final ServiceRate rate;
  final VoidCallback onTap;

  const _PremiumGarmentCard({required this.rate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: AppTheme.premiumShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Circle
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForService(rate.serviceType),
                color: AppTheme.primaryColor,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              rate.garmentName,
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              rate.serviceType,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppTheme.textGrey,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              CurrencyFormatter.format(rate.price),
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForService(String type) {
    final t = type.toLowerCase();
    if (t.contains("wash")) return Iconsax.d_cube_scan;
    if (t.contains("iron")) return Iconsax.box;
    if (t.contains("dry")) return Iconsax.wind_2; // Use wind for dry cleaning
    return Iconsax.tag;
  }
}

class _PremiumCartSummary extends ConsumerWidget {
  const _PremiumCartSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.textDark,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Iconsax.bag_2, color: Colors.white),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${cartState.items.length} Items",
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                  Text(
                    CurrencyFormatter.format(cartState.totalAmount),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: "Checkout",
                icon: Iconsax.arrow_right_1,
                onPressed: () async {
                  final order = await ref
                      .read(cartProvider.notifier)
                      .generateOrder();
                  if (order != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Order Created Successfully!"),
                      ),
                    );
                    Navigator.pop(context); // Go back to lobby
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
