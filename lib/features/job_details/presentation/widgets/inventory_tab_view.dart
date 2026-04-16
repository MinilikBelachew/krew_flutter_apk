import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/utils/responsive.dart';
import 'package:movers/features/job_details/domain/entities/job_detail_entity.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_bloc.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_event.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_state.dart';

class InventoryTabView extends StatefulWidget {
  final List<InventoryItem>? items;
  final String? jobId;
  const InventoryTabView({super.key, this.items, this.jobId});

  @override
  State<InventoryTabView> createState() => _InventoryTabViewState();
}

class _InventoryTabViewState extends State<InventoryTabView> {
  String _selectedRoom = 'All items';

  @override
  Widget build(BuildContext context) {
    final bool isLoading = widget.items == null;
    final List<InventoryItem> safeItems = widget.items ?? [];
    final isTablet = Responsive.isTablet(context);

    if (isLoading) {
      return const _InventorySkeleton();
    }

    // Get unique rooms and their counts
    final Map<String, int> roomCounts = {};
    for (var item in safeItems) {
      roomCounts[item.room] = (roomCounts[item.room] ?? 0) + 1;
    }

    final filteredItems = _selectedRoom == 'All items'
        ? safeItems
        : safeItems.where((e) => e.room == _selectedRoom).toList();

    if (isTablet) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sidebar
            Expanded(
              flex: 3,
              child: _buildSidebar(roomCounts, safeItems.length),
            ),
            const SizedBox(width: 20),
            // Item List
            Expanded(flex: 7, child: _buildItemList(filteredItems)),
          ],
        ),
      );
    }

    // Mobile Layout
    return Column(
      children: [
        _buildMobileHeader(roomCounts, safeItems.length),
        _buildItemList(filteredItems),
      ],
    );
  }

  Widget _buildSidebar(Map<String, int> roomCounts, int totalCount) {
    final rooms = ['All items', ...roomCounts.keys];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.adaptiveNeutralBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: rooms.map((room) {
          final isSelected = _selectedRoom == room;
          final count = room == 'All items' ? totalCount : roomCounts[room]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => setState(() => _selectedRoom = room),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.adaptiveCardBackground(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      room,
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

  Widget _buildMobileHeader(Map<String, int> roomCounts, int totalCount) {
    final rooms = ['All items', ...roomCounts.keys];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildCategoryChip('All items', _selectedRoom == 'All items', () {
            setState(() => _selectedRoom = 'All items');
          }),
          const Spacer(),
          Text(
            'By room',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.adaptiveTextPrimary(context),
            ),
          ),
          const SizedBox(width: 12),
          _buildRoomDropdown(rooms),
        ],
      ),
    );
  }

  Widget _buildItemList(List<InventoryItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Total Items - ${items.length}',
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
            child: items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: Text('No items found')),
                  )
                : BlocBuilder<JobDetailsBloc, JobDetailsState>(
                    builder: (context, state) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 24,
                          color: AppColors.adaptiveBorder(context),
                        ),
                        itemBuilder: (context, index) {
                          return _buildInventoryCard(
                            context,
                            items[index],
                            state.checkedInventoryKeys,
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

  Widget _buildCategoryChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.secondary
              : AppColors.adaptiveCardBackground(context),
          borderRadius: BorderRadius.circular(100),
          border: isActive
              ? null
              : Border.all(color: AppColors.adaptiveBorder(context)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive
                ? Colors.white
                : AppColors.adaptiveTextPrimary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomDropdown(List<String> rooms) {
    final dropdownRooms = rooms.where((r) => r != 'All items').toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardBackground(context),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRoom == 'All items' ? null : _selectedRoom,
          items: dropdownRooms
              .map(
                (room) => DropdownMenuItem(
                  value: room,
                  child: Text(
                    room,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedRoom = val);
          },
          hint: Text(
            'Dining room', // Default hint from design
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.adaptiveTextSecondary(context),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.adaptiveTextSecondary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryCard(
    BuildContext context,
    InventoryItem item,
    Set<String> checkedKeys,
  ) {
    final overrideKey = _overrideKey(item);
    final isLoaded = checkedKeys.contains(overrideKey);
    final int baseTruck = item.truckCount;
    final int baseHouse = item.houseCount;
    final int total = baseTruck + baseHouse;
    final int truckCount = isLoaded ? total : baseTruck;
    final int houseCount = isLoaded ? 0 : baseHouse;

    void toggleLoaded() {
      if (widget.jobId != null) {
        context.read<JobDetailsBloc>().add(
              ToggleInventoryItem(widget.jobId!, overrideKey),
            );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: toggleLoaded,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isLoaded ? 0.7 : 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loaded Checkbox
              SizedBox(
                width: 40,
                height: 40,
                child: Align(
                  alignment: Alignment.center,
                  child: Checkbox(
                    value: isLoaded,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    onChanged: (val) => toggleLoaded(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Item Image or Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.adaptiveSurface(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.adaptiveBorder(context)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const _SkeletonBox(
                              height: 40,
                              width: 40,
                              borderRadius: 8,
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
                            item.icon,
                            size: 24,
                            color: AppColors.adaptiveTextSecondary(context),
                          ),
                        )
                      : Icon(
                          item.icon,
                          size: 24,
                          color: AppColors.adaptiveTextSecondary(context),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Name and Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.adaptiveTextPrimary(context),
                              decoration: isLoaded
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (isLoaded)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(
                                  0xFF22C55E,
                                ).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              'Done',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (item.isOversize)
                          _buildBadge('Oversize', const Color(0xFFF59E0B)),
                        if (item.isPbo)
                          _buildBadge('PBO', const Color(0xFF6B7280)),
                        if (item.isPackingNeeded)
                          _buildBadge('Needs Packing', const Color(0xFF3B82F6)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Status Indicators (Truck / House)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusCount(
                    Icons.local_shipping_rounded,
                    truckCount,
                    const Color(0xFF22C55E),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusCount(
                    Icons.home_rounded,
                    houseCount,
                    const Color(0xFFEF4444),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _overrideKey(InventoryItem item) {
    return '${item.room}::${item.name}';
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusCount(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '- $count',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InventorySkeleton extends StatefulWidget {
  const _InventorySkeleton();

  @override
  State<_InventorySkeleton> createState() => _InventorySkeletonState();
}

class _InventorySkeletonState extends State<_InventorySkeleton>
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

        Widget box({double? w, required double h, double r = 12}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(r),
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  box(w: 110, h: 36, r: 100),
                  const Spacer(),
                  box(w: 130, h: 40, r: 100),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: box(w: 140, h: 14, r: 8),
              ),
              const SizedBox(height: 12),
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
                child: Column(
                  children: List.generate(
                    6,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: i == 5 ? 0 : 18),
                      child: Row(
                        children: [
                          box(w: 48, h: 48, r: 8),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                box(w: double.infinity, h: 14, r: 8),
                                const SizedBox(height: 10),
                                box(w: 120, h: 10, r: 8),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              box(w: 48, h: 14, r: 8),
                              const SizedBox(height: 8),
                              box(w: 48, h: 14, r: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
