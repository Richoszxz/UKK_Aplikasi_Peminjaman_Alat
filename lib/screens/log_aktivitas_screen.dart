import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class LogAktivitasScreen extends StatefulWidget {
  const LogAktivitasScreen({super.key});

  @override
  State<LogAktivitasScreen> createState() => _LogAktivitasScreenState();
}

class _LogAktivitasScreenState extends State<LogAktivitasScreen> {
  final LogService _logService = LogService();

  String _formatWaktu(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  return '${diff.inDays} hari lalu';
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(judulAppBar: "Log\nAktivitas"),
      drawer: const NavigationDrawerWidget(),
      body: FutureBuilder(
        future: _logService.ambilLog(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (asyncSnapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${asyncSnapshot.error}',
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final logs = asyncSnapshot.data ?? [];

          if (logs.isEmpty) {
            return Center(
              child: Text(
                'Belum ada log aktivitas',
                style: GoogleFonts.poppins(),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final item = logs[index];
              return _buildLogTile(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogTile(ModelLog log) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
        border: BoxBorder.all(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        title: Text(
          log.judulLog,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.keteranganLog,
              maxLines: 1,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              _formatWaktu(log.waktuLog!),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        // ICON DI KANAN DENGAN KOTAK DI BELAKANGNYA
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary, // Warna Kotak
            borderRadius: BorderRadius.circular(10),
            border: BoxBorder.all(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.history,
            color: Theme.of(context).colorScheme.onSecondary, // Warna Ikon
            size: 24,
          ),
        ),
      ),
    );
  }
}
