import '../models/user.dart';
import '../models/anomaly.dart';

/// Role-based permission utilities
class RolePermissions {
  /// Check if a user can create anomalies
  static bool canCreateAnomaly(UserRole role) {
    // All roles can create anomalies
    return true;
  }

  /// Check if a user can change status from "ouvert" to "en cours"
  static bool canChangeToEnCours(UserRole role, AnomalyStatus currentStatus) {
    if (currentStatus != AnomalyStatus.ouvert) {
      return false;
    }
    // Only manager can change from "ouvert" to "en cours"
    return role == UserRole.manager;
  }

  /// Check if a user can change status from "en cours" to "resolu"
  static bool canChangeToResolu(UserRole role, AnomalyStatus currentStatus) {
    if (currentStatus != AnomalyStatus.enCours) {
      return false;
    }
    // Only technicien can change from "en cours" to "resolu"
    return role == UserRole.technicien;
  }

  /// Get allowed status transitions for a user role
  static List<AnomalyStatus> getAllowedStatusTransitions(
    UserRole role,
    AnomalyStatus currentStatus,
  ) {
    final allowed = <AnomalyStatus>[];

    // Always allow current status (no change)
    allowed.add(currentStatus);

    switch (role) {
      case UserRole.manager:
        // Manager can change "ouvert" -> "en cours"
        if (currentStatus == AnomalyStatus.ouvert) {
          allowed.add(AnomalyStatus.enCours);
        }
        break;
      case UserRole.technicien:
        // Technicien can change "en cours" -> "resolu"
        if (currentStatus == AnomalyStatus.enCours) {
          allowed.add(AnomalyStatus.resolu);
        }
        break;
      case UserRole.inspecteur:
        // Inspecteur cannot change status
        break;
    }

    return allowed;
  }

  /// Check if a user can change the status of an anomaly
  static bool canChangeStatus(UserRole role, AnomalyStatus currentStatus) {
    return canChangeToEnCours(role, currentStatus) ||
        canChangeToResolu(role, currentStatus);
  }
}

