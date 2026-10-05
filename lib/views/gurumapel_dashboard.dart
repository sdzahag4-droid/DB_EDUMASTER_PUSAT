import 'package:flutter/material.dart';
import 'fitur_view.dart';
import 'login_view.dart';

class GuruMapelDashboard extends StatelessWidget {
  final String namaGuru;
  final String kodeLembaga;
  final String mapelGuru;

  const GuruMapelDashboard({
    super.key,
    required this.namaGuru,
    required this.kodeLembaga,
    required this.mapelGuru,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuMapel = [
      {"title": "Absen Harian Mapel", "icon": Icons.event_available, "type": "absen", "kategori": mapelGuru},
      {"title": "Rekap Absen Mapel", "icon": Icons.bar_chart, "type": "rekap", "kategori": mapelGuru},
      {"title": "Input Nilai Mapel", "icon": Icons.assignment, "type": "nilai", "kategori": mapelGuru},
      {"title": "Data Siswa", "icon": Icons.people, "type": "siswa", "kategori": mapelGuru},
      {"title": "Catatan Guru Mapel", "icon": Icons.edit_note, "type": "catatan", "kategori": mapelGuru},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Guru Mapel - $mapelGuru'),
        backgroundColor: Colors.indigo,
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
            color: Colors.indigo.shade50,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Guru Mapel: $namaGuru ($mapelGuru)", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Lembaga: $kodeLembaga", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemCount: menuMapel.length,
              itemBuilder: (context, index) {
                var m = menuMapel[index];
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
                          kelasWali: "-", // Diubah dari kelasGuru ke kelasWali
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
                        Icon(m['icon'], size: 48, color: Colors.indigo),
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