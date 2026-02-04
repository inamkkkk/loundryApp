import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:loundryapp/core/theme/app_theme.dart';
import 'package:loundryapp/features/orders/data/repositories/order_repository.dart';
import 'package:loundryapp/features/orders/domain/models/order_model.dart';
import 'package:iconsax/iconsax.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && !_isProcessing) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  _processCode(code);
                }
              }
            },
          ),

          // Overlay
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Iconsax.arrow_left_2,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Scan Receipt QR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: ValueListenableBuilder(
                          valueListenable: controller.torchState,
                          builder: (context, state, child) {
                            return Icon(
                              state == TorchState.off
                                  ? Iconsax.flash_1
                                  : Iconsax.flash_circle5,
                              color: Colors.white,
                            );
                          },
                        ),
                        onPressed: () => controller.toggleTorch(),
                      ),
                    ],
                  ),
                ),
                constSpacer(),
                // Scan Frame
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryColor, width: 4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Container(
                      width: 240,
                      height: 1, // Scan line animation could go here
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Align QR code within frame",
                  style: TextStyle(color: Colors.white70),
                ),
                constSpacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget constSpacer() => const Spacer();

  Future<void> _processCode(String rawData) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Expected Format: "Order:{ID}|Amt:{Amount}"
      // Logic: Extract ID, fetch order, show Dialog
      String orderId = "";
      if (rawData.contains("Order:") && rawData.contains("|")) {
        final parts = rawData.split("|");
        final idPart = parts.firstWhere((p) => p.startsWith("Order:"));
        orderId = idPart.replaceAll("Order:", "");
      } else {
        // Fallback: assume raw data is ID if simple
        orderId = rawData;
      }

      // Fetch Order logic (Requires Repository method to get single order or iterate list)
      // For efficiency, we scan list.
      final orders = await ref.read(orderRepositoryProvider).getOrders();
      try {
        final order = orders.firstWhere((o) => o.id == orderId);
        if (!mounted) return;
        _showOrderFoundDialog(order);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order not found or invalid QR")),
        );
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
    }
  }

  void _showOrderFoundDialog(Order order) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.verify5, color: AppTheme.statusPaid, size: 48),
            const SizedBox(height: 16),
            Text(
              "Order Found!",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(order.customerName, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              "Total: ${order.totalAmount}", // Use currency formatter ideally
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _isProcessing = false);
                    },
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      // Mark as Paid Logic
                      final updatedOrder = order.copyWith(isPaid: true);
                      await ref
                          .read(orderRepositoryProvider)
                          .updateOrder(updatedOrder);

                      if (context.mounted) {
                        Navigator.pop(context); // Close sheet
                        Navigator.pop(context); // Close scanner
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Order Marked as Paid & Delivered!"),
                          ),
                        );
                      }
                    },
                    child: const Text("Confirm Payment"),
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
