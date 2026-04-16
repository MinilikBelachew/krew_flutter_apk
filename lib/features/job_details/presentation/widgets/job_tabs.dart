import 'package:flutter/material.dart';
import 'package:movers/core/widgets/primary_tabs.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_state.dart';

class JobTabs extends StatelessWidget {
  final JobDetailsTab activeTab;
  final Function(JobDetailsTab) onTabChanged;

  const JobTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PrimaryTabBar(
        expanded: true,
        labels: const ['Job Info', 'Inventory', 'Packing', 'Photos'],
        selectedIndex: JobDetailsTab.values.indexOf(activeTab),
        onTabChanged: (index) {
          onTabChanged(JobDetailsTab.values[index]);
        },
      ),
    );
  }
}
