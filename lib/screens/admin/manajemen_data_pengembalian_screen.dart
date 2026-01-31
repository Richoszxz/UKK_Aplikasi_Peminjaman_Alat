import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import '../../widgets/card_data_pengembalian_widget.dart';
import 'package:creaventory/screens/admin/tambah_data_pengembalian_screen.dart';
import 'package:creaventory/screens/admin/detail_data_pengembalian_screen.dart';
import 'package:creaventory/screens/admin/edit_data_pengembalian_screen.dart';

class ManajemenDataPengembalianScreen extends StatefulWidget {
  const ManajemenDataPengembalianScreen({super.key});

  @override
  State<ManajemenDataPengembalianScreen> createState() =>
      _ManajemenDataPengembalianScreenState();
}

class _ManajemenDataPengembalianScreenState
    extends State<ManajemenDataPengembalianScreen> {
  final PengembalianService _pengembalianService = PengembalianService();

  bool isLoading = true;

  String formatTanggal(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String keywoardPencarian = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Manajemen\nPengembalian"),
      drawer: NavigationDrawerWidget(),
      body: Column(
        children: [
          BarPencarianWidget(
            hintText: "Cari data pengembalian...",
            onSearch: (value) {
              setState(() {
                keywoardPencarian = value.toLowerCase();
              });
            },
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: FutureBuilder(
                future: _pengembalianService.ambilPengembalian(),
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

                  final data = semuaData.where((pengembalian) {
                    final keyword = keywoardPencarian;

                    if (keyword.isEmpty) return true;

                    final cocokKode =
                        pengembalian.peminjaman?.kodePeminjaman
                            ?.toLowerCase()
                            .contains(keyword) ??
                        false;

                    final cocokNama =
                        pengembalian.peminjaman?.namaUser
                            ?.toLowerCase()
                            .contains(keyword) ??
                        false;

                    return cocokKode || cocokNama;
                  }).toList();

                  if (data.isEmpty) {
                    return Center(child: Text("Tidak ada data peminjaman"));
                  }
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final listDataPengembalian = data[index];

                      final peminjaman = listDataPengembalian.peminjaman;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CardDataPengembalianWidget(
                          kode: peminjaman?.kodePeminjaman ?? '-',
                          nama: peminjaman!.namaUser!,
                          tglPinjam: peminjaman?.tanggalPeminjaman != null
                              ? formatTanggal(peminjaman!.tanggalPeminjaman)
                              : "-",
                          tglKembali: formatTanggal(
                            listDataPengembalian.tanggalKembaliAsli,
                          ),
                          onDetail: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPengembalianScreen(
                                  data: listDataPengembalian,
                                ),
                              ),
                            );
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditDataPengembalianScreen(
                                      data: listDataPengembalian,
                                    ),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          onDelete: () {
                            AlertHelper.showConfirm(
                              context,
                              judul: 'Menghapus data pengembalian',
                              pesan:
                                  'Apakah anda yakin menghapus data pengembalian ?',
                              onConfirm: () async {
                                try {
                                  await _pengembalianService.hapusPengembalian(
                                    listDataPengembalian.idPengembalian,
                                  );
                                  AlertHelper.showSuccess(
                                    context,
                                    'Berhasil menghapus data pengembalian !',
                                    onOk: () => setState(() {}),
                                  );
                                } catch (e) {
                                  AlertHelper.showError(
                                    context,
                                    'Gagal menghapus data pengembalian !',
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
              builder: (context) => TambahDataPengembalianScreen(),
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
