import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../theme/app_theme.dart';
import '../anomalies/anomaly_details.dart';
import '../../services/firebase_anomaly_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final FirebaseAnomalyService _anomalyService = FirebaseAnomalyService();
  bool _showUnreadOnly = false;

  void _markAllAsRead() async {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;
    
    if (userId == null) return;

    try {
      await _notificationService.markAllAsRead(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Toutes les notifications marquées comme lues',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<app_auth.AuthProvider>(
      builder: (context, authProvider, child) {
        final userId = authProvider.firebaseUser?.uid;
        
        if (userId == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'Veuillez vous connecter',
                style: GoogleFonts.poppins(),
              ),
            ),
          );
        }

        return StreamBuilder<List<AppNotification>>(
          stream: _notificationService.getNotificationsStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: Text(
                    'Erreur: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: AppColors.error),
                  ),
                ),
              );
            }

            final allNotifications = snapshot.data ?? [];
            final displayedNotifications = _showUnreadOnly
                ? allNotifications.where((n) => !n.isRead).toList()
                : allNotifications;
            final unreadCount = allNotifications.where((n) => !n.isRead).length;

            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(unreadCount),
                    _buildFilterTabs(),
                    Expanded(
                      child: displayedNotifications.isEmpty
                          ? _buildEmptyState()
                          : _buildNotificationsList(displayedNotifications),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(int unreadCount) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alertes',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (unreadCount > 0)
                Text(
                  '$unreadCount non lues',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: Text(
                'Tout marquer lu',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterTab(
            label: 'Toutes',
            isSelected: !_showUnreadOnly,
            onTap: () => setState(() => _showUnreadOnly = false),
          ),
          const SizedBox(width: 8),
          _FilterTab(
            label: 'Non lues',
            isSelected: _showUnreadOnly,
            onTap: () => setState(() => _showUnreadOnly = true),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _showUnreadOnly ? 'Aucune notification non lue' : 'Aucune notification',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous êtes à jour !',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    // Group notifications by date
    final grouped = <String, List<AppNotification>>{};
    for (var notification in notifications) {
      final dateKey = _getDateKey(notification.date);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(notification);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.toList()[index];
        final items = grouped[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                dateKey,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ...items.map((notification) => _NotificationCard(
              notification: notification,
              onTap: () async {
                // Mark as read
                if (!notification.isRead) {
                  await _notificationService.markAsRead(notification.id);
                }
                
                // Navigate to anomaly details if anomalyId exists
                if (notification.anomalyId != null) {
                  try {
                    final anomaly = await _anomalyService.getAnomaly(notification.anomalyId!);
                    if (anomaly != null && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnomalyDetailsScreen(anomaly: anomaly),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erreur lors du chargement de l\'anomalie: $e',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                }
              },
              onDismiss: () async {
                try {
                  await _notificationService.deleteNotification(notification.id);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erreur lors de la suppression: $e',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            )),
          ],
        );
      },
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return "Aujourd'hui";
    } else if (notificationDate == yesterday) {
      return 'Hier';
    } else {
      return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
    }
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.newAnomaly:
        return AppColors.info;
      case NotificationType.assign:
        return AppColors.warning;
      case NotificationType.resolved:
        return AppColors.success;
      case NotificationType.update:
        return AppColors.secondary;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.newAnomaly:
        return Icons.add_alert_rounded;
      case NotificationType.assign:
        return Icons.person_add_alt_rounded;
      case NotificationType.resolved:
        return Icons.check_circle_rounded;
      case NotificationType.update:
        return Icons.update_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else {
      return DateFormat('HH:mm').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor();
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Colors.white 
                : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: notification.isRead
                ? null
                : Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            notification.type.label,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(notification.date),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

