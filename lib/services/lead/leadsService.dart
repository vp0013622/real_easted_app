import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inhabit_realties/constants/apiUrls.dart';
import 'package:inhabit_realties/interfaces/lead/leadsInterface.dart';
import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:inhabit_realties/models/lead/LeadStatusModel.dart';
import 'package:inhabit_realties/models/lead/FollowUpStatusModel.dart';
import 'package:inhabit_realties/models/lead/ReferenceSourceModel.dart';

class LeadsService implements LeadsInterface {
  @override
  Future<Map<String, dynamic>> getAllLeads(String token, String userId) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.getAllLeads;

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> getAllLeadsWithParams(
      String token, String userId, Map<String, dynamic> params) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.getAllLeadsWithParams;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(params),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> getAssignedLeadsForCurrentUser(
      String token) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.getAssignedLeadsForCurrentUser;

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> getLeadById(String token, String id) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.getLeadById}$id';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> createLead(String token, LeadsModel lead) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.createLead;
      final requestBody = lead.toJson();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> editLead(String token, LeadsModel lead) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.editLead}${lead.id}';
      final requestBody = lead.toJsonForEdit();

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> deleteLead(String token, String id) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.deleteLead}$id';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  // Lead Status operations
  @override
  Future<Map<String, dynamic>> getAllLeadStatuses(
      String token, String userId) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.getAllLeadStatuses;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> getLeadStatusById(
      String token, String id) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.getLeadStatusById}$id';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> createLeadStatus(
      String token, LeadStatusModel leadStatus) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.createLeadStatus;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(leadStatus.toJson()),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> editLeadStatus(
      String token, LeadStatusModel leadStatus) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.editLeadStatus}${leadStatus.id}';
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(leadStatus.toJson()),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> deleteLeadStatus(String token, String id) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.deleteLeadStatus}$id';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  // Follow-up Status operations
  @override
  Future<Map<String, dynamic>> getAllFollowUpStatuses(
      String token, String userId) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.getAllFollowUpStatuses;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> getFollowUpStatusById(
      String token, String id) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.getFollowUpStatusById}$id';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> createFollowUpStatus(
      String token, FollowUpStatusModel followUpStatus) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.createFollowUpStatus;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(followUpStatus.toJson()),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> editFollowUpStatus(
      String token, FollowUpStatusModel followUpStatus) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.editFollowUpStatus}${followUpStatus.id}';
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(followUpStatus.toJson()),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> deleteFollowUpStatus(
      String token, String id) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.deleteFollowUpStatus}$id';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  // Reference Source operations
  @override
  Future<Map<String, dynamic>> getAllReferenceSources(
      String token, String userId) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.getAllReferenceSources;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> getReferenceSourceById(
      String token, String id) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.getReferenceSourceById}$id';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> createReferenceSource(
      String token, ReferenceSourceModel referenceSource) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.createReferenceSource;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(referenceSource.toJson()),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> editReferenceSource(
      String token, ReferenceSourceModel referenceSource) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.editReferenceSource}${referenceSource.id}';
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(referenceSource.toJson()),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> deleteReferenceSource(
      String token, String id) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.deleteReferenceSource}$id';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }
}
