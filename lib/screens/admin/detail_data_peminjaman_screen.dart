import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import 'package:intl/intl.dart';

class DetailPeminjamanScreen extends StatefulWidget {
  // Menerima data dari halaman Manajemen
  final ModelPeminjaman data;

  const DetailPeminjamanScreen({super.key, required this.data});

  @override
  State<DetailPeminjamanScreen> createState() => _DetailPeminjamanScreenState();
}

class _DetailPeminjamanScreenState extends State<DetailPeminjamanScreen> {
  @override
  Widget build(BuildContext context) {
    // Logika untuk mengambil inisial nama (Contoh: Richo Ferdinand -> RF)
    String nama = widget.data.namaUser ?? "User";
    String inisial = nama
        .split(' ')
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    final dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBarWidget(
        judulAppBar: "Detail\nPeminjaman",
        tombolKembali: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. HEADER (Avatar & Nama)
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      inisial,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nama,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  // Badge Status (Opsional, sesuaikan jika ada data status)
                  _buildBadgeStatus(widget.data.statusPeminjaman),
                ],
              ),
            ),

            SizedBox(height: 15),
            // 2. KODE PEMINJAMAN
            _buildStaticField(
              "Kode Peminjaman",
              widget.data.kodePeminjaman ?? "-",
            ),

            SizedBox(height: 10),

            // 3. TANGGAL (Sejajar)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tanggal peminjaman",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFD9E9D9,
                          ), // Hijau muda sesuai UI
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF2D7D46).withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 5,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          dateFormatter.format(widget.data.tanggalPeminjaman),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: const Color(0xFF2D7D46),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rencana pengembalian",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFD9E9D9,
                          ), // Hijau muda sesuai UI
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF2D7D46).withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 5,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          dateFormatter.format(
                            widget.data.tanggalKembaliRencana,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: const Color(0xFF2D7D46),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            // 4. DAFTAR ALAT
            _buildLabel("Daftar alat:"),
            // Jika data alat ada di dalam map, kita loop.
            // Jika tidak, kita pakai data dummy untuk visualisasi dulu.
            ...widget.data.detailPeminjaman.map((item) {
              return _buildItemCardDetail(
                item.namaAlat,
                item.jumlahPeminjaman,
                item.kondisiAlat,
                item.gambarAlat
              );
            }),

            // 5. PENYETUJU
            _buildStaticField(
              "Disetujui oleh",
              widget.data.namaPenyetuju ?? "Petugas",
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeStatus(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: const Color(0xFF2D7D46),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStaticField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFD9E9D9), // Hijau muda sesuai UI
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF2D7D46).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 5,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF2D7D46),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCardDetail(
    String nama,
    int qty,
    String kondisi,
    String? gambar,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E9D9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF2D7D46).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: gambar != null && gambar.isNotEmpty
                ? Image.network(
                    gambar,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$nama (x$qty)",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D7D46),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "Kondisi alat: ",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D7D46),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        kondisi,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
