import '../models/anomaly.dart';
import '../models/notification.dart';

class MockData {
  // 10 anomalies diverses
  static List<Anomaly> get anomalies => [
    Anomaly(
      id: '1',
      title: 'Fuite hydraulique sur grue #12',
      description: 'Fuite d\'huile détectée au niveau du vérin principal de la grue portuaire n°12. Intervention urgente requise pour éviter tout risque de contamination.',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      location: 'Quai Nord - Terminal A',
      category: AnomalyCategory.mecanique,
      priority: AnomalyPriority.high,
      status: AnomalyStatus.ouvert,
      assignedTo: 'Ahmed Benali',
      createdBy: 'Mohamed Tazi',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      department: 'Maintenance',
      photoUrl: null,
    ),
    Anomaly(
      id: '2',
      title: 'Défaillance éclairage zone B',
      description: 'Plusieurs lampadaires défaillants dans la zone de stockage B. Problème de sécurité pour les opérations nocturnes.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      location: 'Zone de stockage B',
      category: AnomalyCategory.electrique,
      priority: AnomalyPriority.medium,
      status: AnomalyStatus.enCours,
      assignedTo: 'Karim Oufkir',
      createdBy: 'Hassan Alami',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      department: 'Électricité',
      photoUrl: null,
    ),
    Anomaly(
      id: '3',
      title: 'Non-conformité EPI secteur C',
      description: 'Plusieurs employés observés sans casque de sécurité dans le secteur C. Formation de rappel nécessaire.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      location: 'Secteur C - Manutention',
      category: AnomalyCategory.hse,
      priority: AnomalyPriority.high,
      status: AnomalyStatus.resolu,
      assignedTo: 'Fatima Zahra',
      createdBy: 'Omar Benjelloun',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      department: 'HSE',
      photoUrl: null,
    ),
    Anomaly(
      id: '4',
      title: 'Fissure sur dalle béton',
      description: 'Fissure importante détectée sur la dalle de la zone de transit. Risque d\'aggravation avec le passage des engins.',
      date: DateTime.now().subtract(const Duration(days: 3)),
      location: 'Zone de transit principale',
      category: AnomalyCategory.exploitation,
      priority: AnomalyPriority.medium,
      status: AnomalyStatus.ouvert,
      assignedTo: 'Youssef Chakir',
      createdBy: 'Rachid Mouhcine',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      department: 'Infrastructure',
      photoUrl: null,
    ),
    Anomaly(
      id: '5',
      title: 'Caméra surveillance HS',
      description: 'Caméra de surveillance n°7 hors service depuis 48h. Zone non couverte près de l\'entrée principale.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      location: 'Entrée principale',
      category: AnomalyCategory.hse,
      priority: AnomalyPriority.high,
      status: AnomalyStatus.enCours,
      assignedTo: 'Nabil Amrani',
      createdBy: 'Said Lahlou',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      department: 'Sécurité',
      photoUrl: null,
    ),
    Anomaly(
      id: '6',
      title: 'Déversement huile moteur',
      description: 'Déversement accidentel d\'huile moteur détecté près du parking engins. Nettoyage et confinement requis.',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      location: 'Parking engins - Zone D',
      category: AnomalyCategory.hse,
      priority: AnomalyPriority.high,
      status: AnomalyStatus.enCours,
      assignedTo: 'Leila Benchekroun',
      createdBy: 'Mehdi Tahiri',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      department: 'Environnement',
      photoUrl: null,
    ),
    Anomaly(
      id: '7',
      title: 'Usure chaînes portique',
      description: 'Usure anormale constatée sur les chaînes du portique n°3. Remplacement préventif recommandé.',
      date: DateTime.now().subtract(const Duration(days: 4)),
      location: 'Terminal conteneurs - Portique 3',
      category: AnomalyCategory.mecanique,
      priority: AnomalyPriority.medium,
      status: AnomalyStatus.resolu,
      assignedTo: 'Ahmed Benali',
      createdBy: 'Khalid Fassi',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      department: 'Maintenance',
      photoUrl: null,
    ),
    Anomaly(
      id: '8',
      title: 'Court-circuit armoire E4',
      description: 'Court-circuit détecté dans l\'armoire électrique E4. Coupure préventive effectuée.',
      date: DateTime.now().subtract(const Duration(hours: 8)),
      location: 'Local technique Est',
      category: AnomalyCategory.electrique,
      priority: AnomalyPriority.high,
      status: AnomalyStatus.ouvert,
      assignedTo: 'Karim Oufkir',
      createdBy: 'Amine Belkadi',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      department: 'Électricité',
      photoUrl: null,
    ),
    Anomaly(
      id: '9',
      title: 'Signalisation effacée',
      description: 'Marquage au sol effacé sur les voies de circulation principale. Risque de collision.',
      date: DateTime.now().subtract(const Duration(days: 5)),
      location: 'Voies de circulation - Zone A',
      category: AnomalyCategory.exploitation,
      priority: AnomalyPriority.low,
      status: AnomalyStatus.resolu,
      assignedTo: 'Youssef Chakir',
      createdBy: 'Hamza Kettani',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      department: 'Infrastructure',
      photoUrl: null,
    ),
    Anomaly(
      id: '10',
      title: 'Extincteur périmé hangar 2',
      description: 'Extincteur n°15 du hangar 2 a dépassé sa date de contrôle. Remplacement immédiat requis.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      location: 'Hangar 2 - Zone stockage',
      category: AnomalyCategory.hse,
      priority: AnomalyPriority.medium,
      status: AnomalyStatus.enCours,
      assignedTo: 'Fatima Zahra',
      createdBy: 'Driss Chraibi',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      department: 'HSE',
      photoUrl: null,
    ),
  ];

  // 6 départements
  static List<Department> get departments => [
    Department(
      id: '1',
      name: 'Maintenance',
      totalAnomalies: 24,
      resolvedAnomalies: 18,
      openAnomalies: 4,
      inProgressAnomalies: 2,
      icon: 'build',
    ),
    Department(
      id: '2',
      name: 'Électricité',
      totalAnomalies: 15,
      resolvedAnomalies: 10,
      openAnomalies: 3,
      inProgressAnomalies: 2,
      icon: 'electric_bolt',
    ),
    Department(
      id: '3',
      name: 'HSE',
      totalAnomalies: 32,
      resolvedAnomalies: 28,
      openAnomalies: 2,
      inProgressAnomalies: 2,
      icon: 'health_and_safety',
    ),
    Department(
      id: '4',
      name: 'Infrastructure',
      totalAnomalies: 18,
      resolvedAnomalies: 12,
      openAnomalies: 4,
      inProgressAnomalies: 2,
      icon: 'foundation',
    ),
    Department(
      id: '5',
      name: 'Sécurité',
      totalAnomalies: 21,
      resolvedAnomalies: 17,
      openAnomalies: 2,
      inProgressAnomalies: 2,
      icon: 'security',
    ),
    Department(
      id: '6',
      name: 'Environnement',
      totalAnomalies: 12,
      resolvedAnomalies: 9,
      openAnomalies: 1,
      inProgressAnomalies: 2,
      icon: 'eco',
    ),
  ];

  // Statistiques
  static DashboardStats get stats => DashboardStats(
    totalAnomalies: 122,
    openAnomalies: 16,
    inProgressAnomalies: 12,
    resolvedAnomalies: 94,
    highPriority: 23,
    mediumPriority: 54,
    lowPriority: 45,
    resolutionRate: 77.0,
  );

  // Données mensuelles pour graphique
  static List<MonthlyData> get monthlyData => [
    MonthlyData(month: 'Jan', total: 15, resolved: 12),
    MonthlyData(month: 'Fév', total: 18, resolved: 15),
    MonthlyData(month: 'Mar', total: 22, resolved: 18),
    MonthlyData(month: 'Avr', total: 20, resolved: 17),
    MonthlyData(month: 'Mai', total: 25, resolved: 21),
    MonthlyData(month: 'Juin', total: 22, resolved: 19),
  ];

  // Notifications
  static List<AppNotification> get notifications => [
    AppNotification(
      id: '1',
      title: 'Nouvelle anomalie signalée',
      description: 'Fuite hydraulique sur grue #12 - Priorité haute',
      type: NotificationType.newAnomaly,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      userId: 'mock_user_1',
      anomalyId: '1',
    ),
    AppNotification(
      id: '2',
      title: 'Anomalie assignée',
      description: 'Vous avez été assigné à: Défaillance éclairage zone B',
      type: NotificationType.assign,
      date: DateTime.now().subtract(const Duration(days: 1)),
      userId: 'mock_user_1',
      anomalyId: '2',
    ),
    AppNotification(
      id: '3',
      title: 'Anomalie résolue',
      description: 'Non-conformité EPI secteur C a été marquée comme résolue',
      type: NotificationType.resolved,
      date: DateTime.now().subtract(const Duration(days: 2)),
      userId: 'mock_user_1',
      anomalyId: '3',
      isRead: true,
    ),
    AppNotification(
      id: '4',
      title: 'Mise à jour statut',
      description: 'Caméra surveillance HS - Statut changé en "En cours"',
      type: NotificationType.update,
      date: DateTime.now().subtract(const Duration(days: 1)),
      userId: 'mock_user_1',
      anomalyId: '5',
    ),
    AppNotification(
      id: '5',
      title: 'Alerte haute priorité',
      description: 'Déversement huile moteur requiert attention immédiate',
      type: NotificationType.newAnomaly,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      userId: 'mock_user_1',
      anomalyId: '6',
    ),
  ];

  // Activités récentes
  static List<RecentActivity> get recentActivities => [
    RecentActivity(
      id: '1',
      action: 'Nouvelle anomalie créée',
      description: 'Fuite hydraulique sur grue #12',
      user: 'Mohamed Tazi',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: ActivityType.created,
    ),
    RecentActivity(
      id: '2',
      action: 'Statut mis à jour',
      description: 'Défaillance éclairage zone B → En cours',
      user: 'Karim Oufkir',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      type: ActivityType.updated,
    ),
    RecentActivity(
      id: '3',
      action: 'Anomalie résolue',
      description: 'Non-conformité EPI secteur C',
      user: 'Fatima Zahra',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      type: ActivityType.resolved,
    ),
    RecentActivity(
      id: '4',
      action: 'Assignation',
      description: 'Caméra surveillance HS → Nabil Amrani',
      user: 'Admin',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      type: ActivityType.assigned,
    ),
  ];
}

// Classes auxiliaires
class Department {
  final String id;
  final String name;
  final int totalAnomalies;
  final int resolvedAnomalies;
  final int openAnomalies;
  final int inProgressAnomalies;
  final String icon;

  Department({
    required this.id,
    required this.name,
    required this.totalAnomalies,
    required this.resolvedAnomalies,
    required this.openAnomalies,
    required this.inProgressAnomalies,
    required this.icon,
  });

  double get resolutionRate => 
    totalAnomalies > 0 ? (resolvedAnomalies / totalAnomalies) * 100 : 0;
}

class DashboardStats {
  final int totalAnomalies;
  final int openAnomalies;
  final int inProgressAnomalies;
  final int resolvedAnomalies;
  final int highPriority;
  final int mediumPriority;
  final int lowPriority;
  final double resolutionRate;

  DashboardStats({
    required this.totalAnomalies,
    required this.openAnomalies,
    required this.inProgressAnomalies,
    required this.resolvedAnomalies,
    required this.highPriority,
    required this.mediumPriority,
    required this.lowPriority,
    required this.resolutionRate,
  });
}

class MonthlyData {
  final String month;
  final int total;
  final int resolved;

  MonthlyData({
    required this.month,
    required this.total,
    required this.resolved,
  });
}

enum ActivityType { created, updated, resolved, assigned }

class RecentActivity {
  final String id;
  final String action;
  final String description;
  final String user;
  final DateTime timestamp;
  final ActivityType type;

  RecentActivity({
    required this.id,
    required this.action,
    required this.description,
    required this.user,
    required this.timestamp,
    required this.type,
  });
}

