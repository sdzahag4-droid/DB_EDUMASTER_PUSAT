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

  const FiturView({
    super.key,
    required this.title,
    required this.featureType,
    required this.kategoriPengajar,
    required this.namaPengajar,
    required this.kodeLembaga,
  });

  @override
  State<FiturView> createState() => _FiturViewState();
}

class _FiturViewState extends State<FiturView> {
  List<dynamic> listData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => isLoading = true);
    String sheetTarget = "";
    if (widget.featureType == 'siswa') sheetTarget = "Siswa";
    if (widget.featureType == 'absen' || widget.featureType == 'rekap') sheetTarget = "Absensi";
    if (widget.featureType == 'nilai') sheetTarget = "Nilai";
    if (widget.featureType == 'catatan') sheetTarget = "Catatan";

    var data = await ApiService.getData(sheetTarget, widget.kodeLembaga);
    setState(() {
      listData = data;
      isLoading = false;
    });
  }

  // Cetak PDF otomatis dengan menyertakan nama pengajar di bagian bawah
  void _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("LAPORAN: ${widget.title.toUpperCase()}", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text("Lembaga: ${widget.kodeLembaga}"),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Expanded(
                child: pw.ListView.builder(
                  itemCount: listData.length,
                  itemBuilder: (context, index) {
                    var item = listData[index];
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text("- ${item.toString()}", style: const pw.TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
              pw.SizedBox(height: 20),
              // Bagian tanda tangan bawah sesuai permintaan (Menampilkan nama pengajar)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text("Mengetahui,"),
                      pw.SizedBox(height: 45),
                      pw.Text(widget.namaPengajar, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.kategoriPengajar == 'WaliKelas' ? "Wali Kelas" : "Guru Mata Pelajaran"),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Memperbaiki parameter onLayout yang sebelumnya salah ketik
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    bool isExportable = widget.featureType == 'absen' || widget.featureType == 'rekap';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          if (isExportable)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generatePdf,
              tooltip: "Export PDF",
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : listData.isEmpty
              ? const Center(child: Text("Belum ada data pada sistem."))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: listData.length,
                  itemBuilder: (context, index) {
                    var item = listData[index];
                    return Card(
                      child: ListTile(
                        title: Text(item['nama'] ?? item['nisn'] ?? item['catatan'] ?? "Data Record"),
                        subtitle: Text(item.toString()),
                      ),
                    );
                  },
                ),
    );
  }
}