import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/anomaly_provider.dart';

class DepartmentAnalyticsScreen extends StatelessWidget {
  const DepartmentAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Analyse par Département',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDepartmentChart(),
            const SizedBox(height: 24),
            _buildDepartmentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentChart() {
    return Consumer<AnomalyProvider>(
      builder: (context, provider, child) {
        final departments = provider.departmentAnalytics;
        
        if (departments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 48,
                    color: AppColors.textLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune donnée disponible',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        final maxValue = departments.isEmpty 
            ? 10 
            : departments.map((d) => d.totalAnomalies).reduce((a, b) => a > b ? a : b);
        final maxY = maxValue > 0 ? (maxValue * 1.2).ceil().toDouble() : 40.0;
        
        return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anomalies par département',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex >= 0 && groupIndex < departments.length) {
                        return BarTooltipItem(
                          '${departments[groupIndex].name}\n${rod.toY.toInt()}',
                          GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }
                      return BarTooltipItem('', GoogleFonts.poppins());
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < departments.length) {
                          final deptName = departments[index].name;
                          final shortName = deptName.length > 3 ? deptName.substring(0, 3) : deptName;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              shortName,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        );
                      },
                      reservedSize: 30,
                      interval: 10,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                  barGroups: departments.asMap().entries.map((entry) {
                    final colors = [
                      AppColors.chartBlue,
                      AppColors.chartOrange,
                      AppColors.chartGreen,
                      AppColors.chartPurple,
                      AppColors.chartRed,
                      AppColors.chartTeal,
                    ];
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.totalAnomalies.toDouble(),
                          color: colors[entry.key % colors.length],
                          width: departments.length <= 3 ? 30 : 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    );
                  }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildDepartmentList() {
    return Consumer<AnomalyProvider>(
      builder: (context, provider, child) {
        final departments = provider.departmentAnalytics;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails par département',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (departments.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        size: 48,
                        color: AppColors.textLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune donnée par département',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...departments.map((dept) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DepartmentCard(department: dept),
              )),
          ],
        );
      },
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final DepartmentAnalytics department;
  final VoidCallback? onTap;

  const _DepartmentCard({
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

