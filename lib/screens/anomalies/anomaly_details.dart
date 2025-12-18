import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/anomaly.dart';
import '../../models/comment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/anomaly_provider.dart';
import '../../services/comment_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/role_permissions.dart';
import '../../widgets/status_badge.dart';

class AnomalyDetailsScreen extends StatefulWidget {
  final Anomaly anomaly;

  const AnomalyDetailsScreen({
    super.key,
    required this.anomaly,
  });

  @override
  State<AnomalyDetailsScreen> createState() => _AnomalyDetailsScreenState();
}

class _AnomalyDetailsScreenState extends State<AnomalyDetailsScreen> {
  final _commentService = CommentService();
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildContent(context)),
          SliverToBoxAdapter(child: _buildCommentsSection()),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: widget.anomaly.photoUrl != null ? 250 : 120,
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
        background: widget.anomaly.photoUrl != null
            ? Image.network(
                widget.anomaly.photoUrl!,
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
              StatusBadge(status: widget.anomaly.status),
              const SizedBox(width: 8),
              PriorityBadge(priority: widget.anomaly.priority),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.anomaly.title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          CategoryBadge(category: widget.anomaly.category),
          const SizedBox(height: 24),
          
          // Info cards
          _buildInfoCard(
            icon: Icons.description_outlined,
            title: 'Description',
            content: widget.anomaly.description,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.location_on_outlined,
            title: 'Localisation',
            content: widget.anomaly.location,
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
                  value: DateFormat('dd/MM/yyyy').format(widget.anomaly.date),
                ),
              ),
              Expanded(
                child: _DetailItem(
                  icon: Icons.access_time_rounded,
                  label: 'Heure',
                  value: DateFormat('HH:mm').format(widget.anomaly.date),
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
                  value: widget.anomaly.createdBy,
                ),
              ),
              Expanded(
                child: _DetailItem(
                  icon: Icons.person_add_alt_rounded,
                  label: 'Assigné à',
                  value: widget.anomaly.assignedTo ?? 'Non assigné',
                ),
              ),
            ],
          ),
          if (widget.anomaly.department != null) ...[
            const SizedBox(height: 16),
            _DetailItem(
              icon: Icons.business_rounded,
              label: 'Département',
              value: widget.anomaly.department!,
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
            description: 'Créée par ${widget.anomaly.createdBy}',
            time: widget.anomaly.createdAt,
            isFirst: true,
            isLast: widget.anomaly.status == AnomalyStatus.ouvert,
          ),
          if (widget.anomaly.status != AnomalyStatus.ouvert)
            _TimelineItem(
              title: 'Prise en charge',
              description: 'Assignée à ${widget.anomaly.assignedTo ?? "l'équipe"}',
              time: widget.anomaly.createdAt.add(const Duration(hours: 2)),
              isLast: widget.anomaly.status == AnomalyStatus.enCours,
            ),
          if (widget.anomaly.status == AnomalyStatus.resolu)
            _TimelineItem(
              title: 'Anomalie résolue',
              description: 'Résolue avec succès',
              time: widget.anomaly.date,
              isLast: true,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.appUser?.role;
        final canChangeStatus = userRole != null &&
            RolePermissions.canChangeStatus(userRole, widget.anomaly.status);

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
              if (canChangeStatus && widget.anomaly.status != AnomalyStatus.resolu) ...[
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
                flex: canChangeStatus && widget.anomaly.status != AnomalyStatus.resolu ? 1 : 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showCommentDialog(context);
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
      },
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.appUser?.role;

    print('_showStatusChangeDialog - appUser: ${authProvider.appUser != null ? "exists" : "null"}');
    print('_showStatusChangeDialog - userRole: ${userRole?.value ?? "null"}');
    print('_showStatusChangeDialog - current anomaly status: ${widget.anomaly.status.labelFr}');

    if (userRole == null) {
      print('ERROR: User role is null!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur: Rôle utilisateur non trouvé. Veuillez vous déconnecter et vous reconnecter.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    final allowedStatuses = RolePermissions.getAllowedStatusTransitions(
      userRole,
      widget.anomaly.status,
    );

    // Filter out the current status from the options, unless it's the only option
    final displayStatuses = allowedStatuses.where((s) => s != widget.anomaly.status).toList();

    if (displayStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vous n\'avez pas la permission de changer ce statut',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

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
          children: displayStatuses.map((status) {
            return ListTile(
              leading: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
              ),
              title: Text(status.labelFr, style: GoogleFonts.poppins()),
              selected: widget.anomaly.status == status,
              onTap: () async {
                Navigator.pop(context);
                await _updateStatus(context, status);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, AnomalyStatus newStatus) async {
    if (!context.mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading indicator
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Mise à jour du statut...',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final anomalyProvider = Provider.of<AnomalyProvider>(context, listen: false);
      await anomalyProvider.updateAnomalyStatus(widget.anomaly.id, newStatus);

      if (!context.mounted) return;

      // Remove loading snackbar and show success
      scaffoldMessenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Statut mis à jour avec succès',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    } catch (e) {
      if (!context.mounted) return;

      // Remove loading snackbar and show error
      scaffoldMessenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Erreur lors de la mise à jour',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  e.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
    }
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

  void _showCommentDialog(BuildContext context) {
    _commentController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_comment_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Ajouter un commentaire',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: _commentController,
          maxLines: 5,
          style: GoogleFonts.poppins(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Écrivez votre commentaire...',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textLight,
              fontSize: 15,
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Veuillez entrer un commentaire',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final currentUser = authProvider.appUser;
                final createdBy = currentUser?.name ?? authProvider.firebaseUser?.email ?? 'Utilisateur';

                final comment = Comment(
                  id: '',
                  anomalyId: widget.anomaly.id,
                  text: _commentController.text.trim(),
                  createdBy: createdBy,
                  createdAt: DateTime.now(),
                );

                await _commentService.addComment(comment);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'Commentaire ajouté',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erreur: $e',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Publier',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return StreamBuilder<List<Comment>>(
      stream: _commentService.getCommentsStream(widget.anomaly.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Erreur lors du chargement des commentaires',
                style: GoogleFonts.poppins(color: AppColors.error),
              ),
            ),
          );
        }

        final comments = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commentaires',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (comments.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${comments.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (comments.isEmpty)
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
                          Icons.comment_outlined,
                          size: 48,
                          color: AppColors.textLight.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun commentaire',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Soyez le premier à commenter',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...comments.map((comment) => _CommentCard(
                  comment: comment,
                  commentService: _commentService,
                )),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }
}

class _CommentCard extends StatefulWidget {
  final Comment comment;
  final CommentService commentService;

  const _CommentCard({
    required this.comment,
    required this.commentService,
  });

  @override
  State<_CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<_CommentCard> {
  final _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editController.text = widget.comment.text;
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  bool _canEdit() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.appUser;
    final currentUserName = currentUser?.name ?? authProvider.firebaseUser?.email ?? '';
    
    // Check if comment belongs to current user (case-insensitive comparison)
    if (widget.comment.createdBy.toLowerCase().trim() != currentUserName.toLowerCase().trim()) {
      return false;
    }
    
    // Check if comment was posted within last 1 minute
    final now = DateTime.now();
    final diff = now.difference(widget.comment.createdAt);
    return diff.inMinutes < 1 || (diff.inMinutes == 1 && diff.inSeconds < 60);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'À l\'instant';
    } else if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays}j';
    } else {
      return DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(time);
    }
  }

  void _showEditDialog(BuildContext context) {
    _editController.text = widget.comment.text;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Modifier le commentaire',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: _editController,
          maxLines: 5,
          style: GoogleFonts.poppins(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Écrivez votre commentaire...',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textLight,
              fontSize: 15,
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_editController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Le commentaire ne peut pas être vide',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                await widget.commentService.updateComment(
                  widget.comment.id,
                  _editController.text.trim(),
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'Commentaire modifié',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erreur: $e',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Enregistrer',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _canEdit();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    widget.comment.createdBy.isNotEmpty
                        ? widget.comment.createdBy[0].toUpperCase()
                        : 'U',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.comment.createdBy,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatTime(widget.comment.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (canEdit)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showEditDialog(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.comment.text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
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

