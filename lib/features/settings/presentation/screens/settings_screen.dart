import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loundryapp/core/theme/white_label_theme.dart';
import 'package:loundryapp/core/widgets/primary_button.dart';
import 'package:loundryapp/core/constants/laundry_data.dart';
import 'package:loundryapp/features/settings/data/repositories/settings_repository.dart';
import 'package:loundryapp/features/settings/domain/models/service_rate_model.dart';
import 'package:loundryapp/core/utils/currency_formatter.dart';
import 'package:loundryapp/services/whatsapp_service.dart';
import 'package:loundryapp/features/settings/presentation/widgets/pairing_dialog.dart';
import 'package:get_storage/get_storage.dart';

// --- Controller Logic (Kept same, just cleaner imports) ---
final ratesProvider =
    StateNotifierProvider<RatesController, AsyncValue<List<ServiceRate>>>((
      ref,
    ) {
      return RatesController(ref.read(settingsRepositoryProvider));
    });

class RatesController extends StateNotifier<AsyncValue<List<ServiceRate>>> {
  final SettingsRepository _repository;

  RatesController(this._repository) : super(const AsyncValue.loading()) {
    loadRates();
  }

  Future<void> loadRates() async {
    try {
      final rates = await _repository.getRates();
      state = AsyncValue.data(rates);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRate(String garment, String service, double price) async {
    final newRate = ServiceRate(
      id: const Uuid().v4(),
      garmentName: garment,
      serviceType: service,
      price: price,
    );
    await _repository.addRate(newRate);
    await loadRates();
  }

  Future<void> deleteRate(String id) async {
    await _repository.deleteRate(id);
    await loadRates();
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(ratesProvider);

    return Scaffold(
      backgroundColor: WhiteLabelTheme.backgroundLight,
      appBar: AppBar(title: const Text('Price List'), centerTitle: false),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: WhiteLabelTheme.primaryBlack,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          "Add Item",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: WhiteLabelTheme.surfaceWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            builder: (context) => const _AddRateModal(),
          );
        },
      ),
      body: Column(
        children: [
          // Filter Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: WhiteLabelTheme.surfaceWhite,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search items...",
                prefixIcon: const Icon(Iconsax.search_normal),
                fillColor: WhiteLabelTheme.backgroundLight,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16.w,
                ),
              ),
              onChanged: (val) {
                // Implement search logic if list is long
              },
            ),
          ),
          Divider(height: 1, color: WhiteLabelTheme.borderGrey),

          // WhatsApp Connect Section (Pro-POS)
          Padding(padding: EdgeInsets.all(16.w), child: _WhatsAppConnectTile()),
          Divider(height: 1, color: WhiteLabelTheme.borderGrey),

          // WhatsApp Connect Section (Pro-POS)
          Padding(padding: EdgeInsets.all(16.w), child: _WhatsAppConnectTile()),
          Divider(height: 1, color: WhiteLabelTheme.borderGrey),

          // List
          Expanded(
            child: ratesAsync.when(
              data: (rates) {
                if (rates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.box_remove,
                          size: 48.sp,
                          color: WhiteLabelTheme.textGrey,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "No items configured",
                          style: GoogleFonts.inter(
                            color: WhiteLabelTheme.textGrey,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Trigger FAB
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: WhiteLabelTheme.surfaceWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16.r),
                                ),
                              ),
                              builder: (context) => const _AddRateModal(),
                            );
                          },
                          child: const Text("Add your first item"),
                        ),
                      ],
                    ),
                  );
                }

                // Group by Category for cleaner look? Or just flat list. Flat is standard for managing many skus.
                return ListView.separated(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 16.h,
                    bottom: 80.h,
                  ), // Bottom padding for FAB
                  itemCount: rates.length,
                  separatorBuilder: (c, i) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final rate = rates[index];
                    return Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: WhiteLabelTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: WhiteLabelTheme.borderGrey),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: WhiteLabelTheme.backgroundLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForGarment(rate.garmentName),
                              color: WhiteLabelTheme.textDark,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rate.garmentName,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                    color: WhiteLabelTheme.textDark,
                                  ),
                                ),
                                Text(
                                  rate.serviceType,
                                  style: TextStyle(
                                    color: WhiteLabelTheme.textGrey,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(rate.price),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: WhiteLabelTheme.textDark,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: const Icon(Iconsax.trash, color: Colors.red),
                            onPressed: () {
                              ref
                                  .read(ratesProvider.notifier)
                                  .deleteRate(rate.id);
                            },
                          ),
                        ],
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
    );
  }

  IconData _getIconForGarment(String name) {
    final n = name.toLowerCase();
    if (n.contains('shirt') || n.contains('polo')) return Iconsax.user_tag;
    if (n.contains('pant') || n.contains('trouser'))
      return Iconsax.driver; // Close enough leg shape
    if (n.contains('curtain') || n.contains('sheet')) return Iconsax.home_2;
    if (n.contains('suit') || n.contains('coat')) return Iconsax.briefcase;
    return Iconsax.tag;
  }
}

class _AddRateModal extends StatefulWidget {
  const _AddRateModal();

  @override
  State<_AddRateModal> createState() => _AddRateModalState();
}

class _AddRateModalState extends State<_AddRateModal> {
  String _selectedCategory = 'Men';
  String? _selectedGarment;
  String? _selectedService;
  final _priceController = TextEditingController();

  // Categories list wrapper for choice chips
  final List<String> _categories = LaundryData.garmentCategories.keys.toList();

  @override
  Widget build(BuildContext context) {
    // Access provider via Consumer wrapper inside build if needed,
    // or just pass ref. But since this is StatefulWidget, we use Consumer wrapping inside.

    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.w,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add New Rate",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Iconsax.close_circle),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          Text(
            "Category",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 40.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (c, i) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val)
                      setState(() {
                        _selectedCategory = cat;
                        _selectedGarment = null;
                      });
                  },
                  selectedColor: WhiteLabelTheme.primaryBlack,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : WhiteLabelTheme.textDark,
                    fontWeight: FontWeight.w500,
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
                );
              },
            ),
          ),

          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGarment,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Garment",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  items: LaundryData.garmentCategories[_selectedCategory]!
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedGarment = val),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedService,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Service",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  items: LaundryData.serviceTypes
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedService = val),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Price (PKR)",
              prefixIcon: const Icon(Iconsax.money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          Consumer(
            builder: (context, ref, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedGarment != null &&
                        _selectedService != null &&
                        _priceController.text.isNotEmpty) {
                      ref
                          .read(ratesProvider.notifier)
                          .addRate(
                            _selectedGarment!,
                            _selectedService!,
                            double.tryParse(_priceController.text) ?? 0,
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Item Added!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WhiteLabelTheme.primaryBlack,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    "Save Item",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WhatsAppConnectTile extends StatefulWidget {
  @override
  State<_WhatsAppConnectTile> createState() => _WhatsAppConnectTileState();
}

class _WhatsAppConnectTileState extends State<_WhatsAppConnectTile> {
  final box = GetStorage();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    isConnected = box.read('wa_connected') ?? false;
  }

  void _startPairing() {
    final phoneController = TextEditingController();

    // 1. Ask for Phone Number first
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter WhatsApp Number"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter the number you want to send receipts FROM."),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: "e.g. +923001234567"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close phone input
              _initiateBot(phoneController.text);
            },
            child: const Text("Connect"),
          ),
        ],
      ),
    );
  }

  void _initiateBot(String phone) {
    // Show Pairing Dialog with Loading State
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          String? pairingCode;
          String? errorMsg;

          // Trigger Service
          if (pairingCode == null && errorMsg == null) {
            WhatsappService.setupBot(
              phoneNumber: phone,
              onPairingCode: (code) {
                if (context.mounted) {
                  setState(() {
                    pairingCode = code;
                  });
                }
              },
              onSuccess: () {
                if (context.mounted) {
                  Navigator.pop(context); // Close Dialog
                  _markConnected();
                }
              },
              onError: (err) {
                if (context.mounted) {
                  setState(() {
                    errorMsg = err;
                  });
                }
              },
            );
          }

          return PairingDialog(
            isLoading: pairingCode == null && errorMsg == null,
            code: pairingCode,
            error: errorMsg,
            onCancel: () {
              WhatsappService.disconnect();
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  void _markConnected() {
    setState(() {
      isConnected = true;
    });
    box.write('wa_connected', true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("WhatsApp Connected Successfully!")),
    );
  }

  void _disconnect() async {
    await WhatsappService.disconnect();
    setState(() {
      isConnected = false;
    });
    box.write('wa_connected', false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF25D366).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.message, color: Color(0xFF25D366)),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "WhatsApp Receipt Bot",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: WhiteLabelTheme.textDark,
                ),
              ),
              Text(
                isConnected ? "Connected & Active" : "Not Connected",
                style: TextStyle(
                  color: isConnected
                      ? WhiteLabelTheme.successGreen
                      : WhiteLabelTheme.textGrey,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
        if (isConnected)
          OutlinedButton(
            onPressed: _disconnect,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text("Disconnect"),
          )
        else
          ElevatedButton(
            onPressed: _startPairing,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
            ),
            child: const Text("Connect"),
          ),
      ],
    );
  }
}
