import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:movers/core/config/theme.dart';
import '../../domain/entities/job_detail_entity.dart';

class EditResourcesPage extends StatelessWidget {
  final JobDetailEntity job;

  const EditResourcesPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Group crew members by role
    final roles = ['Forman', 'Driver', 'Loader', 'Crew'];
    final Map<String, List<CrewMember>> groupedCrew = {};

    for (var cm in job.crewMembers) {
      final role = cm.role;
      if (!groupedCrew.containsKey(role)) {
        groupedCrew[role] = [];
      }
      groupedCrew[role]!.add(cm);
    }

    // Sort roles to match ordered list preference if possible
    final sortedRoles = roles.where((r) => groupedCrew.containsKey(r)).toList();
    // Add any roles that might be missing from the preference list
    for (var role in groupedCrew.keys) {
      if (!sortedRoles.contains(role)) {
        sortedRoles.add(role);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.adaptivePageBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.adaptiveCardBackground(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Color(0xFF4F46E5),
          ),
        ),
        title: Text(
          'Edit resources',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.adaptiveTextPrimary(context),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: AppColors.adaptiveTextPrimary(context),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rate & Time Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.adaptiveCardBackground(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.adaptiveTextPrimary(
                            context,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(0, 32),
                        ),
                        child: Text(
                          'Edit Time',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(context, 'Rate', job.rate),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    context,
                    'Estimated time on job',
                    job.timeEstimate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Truck Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.adaptiveCardBackground(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assigned Truck',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.adaptiveTextSecondary(context),
                    ),
                  ),
                  Text(
                    job.truckNumber,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.adaptiveTextPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Crew List Grouped by Role
            if (sortedRoles.isNotEmpty)
              ...sortedRoles.map((role) {
                final members = groupedCrew[role]!;
                return Column(
                  key: ValueKey(role),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        role,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.adaptiveTextSecondary(context),
                        ),
                      ),
                    ),
                    ...members.map((cm) => _buildCrewMemberTile(context, cm)),
                    const SizedBox(height: 16),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.adaptiveTextSecondary(context),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.adaptiveTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCrewMemberTile(BuildContext context, CrewMember cm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.adaptiveBorder(context).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.adaptiveNeutralBackground(context),
            backgroundImage:
                (cm.photoUrl != null && cm.photoUrl!.trim().isNotEmpty)
                ? NetworkImage(cm.photoUrl!)
                : null,
            child: (cm.photoUrl == null || cm.photoUrl!.trim().isEmpty)
                ? Icon(
                    Icons.person,
                    color: AppColors.adaptiveTextSecondary(
                      context,
                    ).withValues(alpha: 0.5),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cm.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.adaptiveTextPrimary(context),
                  ),
                ),
                if (cm.clockInTime != null) ...[
                  Text(
                    DateFormat('MMM d, yyyy, h:mm a').format(cm.clockInTime!),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.adaptiveTextSecondary(context),
                    ),
                  ),
                  if (cm.duration != null && cm.duration!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Worked: ${cm.duration}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981), // Green highlight for payroll hours
                      ),
                    ),
                  ],
                ] else
                  Text(
                    'Not clocked in',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.adaptiveTextSecondary(context),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
              color: AppColors.adaptiveTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
