import 'package:flutter/material.dart';
import 'package:inhabit_realties/providers/register_page_provider.dart';

class RegisterGreetContainer extends StatelessWidget {
  const RegisterGreetContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    RegisterPageProvider.greet,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                );
  }
}