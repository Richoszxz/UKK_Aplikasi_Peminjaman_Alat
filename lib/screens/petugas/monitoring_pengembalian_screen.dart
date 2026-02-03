import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import 'package:creaventory/widgets/card_list_monitoring_pengembalian_widget.dart';
import 'package:creaventory/screens/petugas/konfirmasi_pengembalian_screen.dart';

class MonitoringPengembalianScreen extends StatefulWidget {
  const MonitoringPengembalianScreen({super.key});

  @override
  State<MonitoringPengembalianScreen> createState() =>
      _MonitoringPengembalianScreenState();
}

class _MonitoringPengembalianScreenState
    extends State<MonitoringPengembalianScreen> {
  Future<List<ModelPengembalian>> ambilPengembalian() async {
    final result = await SupabaseService.client
        .from('pengembalian')
        .select('''
          *, 
          pengonfirmasi:pengguna!pengembalian_dikonfirmasi_oleh_fkey(
          username
          ),
          peminjaman(
          id_peminjaman,
          id_user,
          tanggal_peminjaman,
          tanggal_kembali_rencana,
          status_peminjaman,
          kode_peminjaman,
          peminjam:pengguna!peminjaman_id_user_fkey (
                    username,
                    email
                  ),
          detail_peminjaman (
          id_detail_peminjaman,
          id_peminjaman,
          id_alat,
          jumlah_peminjaman,
          kondisi_awal,
          kondisi_kembali,
          alat (
            nama_alat,
            gambar_url,
            kondisi_alat,
            stok_alat
            )
          )
        )
          
          ''')
        .isFilter('dikonfirmasi_oleh', null)
        .order('created_at', ascending: false);

    debugPrint("Result type: ${result.runtimeType}");
    debugPrint("Result content: $result");

    // Pastikan result adalah List<Map<String,dynamic>>
    return result.map((item) => ModelPengembalian.fromJson(item)).toList();
  }

  String formatTanggal(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Monitoring\nPengembalian"),
      drawer: NavigationDrawerWidget(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: FutureBuilder<List<ModelPengembalian>>(
          future: ambilPengembalian(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "Belum ada data pengembalian",
                  style: GoogleFonts.poppins(),
                ),
              );
            }

            final data = asyncSnapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final listPengembalian = data[index];

                return CardListMonitoringPengembalianWidget(
                  kodePeminjaman: listPengembalian.peminjaman!.kodePeminjaman!,
                  namaPeminjam: listPengembalian.peminjaman!.namaUser!,
                  tanggalPinjam: formatTanggal(
                    listPengembalian.peminjaman!.tanggalPeminjaman,
                  ),
                  tanggalPengembalian: formatTanggal(
                    listPengembalian.tanggalKembaliAsli,
                  ),
                  listAlatDikembalikan: listPengembalian
                      .peminjaman!
                      .detailPeminjaman
                      .map(
                        (item) => 'x${item.jumlahPeminjaman} ${item.namaAlat}',
                      )
                      .join(', '),
                  terlambat: listPengembalian.totalDenda! > 0,
                  aksiVerifikasiPengembalian: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KonfirmasiPengembalianScreen(
                          dataPengembalian: listPengembalian,
                        ),
                      ),
                    ).then((_) => setState(() {}));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
