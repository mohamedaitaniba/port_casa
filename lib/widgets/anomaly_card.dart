import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/anomaly.dart';
import '../theme/app_theme.dart';

class AnomalyCard extends StatelessWidget {
  final Anomaly anomaly;
  final VoidCallback? onTap;
  final bool showFullDescription;

  const AnomalyCard({
    super.key,
    required this.anomaly,
    this.onTap,
    this.showFullDescription = false,
  });

  Color _getPriorityColor() {
    switch (anomaly.priority) {
      case AnomalyPriority.high:
        return AppColors.highPriority;
      case AnomalyPriority.medium:
        return AppColors.mediumPriority;
      case AnomalyPriority.low:
        return AppColors.lowPriority;
    }
  }

  Color _getStatusColor() {
    switch (anomaly.status) {
      case AnomalyStatus.ouvert:
        return AppColors.statusOpen;
      case AnomalyStatus.enCours:
        return AppColors.statusInProgress;
      case AnomalyStatus.resolu:
        return AppColors.statusResolved;
    }
  }

  Color _getStatusBgColor() {
    switch (anomaly.status) {
      case AnomalyStatus.ouvert:
        return AppColors.statusOpenBg;
      case AnomalyStatus.enCours:
        return AppColors.statusInProgressBg;
      case AnomalyStatus.resolu:
        return AppColors.statusResolvedBg;
    }
  }

  IconData _getCategoryIcon() {
    switch (anomaly.category) {
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority indicator bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: _getPriorityColor(),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Category icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(),
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title and category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              anomaly.title,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              anomaly.category.label,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          anomaly.status.labelFr,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    anomaly.description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: showFullDescription ? null : 2,
                    overflow: showFullDescription ? null : TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Footer
                  Row(
                    children: [
                      // Location
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          anomaly.location,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Date
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(anomaly.date),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  // Priority badge
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _PriorityBadge(priority: anomaly.priority),
                      const Spacer(),
                      if (anomaly.assignedTo != null)
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              anomaly.assignedTo!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}

class _PriorityBadge extends StatelessWidget {
  final AnomalyPriority priority;

  const _PriorityBadge({required this.priority});

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

  String _getLabel() {
    switch (priority) {
      case AnomalyPriority.high:
        return 'Haute';
      case AnomalyPriority.medium:
        return 'Moyenne';
      case AnomalyPriority.low:
        return 'Basse';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _getColor().withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getLabel(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _getColor(),
            ),
          ),
        ],
      ),
    );
  }
}

class AnomalyCardCompact extends StatelessWidget {
  final Anomaly anomaly;
  final VoidCallback? onTap;

  const AnomalyCardCompact({
    super.key,
    required this.anomaly,
    this.onTap,
  });

  Color _getPriorityColor() {
    switch (anomaly.priority) {
      case AnomalyPriority.high:
        return AppColors.highPriority;
      case AnomalyPriority.medium:
        return AppColors.mediumPriority;
      case AnomalyPriority.low:
        return AppColors.lowPriority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: _getPriorityColor(),
              width: 3,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anomaly.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    anomaly.location,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

