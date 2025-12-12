import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anomaly.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final AnomalyStatus status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  Color _getColor() {
    switch (status) {
      case AnomalyStatus.ouvert:
        return AppColors.statusOpen;
      case AnomalyStatus.enCours:
        return AppColors.statusInProgress;
      case AnomalyStatus.resolu:
        return AppColors.statusResolved;
    }
  }

  Color _getBgColor() {
    switch (status) {
      case AnomalyStatus.ouvert:
        return AppColors.statusOpenBg;
      case AnomalyStatus.enCours:
        return AppColors.statusInProgressBg;
      case AnomalyStatus.resolu:
        return AppColors.statusResolvedBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getBgColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.labelFr,
        style: GoogleFonts.poppins(
          fontSize: isCompact ? 10 : 12,
          fontWeight: FontWeight.w600,
          color: _getColor(),
        ),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final AnomalyPriority priority;
  final bool showIcon;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showIcon = true,
  });

  Color _getColor() {
    switch (priority) {
      case AnomalyPriority.high:
        return AppColors.highPriority;
      case AnomalyPriority.medium:
        return AppColors.mediumPriority;
      case AnomalyPriority.low:
        return AppColors.lowPriority;
    }
  }

  IconData _getIcon() {
    switch (priority) {
      case AnomalyPriority.high:
        return Icons.arrow_upward_rounded;
      case AnomalyPriority.medium:
        return Icons.remove_rounded;
      case AnomalyPriority.low:
        return Icons.arrow_downward_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _getColor().withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getIcon(),
              size: 14,
              color: _getColor(),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            priority.labelFr,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getColor(),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final AnomalyCategory category;

  const CategoryBadge({
    super.key,
    required this.category,
  });

  IconData _getIcon() {
    switch (category) {
      case AnomalyCategory.mecanique:
        return Icons.build_rounded;
      case AnomalyCategory.electrique:
        return Icons.electric_bolt_rounded;
      case AnomalyCategory.hse:
        return Icons.health_and_safety_rounded;
      case AnomalyCategory.infrastructure:
        return Icons.foundation_rounded;
      case AnomalyCategory.securite:
        return Icons.security_rounded;
      case AnomalyCategory.environnement:
        return Icons.eco_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            category.label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

