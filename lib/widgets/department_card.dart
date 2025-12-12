import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class DepartmentCard extends StatelessWidget {
  final Department department;
  final VoidCallback? onTap;

  const DepartmentCard({
    super.key,
    required this.department,
    this.onTap,
  });

  IconData _getIcon() {
    switch (department.icon) {
      case 'build':
        return Icons.build_rounded;
      case 'electric_bolt':
        return Icons.electric_bolt_rounded;
      case 'health_and_safety':
        return Icons.health_and_safety_rounded;
      case 'foundation':
        return Icons.foundation_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'eco':
        return Icons.eco_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  Color _getDepartmentColor() {
    switch (department.icon) {
      case 'build':
        return AppColors.chartBlue;
      case 'electric_bolt':
        return AppColors.chartOrange;
      case 'health_and_safety':
        return AppColors.chartGreen;
      case 'foundation':
        return AppColors.chartPurple;
      case 'security':
        return AppColors.chartRed;
      case 'eco':
        return AppColors.chartTeal;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getDepartmentColor();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${department.totalAnomalies} anomalies',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: department.resolutionRate >= 80
                        ? AppColors.successLight
                        : department.resolutionRate >= 50
                            ? AppColors.warningLight
                            : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${department.resolutionRate.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: department.resolutionRate >= 80
                          ? AppColors.success
                          : department.resolutionRate >= 50
                              ? AppColors.warning
                              : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: department.resolutionRate / 100,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            // Stats row
            Row(
              children: [
                _StatItem(
                  label: 'Ouvert',
                  value: department.openAnomalies.toString(),
                  color: AppColors.statusOpen,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  label: 'En cours',
                  value: department.inProgressAnomalies.toString(),
                  color: AppColors.statusInProgress,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  label: 'Résolu',
                  value: department.resolvedAnomalies.toString(),
                  color: AppColors.statusResolved,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class DepartmentCardCompact extends StatelessWidget {
  final Department department;
  final VoidCallback? onTap;

  const DepartmentCardCompact({
    super.key,
    required this.department,
    this.onTap,
  });

  IconData _getIcon() {
    switch (department.icon) {
      case 'build':
        return Icons.build_rounded;
      case 'electric_bolt':
        return Icons.electric_bolt_rounded;
      case 'health_and_safety':
        return Icons.health_and_safety_rounded;
      case 'foundation':
        return Icons.foundation_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'eco':
        return Icons.eco_rounded;
      default:
        return Icons.folder_rounded;
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIcon(),
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    department.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${department.resolvedAnomalies}/${department.totalAnomalies} résolues',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${department.resolutionRate.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: department.resolutionRate >= 70
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

