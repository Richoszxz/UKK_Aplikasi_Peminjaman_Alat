import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import 'package:creaventory/widgets/card_request_peminjaman_widget.dart';

class MonitoringPeminjamanScreen extends StatefulWidget {
  const MonitoringPeminjamanScreen({super.key});

  @override
  State<MonitoringPeminjamanScreen> createState() =>
      _MonitoringPeminjamanScreenState();
}

class _MonitoringPeminjamanScreenState
    extends State<MonitoringPeminjamanScreen> {
  final List<Map<String, dynamic>> requests = [
    {
      "kode": "TRX24578965",
      "nama": "Richo Ferdinand",
      "barang": "1 Tablet iPad, 1 Stylus Pen",
    },
    {
      "kode": "TRX24578966",
      "nama": "Richa Ferdinyoy",
      "barang": "1 Kamera DSLR",
    },
  ];

  Future<List<ModelPeminjaman>> ambilDataPeminjaman() async {
    final result = await SupabaseService.client
        .from('peminjaman')
        .select('''
        *,
        peminjam:pengguna!peminjaman_id_user_fkey (
          username
        ),
        detail_peminjaman (
        id_detail_peminjaman,
        id_peminjaman,
        id_alat,
        jumlah_peminjaman,
        kondisi_awal,
        kondisi_kembali,
        denda_kerusakan,
        alat (
          nama_alat,
          gambar_url,
          kondisi_alat,
          stok_alat
        )
      )
      ''')
        .eq('status_peminjaman', 'menunggu');

    return (result as List).map((e) => ModelPeminjaman.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Monitoring\nPeminjaman"),
      drawer: NavigationDrawerWidget(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: FutureBuilder(
          future: ambilDataPeminjaman(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (asyncSnapshot.hasError) {
              return Center(child: Text("Error: ${asyncSnapshot.error}"));
            }

            if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
              return const Center(child: Text("Tidak ada peminjaman menunggu"));
            }
            final data = asyncSnapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final listPeminjaman = data[index];

                return CardRequestPeminjamanWidget(
                  kodePeminjaman: listPeminjaman.kodePeminjaman,
                  namaPeminjam: listPeminjaman.namaUser,
                  daftarBarang: listPeminjaman.detailPeminjaman
                      .map(
                        (item) => 'x${item.jumlahPeminjaman} ${item.namaAlat}',
                      )
                      .join(', '),
                  disetujui: () async {
                    try {
                      await PeminjamanService().menyetujuiPeminjaman(
                        listPeminjaman.idPeminjaman,
                      );

                      setState(() {});

                      AlertHelper.showSuccess(
                        context,
                        'Berhasil menyetujui peminjaman !',
                      );
                    } catch (e) {
                      debugPrint('$e');
                      AlertHelper.showError(context, '$e');
                    }
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
