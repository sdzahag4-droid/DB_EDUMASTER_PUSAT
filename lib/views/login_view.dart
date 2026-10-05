import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'walikelas_dashboard.dart';
import 'gurumapel_dashboard.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool isLoading = false;

  void _prosesLogin() async {
    setState(() => isLoading = true);
    var res = await ApiService.login(_userController.text, _passController.text);
    setState(() => isLoading = false);

    if (res['status'] == 'success') {
      String role = (res['role'] ?? '').toString().trim().toLowerCase();
      String nama = res['nama_lengkap'] ?? '';
      String lembaga = res['kode_lembaga'] ?? '';
      
      // PERBAIKAN: Menangkap berbagai kemungkinan penamaan key dari Google Apps Script untuk ID Kelas
      String kelasGuru = (res['id_kelas'] ?? res['ID Kelas'] ?? res['ID_Kelas'] ?? res['kelas'] ?? '').toString().trim();
      String mapelGuru = (res['mata_pelajaran'] ?? res['Mata Pelajaran'] ?? '').toString().trim();

      if (role.contains('wali')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WaliKelasDashboard(
              namaGuru: nama, 
              kodeLembaga: lembaga, 
              kelasGuru: kelasGuru, // Mengirimkan kelas yang benar (misal: 5A)
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GuruMapelDashboard(
              namaGuru: nama, 
              kodeLembaga: lembaga,
              mapelGuru: mapelGuru,
            ),
          ),
        );
      }
    } else {
      _showMsg(res['message'] ?? "Login Gagal");
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_rounded, size: 70, color: Colors.blueAccent),
                  const SizedBox(height: 12),
                  const Text("EduMaster", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  const Text("Portal Administrasi Guru & Wali Kelas", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 24),
                  TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: _passController, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), obscureText: true),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                      onPressed: isLoading ? null : _prosesLogin,
                      child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('MASUK APLIKASI', style: TextStyle(fontWeight: FontWeight.bold)),
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