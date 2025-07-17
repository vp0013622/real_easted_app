import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:inhabit_realties/models/lead/LeadStatusModel.dart';
import 'package:inhabit_realties/models/lead/FollowUpStatusModel.dart';
import 'package:inhabit_realties/models/lead/ReferenceSourceModel.dart';

abstract class LeadsInterface {
  // Lead CRUD operations
  Future<Map<String, dynamic>> getAllLeads(String token, String userId);
  Future<Map<String, dynamic>> getAllLeadsWithParams(
      String token, String userId, Map<String, dynamic> params);
  Future<Map<String, dynamic>> getAssignedLeadsForCurrentUser(String token);
  Future<Map<String, dynamic>> getLeadById(String token, String id);
  Future<Map<String, dynamic>> createLead(String token, LeadsModel lead);
  Future<Map<String, dynamic>> editLead(String token, LeadsModel lead);
  Future<Map<String, dynamic>> deleteLead(String token, String id);

  // Lead Status operations
  Future<Map<String, dynamic>> getAllLeadStatuses(String token, String userId);
  Future<Map<String, dynamic>> getLeadStatusById(String token, String id);
  Future<Map<String, dynamic>> createLeadStatus(
      String token, LeadStatusModel leadStatus);
  Future<Map<String, dynamic>> editLeadStatus(
      String token, LeadStatusModel leadStatus);
  Future<Map<String, dynamic>> deleteLeadStatus(String token, String id);

  // Follow-up Status operations
  Future<Map<String, dynamic>> getAllFollowUpStatuses(
      String token, String userId);
  Future<Map<String, dynamic>> getFollowUpStatusById(String token, String id);
  Future<Map<String, dynamic>> createFollowUpStatus(
      String token, FollowUpStatusModel followUpStatus);
  Future<Map<String, dynamic>> editFollowUpStatus(
      String token, FollowUpStatusModel followUpStatus);
  Future<Map<String, dynamic>> deleteFollowUpStatus(String token, String id);

  // Reference Source operations
  Future<Map<String, dynamic>> getAllReferenceSources(
      String token, String userId);
  Future<Map<String, dynamic>> getReferenceSourceById(String token, String id);
  Future<Map<String, dynamic>> createReferenceSource(
      String token, ReferenceSourceModel referenceSource);
  Future<Map<String, dynamic>> editReferenceSource(
      String token, ReferenceSourceModel referenceSource);
  Future<Map<String, dynamic>> deleteReferenceSource(String token, String id);
}
