import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import 'package:creaventory/widgets/card_list_alat_widget.dart';
import 'package:creaventory/services/keranjang_service.dart';

class PengajuanPeminjamanScreen extends StatefulWidget {
  const PengajuanPeminjamanScreen({super.key});

  @override
  State<PengajuanPeminjamanScreen> createState() =>
      _PengajuanPeminjamanScreenState();
}

class _PengajuanPeminjamanScreenState extends State<PengajuanPeminjamanScreen> {
  final AlatService _alatService = AlatService();
  final KategoriService _kategoriService = KategoriService();
  final KeranjangService _keranjangService = KeranjangService();

  String selectedKategori = "Semua";
  List<String> kategoriList = ["Semua"];
  String keywordPencarian = "";

  Future<void> _loadKategori() async {
    try {
      final data = await _kategoriService.ambilKategori();

      if (!mounted) return;

      setState(() {
        kategoriList = [
          "Semua",
          ...(data).map((e) => e.namaKategori.toString()),
        ];
      });
    } catch (e) {
      debugPrint("Error kategori: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Pengajuan\nPeminjaman"),
      drawer: NavigationDrawerWidget(),
      body: Column(
        children: [
          BarPencarianWidget(
            hintText: "Cari alat...",
            onSearch: (value) {
              setState(() {
                keywordPencarian = value.toLowerCase();
              });
            },
          ),

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
                      value: kategoriList.contains(selectedKategori)
                          ? selectedKategori
                          : kategoriList.first,
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),

                      items: kategoriList.isEmpty
                          ? []
                          : kategoriList
                                .map(
                                  (kategori) => DropdownMenuItem<String>(
                                    value: kategori,
                                    child: Text(kategori),
                                  ),
                                )
                                .toList(),

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
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xFF424242),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= GRID ALAT =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FutureBuilder<List<ModelAlat>>(
                future: _alatService.ambilAlat(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (asyncSnapshot.hasError) {
                    return Center(child: Text("Error: ${asyncSnapshot.error}"));
                  }

                  final semuaData = asyncSnapshot.data ?? [];

                  final dataAlat = semuaData.where((alat) {
                    final cocokKategori = selectedKategori == "Semua"
                        ? true
                        : alat.namaKategori == selectedKategori;

                    final cocokSearch = alat.namaAlat
                        .toString()
                        .toLowerCase()
                        .contains(keywordPencarian);

                    return cocokKategori && cocokSearch;
                  }).toList();

                  if (dataAlat.isEmpty) {
                    return Center(
                      child: Text(
                        "Tidak ada alat tersedia",
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }

                  final screenWidth = MediaQuery.of(context).size.width;

                  // Atur jumlah kolom & childAspectRatio sesuai lebar layar
                  int crossAxisCount;
                  double childAspectRatio;

                  if (screenWidth >= 1200) {
                    crossAxisCount = 4;
                    childAspectRatio = 1.20;
                  } else if (screenWidth >= 800) {
                    crossAxisCount = 3;
                    childAspectRatio = 0.6;
                  } else if (screenWidth >= 600) {
                    crossAxisCount = 2;
                    childAspectRatio = 0.65;
                  } else {
                    crossAxisCount = 2;
                    childAspectRatio = 0.69; // HP
                  }

                  return GridView.builder(
                    itemCount: dataAlat.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount, // 2 kolom
                      crossAxisSpacing: 10,
                      childAspectRatio: childAspectRatio, // tinggi card
                    ),
                    itemBuilder: (context, index) {
                      final alat = dataAlat[index];

                      return CardListAlatWidget(
                        namaAlat: alat.namaAlat,
                        spesifikasiAlat: alat.spesifikasiAlat!,
                        gambarUrl: alat.gambarUrl,
                        tombolAksi: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _keranjangService.tambahItem({
                                    "id_alat": alat.idAlat,
                                    "nama": alat.namaAlat,
                                    "spesifikasi": alat.spesifikasiAlat,
                                    "gambar": alat.gambarUrl,
                                  });
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    content: Text(
                                      "${alat.namaAlat} ditambahkan ke keranjang",
                                      style: GoogleFonts.poppins(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "+ Pinjam",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(
              context,
            ).pushNamed('/keranjang_peminjaman').then((_) => setState(() {})),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.shopping_bag_outlined),
          ),

          if (_keranjangService.totalItem > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _keranjangService.totalItem.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
