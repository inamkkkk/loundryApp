import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loundryapp/features/settings/domain/models/service_rate_model.dart';

// Provider for the repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsRepository {
  static const String _ratesKey = 'service_rates';

  Future<List<ServiceRate>> getRates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ratesJson = prefs.getString(_ratesKey);
    if (ratesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(ratesJson);
    return decoded.map((e) => ServiceRate.fromJson(e)).toList();
  }

  Future<void> saveRates(List<ServiceRate> rates) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(rates.map((e) => e.toJson()).toList());
    await prefs.setString(_ratesKey, encoded);
  }

  Future<void> addRate(ServiceRate rate) async {
    final rates = await getRates();
    final updatedRates = [...rates, rate];
    await saveRates(updatedRates);
  }

  Future<void> updateRate(ServiceRate updatedRate) async {
    final rates = await getRates();
    final updatedRates = rates
        .map((r) => r.id == updatedRate.id ? updatedRate : r)
        .toList();
    await saveRates(updatedRates);
  }

  Future<void> deleteRate(String id) async {
    final rates = await getRates();
    final updatedRates = rates.where((r) => r.id != id).toList();
    await saveRates(updatedRates);
  }
}
