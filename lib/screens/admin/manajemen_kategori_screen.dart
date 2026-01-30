import 'package:creaventory/widgets/card_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class ManajemenKategoriScreen extends StatefulWidget {
  const ManajemenKategoriScreen({super.key});

  @override
  State<ManajemenKategoriScreen> createState() =>
      _ManajemenKategoriScreenState();
}

class _ManajemenKategoriScreenState extends State<ManajemenKategoriScreen> {
  final KategoriService _kategoriService = KategoriService();
  String keywordPencarian = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Manajemen\nKategori"),
      drawer: NavigationDrawerWidget(),
      body: Column(
        children: [
          BarPencarianWidget(
            hintText: "Cari kategori...",
            onSearch: (value) {
              setState(() {
                keywordPencarian = value.toLowerCase();
              });
            },
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: FutureBuilder(
                future: _kategoriService.ambilKategori(),
                builder: (context, asyncSnapshot) {
                  // State Loading
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // State Error
                  if (asyncSnapshot.hasError) {
                    return Center(child: Text("Error: ${asyncSnapshot.error}"));
                  }

                  // State Data Kosong
                  if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
                    return const Center(child: Text("Tidak ada data pengguna"));
                  }

                  final semuaData = asyncSnapshot.data!;

                  final data = semuaData.where((kategori) {
                    return kategori.namaKategori
                        .toString()
                        .toLowerCase()
                        .contains(keywordPencarian);
                  }).toList();

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final listKategori = data[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: CardListWidget(
                          title: listKategori.namaKategori,
                          subtitle:
                              listKategori.deskripsiKategori ??
                              'Tidak ada deskripsi kategori',
                          diEdit: () => Navigator.of(context).pushNamed(
                            '/edit_kategori',
                            arguments: listKategori,
                          ),
                          diHapus: () async {
                            await _kategoriService.hapusKategori(
                              listKategori.idKategori!,
                            );
                            setState(() {});
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
        onPressed: () => Navigator.of(context).pushNamed('/tambah_kategori'),
        child: Icon(Icons.add_outlined),
        shape: CircleBorder(),
      ),
    );
  }
}
