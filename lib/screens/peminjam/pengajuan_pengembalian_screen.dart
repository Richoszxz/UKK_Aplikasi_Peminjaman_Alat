import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class PengajuanPengembalianScreen extends StatefulWidget {
  final Map<String, dynamic> peminjaman;
  const PengajuanPengembalianScreen({super.key, required this.peminjaman});

  @override
  State<PengajuanPengembalianScreen> createState() =>
      _PengajuanPengembalianScreenState();
}

class _PengajuanPengembalianScreenState
    extends State<PengajuanPengembalianScreen> {
  final PengembalianService _pengembalianService = PengembalianService();
  TextEditingController catatanController = TextEditingController();

  Map<String, String> kondisiPerAlat = {};

  final List<String> opsiKondisi = ["baik", "rusak"];

  @override
  void initState() {
    super.initState();
    final detail = widget.peminjaman['detail_peminjaman'] as List<dynamic>;

    for (var d in detail) {
      kondisiPerAlat[d['alat']['nama_alat']] = opsiKondisi[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.peminjaman['detail_peminjaman'] as List<dynamic>;

    return Scaffold(
      appBar: AppBarWidget(
        judulAppBar: "Pengajuan\nPengembalian",
        tombolKembali: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: ListView(
          children: [
            // ================= KODE TRANSAKSI =================
            _label("Kode Peminjaman"),
            _readonlyField(widget.peminjaman["kode_peminjaman"]),

            const SizedBox(height: 15),

            // ================= DAFTAR ALAT =================
            _label("Daftar Alat"),
            const SizedBox(height: 6),

            ...detail.map((item) {
              debugPrint('GAMBAR URL: ${item['alat']['gambar_url']}');
              return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _alatItem({
                  'nama': item['alat']['nama_alat'],
                  'qty': item['jumlah_peminjaman'],
                  'gambar': item['alat']['gambar_url'],
                }),
              );
            }),

            const SizedBox(height: 15),

            // ================= CATATAN =================
            _label("Catatan"),
            _textField(
              controller: catatanController,
              hint: "Tulis catatan (opsional)",
              maxLines: 3,
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 5,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final idPeminjaman = widget.peminjaman['id_peminjaman'];

                  await _pengembalianService.ajukanPengembalian(
                    id_peminjaman: idPeminjaman,
                    catatan: catatanController.text.trim().isEmpty
                        ? null
                        : catatanController.text.trim(),
                  );

                  if (mounted) Navigator.pop(context);
                  AlertHelper.showSuccess(
                    context,
                    'Berhasil mengajukan peminjaman, silahkan menemui laboran !',
                  );
                } catch (e) {
                  debugPrint('$e');
                  AlertHelper.showError(
                    context,
                    'Gagal mengajukan peminjaman !',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                "Ajukan Pengembalian",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------- WIDGET ALAT -------------------
  Widget _alatItem(Map<String, dynamic> alat) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
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
          // Gambar
          ClipRRect(
            child: (alat['gambar'] != null && alat['gambar'] != '')
                ? Image.network(
                    alat['gambar'],
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                  )
                : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image, size: 40),
                  ),
          ),

          const SizedBox(width: 12),

          // Info + Dropdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nama + Jumlah
                Text(
                  "${alat["nama"]} (x${alat["qty"]})",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),

                const SizedBox(height: 10),

                // Kondisi alat (Dropdown gaya custom)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    "Kondisi Alat:",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
                Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: kondisiPerAlat[alat["nama"]],
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      items: opsiKondisi.map((k) {
                        return DropdownMenuItem(value: k, child: Text(k));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          kondisiPerAlat[alat["nama"]] = value!;
                        });
                      },
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

  // ------------------- WIDGET UTILITY -------------------
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF424242),
        ),
      ),
    );
  }

  Widget _readonlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
      ),
    );
  }
}
