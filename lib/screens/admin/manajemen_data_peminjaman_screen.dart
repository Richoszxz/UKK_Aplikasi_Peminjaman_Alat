import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import '../../widgets/card_data_peminjaman_widget.dart';
import 'package:creaventory/screens/admin/tambah_data_peminjaman_screen.dart';
import 'package:creaventory/screens/admin/detail_data_peminjaman_screen.dart';
import 'package:creaventory/screens/admin/edit_data_peminjaman_screen.dart';

class ManajemenDataPeminjamanScreen extends StatefulWidget {
  const ManajemenDataPeminjamanScreen({super.key});

  @override
  State<ManajemenDataPeminjamanScreen> createState() =>
      _ManajemenDataPeminjamanScreenState();
}

class _ManajemenDataPeminjamanScreenState
    extends State<ManajemenDataPeminjamanScreen> {
  final PeminjamanService _peminjamanService = PeminjamanService();
  bool isLoading = true;

  String formatTanggal(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String keywordPencarian = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Manajemen\nPeminjaman"),
      drawer: NavigationDrawerWidget(),
      body: Column(
        children: [
          BarPencarianWidget(
            hintText: "Cari data peminjaman...",
            onSearch: (value) {
              setState(() {
                keywordPencarian = value.toLowerCase();
              });
            },
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FutureBuilder(
                future: _peminjamanService.ambilPeminjaman(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (asyncSnapshot.hasError)
                    return Center(child: Text("Error: ${asyncSnapshot.error}"));

                  final semuaData = asyncSnapshot.data!
                      .where((e) => e != null)
                      .toList();

                  final data = semuaData.where((peminjaman) {
                    final keyword = keywordPencarian;

                    if (keyword.isEmpty) return true;

                    final cocokKode =
                        peminjaman.kodePeminjaman?.toLowerCase().contains(
                          keyword,
                        ) ??
                        false;

                    final cocokNama =
                        peminjaman.namaUser?.toLowerCase().contains(keyword) ??
                        false;

                    return cocokKode || cocokNama;
                  }).toList();

                  if (data.isEmpty) {
                    return const Center(
                      child: Text("Data peminjaman tidak ditemukan"),
                    );
                  }

                  if (data.isEmpty) {
                    return Center(child: Text("Tidak ada data peminjaman"));
                  }

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final listDataPeminjaman = data[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CardDataPeminjamanWidget(
                          kode: listDataPeminjaman.kodePeminjaman ?? "-",
                          nama: listDataPeminjaman.namaUser ?? "Tanpa nama",
                          tglPinjam: formatTanggal(
                            listDataPeminjaman.tanggalPeminjaman,
                          ),
                          tglRencanaKembali: formatTanggal(
                            listDataPeminjaman.tanggalKembaliRencana,
                          ),
                          onDetail: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Mengirimkan variabel 'data' (item dari ListView) ke screen Detail
                                builder: (context) => DetailPeminjamanScreen(
                                  data: listDataPeminjaman,
                                ),
                              ),
                            );
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditDataPeminjamanScreen(
                                  data: listDataPeminjaman,
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          onDelete: () {
                            AlertHelper.showConfirm(
                              context,
                              judul: 'Menghapus Data Peminjaman !',
                              pesan:
                                  'Apakah anda yakin untuk menghapus data peminjaman !',
                              onConfirm: () async {
                                try {
                                  await _peminjamanService.hapusPeminjaman(
                                    listDataPeminjaman.idPeminjaman,
                                  );

                                  setState(() {});

                                  AlertHelper.showSuccess(
                                    context,
                                    "Berhasil menyimpan data peminjaman !",
                                  );
                                } catch (e) {
                                  AlertHelper.showError(
                                    context,
                                    'Gagal menghapus data peminjaman',
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahDataPeminjamanScreen(),
            ),
          ).then((_) => setState(() {}));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
        shape: CircleBorder(),
      ),
    );
  }
}
