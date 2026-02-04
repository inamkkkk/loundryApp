import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loundryapp/core/theme/app_theme.dart';
import 'package:loundryapp/features/orders/presentation/screens/create_order_screen.dart';
import 'package:loundryapp/features/orders/presentation/screens/order_list_screen.dart';
import 'package:loundryapp/features/settings/presentation/screens/settings_screen.dart';
import 'package:loundryapp/features/dashboard/presentation/screens/scan_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "LaundryFlow",
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        "Lobby & Management",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.premiumShadow,
                      ),
                      child: Icon(
                        Iconsax.setting_2,
                        size: 24.sp,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Main Action Cards
              Expanded(
                child: Column(
                  children: [
                    _DashboardCard(
                      title: "New Order",
                      subtitle: "Create invoice & add items",
                      icon: Iconsax.add_circle,
                      color: AppTheme.primaryColor,
                      textColor: Colors.white,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateOrderScreen(),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _DashboardCard(
                            title: "All Orders",
                            subtitle: "View History",
                            icon: Iconsax.receipt_2,
                            color: Colors.white,
                            textColor: AppTheme.textDark,
                            isSmall: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrderListScreen(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _DashboardCard(
                            title: "Scan QR",
                            subtitle: "Quick Pay",
                            icon: Iconsax.scan_barcode,
                            color: Colors.white,
                            textColor: AppTheme.textDark,
                            isSmall: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScanScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool isSmall;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isSmall ? 160.h : 200.h,
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: AppTheme.premiumShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSmall
                    ? AppTheme.backgroundLight
                    : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSmall ? AppTheme.primaryColor : Colors.white,
                size: 28.sp,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmall ? 18.sp : 24.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Outfit',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isSmall ? 12.sp : 14.sp,
                    color: textColor.withOpacity(0.7),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
