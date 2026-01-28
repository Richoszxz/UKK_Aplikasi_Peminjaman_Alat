import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int penggunaAktif = 0;
  int jumlahAlat = 0;
  int alatDipinjam = 0;
  int alatTersedia = 0;
  bool isLoading = true;

  Future<void> loadDashboard() async {
    try {
      final client = SupabaseService.client;

      /// 1️⃣ Pengguna aktif
      final pengguna = await client
          .from('pengguna')
          .select('id_user')
          .eq('status', true);

      /// 2️⃣ Total alat + total stok
      final alat = await client.from('alat').select('id_alat, stok_alat');

      int totalStok = 0;
      for (final item in alat) {
        totalStok += (item['stok_alat'] as int);
      }

      /// 3️⃣ Alat sedang dipinjam
      final dipinjam = await client
          .from('detail_peminjaman')
          .select('jumlah_peminjaman, peminjaman!inner(status_peminjaman)')
          .inFilter('peminjaman.status_peminjaman', ['menunggu', 'dipinjam']);

      int totalDipinjam = 0;
      for (final item in dipinjam) {
        totalDipinjam += (item['jumlah_peminjaman'] as int);
      }

      setState(() {
        penggunaAktif = pengguna.length;
        jumlahAlat = alat.length;
        alatDipinjam = totalDipinjam;
        alatTersedia = totalStok - totalDipinjam;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal load dashboard: $e");
      isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Dashboard"),
      drawer: NavigationDrawerWidget(),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // ===================== DASHBOARD CARD =====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildDashboardCard(
                context,
                "Pengguna Aktif",
                isLoading ? "-" : penggunaAktif.toString(),
                Theme.of(context).colorScheme.secondary,
              ),
              buildDashboardCard(
                context,
                "Jumlah Alat",
                isLoading ? "-" : jumlahAlat.toString(),
                Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildDashboardCard(
                context,
                "Alat Dipinjam",
                isLoading ? "-" : alatDipinjam.toString(),
                Theme.of(context).colorScheme.secondary,
              ),
              buildDashboardCard(
                context,
                "Alat Tersedia",
                isLoading ? "-" : alatTersedia.toString(),
                Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ===================== CETAK LAPORAN =====================
          Text(
            "Cetak Laporan:",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF424242),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: 5,
            ),
            width: double.infinity,
            height: 135,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSecondary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.insert_drive_file_outlined,
                        size: 35,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      "Laporan Peminjaman",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.print_outlined,
                          size: 24,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Cetak",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildDashboardCard(
  BuildContext context,
  String title,
  String count,
  Color color,
) {
  return Container(
    margin: EdgeInsets.all(5),
    height: MediaQuery.of(context).size.height * 0.20,
    width: MediaQuery.of(context).size.width * 0.43,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 5,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}
