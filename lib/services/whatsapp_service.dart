import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Still needed for some types if exposed, but less critical now
import 'package:whatsapp_bot_flutter_mobile/whatsapp_bot_flutter_mobile.dart';
import 'package:whatsapp_bot_platform_interface/whatsapp_bot_platform_interface.dart';

class WhatsappService {
  static WhatsappClient? _client;
  static bool _isConnecting = false;

  /// 1. START THE GHOST (Early-Warm & Pairing)
  /// If [phoneNumber] is provided, it attempts to pair using the code method.
  /// [onPairingCode] callback returns the 8-digit code to display in UI.
  static Future<void> setupBot({
    String? phoneNumber,
    Function(String)? onPairingCode,
    Function()? onSuccess,
    Function(String)? onError,
  }) async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      print("Starting WhatsApp Setup...");
      String? cleanPhone = _formatPhone(phoneNumber);
      print("Debug: Clean Phone: $cleanPhone");

      _client = await WhatsappBotFlutterMobile.connect(
        saveSession: false,
        linkWithPhoneNumber: cleanPhone,
        onPhoneLinkCode: (code) {
          print("SUCCESS: Pairing Code Received: $code");
          if (onPairingCode != null) {
            onPairingCode(code);
          }
        },
        onConnectionEvent: (event) {
          print("DEBUG: Connection Event: $event");
          if (event == ConnectionEvent.connected) {
            if (onSuccess != null) onSuccess();
            _isConnecting = false;
          }
        },
        onQrCode: (qr, image) {
          print("DEBUG: QR Code callback fired. Page Loaded.");
        },
        // camelCase onError Removed as it is not supported in v2.1.2
      );
    } catch (e) {
      print("WhatsApp Setup Exception: $e");
      if (onError != null) onError(e.toString());
      _isConnecting = false;
    }
  }

  /// 2. SEND & KILL
  static Future<void> sendReceipt(String phone, String message) async {
    if (_client == null) {
      try {
        await setupBot();
      } catch (e) {
        print("Failed to auto-connect for sending: $e");
        return;
      }
    }

    if (_client != null) {
      try {
        String formattedPhone = phone;
        if (formattedPhone.startsWith("0")) {
          formattedPhone = "92" + formattedPhone.substring(1);
        }

        await _client!.chat.sendTextMessage(
          phone: formattedPhone,
          message: message,
        );
        print("Receipt sent to $formattedPhone");

        Future.delayed(const Duration(seconds: 5), () {
          disconnect();
        });
      } catch (e) {
        print("Failed to send message: $e");
      }
    }
  }

  static Future<void> disconnect() async {
    try {
      await _client?.disconnect();
      _client = null;
      _isConnecting = false;
    } catch (e) {
      print("Error disconnecting: $e");
    }
  }

  static bool get isConnected =>
      _client != null && (_client?.isConnected ?? false);

  static String? _formatPhone(String? phone) {
    if (phone == null) return null;
    String p = phone.replaceAll("+", "").replaceAll(" ", "");
    if (p.startsWith("0")) {
      p = "92" + p.substring(1);
    }
    return p;
  }
}
