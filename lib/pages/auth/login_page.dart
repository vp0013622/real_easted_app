// ignore_for_file: unused_local_variable, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/auth/authController.dart';
import 'package:inhabit_realties/pages/auth/widgets/loginGreetContainer.dart';
import 'package:inhabit_realties/pages/auth/widgets/logoContainer.dart';
import 'package:inhabit_realties/pages/widgets/appSnackBar.dart';
import 'package:inhabit_realties/pages/widgets/appSpinner.dart';
import 'package:inhabit_realties/pages/widgets/formTextField.dart';
import 'package:inhabit_realties/providers/login_page_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _authController = AuthController();
  bool isPageLoading = false;

  Future<Map<String, dynamic>> processLogin(
      String email, String password) async {
    setState(() {
      isPageLoading = true;
    });
    return await _authController.login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    TextEditingController _email = TextEditingController();
    TextEditingController _password = TextEditingController();

    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(LoginPageProvider.title),
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: isPageLoading
          ? const AppSpinner()
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        //logo Container
                        const LogoContainer(),

                        //Greet container
                        const LoginGreetContainer(),

                        //Email and password text field
                        FormTextField(
                          textEditingController: _email,
                          labelText: LoginPageProvider.email,
                          prefixIcon: CupertinoIcons.mail,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${LoginPageProvider.email} is required';
                            }
                            final bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                                .hasMatch(value);
                            if (!emailValid) {
                              return LoginPageProvider.emailValidationMessage;
                            }
                            return null;
                          },
                        ),
                        FormTextField(
                          textEditingController: _password,
                          labelText: LoginPageProvider.password,
                          prefixIcon: CupertinoIcons.lock,
                          suffixIcon: CupertinoIcons.eye,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${LoginPageProvider.password} is required';
                            }
                            if (value.length < 6) {
                              return LoginPageProvider
                                  .passwordValidationMessage;
                            }
                            return null;
                          },
                        ),

                        //forgot password container

                        //sign in elevated button container
                        Container(
                          width: double.infinity,
                          height: 50,
                          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandPrimary,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: AppColors.brandPrimary.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              LoginPageProvider.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Proceed with sign in
                                var email = _email.text.trim();
                                var password = _password.text.trim();
                                var response =
                                    await processLogin(email, password);
                                if (response['statusCode'] == 200) {
                                  var message = response["message"];
                                  AppSnackBar.showSnackBar(
                                      context,
                                      'Heyy..',
                                      'Welcome, Nice to see you',
                                      ContentType.success);
                                  //show success and navigate to the home
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                } else {
                                  var message = response["message"];
                                  AppSnackBar.showSnackBar(context, 'Failure',
                                      message, ContentType.failure);
                                }
                                setState(() {
                                  isPageLoading = false;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
