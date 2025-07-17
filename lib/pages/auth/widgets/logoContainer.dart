import 'package:flutter/material.dart';

class LogoContainer extends StatelessWidget {
  const LogoContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 70),
            child: Image.asset(
              'assets/images/applogo.png',
              height: MediaQuery.of(context).size.height/5,
            )
          );
  }
}