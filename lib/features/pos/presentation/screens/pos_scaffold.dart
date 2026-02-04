import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loundryapp/core/theme/white_label_theme.dart';
import 'package:loundryapp/features/pos/presentation/screens/pos_register_screen.dart';
import 'package:loundryapp/features/orders/presentation/screens/order_list_screen.dart';
import 'package:loundryapp/features/dashboard/presentation/screens/scan_screen.dart';
import 'package:loundryapp/features/settings/presentation/screens/settings_screen.dart';

class PosScaffold extends StatefulWidget {
  const PosScaffold({super.key});

  @override
  State<PosScaffold> createState() => _PosScaffoldState();
}

class _PosScaffoldState extends State<PosScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PosRegisterScreen(),
    OrderListScreen(),
    ScanScreen(), // We might want to push this instead of tab, but tab is fine for now
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _screens[_currentIndex], // Rebuilds on switch, preventing hidden camera init
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: WhiteLabelTheme.surfaceWhite,
        indicatorColor: WhiteLabelTheme.primaryBlue.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Iconsax.shop),
            selectedIcon: Icon(
              Iconsax.shop5,
              color: WhiteLabelTheme.primaryBlue,
            ),
            label: 'Register',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.receipt_2_1),
            selectedIcon: Icon(
              Iconsax.receipt_2_15,
              color: WhiteLabelTheme.primaryBlue,
            ),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.scan_barcode),
            selectedIcon: Icon(
              Iconsax.scan_barcode,
              color: WhiteLabelTheme.primaryBlue,
            ),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.setting_2),
            selectedIcon: Icon(
              Iconsax.setting_25,
              color: WhiteLabelTheme.primaryBlue,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
