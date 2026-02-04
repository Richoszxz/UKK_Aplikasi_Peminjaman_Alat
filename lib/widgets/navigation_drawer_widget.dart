import 'package:creaventory/export.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({super.key});

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final _supabase = SupabaseService.client;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole(); // Ambil role saat drawer pertama kali dibuat
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('user_role') ?? 'peminjam';
    });
  }

  // Fungsi ambil username dari tabel pengguna
  Future<String> _getUsername() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return "Guest";
      
      final data = await _supabase
          .from('pengguna')
          .select('username')
          .eq('id_user', user.id)
          .single();
      
      return data['username'] ?? "User";
    } catch (e) {
      return "User Creaventory";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika role belum keload, tampilkan loading/drawer kosong sebentar
    if (_role == null) return const Drawer(child: Center(child: CircularProgressIndicator()));

    return Drawer(
      backgroundColor: const Color(0xFFD0E6D1),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // HEADER DENGAN USERNAME DINAMIS
          FutureBuilder<String>(
            future: _getUsername(),
            builder: (context, snapshot) {
              return SizedBox(
                height: 260,
                child: DrawerHeader(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Color(0xFF248250)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFFD0E6D1),
                          child: Icon(Icons.account_circle_outlined, size: 90, color: Color(0xFF248250)),
                        ),
                        Text(
                          snapshot.data ?? "Loading...",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD0E6D1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/profil'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            "Lihat Profil",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD0E6D1),
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // 2. KHUSUS ADMIN (Manajemen)
          if (_role == 'admin') ...[
            _buildItem(Icons.dashboard_outlined, 'Dashboard', '/dashboard'),
            _buildItem(Icons.group_outlined, 'Manajemen Pengguna', '/manajemen_pengguna'),
            _buildItem(Icons.build_outlined, 'Manajemen Alat', '/manajemen_alat'),
            _buildItem(Icons.category_outlined, 'Manajemen Kategori', '/manajemen_kategori'),
            _buildItem(Icons.assignment_outlined, 'Manajemen Peminjaman', '/manajemen_data_peminjaman'),
            _buildItem(Icons.assignment_returned_outlined, 'Manajemen Pengembalian', '/manajemen_data_pengembalian'),
            _buildItem(Icons.history_outlined, 'Log Aktivitas', '/log_aktivitas'),
          ],

          // 3. KHUSUS PETUGAS (Monitoring)
          if (_role == 'petugas') ...[
            _buildItem(Icons.dashboard_outlined, 'Dashboard', '/dashboard'),
            _buildItem(Icons.track_changes_outlined, 'Monitoring Peminjaman', '/monitoring_peminjaman'),
            _buildItem(Icons.fact_check_outlined, 'Monitoring Pengembalian', '/monitoring_pengembalian'),
          ],

          // 4. KHUSUS PEMINJAM (Pengajuan & Riwayat)
          if (_role == 'peminjam') ...[
            _buildItem(Icons.assignment_add, 'Pengajuan Peminjaman', '/pengajuan_peminjaman'),
            _buildItem(Icons.receipt_long_outlined, 'Riwayat Peminjaman', '/riwayat_peminjaman'),
          ],
        ],
      ),
    );
  }

  // Helper biar kode ListTile nggak panjang berulang-ulang
  Widget _buildItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF424242)),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF424242)),
      ),
      onTap: () => Navigator.of(context).pushReplacementNamed(route),
    );
  }
}