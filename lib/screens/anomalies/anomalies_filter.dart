import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/anomaly.dart';
import '../../theme/app_theme.dart';

class AnomaliesFilterSheet extends StatefulWidget {
  final AnomalyStatus? selectedStatus;
  final AnomalyCategory? selectedCategory;
  final Function(AnomalyStatus?, AnomalyCategory?) onApply;
  final VoidCallback onClear;

  const AnomaliesFilterSheet({
    super.key,
    this.selectedStatus,
    this.selectedCategory,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<AnomaliesFilterSheet> createState() => _AnomaliesFilterSheetState();
}

class _AnomaliesFilterSheetState extends State<AnomaliesFilterSheet> {
  late AnomalyStatus? _selectedStatus;
  late AnomalyCategory? _selectedCategory;
  AnomalyPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.selectedStatus;
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtres',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = null;
                      _selectedCategory = null;
                      _selectedPriority = null;
                    });
                  },
                  child: Text(
                    'Réinitialiser',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status filter
                Text(
                  'Statut',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AnomalyStatus.values.map((status) {
                    final isSelected = _selectedStatus == status;
                    return _FilterChip(
                      label: status.labelFr,
                      isSelected: isSelected,
                      color: _getStatusColor(status),
                      onTap: () {
                        setState(() {
                          _selectedStatus = isSelected ? null : status;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Department filter
                Text(
                  'Département',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AnomalyCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return _FilterChip(
                      label: category.label,
                      isSelected: isSelected,
                      icon: _getCategoryIcon(category),
                      onTap: () {
                        setState(() {
                          _selectedCategory = isSelected ? null : category;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Priority filter
                Text(
                  'Priorité',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AnomalyPriority.values.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    return _FilterChip(
                      label: priority.labelFr,
                      isSelected: isSelected,
                      color: _getPriorityColor(priority),
                      onTap: () {
                        setState(() {
                          _selectedPriority = isSelected ? null : priority;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Text(
                      'Effacer',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_selectedStatus, _selectedCategory);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Appliquer',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Color _getStatusColor(AnomalyStatus status) {
    switch (status) {
      case AnomalyStatus.ouvert:
        return AppColors.statusOpen;
      case AnomalyStatus.enCours:
        return AppColors.statusInProgress;
      case AnomalyStatus.resolu:
        return AppColors.statusResolved;
    }
  }

  Color _getPriorityColor(AnomalyPriority priority) {
    switch (priority) {
      case AnomalyPriority.high:
        return AppColors.highPriority;
      case AnomalyPriority.medium:
        return AppColors.mediumPriority;
      case AnomalyPriority.low:
        return AppColors.lowPriority;
    }
  }

  IconData _getCategoryIcon(AnomalyCategory category) {
    switch (category) {
      case AnomalyCategory.mecanique:
        return Icons.build_rounded;
      case AnomalyCategory.electrique:
        return Icons.electric_bolt_rounded;
      case AnomalyCategory.vente:
        return Icons.shopping_cart_rounded;
      case AnomalyCategory.exploitation:
        return Icons.engineering_rounded;
      case AnomalyCategory.hse:
        return Icons.health_and_safety_rounded;
      case AnomalyCategory.bureauDeMethode:
        return Icons.assignment_rounded;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.15) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? chipColor : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? chipColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

