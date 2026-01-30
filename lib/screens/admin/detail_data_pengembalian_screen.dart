import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class DetailPengembalianScreen extends StatefulWidget {
  // Menerima data dari halaman Manajemen Pengembalian
  final ModelPengembalian data;

  const DetailPengembalianScreen({super.key, required this.data});

  @override
  State<DetailPengembalianScreen> createState() =>
      _DetailPengembalianScreenState();
}

class _DetailPengembalianScreenState extends State<DetailPengembalianScreen> {

  String formatTanggal(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    // Logika untuk mengambil inisial nama
    String nama = widget.data.peminjaman.first.namaUser ?? "User";
    String inisial = nama
        .split(' ')
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    return Scaffold(
      appBar: AppBarWidget(
        judulAppBar: "Detail\nPengembalian",
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
                  _buildBadgeStatus(widget.data.peminjaman.first.statusPeminjaman ?? "Dikembalikan"),
                ],
              ),
            ),

            const SizedBox(height: 15),
            // 2. KODE PEMINJAMAN
            _buildStaticField("Kode Peminjaman", widget.data.peminjaman.first.kodePeminjaman ?? "-"),

            // 3. TANGGAL PINJAM & RENCANA KEMBALI (Sejajar)
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
                          formatTanggal(widget.data.peminjaman.first.tanggalPeminjaman),
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
                          formatTanggal(widget.data.peminjaman.first.tanggalKembaliRencana),
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

            const SizedBox(height: 10),

            // 4. TANGGAL PENGEMBALIAN (Yang membedakan dengan Peminjaman)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tanggal pengembalian",
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
                    color: const Color(0xFFD9E9D9), // Hijau muda sesuai UI
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
                    formatTanggal(widget.data.tanggalKembaliAsli),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: const Color(0xFF2D7D46),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 5. DAFTAR ALAT
            _buildLabel("Daftar alat:"),
            // Kamu bisa mengganti ini dengan ListView.builder jika data alatnya dinamis dalam List
            _buildItemCardDetail("iPad M3 Pro", "1", "Baik"),
            _buildItemCardDetail("Stylus Pen", "1", "Baik"),

            // 6. KONFIRMASI PETUGAS
            _buildStaticField(
              "Dikonfirmasi oleh",
              widget.data.dikonfirmasiOleh ?? "Petugas 1",
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS (SAMA PERSIS DENGAN DETAIL PEMINJAMAN) ---

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
            color: const Color(0xFF424242),
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
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF424242),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF2D7D46),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildItemCardDetail(String nama, String qty, String kondisi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2D7D46),
              borderRadius: BorderRadius.circular(12),
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
