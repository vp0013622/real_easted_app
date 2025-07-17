import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:inhabit_realties/models/lead/LeadStatusModel.dart';
import 'package:inhabit_realties/models/lead/FollowUpStatusModel.dart';
import 'package:inhabit_realties/models/lead/ReferenceSourceModel.dart';
import 'package:inhabit_realties/services/lead/leadsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeadsController extends ChangeNotifier {
  final LeadsService _leadsService = LeadsService();

  // State variables
  bool _isLoading = false;
  String _errorMessage = '';
  List<LeadsModel> _leads = [];
  List<LeadStatusModel> _leadStatuses = [];
  List<FollowUpStatusModel> _followUpStatuses = [];
  List<ReferenceSourceModel> _referenceSources = [];

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<LeadsModel> get leads => _leads;
  List<LeadStatusModel> get leadStatuses => _leadStatuses;
  List<FollowUpStatusModel> get followUpStatuses => _followUpStatuses;
  List<ReferenceSourceModel> get referenceSources => _referenceSources;

  // Helper method to get current user
  Future<Map<String, dynamic>> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('currentUser') ?? "";
    return jsonDecode(currentUser);
  }

  // Helper method to get token
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? "";
  }

  // Load all leads
  Future<void> loadLeads() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _getToken();
      final currentUser = await _getCurrentUser();
      final userId = currentUser['_id'] ?? '';
      final result = await _leadsService.getAllLeads(token, userId);

      if (result['statusCode'] == 200) {
        final data = result['data'];
        List<dynamic> leadsData = [];

        if (data is Map && data.containsKey('value')) {
          leadsData = data['value'] ?? [];
        } else if (data is List) {
          leadsData = data;
        } else {
          leadsData = [];
        }

        _leads.clear();
        for (final json in leadsData) {
          try {
            final lead = LeadsModel.fromJson(json);
            _leads.add(lead);
          } catch (error) {
            // Skip invalid lead data
            continue;
          }
        }
      } else {
        _errorMessage = result['message'] ?? 'Failed to load leads';
      }
    } catch (error) {
      _errorMessage = 'Exception occurred while loading leads';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load leads with parameters
  Future<void> loadLeadsWithParams(Map<String, dynamic> params) async {
    _setLoading(true);
    _clearError();

    try {
      final token = await _getToken();
      final currentUser = await _getCurrentUser();
      final userId = currentUser['_id'] ?? '';

      final result =
          await _leadsService.getAllLeadsWithParams(token, userId, params);

      if (result['statusCode'] == 200) {
        // Handle nested data structure: result -> data -> value -> [array]
        dynamic data = result['data'];
        List<dynamic> leadsData = [];

        // If data is a Map and contains 'value' key
        if (data is Map && data.containsKey('value')) {
          leadsData = data['value'] ?? [];
        }
        // If data is directly an array
        else if (data is List) {
          leadsData = data;
        }
        // If data is null or empty, use empty array
        else {
          leadsData = [];
        }

        _leads = leadsData
            .map((json) {
              try {
                return LeadsModel.fromJson(json);
              } catch (error) {
                // Skip invalid lead data
                return null;
              }
            })
            .where((lead) => lead != null)
            .cast<LeadsModel>()
            .toList();
      } else {
        _setError(result['message'] ?? 'Failed to load leads');
      }
    } catch (error) {
      _setError('Error loading leads: $error');
    } finally {
      _setLoading(false);
    }
  }

  // Create new lead
  Future<bool> createLead(LeadsModel lead) async {
    _setLoading(true);
    _clearError();

    try {
      final token = await _getToken();

      final result = await _leadsService.createLead(token, lead);

      if (result['statusCode'] == 200) {
        await loadLeads(); // Refresh the list
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to create lead');
        return false;
      }
    } catch (error) {
      _setError('Error creating lead: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Edit lead
  Future<bool> editLead(LeadsModel lead) async {
    _setLoading(true);
    _clearError();

    try {
      final token = await _getToken();
      final result = await _leadsService.editLead(token, lead);

      if (result['statusCode'] == 200) {
        await loadLeads(); // Refresh the list
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to edit lead');
        return false;
      }
    } catch (error) {
      _setError('Error editing lead: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete lead
  Future<bool> deleteLead(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final token = await _getToken();
      final result = await _leadsService.deleteLead(token, id);

      if (result['statusCode'] == 200) {
        await loadLeads(); // Refresh the list
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to delete lead');
        return false;
      }
    } catch (error) {
      _setError('Error deleting lead: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load lead statuses
  Future<void> loadLeadStatuses() async {
    _setLoading(true);
    _clearError();

    try {
      final token = await _getToken();
      final currentUser = await _getCurrentUser();
      final userId = currentUser['_id'] ?? '';

      final result = await _leadsService.getAllLeadStatuses(token, userId);

      if (result['statusCode'] == 200) {
        final List<dynamic> statusesData = result['data'] ?? [];
        _leadStatuses =
            statusesData.map((json) => LeadStatusModel.fromJson(json)).toList();
      } else {
        _setError(result['message'] ?? 'Failed to load lead statuses');
      }
    } catch (error) {
      _setError('Error loading lead statuses: $error');
    } finally {
      _setLoading(false);
    }
  }

  // Load follow-up statuses
  Future<void> loadFollowUpStatuses() async {
    _setLoading(true);
    _clearError();

    try {
      final token = await _getToken();
      final currentUser = await _getCurrentUser();
      final userId = currentUser['_id'] ?? '';

      final result = await _leadsService.getAllFollowUpStatuses(token, userId);

      if (result['statusCode'] == 200) {
        final List<dynamic> statusesData = result['data'] ?? [];
        _followUpStatuses = statusesData
            .map((json) => FollowUpStatusModel.fromJson(json))
            .toList();
      } else {
        _setError(result['message'] ?? 'Failed to load follow-up statuses');
      }
    } catch (error) {
      _setError('Error loading follow-up statuses: $error');
    } finally {
      _setLoading(false);
    }
  }

  // Load reference sources
  Future<void> loadReferenceSources() async {
    _setLoading(true);
    _clearError();

    try {
      final token = await _getToken();
      final currentUser = await _getCurrentUser();
      final userId = currentUser['_id'] ?? '';

      final result = await _leadsService.getAllReferenceSources(token, userId);

      if (result['statusCode'] == 200) {
        final List<dynamic> sourcesData = result['data'] ?? [];
        _referenceSources = sourcesData
            .map((json) => ReferenceSourceModel.fromJson(json))
            .toList();
      } else {
        _setError(result['message'] ?? 'Failed to load reference sources');
      }
    } catch (error) {
      _setError('Error loading reference sources: $error');
    } finally {
      _setLoading(false);
    }
  }

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadLeads(),
      loadLeadStatuses(),
      loadFollowUpStatuses(),
      loadReferenceSources(),
    ]);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _leads = [];
    _leadStatuses = [];
    _followUpStatuses = [];
    _referenceSources = [];
    _errorMessage = '';
    notifyListeners();
  }
}
