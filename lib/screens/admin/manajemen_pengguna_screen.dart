import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import '../../widgets/card_list_widget.dart';
import 'package:creaventory/screens/admin/edit_pengguna_screen.dart';

class ManajemenPenggunaScreen extends StatefulWidget {
  const ManajemenPenggunaScreen({super.key});

  @override
  State<ManajemenPenggunaScreen> createState() =>
      _ManajemenPenggunaScreenState();
}

class _ManajemenPenggunaScreenState extends State<ManajemenPenggunaScreen> {
  final PenggunaService _penggunaService = PenggunaService();
  String keywordPencarian = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Manajemen\nPengguna"),
      drawer: NavigationDrawerWidget(),
      body: Column(
        children: [
          BarPencarianWidget(
            hintText: 'Cari pengguna...',
            onSearch: (value) {
              setState(() {
                keywordPencarian = value.toLowerCase();
              });
            },
          ),
          Expanded(
            child: FutureBuilder<List<ModelPengguna>>(
              future: _penggunaService.ambilPengguna(),
              builder: (context, asyncSnapshot) {
                // State Loading
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
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

                final semuaData = asyncSnapshot.data!
                    .where((e) => e != null)
                    .toList();

                final data = semuaData.where((pengguna) {
                  final keyword = keywordPencarian;

                  if (keyword.isEmpty) return true;

                  final cocokUsername =
                      pengguna.userName?.toLowerCase().contains(keyword) ??
                      false;

                  final cocokEmail =
                      pengguna.email?.toLowerCase().contains(keyword) ?? false;

                  return cocokUsername || cocokEmail;
                }).toList();

                if (data.isEmpty) {
                  return Center(
                    child: Text(
                      "Pengguna tidak ditemukan",
                      style: GoogleFonts.poppins(),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final pengguna = data[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      child: CardListWidget(
                        title: pengguna.userName ?? "Tanpa Nama",
                        subtitle: pengguna.email ?? "-",
                        diEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPenggunaScreen(),
                            settings: RouteSettings(arguments: pengguna),
                          ),
                        ).then((_) => setState(() {})),
                        diHapus: () {
                          AlertHelper.showConfirm(
                            context,
                            judul: "Menghapus Pengguna !",
                            pesan: "Apakah anda yakin menghapus pengguna ini ?",
                            onConfirm: () async {
                              try {
                                await _penggunaService.hapusPengguna(
                                  pengguna.idUser!,
                                );

                                AlertHelper.showSuccess(
                                  context,
                                  'Berhasil menghapus pengguna !',
                                  onOk: () => Navigator.pop(context),
                                );

                                setState(() {});
                              } catch (e) {
                                AlertHelper.showError(
                                  context,
                                  'Gagal menghapus pengguna !',
                                );
                                debugPrint('$e');
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
        ],
      ),
      floatingActionButton: FutureBuilder<List<ModelPengguna>>(
        future: _penggunaService.ambilPenggunaButuhPersetujuan(),
        builder: (context, snapshot) {
          int jumlah = snapshot.data?.length ?? 0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                onPressed: () async {
                  await Navigator.of(
                    context,
                  ).pushNamed('/persetujuan_pengguna');
                  setState(() {}); // Refresh data saat kembali
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.group_add_outlined,
                  color: Colors.white,
                ),
              ),
              if (jumlah > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$jumlah',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
