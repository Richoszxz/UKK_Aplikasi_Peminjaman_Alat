import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import 'package:creaventory/widgets/card_list_alat_widget.dart';
import 'package:creaventory/screens/admin/detail_alat_screen.dart';

class ManajemenAlatScreen extends StatefulWidget {
  const ManajemenAlatScreen({super.key});

  @override
  State<ManajemenAlatScreen> createState() => _ManajemenAlatScreenState();
}

class _ManajemenAlatScreenState extends State<ManajemenAlatScreen> {
  final AlatService _alatService = AlatService();
  final KategoriService _kategoriService = KategoriService();

  // Tambahkan variabel ini agar tidak error
  String selectedKategori = "Semua";
  List<String> kategoriList = ["Semua"];

  // Simpan future dalam variabel agar tidak reload terus saat setState
  late Future<List<dynamic>> _futureAlat;

  @override
  void initState() {
    super.initState();
    _futureAlat = _alatService.ambilAlat();
    _loadKategori();
  }

  // Mengambil kategori langsung dari Service
  Future<void> _loadKategori() async {
    try {
      final listModel = await _kategoriService
          .ambilKategori(); // Pastikan fungsi ini ada di service
      setState(() {
        final listString = listModel.map(
          (item) => item.namaKategori.toString(),
        );
        kategoriList = ["Semua", ...listString];
      });
    } catch (e) {
      debugPrint("Gagal memuat kategori: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Manajemen Alat"),
      drawer: NavigationDrawerWidget(),
      body: Column(
        children: [
          BarPencarianWidget(hintText: "Cari alat..."),

          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 10),
            child: Row(
              children: [
                Container(
                  height: 35,
                  width: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedKategori,
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),

                      items: kategoriList.map((kategori) {
                        return DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori),
                        );
                      }).toList(),

                      onChanged: (value) {
                        setState(() {
                          selectedKategori = value!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Kategori terpilih: $selectedKategori",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xFF424242),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder(
              future: _futureAlat,
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (asyncSnapshot.hasError)
                  return Center(child: Text("Error: ${asyncSnapshot.error}"));

                // LOGIKA FILTER DISINI
                final semuaData = asyncSnapshot.data ?? [];
                final dataAlat = selectedKategori == "Semua"
                    ? semuaData
                    : semuaData
                          .where(
                            (alat) => alat.namaKategori == selectedKategori,
                          )
                          .toList();

                if (dataAlat.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada alat di kategori ini."),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: GridView.builder(
                    itemCount: dataAlat.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 kolom
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.70, // tinggi card
                        ),
                    itemBuilder: (context, index) {
                      final alat = dataAlat[index];

                      return CardListAlatWidget(
                        namaAlat: alat.namaAlat,
                        spesifikasiAlat: alat.spesifikasiAlat as String,
                        gambarUrl: alat.gambarUrl,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailAlatScreen(
                                heroTag: "alat_$index",
                                alat: alat,
                              ),
                            ),
                          );
                        },
                        tombolAksi: [
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/edit_alat'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Edit",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              AlertHelper.showConfirm(
                                context,
                                judul: "Konfirmasi Hapus Alat !",
                                pesan: "Apakah anda yakin menghapus alat ini ?",
                                onConfirm: () async {
                                  try {
                                    await _alatService.hapusAlat(alat.idUser!);

                                    AlertHelper.showSuccess(
                                      context,
                                      'Berhasil menghapus alat !',
                                    );

                                    setState(() {});
                                  } catch (e) {
                                    AlertHelper.showError(
                                      context,
                                      'Gagal menghapus alat !',
                                    );
                                    debugPrint('Error: $e');
                                  }
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Hapus",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/tambah_alat'),
        child: Icon(Icons.add_outlined),
        shape: CircleBorder(),
      ),
    );
  }
}
