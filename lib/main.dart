import 'package:flutter/material.dart';
import 'views/login_view.dart';

void main() {
  runApp(const EduMasterApp());
}

class EduMasterApp extends StatelessWidget {
  const EduMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduMaster',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginView(),
      debugShowCheckedModeBanner: false,
    );
  }
}