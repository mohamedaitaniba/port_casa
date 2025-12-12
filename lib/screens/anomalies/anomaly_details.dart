import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/anomaly.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class AnomalyDetailsScreen extends StatelessWidget {
  final Anomaly anomaly;

  const AnomalyDetailsScreen({
    super.key,
    required this.anomaly,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildContent(context)),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: anomaly.photoUrl != null ? 250 : 120,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Edit anomaly
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit_rounded, color: Colors.white),
          ),
        ),
        IconButton(
          onPressed: () {
            _showOptionsMenu(context);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.more_vert_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: anomaly.photoUrl != null
            ? Image.network(
                anomaly.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primary,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_rounded, 
                        color: Colors.white54, size: 48),
                  ),
                ),
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and badges
          Row(
            children: [
              StatusBadge(status: anomaly.status),
              const SizedBox(width: 8),
              PriorityBadge(priority: anomaly.priority),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            anomaly.title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          CategoryBadge(category: anomaly.category),
          const SizedBox(height: 24),
          
          // Info cards
          _buildInfoCard(
            icon: Icons.description_outlined,
            title: 'Description',
            content: anomaly.description,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.location_on_outlined,
            title: 'Localisation',
            content: anomaly.location,
          ),
          const SizedBox(height: 16),
          
          // Details grid
          _buildDetailsGrid(),
          const SizedBox(height: 24),
          
          // Timeline / History
          _buildHistorySection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: DateFormat('dd/MM/yyyy').format(anomaly.date),
                ),
              ),
              Expanded(
                child: _DetailItem(
                  icon: Icons.access_time_rounded,
                  label: 'Heure',
                  value: DateFormat('HH:mm').format(anomaly.date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Créé par',
                  value: anomaly.createdBy,
                ),
              ),
              Expanded(
                child: _DetailItem(
                  icon: Icons.person_add_alt_rounded,
                  label: 'Assigné à',
                  value: anomaly.assignedTo ?? 'Non assigné',
                ),
              ),
            ],
          ),
          if (anomaly.department != null) ...[
            const SizedBox(height: 16),
            _DetailItem(
              icon: Icons.business_rounded,
              label: 'Département',
              value: anomaly.department!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historique',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TimelineItem(
            title: 'Anomalie créée',
            description: 'Créée par ${anomaly.createdBy}',
            time: anomaly.createdAt,
            isFirst: true,
            isLast: anomaly.status == AnomalyStatus.ouvert,
          ),
          if (anomaly.status != AnomalyStatus.ouvert)
            _TimelineItem(
              title: 'Prise en charge',
              description: 'Assignée à ${anomaly.assignedTo ?? "l\'équipe"}',
              time: anomaly.createdAt.add(const Duration(hours: 2)),
              isLast: anomaly.status == AnomalyStatus.enCours,
            ),
          if (anomaly.status == AnomalyStatus.resolu)
            _TimelineItem(
              title: 'Anomalie résolue',
              description: 'Résolue avec succès',
              time: anomaly.date,
              isLast: true,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (anomaly.status != AnomalyStatus.resolu) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _showStatusChangeDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.update_rounded),
                label: Text(
                  'Changer statut',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: anomaly.status != AnomalyStatus.resolu ? 1 : 2,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Add comment
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
              label: Text(
                'Commentaire',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: Text('Partager', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.print_rounded),
              title: Text('Imprimer', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: AppColors.error),
              title: Text('Supprimer', 
                  style: GoogleFonts.poppins(color: AppColors.error)),
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showStatusChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Changer le statut',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AnomalyStatus.values.map((status) {
            return ListTile(
              leading: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
              ),
              title: Text(status.labelFr, style: GoogleFonts.poppins()),
              selected: anomaly.status == status,
              onTap: () {
                Navigator.pop(context);
                // TODO: Update status
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getStatusIcon(AnomalyStatus status) {
    switch (status) {
      case AnomalyStatus.ouvert:
        return Icons.error_outline_rounded;
      case AnomalyStatus.enCours:
        return Icons.pending_rounded;
      case AnomalyStatus.resolu:
        return Icons.check_circle_outline_rounded;
    }
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
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String description;
  final DateTime time;
  final bool isFirst;
  final bool isLast;
  final Color? color;

  const _TimelineItem({
    required this.title,
    required this.description,
    required this.time,
    this.isFirst = false,
    this.isLast = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.primary;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: itemColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy à HH:mm').format(time),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

