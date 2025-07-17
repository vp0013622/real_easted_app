// ignore_for_file: file_names

import 'package:inhabit_realties/models/auth/UsersModel.dart';

abstract class AuthInterface{
  Future<Map<String, dynamic>> login(UsersModel userModel);
  Future<Map<String, dynamic>> register(String token, UsersModel userModel);
}