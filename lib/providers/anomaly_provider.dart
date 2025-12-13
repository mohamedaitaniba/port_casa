import 'package:flutter/material.dart';
import '../models/anomaly.dart';
import '../services/firebase_anomaly_service.dart';
import '../data/mock_data.dart';

class AnomalyProvider extends ChangeNotifier {
  final FirebaseAnomalyService _anomalyService = FirebaseAnomalyService();
  
  List<Anomaly> _anomalies = [];
  List<Anomaly> _filteredAnomalies = [];
  Anomaly? _selectedAnomaly;
  bool _isLoading = false;
  String? _error;
  bool _useMockData = false; // Use real Firebase data

  // Filters
  AnomalyStatus? _statusFilter;
  AnomalyCategory? _categoryFilter;
  AnomalyPriority? _priorityFilter;
  String _searchQuery = '';

  List<Anomaly> get anomalies => _filteredAnomalies.isEmpty && _searchQuery.isEmpty 
      ? _anomalies 
      : _filteredAnomalies;
  Anomaly? get selectedAnomaly => _selectedAnomaly;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AnomalyStatus? get statusFilter => _statusFilter;
  AnomalyCategory? get categoryFilter => _categoryFilter;
  AnomalyPriority? get priorityFilter => _priorityFilter;
  String get searchQuery => _searchQuery;

  AnomalyProvider() {
    loadAnomalies();
  }

  void loadAnomalies() {
    if (_useMockData) {
      _anomalies = MockData.anomalies;
      _applyFilters();
      notifyListeners();
    } else {
      _anomalyService.getAnomaliesStream().listen((anomalies) {
        _anomalies = anomalies;
        _applyFilters();
        notifyListeners();
      });
    }
  }

  void setUseMockData(bool value) {
    _useMockData = value;
    loadAnomalies();
  }

  void setStatusFilter(AnomalyStatus? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void setCategoryFilter(AnomalyCategory? category) {
    _categoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  void setPriorityFilter(AnomalyPriority? priority) {
    _priorityFilter = priority;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _categoryFilter = null;
    _priorityFilter = null;
    _searchQuery = '';
    _filteredAnomalies = [];
    notifyListeners();
  }

  void _applyFilters() {
    _filteredAnomalies = _anomalies.where((anomaly) {
      // Status filter
      if (_statusFilter != null && anomaly.status != _statusFilter) {
        return false;
      }

      // Category filter
      if (_categoryFilter != null && anomaly.category != _categoryFilter) {
        return false;
      }

      // Priority filter
      if (_priorityFilter != null && anomaly.priority != _priorityFilter) {
        return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return anomaly.title.toLowerCase().contains(query) ||
            anomaly.description.toLowerCase().contains(query) ||
            anomaly.location.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  void selectAnomaly(Anomaly anomaly) {
    _selectedAnomaly = anomaly;
    notifyListeners();
  }

  Future<void> createAnomaly(Anomaly anomaly) async {
    _setLoading(true);
    _clearError();

    try {
      if (_useMockData) {
        _anomalies.insert(0, anomaly);
        _applyFilters();
      } else {
        await _anomalyService.createAnomaly(anomaly);
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> updateAnomaly(String id, Anomaly updatedAnomaly) async {
    _setLoading(true);
    _clearError();

    try {
      if (_useMockData) {
        final index = _anomalies.indexWhere((a) => a.id == id);
        if (index != -1) {
          _anomalies[index] = updatedAnomaly;
          _applyFilters();
        }
      } else {
        await _anomalyService.updateAnomaly(id, updatedAnomaly.toFirestore());
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> updateAnomalyStatus(String id, AnomalyStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      if (_useMockData) {
        final index = _anomalies.indexWhere((a) => a.id == id);
        if (index != -1) {
          _anomalies[index] = _anomalies[index].copyWith(status: status);
          _applyFilters();
        }
      } else {
        await _anomalyService.updateAnomalyStatus(id, status);
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> deleteAnomaly(String id) async {
    _setLoading(true);
    _clearError();

    try {
      if (_useMockData) {
        _anomalies.removeWhere((a) => a.id == id);
        _applyFilters();
      } else {
        await _anomalyService.deleteAnomaly(id);
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
    notifyListeners();
  }

  // Statistics
  int get totalAnomalies => _anomalies.length;
  
  int get openAnomalies => 
      _anomalies.where((a) => a.status == AnomalyStatus.ouvert).length;
  
  int get inProgressAnomalies => 
      _anomalies.where((a) => a.status == AnomalyStatus.enCours).length;
  
  int get resolvedAnomalies => 
      _anomalies.where((a) => a.status == AnomalyStatus.resolu).length;

  int get highPriorityAnomalies =>
      _anomalies.where((a) => a.priority == AnomalyPriority.high).length;

  List<Anomaly> get highPriorityAlerts => _anomalies
      .where((a) => 
          a.priority == AnomalyPriority.high && 
          a.status != AnomalyStatus.resolu)
      .take(5)
      .toList();

  double get resolutionRate => totalAnomalies > 0 
      ? (resolvedAnomalies / totalAnomalies) * 100 
      : 0;

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String? value) {
    _error = value;
  }

  void _clearError() {
    _error = null;
  }
}

