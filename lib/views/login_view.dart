import 'package:flutter/material.dart';
import 'gurumapel_dashboard.dart';
import 'walikelas_dashboard.dart';
// Pastikan fitur_view.dart sudah ada, jika belum silakan buat file fitur_view.dart
import 'fitur_view.dart'; 

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    String username = _usernameController.text.trim();
    
    // Contoh navigasi berdasarkan input atau uji coba
    if (username.toLowerCase().contains('wali')) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WaliKelasDashboard(
            namaGuru: 'Bapak Guru Wali',
            kodeLembaga: 'SD-ZAHA',
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const GuruMapelDashboard(
            namaGuru: 'Bapak Guru Mapel',
            kodeLembaga: 'SD-ZAHA',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login EduMaster')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}