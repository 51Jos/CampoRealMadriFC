import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking.dart';
import 'responsive_constants.dart';

class BookingFilterChips extends StatelessWidget {
  final BookingStatus? selectedFilter;
  final Function(BookingStatus?) onFilterChanged;
  final ScreenBreakpoint breakpoint;

  const BookingFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.breakpoint,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getPadding(breakpoint);
    final spacing = ResponsiveUtils.getSpacing(breakpoint);
    final buttonSize = ResponsiveUtils.getButtonSize(breakpoint);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: spacing,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.getMaxContentWidth(breakpoint),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing * 0.5,
              children: [
                _buildChip('Todas', null, Icons.list, buttonSize),
                _buildChip('Pendientes', BookingStatus.pending, Icons.access_time, buttonSize),
                _buildChip('Confirmadas', BookingStatus.confirmed, Icons.check_circle, buttonSize),
                _buildChip('Canceladas', BookingStatus.cancelled, Icons.cancel, buttonSize),
                _buildChip('Completadas', BookingStatus.completed, Icons.done_all, buttonSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, BookingStatus? status, IconData icon, double fontSize) {
    final isSelected = selectedFilter == status;
    final iconSize = breakpoint == ScreenBreakpoint.mobile ? 16.0 : 18.0;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: (selected) => onFilterChanged(selected ? status : null),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.primary,
          width: isSelected ? 2 : 1,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: breakpoint == ScreenBreakpoint.mobile ? 12 : 16,
        vertical: breakpoint == ScreenBreakpoint.mobile ? 8 : 10,
      ),
    );
  }
}
