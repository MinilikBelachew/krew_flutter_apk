import 'package:flutter/material.dart';
import 'package:movers/core/config/theme.dart';

class SectionGroup extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const SectionGroup({
    super.key,
    required this.label,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.adaptiveCardBackground(context),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
