import 'package:flutter/material.dart';

class FiturView extends StatelessWidget {
  final String kodeLembaga;
  final String kelasWali;
  final List<dynamic>? listSiswa;
  final String? title;
  final String? featureType;
  final String? kategoriPengajar;
  final String? namaPengajar;

  const FiturView({
    Key? key,
    required this.kodeLembaga,
    required this.kelasWali,
    this.listSiswa,
    this.title,
    this.featureType,
    this.kategoriPengajar,
    this.namaPengajar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Detail Fitur'),
        backgroundColor: kategoriPengajar == 'WaliKelas' ? Colors.blue : Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _buildFeatureContent(context),
    );
  }

  Widget _buildFeatureContent(BuildContext context) {
    switch (featureType) {
      case 'absen':
        return _buildAbsenView(context);
      case 'rekap':
        return _buildRekapView(context);
      case 'nilai':
        return _buildNilaiView(context);
      case 'siswa':
        return _buildDataSiswaView(context);
      case 'catatan':
        return _buildCatatanView(context);
      default:
        return Center(
          child: Text('Fitur $title belum tersedia untuk kelas $kelasWali'),
        );
    }
  }

  // 1. Tampilan Absen Harian
  Widget _buildAbsenView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Absensi Harian - Kelas $kelasWali', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Pengajar: $namaPengajar', style: const TextStyle(color: Colors.grey)),
          const Divider(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('Nama Siswa Contoh ${index + 1}'),
                    subtitle: Text('NISN: 00${index + 12345}'), // Diperbaiki (tanpa const)
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                          child: const Text('Hadir'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Alpha'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Absen harian berhasil disimpan!')),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Simpan Absensi'),
          ),
        ],
      ),
    );
  }

  // 2. Tampilan Rekap Absen Bulanan
  Widget _buildRekapView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Rekap Absensi Bulanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: 'Oktober 2026',
                items: ['Oktober 2026', 'September 2026', 'Agustus 2026']
                    .map((bulan) => DropdownMenuItem(value: bulan, child: Text(bulan)))
                    .toList(),
                onChanged: (_) {},
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text('Siti Aminah'),
                  subtitle: Text('Hadir: 20 | Izin: 1 | Sakit: 0 | Alpha: 0'),
                  trailing: Text('95%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ),
                Divider(),
                ListTile(
                  title: Text('Ahmad Zaini'),
                  subtitle: Text('Hadir: 18 | Izin: 2 | Sakit: 1 | Alpha: 0'),
                  trailing: Text('85%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Tampilan Nilai Siswa
  Widget _buildNilaiView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daftar Nilai Kelas $kelasWali', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Input Nilai'),
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: ListView(
              children: const [
                ExpansionTile(
                  title: Text('Siti Aminah'),
                  subtitle: Text('Rata-rata: 88.5'),
                  children: [
                    ListTile(title: Text('Matematika: 90'), dense: true),
                    ListTile(title: Text('Bahasa Indonesia: 87'), dense: true),
                    ListTile(title: Text('IPA: 89'), dense: true),
                  ],
                ),
                ExpansionTile(
                  title: Text('Ahmad Zaini'),
                  subtitle: Text('Rata-rata: 82.0'),
                  children: [
                    ListTile(title: Text('Matematika: 80'), dense: true),
                    ListTile(title: Text('Bahasa Indonesia: 84'), dense: true),
                    ListTile(title: Text('IPA: 82'), dense: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Tampilan Data Siswa
  Widget _buildDataSiswaView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Direktori Siswa Kelas $kelasWali', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Total Siswa: 25 Anak', style: TextStyle(color: Colors.grey)),
          const Divider(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text('Nama Siswa ${index + 1}'),
                    subtitle: Text('NISN: 0098234$index | JK: ${index % 2 == 0 ? "L" : "P"}'), // Diperbaiki (tanpa const)
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {},
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

  // 5. Tampilan Catatan Wali Kelas
  Widget _buildCatatanView(BuildContext context) {
    final TextEditingController catatanController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Catatan & Jurnal Perkembangan Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Catat kejadian penting, pelanggaran, atau catatan khusus kelas.', style: TextStyle(color: Colors.grey)),
          const Divider(height: 24),
          TextField(
            controller: catatanController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tulis catatan harian wali kelas di sini...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catatan berhasil disimpan!')),
              );
            },
            child: const Text('Simpan Catatan'),
          ),
        ],
      ),
    );
  }
}