import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/anomaly_provider.dart';
import '../theme/app_theme.dart';

class DepartmentCard extends StatelessWidget {
  final DepartmentAnalytics department;
  final VoidCallback? onTap;

  const DepartmentCard({
    super.key,
    required this.department,
    this.onTap,
  });

  IconData _getIcon() {
    return department.icon;
  }

  Color _getDepartmentColor() {
    switch (department.name) {
      case 'Mécanique':
      case 'Maintenance':
        return AppColors.chartBlue;
      case 'Électrique':
      case 'Électricité':
        return AppColors.chartOrange;
      case 'HSE':
      case 'Sécurité':
        return AppColors.chartGreen;
      case 'Exploitation':
        return AppColors.chartPurple;
      case 'Vente':
        return AppColors.chartRed;
      case 'Bureau de méthode':
      case 'Infrastructure':
        return AppColors.chartTeal;
      case 'Environnement':
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
  final DepartmentAnalytics department;
  final VoidCallback? onTap;

  const DepartmentCardCompact({
    super.key,
    required this.department,
    this.onTap,
  });

  IconData _getIcon() {
    return department.icon;
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

