import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/department_card.dart';
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
      builder: (context, anomalyProvider, child) {
        final departments = anomalyProvider.departmentAnalytics;
        
        if (departments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
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
              child: Text(
                'Aucun département avec des anomalies',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }
        
        // Calculate max Y dynamically
        final maxValue = departments.map((d) => d.totalAnomalies).reduce((a, b) => a > b ? a : b);
        final maxY = (maxValue * 1.2).ceilToDouble();
    
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
                          return BarTooltipItem(
                            '${departments[groupIndex].name}\n${rod.toY.toInt()}',
                            GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
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
                            if (value.toInt() < departments.length) {
                              final deptName = departments[value.toInt()].name;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  deptName.length > 3 ? deptName.substring(0, 3) : deptName,
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
                          interval: maxY > 20 ? 10 : 5,
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 20 ? 10 : 5,
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
                            width: departments.length <= 3 ? 30.0 : 20.0,
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
      builder: (context, anomalyProvider, child) {
        final departments = anomalyProvider.departmentAnalytics;
    
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
              ...departments.map((dept) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DepartmentCard(department: dept),
              )),
          ],
        );
      },
    );
  }
}

