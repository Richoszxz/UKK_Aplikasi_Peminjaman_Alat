import 'package:creaventory/export.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/admin/manajemen_pengguna_screen.dart';
import 'screens/admin/persetujuan_pengguna_screen.dart';
import 'screens/admin/manajemen_alat_screen.dart';
import 'screens/admin/manajemen_kategori_screen.dart';
import 'screens/admin/manajemen_data_peminjaman_screen.dart';
import 'screens/admin/manajemen_data_pengembalian_screen.dart';
import 'screens/peminjam/pengajuan_peminjaman_screen.dart';
import 'screens/peminjam/riwayat_peminjaman_screen.dart';
import 'screens/petugas/monitoring_peminjaman_screen.dart';
import 'screens/petugas/monitoring_pengembalian_screen.dart';
import 'screens/admin/tambah_alat_screen.dart';
import 'screens/admin/edit_alat_screen.dart';
import 'screens/admin/tambah_kategori_screen.dart';
import 'screens/admin/edit_kategori_screen.dart';
import 'screens/petugas/cetak_kartu_peminjaman_screen.dart';
import 'screens/peminjam/keranjang_peminjaman_screen.dart';
import 'screens/log_aktivitas_screen.dart';
import 'screens/profil_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
        dividerColor: Colors.transparent,
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF248250),
          foregroundColor: Color(0xFFF5F7FA),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF5F7FA),
          ),
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF248250),
          onPrimary: Color(0xFFD0E6D1),
          secondary: Color(0xFFD0E6D1),
          onSecondary: Color(0xFF248250),
          error: Colors.red,
          onError: Colors.white,
          surface: Color(0xFFF5F7FA),
          onSurface: Colors.black,
        ),
        drawerTheme: DrawerThemeData(
          scrimColor: Color(0xFF248250).withOpacity(0.5),
        ),
      ),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/manajemen_pengguna': (context) => const ManajemenPenggunaScreen(),
        '/persetujuan_pengguna': (context) => const PersetujuanPenggunaScreen(),
        '/manajemen_alat': (context) => const ManajemenAlatScreen(),
        '/manajemen_kategori': (context) => const ManajemenKategoriScreen(),
        '/manajemen_data_peminjaman': (context) =>
            const ManajemenDataPeminjamanScreen(),
        '/manajemen_data_pengembalian': (context) =>
            const ManajemenDataPengembalianScreen(),
        '/pengajuan_peminjaman': (context) => const PengajuanPeminjamanScreen(),
        '/riwayat_peminjaman': (context) => const RiwayatPeminjamanScreen(),
        '/monitoring_peminjaman': (context) =>
            const MonitoringPeminjamanScreen(),
        '/monitoring_pengembalian': (context) =>
            const MonitoringPengembalianScreen(),
        '/tambah_alat': (context) => const TambahAlatScreen(),
        '/edit_alat': (context) => const EditAlatScreen(),
        '/tambah_kategori': (context) => TambahKategoriScreen(),
        '/edit_kategori': (context) => EditKategoriScreen(),
        '/cetak_kartu_peminjaman': (context) => CetakKartuPeminjamanScreen(),
        '/keranjang_peminjaman': (context) => KeranjangPeminjamanScreen(),
        '/log_aktivitas': (context) => LogAktivitasScreen(),
        '/profil': (context) => ProfilScreen(),
      },
    );
  }
}
