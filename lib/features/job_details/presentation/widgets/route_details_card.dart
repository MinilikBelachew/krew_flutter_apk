import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';
import '../../domain/entities/job_detail_entity.dart';

class RouteDetailsCard extends StatelessWidget {
  final List<AddressDetail> pickups;
  final List<AddressDetail> deliveries;
  final String distance;
  final VoidCallback? onOpenMap;

  const RouteDetailsCard({
    super.key,
    required this.pickups,
    required this.deliveries,
    required this.distance,
    this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Route',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.adaptiveTextSecondary(context),
                ),
              ),
              // Text(
              //   'Distance - $distance',
              //   style: GoogleFonts.inter(
              //     fontSize: 12,
              //     fontWeight: FontWeight.w700,
              //     color: AppColors.adaptiveTextSecondary(context),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 20),
          ...pickups.asMap().entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationItem(
                  context,
                  Icons.location_on_outlined,
                  entry.value.label ?? 'Pickup ${entry.key + 1}',
                  entry.value.fullAddress,
                  color: Colors.green,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
                  child: SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      width: 1,
                      color: AppColors.adaptiveBorder(context),
                    ),
                  ),
                ),
              ],
            );
          }),
          ...deliveries.asMap().entries.map((entry) {
            final isLast = entry.key == deliveries.length - 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationItem(
                  context,
                  Icons.local_shipping_outlined,
                  entry.value.label ?? 'Delivery ${entry.key + 1}',
                  entry.value.fullAddress,
                  color: Colors.blue,
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
                    child: SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        width: 1,
                        color: AppColors.adaptiveBorder(context),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 20),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: TextButton.icon(
          //     onPressed: onOpenMap,
          //     icon: Icon(
          //       Icons.location_on_outlined,
          //       size: 16,
          //       color: AppColors.adaptiveTextPrimary(context),
          //     ),
          //     label: Text(
          //       'Open in map',
          //       style: GoogleFonts.inter(
          //         fontSize: 12,
          //         fontWeight: FontWeight.w700,
          //         color: AppColors.adaptiveTextPrimary(context),
          //       ),
          //     ),
          //     style: TextButton.styleFrom(padding: EdgeInsets.zero),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(
    BuildContext context,
    IconData icon,
    String label,
    String address, {
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: color ?? AppColors.adaptiveTextPrimary(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.adaptiveTextSecondary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.adaptiveTextPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
