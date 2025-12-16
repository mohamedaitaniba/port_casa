import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/anomaly.dart';
import '../../providers/anomaly_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/anomaly_card.dart';
import 'anomaly_details.dart';
import 'anomalies_filter.dart';
import 'new_anomaly.dart';

class AnomaliesListScreen extends StatefulWidget {
  const AnomaliesListScreen({super.key});

  @override
  State<AnomaliesListScreen> createState() => _AnomaliesListScreenState();
}

class _AnomaliesListScreenState extends State<AnomaliesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  AnomalyStatus? _selectedStatus;
  AnomalyCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final provider = Provider.of<AnomalyProvider>(context, listen: false);
    
    // Update provider filters
    provider.setStatusFilter(_selectedStatus);
    provider.setCategoryFilter(_selectedCategory);
    provider.setSearchQuery(_searchController.text);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnomaliesFilterSheet(
        selectedStatus: _selectedStatus,
        selectedCategory: _selectedCategory,
        onApply: (status, category) {
          setState(() {
            _selectedStatus = status;
            _selectedCategory = category;
          });
          _applyFilters();
        },
        onClear: () {
          setState(() {
            _selectedStatus = null;
            _selectedCategory = null;
            _searchController.clear();
          });
          final provider = Provider.of<AnomalyProvider>(context, listen: false);
          provider.clearFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildStatusTabs(),
            Expanded(child: _buildAnomaliesList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewAnomalyScreen()),
          );
          // Refresh anomalies list when returning
          if (mounted) {
            Provider.of<AnomalyProvider>(context, listen: false).loadAnomalies();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Anomalies',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: (_selectedStatus != null || _selectedCategory != null)
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _showFilterSheet,
                  icon: Badge(
                    isLabelVisible: _selectedStatus != null || _selectedCategory != null,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: (_selectedStatus != null || _selectedCategory != null)
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
          child: TextField(
          controller: _searchController,
          onChanged: (value) {
            _applyFilters();
          },
          style: GoogleFonts.poppins(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Rechercher une anomalie...',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textLight,
              fontSize: 15,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textLight,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                    icon: const Icon(Icons.close_rounded, color: AppColors.textLight),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Consumer<AnomalyProvider>(
      builder: (context, provider, child) {
        // Get all anomalies (unfiltered) for counts
        final allAnomalies = provider.allAnomalies;
        final openCount = allAnomalies.where((a) => a.status == AnomalyStatus.ouvert).length;
        final inProgressCount = allAnomalies.where((a) => a.status == AnomalyStatus.enCours).length;
        final resolvedCount = allAnomalies.where((a) => a.status == AnomalyStatus.resolu).length;
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatusChip(
                  label: 'Tous',
                  count: allAnomalies.length,
                  isSelected: _selectedStatus == null,
                  onTap: () {
                    setState(() => _selectedStatus = null);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'Ouvert',
                  count: openCount,
                  isSelected: _selectedStatus == AnomalyStatus.ouvert,
                  color: AppColors.statusOpen,
                  onTap: () {
                    setState(() => _selectedStatus = AnomalyStatus.ouvert);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'En cours',
                  count: inProgressCount,
                  isSelected: _selectedStatus == AnomalyStatus.enCours,
                  color: AppColors.statusInProgress,
                  onTap: () {
                    setState(() => _selectedStatus = AnomalyStatus.enCours);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'Résolu',
                  count: resolvedCount,
                  isSelected: _selectedStatus == AnomalyStatus.resolu,
                  color: AppColors.statusResolved,
                  onTap: () {
                    setState(() => _selectedStatus = AnomalyStatus.resolu);
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnomaliesList() {
    return Consumer<AnomalyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final anomalies = provider.anomalies;
        final hasFilters = _selectedStatus != null || 
                          _selectedCategory != null || 
                          _searchController.text.isNotEmpty;

        if (anomalies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasFilters ? Icons.search_off_rounded : Icons.inbox_rounded,
                  size: 64,
                  color: AppColors.textLight.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  hasFilters ? 'Aucune anomalie trouvée' : 'Aucune anomalie',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (hasFilters)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedStatus = null;
                          _selectedCategory = null;
                          _searchController.clear();
                        });
                        provider.clearFilters();
                      },
                      child: Text(
                        'Réinitialiser les filtres',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            provider.loadAnomalies();
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: anomalies.length,
            itemBuilder: (context, index) {
              final anomaly = anomalies[index];
              return AnomalyCard(
                anomaly: anomaly,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnomalyDetailsScreen(anomaly: anomaly),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

