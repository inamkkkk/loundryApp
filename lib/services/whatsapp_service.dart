import 'dart:async';
import 'dart:typed_data';
import 'package:whatsapp_bot_flutter_mobile/whatsapp_bot_flutter_mobile.dart';
import 'package:whatsapp_bot_platform_interface/whatsapp_bot_platform_interface.dart';

class WhatsappService {
  static WhatsappClient? _client;
  static bool _isConnecting = false;

  /// Connect using QR Code (as per official documentation)
  /// [onQrCode] callback returns QR code image bytes to display
  static Future<void> connectWithQR({
    Function(Uint8List?)? onQrCode,
    Function()? onSuccess,
    Function(String)? onError,
  }) async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      print("Starting WhatsApp Connection with QR Code...");

      _client = await WhatsappBotFlutterMobile.connect(
        saveSession: true,
        onConnectionEvent: (ConnectionEvent event) {
          print("DEBUG: Connection Event: $event");
          if (event == ConnectionEvent.connected) {
            print("SUCCESS: WhatsApp Connected!");
            if (onSuccess != null) onSuccess();
            _isConnecting = false;
          }
        },
        onQrCode: (String qr, Uint8List? imageBytes) {
          print("DEBUG: QR Code Generated");
          if (onQrCode != null && imageBytes != null) {
            onQrCode(imageBytes);
          }
        },
      );
    } catch (e) {
      print("WhatsApp Connection Exception: $e");
      if (onError != null) onError(e.toString());
      _isConnecting = false;
    }
  }

  /// Send receipt message
  static Future<void> sendReceipt(String phone, String message) async {
    if (_client == null) {
      print("Error: WhatsApp not connected");
      return;
    }

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
    } catch (e) {
      print("Failed to send message: $e");
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
}
