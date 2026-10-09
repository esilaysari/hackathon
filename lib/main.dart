import 'package:flutter/material.dart';

import 'strings.dart';
import 'theme/tokens.dart';

void main() {
  runApp(const EduSwarmApp());
}

class EduSwarmApp extends StatelessWidget {
  const EduSwarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        backgroundColor: AppColors.creamBase,
        body: Center(
          child: Text(AppStrings.appTitle, style: AppTextStyles.appBarTitle),
        ),
      ),
    );
  }
}
