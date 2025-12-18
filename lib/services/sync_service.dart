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
    if (_isSyncing) {
      print('Sync already in progress, skipping...');
      return;
    }
    
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      print('No connection, cannot sync');
      return;
    }

    _isSyncing = true;
    print('Starting sync of pending anomalies...');

    try {
      final pending = await _offlineStorage.getPendingAnomalies();
      print('Found ${pending.length} pending anomalies to sync');
      
      int successCount = 0;
      int errorCount = 0;
      
      for (var item in pending) {
        try {
          // Parse anomaly data
          final data = item['data'] as String;
          final imagePath = item['image_path'] as String?;
          final anomalyId = item['id'] as String;

          print('Syncing anomaly: $anomalyId');
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
              print('Uploading image for anomaly $anomalyId');
              final xFile = XFile(imagePath);
              photoUrl = await _storageService.uploadImage(xFile, folder: 'anomalies');
              print('Image uploaded successfully: $photoUrl');
              // Delete local image after upload
              await File(imagePath).delete();
            } catch (e) {
              print('Error uploading image for anomaly $anomalyId: $e');
              // Continue without image
            }
          }

          // Create anomaly in Firebase
          print('Creating anomaly in Firebase: $anomalyId');
          final updatedAnomaly = anomaly.copyWith(photoUrl: photoUrl);
          await _firebaseService.createAnomaly(updatedAnomaly);
          print('Anomaly created successfully in Firebase');

          // Mark as synced
          await _offlineStorage.markAsSynced(anomalyId);
          print('Anomaly $anomalyId marked as synced');
          successCount++;
        } catch (e) {
          errorCount++;
          print('Error syncing anomaly ${item['id']}: $e');
          print('Stack trace: ${StackTrace.current}');
          // Continue with next anomaly
        }
      }

      print('Sync completed: $successCount succeeded, $errorCount failed');

      // Clean up synced anomalies
      await _offlineStorage.deleteSyncedAnomalies();
      print('Cleaned up synced anomalies');
    } catch (e) {
      print('Fatal error during sync: $e');
      print('Stack trace: ${StackTrace.current}');
    } finally {
      _isSyncing = false;
      print('Sync finished');
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


