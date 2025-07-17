// ignore_for_file: file_names
import 'dart:convert';

import 'package:inhabit_realties/services/role/roleService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleController {
  final RoleService _roleService = RoleService();

  Future<Map<String, dynamic>> getRoleById(String roleId) async {
    return await _roleService.getRoleById(roleId);
  }

  Future<Map<String, dynamic>> getAllRoles() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    return await _roleService.getAllRoles(token);
  }

  Future<String> getCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    var currentUser = jsonDecode(prefs.getString('currentUser') ?? '{}');
    var currentUserRole = await getRoleById(currentUser['roleId']);
    return currentUserRole['data']['name'];
  }
}
