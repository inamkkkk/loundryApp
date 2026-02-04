import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loundryapp/core/theme/white_label_theme.dart';

class PairingDialog extends StatelessWidget {
  final String? code;
  final bool isLoading;
  final String? error;
  final VoidCallback? onCancel;

  const PairingDialog({
    super.key,
    this.code,
    this.isLoading = true,
    this.error,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: WhiteLabelTheme.surfaceWhite,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.mobile,
                size: 32.sp,
                color: const Color(0xFF25D366),
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              "Link Device",
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),

            if (isLoading) ...[
              SizedBox(height: 16.h),
              const SpinKitThreeBounce(
                color: WhiteLabelTheme.primaryBlue,
                size: 24,
              ),
              SizedBox(height: 16.h),
              Text(
                "Generating Pairing Code...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WhiteLabelTheme.textGrey,
                  fontSize: 14.sp,
                ),
              ),
            ] else if (error != null) ...[
              SizedBox(height: 16.h),
              Text(
                "Error",
                style: TextStyle(
                  color: WhiteLabelTheme.dangerRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WhiteLabelTheme.textGrey,
                  fontSize: 14.sp,
                ),
              ),
            ] else if (code != null) ...[
              SizedBox(height: 8.h),
              Text(
                "Enter this code on your phone:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WhiteLabelTheme.textGrey,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 16.h),

              // The Code Display
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: WhiteLabelTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: WhiteLabelTheme.borderGrey),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatCode(code!),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: WhiteLabelTheme.textDark,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    IconButton(
                      icon: const Icon(Iconsax.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Code Copied!")),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),
              Text(
                "WhatsApp > Linked Devices > Link with phone number",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: WhiteLabelTheme.textGrey.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel ?? () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCode(String raw) {
    // e.g. J2K39L0P -> J2K3-9L0P
    if (raw.length == 8) {
      return "${raw.substring(0, 4)}-${raw.substring(4)}";
    }
    return raw;
  }
}
