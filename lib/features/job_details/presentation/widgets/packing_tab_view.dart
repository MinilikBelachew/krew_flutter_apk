import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/features/job_details/domain/entities/job_detail_entity.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_bloc.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_event.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_state.dart';

class PackingTabView extends StatefulWidget {
  final List<MaterialDetail>? materials;
  final String? jobId;
  const PackingTabView({super.key, this.materials, this.jobId});

  @override
  State<PackingTabView> createState() => _PackingTabViewState();
}

class _PackingTabViewState extends State<PackingTabView> {
  @override
  Widget build(BuildContext context) {
    final bool isLoading = widget.materials == null;
    final List<MaterialDetail> safeMaterials = widget.materials ?? [];
    final List<MaterialDetail> dedupedMaterials = _dedupeByName(safeMaterials);

    if (isLoading) {
      return const _PackingSkeleton();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Total Materials - ${safeMaterials.length}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.adaptiveTextSecondary(context),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.adaptiveCardBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.adaptiveBorder(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: dedupedMaterials.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: Text('No materials found')),
                  )
                : BlocBuilder<JobDetailsBloc, JobDetailsState>(
                    builder: (context, state) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dedupedMaterials.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 24,
                          color: AppColors.adaptiveBorder(context),
                        ),
                        itemBuilder: (context, index) {
                          return _buildMaterialRow(
                            context,
                            dedupedMaterials[index],
                            state.checkedPackingKeys,
                          );
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(
    BuildContext context,
    MaterialDetail material,
    Set<String> checkedKeys,
  ) {
    final key = _key(material);
    final checked = checkedKeys.contains(key);

    void toggle() {
      if (widget.jobId != null) {
        context.read<JobDetailsBloc>().add(
              TogglePackingItem(widget.jobId!, key),
            );
      }
    }

    return InkWell(
      onTap: toggle,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: checked ? 0.85 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Align(
                  alignment: Alignment.center,
                  child: Checkbox(
                    value: checked,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    onChanged: (val) => toggle(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.adaptiveSurface(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.adaptiveBorder(context)),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 24,
                  color: AppColors.adaptiveTextSecondary(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            material.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.adaptiveTextPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'x${material.count}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.adaptiveTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _key(MaterialDetail material) => material.name;

  List<MaterialDetail> _dedupeByName(List<MaterialDetail> materials) {
    final Map<String, int> counts = {};
    for (final m in materials) {
      final name = m.name.trim();
      if (name.isEmpty) continue;
      counts[name] = (counts[name] ?? 0) + m.count;
    }

    final keys = counts.keys.toList()..sort();
    return keys
        .map((k) => MaterialDetail(name: k, count: counts[k] ?? 0))
        .toList();
  }
}

class _PackingSkeleton extends StatelessWidget {
  const _PackingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.adaptiveCardBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.adaptiveBorder(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const SizedBox(height: 220),
      ),
    );
  }
}
