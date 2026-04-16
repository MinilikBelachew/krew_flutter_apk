import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signature/signature.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/utils/toast_service.dart';

class SignatureInputDialog extends StatefulWidget {
  const SignatureInputDialog({super.key});

  @override
  State<SignatureInputDialog> createState() => _SignatureInputDialogState();
}

class _SignatureInputDialogState extends State<SignatureInputDialog> {
  SignatureController? _controller;

  @override
  void initState() {
    super.initState();
  }

  SignatureController _createController(bool isDark) {
    return SignatureController(
      penStrokeWidth: 3,
      penColor: isDark ? Colors.white : Colors.black,
      exportBackgroundColor: isDark ? const Color(0xFF1E2130) : Colors.white,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _controller ??= _createController(isDark);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.adaptiveCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  'Signature input',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.adaptiveTextPrimary(context),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.adaptiveTextPrimary(context),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Signature Area
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.adaptiveSurface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.adaptiveBorder(context)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Signature(
                  controller: _controller!,
                  backgroundColor: isDark
                      ? const Color(0xFF1E2130)
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _controller?.clear();
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.adaptiveIndigo(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_controller?.isEmpty ?? true) {
                        ToastService.showWarning(
                          context,
                          'Please provide a signature',
                        );
                        return;
                      }
                      final Uint8List? signature = await _controller
                          ?.toPngBytes();
                      if (context.mounted) {
                        Navigator.pop(context, signature);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Input signature',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
