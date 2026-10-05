import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/api_service.dart';

class FiturView extends StatefulWidget {
  final String title;
  final String featureType; 
  final String kategoriPengajar; 
  final String namaPengajar;
  final String kodeLembaga;
  final String kelasGuru; // Menambahkan parameter kelasGuru dari login

  const FiturView({
    super.key,
    required this.title,
    required this.featureType,
    required this.kategoriPengajar,
    required this.namaPengajar,
    required this.kodeLembaga,
    required this.kelasGuru,
  });

  @override
  State<FiturView> createState() => _FiturViewState();
}

class _FiturViewState extends State<FiturView> {
  List<dynamic> listData = [];
  List<dynamic> listSiswa = [];
  List<dynamic> listAbsen = [];
  bool isLoading = true;

  // Menggunakan kelasGuru yang dikirim dari halaman login secara dinamis
  String get _kelasWali {
    return widget.kelasGuru.isNotEmpty ? widget.kelasGuru : "1A";
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  String get _sheetTarget {
    if (widget.featureType == 'siswa') return "Siswa";
    if (widget.featureType == 'absen') return "Absensi";
    if (widget.featureType == 'rekap') return "Absensi";
    if (widget.featureType == 'nilai') return "Nilai";
    if (widget.featureType == 'catatan') return "Catatan";
    return "Siswa";
  }

  void _fetchData() async {
    setState(() => isLoading = true);
    
    if (widget.featureType == 'rekap') {
      var siswaData = await ApiService.getData("Siswa", widget.kodeLembaga, kelas: _kelasWali);
      var absenData = await ApiService.getData("Absensi", widget.kodeLembaga, pemberi: widget.namaPengajar);
      setState(() {
        listSiswa = siswaData;
        listAbsen = absenData;
        isLoading = false;
      });
    } else {
      String? filterPemberi = (widget.featureType == 'absen' || widget.featureType == 'catatan') ? widget.namaPengajar : null;
      String? filterKelas = (widget.featureType == 'siswa') ? _kelasWali : null;
      
      var data = await ApiService.getData(_sheetTarget, widget.kodeLembaga, pemberi: filterPemberi, kelas: filterKelas);
      setState(() {
        listData = data;
        isLoading = false;
      });
    }
  }

  void _showAddAbsenDialog() async {
    var siswaList = await ApiService.getData("Siswa", widget.kodeLembaga, kelas: _kelasWali);
    if (!mounted) return;

    if (siswaList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data Siswa untuk Kelas $_kelasWali masih kosong. Harap tambahkan data siswa dengan kelas $_kelasWali.")),
      );
      return;
    }

    String? selectedNisn;
    String selectedStatus = 'Hadir';
    final tanggalController = TextEditingController(text: DateTime.now().toLocal().toString().split(' ')[0]);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Absen Harian Siswa (Kelas $_kelasWali)"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: tanggalController,
                      decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text("Pilih Siswa:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedNisn,
                      hint: const Text("-- Pilih Nama Siswa --"),
                      items: siswaList.map((siswa) {
                        String nama = siswa['nama'] ?? 'Tanpa Nama';
                        String nisn = siswa['nisn']?.toString() ?? '-';
                        return DropdownMenuItem<String>(
                          value: nisn,
                          child: Text("$nama (NISN: $nisn)"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() {
                          selectedNisn = val;
                        });
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text("Status Kehadiran:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: ['Hadir', 'Sakit', 'Izin', 'Alpa'].map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() {
                          selectedStatus = val!;
                        });
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal")),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedNisn == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text("Silakan pilih siswa terlebih dahulu!")),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);
                    setState(() => isLoading = true);

                    String idUnik = DateTime.now().millisecondsSinceEpoch.toString();
                    bool success = await ApiService.addData("Absensi", [
                      idUnik,
                      tanggalController.text,
                      selectedNisn,
                      selectedStatus,
                      widget.kategoriPengajar,
                      widget.namaPengajar,
                      widget.kodeLembaga,
                    ]);

                    if (success) {
                      _fetchData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Absen berhasil disimpan")));
                      }
                    } else {
                      setState(() => isLoading = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan absen")));
                      }
                    }
                  },
                  child: const Text("Simpan Absen"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDialogGeneral() {
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    final c3 = TextEditingController(text: _kelasWali); 
    final c4 = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Tambah ${widget.title}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.featureType == 'siswa') ...[
                  TextField(controller: c1, decoration: const InputDecoration(labelText: 'ID Siswa')),
                  TextField(controller: c2, decoration: const InputDecoration(labelText: 'Nama Siswa')),
                  TextField(controller: c3, decoration: const InputDecoration(labelText: 'Kelas')),
                  TextField(controller: c4, decoration: const InputDecoration(labelText: 'NISN')),
                ] else if (widget.featureType == 'nilai') ...[
                  TextField(controller: c1, decoration: const InputDecoration(labelText: 'NISN Siswa')),
                  TextField(controller: c2, decoration: const InputDecoration(labelText: 'Mata Pelajaran')),
                  TextField(controller: c3, decoration: const InputDecoration(labelText: 'Nilai Angka')),
                ] else ...[
                  TextField(controller: c1, decoration: const InputDecoration(labelText: 'NISN Siswa')),
                  TextField(controller: c2, decoration: const InputDecoration(labelText: 'Tanggal')),
                  TextField(controller: c3, decoration: const InputDecoration(labelText: 'Isi Catatan')),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                setState(() => isLoading = true);
                
                bool success = false;
                String idUnik = DateTime.now().millisecondsSinceEpoch.toString();

                if (widget.featureType == 'siswa') {
                  success = await ApiService.addData("Siswa", [c1.text, c2.text, c3.text, c4.text, "-", widget.kodeLembaga]);
                } else if (widget.featureType == 'nilai') {
                  success = await ApiService.addData("Nilai", [idUnik, c1.text, c2.text, c3.text, "0", "0", widget.kategoriPengajar, widget.kodeLembaga]);
                } else {
                  success = await ApiService.addData("Catatan", [idUnik, c1.text, c2.text, c3.text, widget.kategoriPengajar, widget.namaPengajar, widget.kodeLembaga]);
                }

                if (success) {
                  _fetchData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan")));
                  }
                } else {
                  setState(() => isLoading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan data")));
                  }
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<pw.Document> _buildRekapPdfDocument() async {
    final pdf = pw.Document();

    List<List<String>> tableData = [];
    for (int i = 0; i < listSiswa.length; i++) {
      var siswa = listSiswa[i];
      String nisn = siswa['nisn']?.toString() ?? '';
      String nama = siswa['nama'] ?? 'Tanpa Nama';

      int hadir = 0, sakit = 0, izin = 0, alpa = 0;
      for (var absen in listAbsen) {
        if (absen['nisn']?.toString() == nisn) {
          String status = (absen['status'] ?? '').toString().toLowerCase();
          if (status == 'hadir') hadir++;
          else if (status == 'sakit') sakit++;
          else if (status == 'izin') izin++;
          else if (status == 'alpa') alpa++;
        }
      }

      tableData.add([
        (i + 1).toString(),
        nama,
        hadir.toString(),
        sakit.toString(),
        izin.toString(),
        alpa.toString(),
      ]);
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("REKAP ABSENSI BULANAN SISWA", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 15),
              pw.Text("Nama Lengkap Wali Kelas : ${widget.namaPengajar}"),
              pw.Text("Wali Kelas : $_kelasWali"),
              pw.Text("Periode : Oktober 2026"),
              pw.Text("Lembaga : ${widget.kodeLembaga.toUpperCase()}"),
              pw.SizedBox(height: 15),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['No', 'Nama Siswa', 'Hadir', 'Sakit', 'Izin', 'Alpa'],
                data: tableData,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(40),
                  3: const pw.FixedColumnWidth(40),
                  4: const pw.FixedColumnWidth(40),
                  5: const pw.FixedColumnWidth(40),
                },
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text("Mengetahui,"),
                      pw.SizedBox(height: 45),
                      pw.Text(widget.namaPengajar, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text("Wali Kelas"),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  void _previewPdf() async {
    final pdfDoc = await _buildRekapPdfDocument();
    await Printing.layoutPdf(onLayout: (format) async => pdfDoc.save());
  }

  void _exportPdf() async {
    final pdfDoc = await _buildRekapPdfDocument();
    await Printing.sharePdf(bytes: await pdfDoc.save(), filename: 'rekap_absen_oktober_2026.pdf');
  }

  @override
  Widget build(BuildContext context) {
    bool isRekap = widget.featureType == 'rekap';
    bool isAbsen = widget.featureType == 'absen';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          if (isRekap) ...[
            IconButton(icon: const Icon(Icons.visibility), onPressed: _previewPdf, tooltip: "Preview PDF"),
            IconButton(icon: const Icon(Icons.download), onPressed: _exportPdf, tooltip: "Export PDF"),
          ],
          if (isAbsen)
            IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _previewPdf, tooltip: "Cetak PDF"),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isRekap
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nama Lengkap Wali Kelas : ${widget.namaPengajar}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("Wali Kelas : $_kelasWali"),
                              const Text("Periode : Oktober 2026"),
                              Text("Lembaga : ${widget.kodeLembaga.toUpperCase()}"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text("Tabel Rekapitulasi Kehadiran Siswa (Kelas $_kelasWali):", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: listSiswa.isEmpty
                            ? Center(child: Text("Belum ada data siswa untuk Kelas $_kelasWali."))
                            : ListView.builder(
                                itemCount: listSiswa.length,
                                itemBuilder: (context, index) {
                                  var siswa = listSiswa[index];
                                  String nisn = siswa['nisn']?.toString() ?? '';
                                  String nama = siswa['nama'] ?? 'Tanpa Nama';

                                  int hadir = 0, sakit = 0, izin = 0, alpa = 0;
                                  for (var absen in listAbsen) {
                                    if (absen['nisn']?.toString() == nisn) {
                                      String status = (absen['status'] ?? '').toString().toLowerCase();
                                      if (status == 'hadir') hadir++;
                                      else if (status == 'sakit') sakit++;
                                      else if (status == 'izin') izin++;
                                      else if (status == 'alpa') alpa++;
                                    }
                                  }

                                  return Card(
                                    child: ListTile(
                                      leading: CircleAvatar(child: Text("${index + 1}")),
                                      title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text("NISN: $nisn | Kelas: $_kelasWali"),
                                      trailing: Text("H: $hadir | S: $sakit | I: $izin | A: $alpa", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                )
              : listData.isEmpty
                  ? Center(child: Text("Belum ada data absensi untuk Kelas $_kelasWali. Silakan tekan tombol '+' untuk menambah absen."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: listData.length,
                      itemBuilder: (context, index) {
                        var item = listData[index];
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(item['nama'] ?? item['nisn'] ?? "Data Absen", style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Tanggal: ${item['tanggal']} | Status: ${item['status']} | Pengajar: ${item['pemberi']}"),
                          ),
                        );
                      },
                    ),
      floatingActionButton: isRekap
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (widget.featureType == 'absen') {
                  _showAddAbsenDialog();
                } else {
                  _showAddDialogGeneral();
                }
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}