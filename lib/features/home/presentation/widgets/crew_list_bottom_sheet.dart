import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/features/home/domain/entities/job_entity.dart';

class CrewListBottomSheet extends StatelessWidget {
  final List<CrewMemberEntity> crewMembers;

  const CrewListBottomSheet({super.key, required this.crewMembers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.adaptiveNeutralBackground(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assigned Crew',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.adaptiveTextPrimary(context),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.adaptiveTextSecondary(context),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (crewMembers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No crew assigned yet.',
                style: GoogleFonts.inter(
                  color: AppColors.adaptiveTextSecondary(context),
                  fontSize: 14,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemCount: crewMembers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final crew = crewMembers[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.adaptiveNeutralBackground(
                      context,
                    ),
                    backgroundImage: crew.photoUrl != null
                        ? NetworkImage(crew.photoUrl!)
                        : null,
                    child: crew.photoUrl == null
                        ? Text(
                            crew.firstName.isNotEmpty
                                ? crew.firstName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: AppColors.adaptiveMoversBlue(context),
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    '${crew.firstName} ${crew.lastName}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.adaptiveTextPrimary(context),
                    ),
                  ),
                  subtitle: Text(
                    crew.role,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.adaptiveTextSecondary(context),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        context,
                        crew.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      crew.status,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(context, crew.status),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'confirmed':
        return AppColors.adaptiveSuccess(context);
      case 'declined':
        return AppColors.adaptiveError(context);
      case 'pending':
        return AppColors.adaptiveWarning(context);
      default:
        return AppColors.adaptiveTextSecondary(context);
    }
  }
}
