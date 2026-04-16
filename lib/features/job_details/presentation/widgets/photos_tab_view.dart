import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/utils/responsive.dart';
import 'package:movers/core/utils/toast_service.dart';
import 'package:movers/features/job_details/domain/entities/job_detail_entity.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_bloc.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_event.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_state.dart';

// Category constants
const _kAllPhotos = 'All Photos';
const _kCategoryLabels = {
  'customer': 'Customer',
  'crew': 'Crew',
  'portal_upload': 'Portal',
  'general': 'General',
};

class PhotosTabView extends StatefulWidget {
  final String jobId;
  const PhotosTabView({super.key, required this.jobId});

  @override
  State<PhotosTabView> createState() => _PhotosTabViewState();
}

class _PhotosTabViewState extends State<PhotosTabView> {
  String _selectedCategory = _kAllPhotos;
  final _picker = ImagePicker();

  Future<void> _openPhotoModal(JobFile file) async {
    if (!mounted || file.url.isEmpty) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'photo_modal',
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, _) {
        return SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      file.url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const _SkeletonBox(
                          width: double.infinity,
                          height: 360,
                          borderRadius: 12,
                        );
                      },
                      errorBuilder: (_, _, _) => Container(
                        width: double.infinity,
                        height: 360,
                        color: AppColors.darkSurface,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white70,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, anim, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch from dedicated files endpoint
    context.read<JobDetailsBloc>().add(FetchJobFiles(widget.jobId));
  }

  // ---- Helpers ----

  String _labelFor(String cat) => _kCategoryLabels[cat] ?? cat;

  Map<String, List<JobFile>> _groupedFiles(List<JobFile> files) {
    final Map<String, List<JobFile>> groups = {};
    for (final f in files) {
      final label = _labelFor(f.category);
      groups.putIfAbsent(label, () => []).add(f);
    }
    return groups;
  }

  List<JobFile> _filteredFiles(List<JobFile> files) {
    if (_selectedCategory == _kAllPhotos) return files;
    return files
        .where((f) => _labelFor(f.category) == _selectedCategory)
        .toList();
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final List<XFile> picked = source == ImageSource.gallery
          ? await _picker.pickMultiImage()
          : [
              await _picker.pickImage(source: source),
            ].whereType<XFile>().toList();

      if (picked.isEmpty || !mounted) return;
      final paths = picked.map((f) => f.path).toList();
      context.read<JobDetailsBloc>().add(UploadJobFiles(paths));
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Could not pick image: $e');
      }
    }
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobDetailsBloc, JobDetailsState>(
      builder: (context, state) {
        Widget content;

        if (state.isLoadingFiles) {
          content = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: _SkeletonBox(height: 36, borderRadius: 100),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _SkeletonBox(height: 36, borderRadius: 100),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return const _SkeletonBox(
                      height: double.infinity,
                      borderRadius: 12,
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          final files = state.jobFiles;
          final grouped = _groupedFiles(files);
          final categories = [_kAllPhotos, ...grouped.keys];
          final filtered = _filteredFiles(files);
          final isTablet = Responsive.isTablet(context);

          if (isTablet) {
            content = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildSidebar(categories, grouped, files),
                  ),
                  const SizedBox(width: 20),
                  Expanded(flex: 7, child: _buildMainPanel(filtered)),
                ],
              ),
            );
          } else {
            content = Column(
              children: [
                _buildMobileHeader(categories, grouped, files),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildPhotoGrid(filtered),
                ),
              ],
            );
          }
        }

        if (!state.isUpdatingStatus) return content;

        return Stack(
          children: [
            content,
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.12),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar(
    List<String> categories,
    Map<String, List<JobFile>> grouped,
    List<JobFile> files,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adaptiveNeutralBackground(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          final count = cat == _kAllPhotos
              ? files.length
              : (grouped[cat]?.length ?? 0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.adaptiveCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                  border: isSelected
                      ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.adaptiveTextPrimary(context)
                            : AppColors.adaptiveTextSecondary(context),
                      ),
                    ),
                    Text(
                      '$count',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.adaptiveTextPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainPanel(List<JobFile> filtered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCategory,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.adaptiveTextPrimary(context),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
        _buildPhotoGrid(filtered),
      ],
    );
  }

  Widget _buildMobileHeader(
    List<String> categories,
    Map<String, List<JobFile>> grouped,
    List<JobFile> files,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _buildChip(_kAllPhotos, _selectedCategory == _kAllPhotos, () {
                setState(() => _selectedCategory = _kAllPhotos);
              }),
              const Spacer(),
              Text(
                'By category',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.adaptiveTextPrimary(context),
                ),
              ),
              const SizedBox(width: 8),
              _buildDropdown(categories),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.adaptiveSurface(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                Icons.camera_alt_outlined,
                'Take photo',
                () => _pickAndUpload(ImageSource.camera),
              ),
              Container(
                width: 1,
                height: 20,
                color: AppColors.adaptiveBorder(context),
              ),
              _buildActionButton(
                Icons.image_outlined,
                'Add from gallery',
                () => _pickAndUpload(ImageSource.gallery),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(
          Icons.camera_alt_outlined,
          'Take photo',
          () => _pickAndUpload(ImageSource.camera),
        ),
        const SizedBox(width: 24),
        _buildActionButton(
          Icons.image_outlined,
          'Add from gallery',
          () => _pickAndUpload(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.adaptiveTextSecondary(context)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.adaptiveTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<JobFile> files) {
    if (files.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 12),
              Text(
                'No photos yet',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.adaptiveTextSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Take a photo or pick from gallery',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.adaptiveTextSecondary(
                    context,
                  ).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group by date
    final Map<String, List<JobFile>> byDate = {};
    for (final f in files) {
      final label = f.uploadedAt != null
          ? DateFormat('MMM d, yyyy').format(f.uploadedAt!)
          : 'Unknown Date';
      byDate.putIfAbsent(label, () => []).add(f);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...byDate.entries.map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  entry.key,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.adaptiveTextSecondary(context),
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: entry.value.length,
                itemBuilder: (context, index) =>
                    _buildPhotoCard(entry.value[index]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPhotoCard(JobFile file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: () => _openPhotoModal(file),
              child: file.url.isNotEmpty
                  ? Image.network(
                      file.url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const _SkeletonBox(
                          height: double.infinity,
                          borderRadius: 12,
                        );
                      },
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.adaptiveNeutralBackground(context),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.adaptiveTextSecondary(context),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.adaptiveNeutralBackground(context),
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.adaptiveTextSecondary(context),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                file.name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.adaptiveTextSecondary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _labelFor(file.category),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.adaptiveTextSecondary(context),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.adaptiveTextPrimary(context)
              : AppColors.adaptiveNeutralBackground(context),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive
                ? AppColors.adaptiveBackground(context)
                : AppColors.adaptiveTextPrimary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> categories) {
    final others = categories.where((c) => c != _kAllPhotos).toList();
    // Use fallback values if no images with categories exist yet
    final displayItems = others.isNotEmpty
        ? others
        : _kCategoryLabels.values.toList();
    final isActive = others.contains(_selectedCategory);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 36,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.adaptiveTextPrimary(context)
            : AppColors.adaptiveNeutralBackground(context),
        borderRadius: BorderRadius.circular(100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: isActive ? _selectedCategory : null,
          dropdownColor: AppColors.adaptiveSurface(context),
          elevation: 2,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive
                ? AppColors.adaptiveBackground(context)
                : AppColors.adaptiveTextPrimary(context),
          ),
          items: displayItems
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
          hint: Text(
            'By category',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? AppColors.adaptiveBackground(context)
                  : AppColors.adaptiveTextPrimary(context),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: isActive
                ? AppColors.adaptiveBackground(context)
                : AppColors.adaptiveTextPrimary(context),
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const _SkeletonBox({
    required this.height,
    this.width,
    this.borderRadius = 12,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final base = AppColors.skeletonBase(context);
        final highlight = AppColors.skeletonHighlight(context);
        final t = _controller.value;
        final baseColor = Color.lerp(base, highlight, t)!;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
