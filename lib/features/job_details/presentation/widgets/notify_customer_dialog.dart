import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';

class NotifyCustomerDialog extends StatefulWidget {
  const NotifyCustomerDialog({super.key});

  @override
  State<NotifyCustomerDialog> createState() => _NotifyCustomerDialogState();
}

class _NotifyCustomerDialogState extends State<NotifyCustomerDialog> {
  int _minutes = 30;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.adaptiveCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notify Customer by Email',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.adaptiveTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'An email will be sent telling the customer\nyour crew will arrive in $_minutes min.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.adaptiveTextSecondary(context),
              ),
            ),
            const SizedBox(height: 32),

            // Counter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCounterButton(Icons.remove, () {
                  if (_minutes > 1) setState(() => _minutes--);
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        '$_minutes',
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: AppColors.adaptiveTextPrimary(context),
                        ),
                      ),
                      Text(
                        'Minutes',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCounterButton(Icons.add, () {
                  setState(() => _minutes++);
                }),
              ],
            ),
            const SizedBox(height: 40),

            // Actions Row
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, 0),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.adaptiveMoversBlue(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _minutes),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.adaptiveTextPrimary(context),
                      foregroundColor: AppColors.adaptiveCardBackground(
                        context,
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Send Email',
                      style: GoogleFonts.inter(
                        fontSize: 13,
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

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: 28,
          color: AppColors.adaptiveTextSecondary(context),
        ),
      ),
    );
  }
}
