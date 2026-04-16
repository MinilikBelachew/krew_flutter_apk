import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movers/core/bloc/theme_bloc.dart';
import 'package:movers/core/config/theme.dart';
import 'section_group.dart';
import 'settings_tile.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        return SectionGroup(
          label: 'Appearance',
          children: [
            SettingsTile(
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              title: 'Dark Mode',
              subtitle: isDark ? 'On' : 'Off',
              isLast: true,
              trailing: Switch.adaptive(
                value: isDark,
                activeTrackColor: AppColors.primary,
                onChanged: (_) =>
                    context.read<ThemeBloc>().add(ThemeToggleRequested()),
              ),
              onTap: () =>
                  context.read<ThemeBloc>().add(ThemeToggleRequested()),
            ),
          ],
        );
      },
    );
  }
}
