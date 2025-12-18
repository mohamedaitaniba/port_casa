import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/anomaly.dart';
import 'offline_storage_service.dart';
import 'firebase_storage_service.dart';
import 'firebase_anomaly_service.dart';
import 'connectivity_service.dart';

class SyncService {
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final FirebaseAnomalyService _firebaseService = FirebaseAnomalyService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final ConnectivityService _connectivity = ConnectivityService();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // Sync all pending anomalies
  Future<void> syncPendingAnomalies() async {
    if (_isSyncing) return;
    
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) return;

    _isSyncing = true;

    try {
      final pending = await _offlineStorage.getPendingAnomalies();
      
      for (var item in pending) {
        try {
          // Parse anomaly data
          final data = item['data'] as String;
          final imagePath = item['image_path'] as String?;
          final anomalyId = item['id'] as String;

          final anomalyData = Map<String, dynamic>.from(jsonDecode(data));

          // Reconstruct anomaly
          final anomaly = Anomaly(
            id: anomalyId,
            title: anomalyData['title'],
            description: anomalyData['description'],
            date: DateTime.parse(anomalyData['date']),
            location: anomalyData['location'],
            category: AnomalyCategory.fromString(anomalyData['category']),
            priority: AnomalyPriority.fromString(anomalyData['priority']),
            status: AnomalyStatus.fromString(anomalyData['status']),
            createdBy: anomalyData['createdBy'],
            createdAt: DateTime.parse(anomalyData['createdAt']),
            department: anomalyData['department'],
          );

          // Upload image if exists
          String? photoUrl;
          if (imagePath != null && File(imagePath).existsSync()) {
            try {
              final xFile = XFile(imagePath);
              photoUrl = await _storageService.uploadImage(xFile, folder: 'anomalies');
              // Delete local image after upload
              await File(imagePath).delete();
            } catch (e) {
              print('Error uploading image: $e');
            }
          }

          // Create anomaly in Firebase
          final updatedAnomaly = anomaly.copyWith(photoUrl: photoUrl);
          await _firebaseService.createAnomaly(updatedAnomaly);

          // Mark as synced
          await _offlineStorage.markAsSynced(anomalyId);
        } catch (e) {
          print('Error syncing anomaly ${item['id']}: $e');
          // Continue with next anomaly
        }
      }

      // Clean up synced anomalies
      await _offlineStorage.deleteSyncedAnomalies();
    } finally {
      _isSyncing = false;
    }
  }

  // Auto-sync when connection is restored
  void startAutoSync() {
    _connectivity.connectionStream.listen((isConnected) {
      if (isConnected) {
        syncPendingAnomalies();
      }
    });
  }
}


