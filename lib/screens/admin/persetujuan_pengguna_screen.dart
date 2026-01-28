import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class PersetujuanPenggunaScreen extends StatefulWidget {
  const PersetujuanPenggunaScreen({super.key});

  @override
  State<PersetujuanPenggunaScreen> createState() =>
      _PersetujuanPenggunaScreenState();
}

class _PersetujuanPenggunaScreenState extends State<PersetujuanPenggunaScreen> {
  final PenggunaService _penggunaService = PenggunaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        judulAppBar: "Persetujuan\nPengguna",
        tombolKembali: true,
      ),
      drawer: NavigationDrawerWidget(),
      body: FutureBuilder<List<ModelPengguna>>(
        future: _penggunaService.ambilPenggunaButuhPersetujuan(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Tidak ada permintaan bergabung",
                style: GoogleFonts.poppins(color: Color(0xFF424242)),
              ),
            );
          }

          final listButuhPersetujuan = asyncSnapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: listButuhPersetujuan.length,
            itemBuilder: (context, index) {
              final pengguna = listButuhPersetujuan[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 75,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 5,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      title: Text(
                        pengguna.userName ?? 'Nama',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        pengguna.email ?? 'email@example.com',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 16,
                        ),
                      ),
                      trailing: InkWell(
                        onTap: () async {
                          try {
                            // Panggil fungsi update status ke database
                            await _penggunaService.tombolPenggunaDisetujui(
                              pengguna.idUser!,
                            );

                            // REFRESH LIST: Karena status jadi true, dia akan hilang dari ambilPenggunaButuhPersetujuan()
                            if (mounted) {
                              setState(() {});
                            }

                            // Beri notifikasi sukses
                            if (mounted) {
                              AlertHelper.showSuccess(
                                context,
                                'Berhasil menyetujui pengguna !',
                                onOk: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PersetujuanPenggunaScreen(),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              AlertHelper.showError(
                                context,
                                "Gagal menyetujui pengguna !",
                              );
                            }
                          }
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
