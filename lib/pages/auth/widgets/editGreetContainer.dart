import 'package:flutter/material.dart';
import 'package:inhabit_realties/providers/register_page_provider.dart';

class EditGreetContainer extends StatelessWidget {
  const EditGreetContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    RegisterPageProvider.editGreet,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                );
  }
}