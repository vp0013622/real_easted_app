// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:inhabit_realties/providers/login_page_provider.dart';

class LoginGreetContainer extends StatelessWidget {
  const LoginGreetContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    LoginPageProvider.greet,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                );
  }
}