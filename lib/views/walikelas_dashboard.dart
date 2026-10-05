import 'package:flutter/material.dart';
import 'fitur_view.dart';
import 'login_view.dart';

class WaliKelasDashboard extends StatelessWidget {
  final String namaGuru;
  final String kodeLembaga;
  final String kelasGuru;

  const WaliKelasDashboard({
    super.key,
    required this.namaGuru,
    required this.kodeLembaga,
    required this.kelasGuru,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuWali = [
      {"title": "Absen Harian", "icon": Icons.calendar_today, "type": "absen", "kategori": "WaliKelas"},
      {"title": "Rekap Absen Bulanan", "icon": Icons.pie_chart, "type": "rekap", "kategori": "WaliKelas"},
      {"title": "Nilai Siswa", "icon": Icons.score, "type": "nilai", "kategori": "WaliKelas"},
      {"title": "Data Siswa", "icon": Icons.people, "type": "siswa", "kategori": "WaliKelas"},
      {"title": "Catatan Wali Kelas", "icon": Icons.note, "type": "catatan", "kategori": "WaliKelas"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Wali Kelas - Kelas $kelasGuru'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView())),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Wali Kelas: $namaGuru", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Kelas: $kelasGuru | Lembaga: $kodeLembaga", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemCount: menuWali.length,
              itemBuilder: (context, index) {
                var m = menuWali[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FiturView(
                          title: m['title'],
                          featureType: m['type'],
                          kategoriPengajar: m['kategori'],
                          namaPengajar: namaGuru,
                          kodeLembaga: kodeLembaga,
                          kelasWali: kelasGuru, // Diubah dari kelasGuru ke kelasWali
                          listSiswa: const [],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(m['icon'], size: 48, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(m['title'], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}