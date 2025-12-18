import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/department_card.dart';
import '../../widgets/kpi_card.dart';
import '../../providers/anomaly_provider.dart';
import 'department_analytics.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildOverviewStats()),
            SliverToBoxAdapter(child: _buildTrendChart()),
            SliverToBoxAdapter(child: _buildPriorityChart()),
            SliverToBoxAdapter(child: _buildDepartmentSection(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Statistiques et indicateurs de performance',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStats() {
    return Consumer<AnomalyProvider>(
      builder: (context, anomalyProvider, child) {
        final total = anomalyProvider.totalAnomalies;
        final resolved = anomalyProvider.resolvedAnomalies;
        final open = anomalyProvider.openAnomalies;
        final inProgress = anomalyProvider.inProgressAnomalies;
        final resolutionRate = anomalyProvider.resolutionRate;
    
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vue d\'ensemble',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Anomalies',
                      value: total.toString(),
                      icon: Icons.folder_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Taux de résolution',
                      value: '${resolutionRate.toStringAsFixed(0)}%',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: KPICardSmall(
                      title: 'Ouvertes',
                      value: open.toString(),
                      icon: Icons.error_outline_rounded,
                      color: AppColors.statusOpen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KPICardSmall(
                      title: 'En cours',
                      value: inProgress.toString(),
                      icon: Icons.pending_rounded,
                      color: AppColors.statusInProgress,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KPICardSmall(
                      title: 'Résolues',
                      value: resolved.toString(),
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.statusResolved,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendChart() {
    return Consumer<AnomalyProvider>(
      builder: (context, anomalyProvider, child) {
        final monthlyData = anomalyProvider.monthlyAnalytics;
        
        // Calculate max Y dynamically
        final maxValue = monthlyData.isEmpty 
            ? 10.0 
            : monthlyData.map((d) => d.total > d.resolved ? d.total : d.resolved).reduce((a, b) => a > b ? a : b).toDouble();
        final maxY = (maxValue * 1.2).ceilToDouble(); // Add 20% padding
    
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total vs Résolues',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '6 derniers mois',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _LegendItem(color: AppColors.chartBlue, label: 'Total'),
                    const SizedBox(width: 20),
                    _LegendItem(color: AppColors.chartGreen, label: 'Résolues'),
                  ],
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
                            return BarTooltipItem(
                              rod.toY.toInt().toString(),
                              GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < monthlyData.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    monthlyData[value.toInt()].month,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
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
                      barGroups: monthlyData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.total.toDouble(),
                              color: AppColors.chartBlue,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                            BarChartRodData(
                              toY: entry.value.resolved.toDouble(),
                              color: AppColors.chartGreen,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityChart() {
    return Consumer<AnomalyProvider>(
      builder: (context, anomalyProvider, child) {
        final highPriority = anomalyProvider.highPriorityAnomalies;
        final mediumPriority = anomalyProvider.mediumPriorityAnomalies;
        final lowPriority = anomalyProvider.lowPriorityAnomalies;
        final total = highPriority + mediumPriority + lowPriority;
    
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
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
                  'Répartition par priorité',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: highPriority.toDouble(),
                              color: AppColors.highPriority,
                              title: total > 0 ? '${((highPriority / total) * 100).toStringAsFixed(0)}%' : '0%',
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              radius: 35,
                            ),
                            PieChartSectionData(
                              value: mediumPriority.toDouble(),
                              color: AppColors.mediumPriority,
                              title: total > 0 ? '${((mediumPriority / total) * 100).toStringAsFixed(0)}%' : '0%',
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              radius: 35,
                            ),
                            PieChartSectionData(
                              value: lowPriority.toDouble(),
                              color: AppColors.lowPriority,
                              title: total > 0 ? '${((lowPriority / total) * 100).toStringAsFixed(0)}%' : '0%',
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              radius: 35,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PriorityLegendItem(
                            color: AppColors.highPriority,
                            label: 'Haute',
                            count: highPriority,
                          ),
                          const SizedBox(height: 12),
                          _PriorityLegendItem(
                            color: AppColors.mediumPriority,
                            label: 'Moyenne',
                            count: mediumPriority,
                          ),
                          const SizedBox(height: 12),
                          _PriorityLegendItem(
                            color: AppColors.lowPriority,
                            label: 'Basse',
                            count: lowPriority,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDepartmentSection(BuildContext context) {
    return Consumer<AnomalyProvider>(
      builder: (context, anomalyProvider, child) {
        final departments = anomalyProvider.departmentAnalytics;
        
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Analyse par département',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DepartmentAnalyticsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Voir tout',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (departments.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'Aucun département avec des anomalies',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...departments.take(3).map((dept) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DepartmentCardCompact(
                    department: dept,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DepartmentAnalyticsScreen(),
                        ),
                      );
                    },
                  ),
                )),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
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
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PriorityLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _PriorityLegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

