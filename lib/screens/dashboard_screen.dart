import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int penggunaAktif = 0;
  int jumlahAlat = 0;
  int alatDipinjam = 0;
  int alatTersedia = 0;
  bool isLoading = true;
  bool isCetakLoading = false;

  Future<void> loadDashboard() async {
    try {
      final client = SupabaseService.client;

      /// 1️⃣ Pengguna aktif
      final pengguna = await client
          .from('pengguna')
          .select('id_user')
          .eq('status', true);

      /// 2️⃣ Total alat + total stok
      final alat = await client.from('alat').select('id_alat, stok_alat');

      int totalStok = 0;
      for (final item in alat) {
        totalStok += (item['stok_alat'] as int);
      }

      /// 3️⃣ Alat sedang dipinjam
      final dipinjam = await client
          .from('detail_peminjaman')
          .select('jumlah_peminjaman, peminjaman!inner(status_peminjaman)')
          .eq('peminjaman.status_peminjaman', 'dipinjam');

      int totalDipinjam = 0;
      for (final item in dipinjam) {
        totalDipinjam += (item['jumlah_peminjaman'] as int);
      }

      setState(() {
        penggunaAktif = pengguna.length;
        jumlahAlat = alat.length;
        alatDipinjam = totalDipinjam;
        alatTersedia = totalStok - totalDipinjam;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal load dashboard: $e");
      isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<List<dynamic>> fetchLaporanHariIni() async {
    final client = SupabaseService.client;

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final data = await client
        .from('peminjaman')
        .select('''
        kode_peminjaman,
        tanggal_peminjaman,
        tanggal_kembali_rencana,
        status_peminjaman,

        pengguna:pengguna!peminjaman_id_user_fkey (
          username,
          email
        ),

        detail_peminjaman (
          jumlah_peminjaman,
          alat (
            nama_alat,
            kondisi_alat
          )
        )
      ''')
        .inFilter('status_peminjaman', ['dipinjam', 'dikembalikan'])
        .gte('tanggal_peminjaman', '$today 00:00:00')
        .lte('tanggal_peminjaman', '$today 23:59:59')
        .order('tanggal_peminjaman', ascending: false);

    return data;
  }

  Future<void> cetakLaporan() async {
    final data = await fetchLaporanHariIni();

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();
    final bold = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'LAPORAN PEMINJAMAN & PENGEMBALIAN HARI INI',
            style: pw.TextStyle(font: bold, fontSize: 18),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Tanggal: ${DateTime.now().toString().substring(0, 10)}',
            style: pw.TextStyle(font: font),
          ),
          pw.SizedBox(height: 15),

          pw.Table.fromTextArray(
            headers: [
              'Kode',
              'Email',
              'Username',
              'Tanggal Pinjam',
              'Tanggal Kembali',
              'Status',
              'Alat',
              'Jumlah',
            ],
            headerStyle: pw.TextStyle(font: bold, fontSize: 6),
            cellStyle: pw.TextStyle(font: font, fontSize: 6),
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 2,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.4), // kode
              1: const pw.FlexColumnWidth(2.2), // email
              2: const pw.FlexColumnWidth(1.5), // user
              3: const pw.FlexColumnWidth(1.3), // pinjam
              4: const pw.FlexColumnWidth(1.3), // kembali
              5: const pw.FlexColumnWidth(1.1), // status
              6: const pw.FlexColumnWidth(2.0), // alat
              7: const pw.FlexColumnWidth(0.8), // qty
            },
            data: data.expand((p) {
              return (p['detail_peminjaman'] as List).map((dp) {
                return [
                  p['kode_peminjaman'],
                  p['pengguna']['email'],
                  p['pengguna']['username'],
                  p['tanggal_peminjaman'].toString().substring(0, 10),
                  p['tanggal_kembali_rencana'].toString().substring(0, 10),
                  p['status_peminjaman'],
                  dp['alat']['nama_alat'],
                  dp['jumlah_peminjaman'].toString(),
                ];
              }).toList();
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _handleCetak() async {
    setState(() => isCetakLoading = true);
    try {
      await cetakLaporan();
    } finally {
      if (mounted) setState(() => isCetakLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Dashboard"),
      drawer: NavigationDrawerWidget(),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // ===================== DASHBOARD CARD =====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildDashboardCard(
                  context,
                  "Pengguna Aktif",
                  isLoading ? "-" : penggunaAktif.toString(),
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              Expanded(
                child: buildDashboardCard(
                  context,
                  "Jumlah Alat",
                  isLoading ? "-" : jumlahAlat.toString(),
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildDashboardCard(
                  context,
                  "Alat Dipinjam",
                  isLoading ? "-" : alatDipinjam.toString(),
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              Expanded(
                child: buildDashboardCard(
                  context,
                  "Alat Tersedia",
                  isLoading ? "-" : alatTersedia.toString(),
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ===================== CETAK LAPORAN =====================
          Text(
            "Cetak Laporan:",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF424242),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: 5,
            ),
            width: double.infinity,
            height: 135,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSecondary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.insert_drive_file_outlined,
                        size: 35,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "Laporan Peminjaman dan Pengembalian Hari Ini",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isCetakLoading ? null : _handleCetak,
                    child: isCetakLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.print_outlined,
                                size: 24,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Cetak",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 15),

          // peminjaman hari ini
          Text(
            "Peminjaman dan Pengembalian Hari ini:",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF424242),
            ),
          ),

          SizedBox(height: 10),

          FutureBuilder<List<dynamic>>(
            future: fetchLaporanHariIni(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text(
                  "Belum ada data hari ini",
                  style: GoogleFonts.poppins(),
                );
              }

              final data = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final p = data[index];
                  final isDipinjam = p['status_peminjaman'] == 'dipinjam';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5,
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// KODE + STATUS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p['kode_peminjaman'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDipinjam
                                    ? Color(0xFFE3F2FD)
                                    : Color(0xFFE6F4EA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                p['status_peminjaman'].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: isDipinjam
                                      ? const Color(0xFF1E88E5)
                                      : Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),

                        /// NAMA PEMINJAM
                        Text(
                          p['pengguna']['username'],
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// TANGGAL PINJAM
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Tanggal Pinjam: ${p['tanggal_peminjaman'].toString().substring(0, 10)}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),

                        /// TANGGAL KEMBALI
                        Row(
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Tanggal Kembali: ${p['tanggal_kembali_rencana'].toString().substring(0, 10)}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget buildDashboardCard(
  BuildContext context,
  String title,
  String count,
  Color color,
) {
  return Container(
    margin: EdgeInsets.all(5),
    constraints: BoxConstraints(minHeight: 140),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 5,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
