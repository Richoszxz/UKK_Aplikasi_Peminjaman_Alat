import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import 'package:creaventory/widgets/card_list_riwayat_peminjaman_widget.dart';
import 'package:creaventory/screens/peminjam/pengajuan_pengembalian_screen.dart';

class RiwayatPeminjamanScreen extends StatefulWidget {
  const RiwayatPeminjamanScreen({super.key});

  @override
  State<RiwayatPeminjamanScreen> createState() =>
      _RiwayatPeminjamanScreenState();
}

class _RiwayatPeminjamanScreenState extends State<RiwayatPeminjamanScreen> {
  Future<List<Map<String, dynamic>>> ambilDataPeminjamanUser() async {
    final idUser = SupabaseService.client.auth.currentUser!.id;
    final result = await SupabaseService.client
        .from('peminjaman')
        .select('''
          peminjam:pengguna!peminjaman_id_user_fkey (
          username
          ),
          id_peminjaman,
          id_user,
          kode_peminjaman,
          tanggal_peminjaman,
          tanggal_kembali_rencana,
          status_peminjaman,
          detail_peminjaman (
            jumlah_peminjaman,
            alat (
              nama_alat
            )
          )
        ''')
        .eq('id_user', idUser)
        .eq('status_peminjaman', 'dipinjam')
        .order('tanggal_peminjaman', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  String formatTanggal(String isoDate) {
    final date = DateTime.parse(isoDate);
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Riwayat\nPeminjaman"),
      drawer: NavigationDrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: ambilDataPeminjamanUser(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (asyncSnapshot.hasError) {
              return Center(
                child: Text("Terjadi kesalahan: ${asyncSnapshot.error}"),
              );
            }

            final data = asyncSnapshot.data ?? [];

            if (data.isEmpty) {
              return const Center(child: Text("Belum ada riwayat peminjaman"));
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final peminjaman = data[index];
                final detailPeminjaman =
                    peminjaman['detail_peminjaman'] as List<dynamic>;

                final listAlatDipinjam = detailPeminjaman
                    .map(
                      (d) =>
                          "x${d['jumlah_peminjaman']} ${d['alat']['nama_alat']}",
                    )
                    .join(", ");

                return Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: CardListRiwayatPeminjamanWidget(
                    kodePeminjaman: peminjaman['kode_peminjaman'],
                    namaPeminjam: peminjaman['peminjam']['username'],
                    tanggalPinjam: formatTanggal(
                      peminjaman['tanggal_peminjaman'],
                    ),
                    tanggalRencanaKembali: formatTanggal(
                      peminjaman['tanggal_kembali_rencana'],
                    ),
                    listAlatDipinjam: listAlatDipinjam,
                    aksiPengajuanPengembalian: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PengajuanPengembalianScreen(
                            peminjaman: peminjaman,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
