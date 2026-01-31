import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class TambahDataPengembalianScreen extends StatefulWidget {
  const TambahDataPengembalianScreen({super.key});

  @override
  State<TambahDataPengembalianScreen> createState() =>
      _TambahDataPengembalianScreenState();
}

class _TambahDataPengembalianScreenState
    extends State<TambahDataPengembalianScreen> {
  int? selectedIdPeminjaman;
  List<Map<String, dynamic>> listPeminjaman = [];
  List<dynamic> daftarAlat = [];
  Map<int, String> kondisiAlat = {};
  bool isLoading = false;

  String? selectedKode;
  DateTime? tglKembali;

  int terlambatHari = 0;
  int dendaTerlambat = 0;
  int dendaKerusakan = 0;
  int totalDenda = 0;

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  // hanya preview denda kerusakan bukan final
  int hitungDendaKerusakan(Map<int, String> kondisiAlat) {
    int total = 0;
    for (final kondisi in kondisiAlat.values) {
      if (kondisi == 'rusak') {
        total += 50000;
      }
    }
    return total;
  }

  Future<void> _loadPeminjaman() async {
    final res = await SupabaseService.client
        .from('peminjaman')
        .select('id_peminjaman, kode_peminjaman')
        .eq('status_peminjaman', 'dipinjam')
        .order('created_at');

    setState(() {
      listPeminjaman = List<Map<String, dynamic>>.from(res);
    });
  }

  Future<void> _loadDaftarAlat() async {
    final res = await SupabaseService.client
        .from('detail_peminjaman')
        .select('''
        id_detail_peminjaman,
        jumlah_peminjaman,
        kondisi_awal,
        alat ( nama_alat )
      ''')
        .eq('id_peminjaman', selectedIdPeminjaman as Object);

    setState(() {
      daftarAlat = res;

      kondisiAlat.clear();
      for (var item in res) {
        kondisiAlat[item['id_detail_peminjaman']] =
            item['kondisi_awal'] ?? 'baik';
      }
    });
  }

  Future<void> _previewDendaTerlambat() async {
    if (selectedIdPeminjaman == null || tglKembali == null) return;

    final res = await SupabaseService.client.rpc(
      'preview_denda_terlambat',
      params: {
        'p_id_peminjaman': selectedIdPeminjaman,
        'p_tanggal_kembali': tglKembali!.toIso8601String(),
      },
    );

    if (res != null && res.isNotEmpty) {
      setState(() {
        terlambatHari = res[0]['terlambat_hari'] ?? 0;
        dendaTerlambat = res[0]['denda_terlambat'] ?? 0;
        totalDenda = dendaTerlambat + dendaKerusakan;
      });
    }
  }

  Future<void> _simpanPengembalian() async {
    if (selectedIdPeminjaman == null || isLoading) return;

    setState(() => isLoading = true);

    try {
      final userId = SupabaseService.client.auth.currentUser!.id;

      // 1️⃣ insert pengembalian
      final pengembalian = await SupabaseService.client
          .from('pengembalian')
          .insert({
            'id_peminjaman': selectedIdPeminjaman,
            'tanggal_kembali_asli': DateTime.now().toIso8601String(),
            'dikonfirmasi_oleh': userId,
          })
          .select()
          .single();

      // 2️⃣ update kondisi kembali per alat
      for (final entry in kondisiAlat.entries) {
        await SupabaseService.client
            .from('detail_peminjaman')
            .update({'kondisi_kembali': entry.value})
            .eq('id_detail_peminjaman', entry.key);
      }

      if (mounted) Navigator.pop(context);

      AlertHelper.showSuccess(context, 'Berhasil menyimpan pengembalian !');
    } catch (e) {
      AlertHelper.showError(context, 'Gagal menyimpan pengembalian !');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        judulAppBar: "Tambah\nPengembalian",
        tombolKembali: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KODE PEMINJAMAN
            _buildLabel("Kode peminjaman:"),
            _buildDropdownKodePeminjaman(),
            const SizedBox(height: 20),

            // 2. TANGGAL PENGEMBALIAN
            _tanggalField(
              label: "Tanggal pengembalian:",
              selectedDate: tglKembali,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),

            // 3. DAFTAR ALAT (Muncul berdasarkan kode yang dipilih)
            _buildLabel("Daftar alat:"),
            Column(
              children: daftarAlat.map((item) {
                return _buildItemCard(item);
              }).toList(),
            ),

            // 4. RINGKASAN DENDA
            _buildLabel("Ringkasan Denda:"),
            _buildDendaCard(
              terlambatHari,
              dendaTerlambat,
              dendaKerusakan,
              totalDenda,
            ), // Default value dummy

            const SizedBox(height: 40),
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
              onPressed: isLoading ? null : _simpanPengembalian,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      "Buat Pengembalian",
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

  // --- WIDGET HELPERS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.secondary,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Theme.of(context).colorScheme.primary),
    );
  }

  Widget _buildDropdownKodePeminjaman() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _fieldDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedKode,
          hint: Text(
            "Pilih Kode Peminjaman",
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 14,
            ),
          ),
          dropdownColor: Theme.of(context).colorScheme.secondary,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          isExpanded: true,
          items: listPeminjaman.map((item) {
            return DropdownMenuItem<String>(
              value: item['kode_peminjaman'],
              child: Text(item['kode_peminjaman']),
            );
          }).toList(),
          onChanged: (kode) async {
            if (kode == null) return;

            setState(() => selectedKode = kode);

            final peminjaman = listPeminjaman.firstWhere(
              (e) => e['kode_peminjaman'] == kode,
            );

            selectedIdPeminjaman = peminjaman['id_peminjaman'];

            await _loadDaftarAlat();
            await _previewDendaTerlambat();
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        tglKembali = picked;
      });

      await _previewDendaTerlambat();
    }
  }

  Widget _tanggalField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: _fieldDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  selectedDate == null
                      ? "dd/mm/yyyy"
                      : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownKondisi(int idDetail) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 25,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: kondisiAlat[idDetail],
          dropdownColor: Theme.of(context).colorScheme.primary,
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          items: const [
            DropdownMenuItem(value: 'baik', child: Text('Baik')),
            DropdownMenuItem(value: 'rusak', child: Text('Rusak')),
          ],
          onChanged: (v) {
            setState(() {
              kondisiAlat[idDetail] = v!;

              dendaKerusakan = hitungDendaKerusakan(kondisiAlat);
              totalDenda = dendaTerlambat + dendaKerusakan;
            });
          },
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final idDetail = item['id_detail_peminjaman'];
    final namaAlat = item['alat']['nama_alat'];
    final qty = item['jumlah_peminjaman'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$namaAlat (x$qty)",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "Kondisi alat:",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    const SizedBox(width: 5),
                    _buildDropdownKondisi(idDetail),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dendaText(String label, String val, {bool isBold = false}) => Text(
    "$label $val",
    style: GoogleFonts.poppins(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 13,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    ),
  );

  Widget _buildDendaCard(
    int hari,
    int dendaterlambat,
    int dendaKerusakan,
    int totalDenda,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dendaText("Terlambat (hari):", "$hari Hari"),
          _dendaText("Denda Terlambat:", "Rp. $dendaterlambat"),
          _dendaText("Denda Kerusakan:", "Rp. $dendaKerusakan"),
          const Divider(color: Colors.black12),
          _dendaText("Total Denda:", "Rp. $totalDenda", isBold: true),
        ],
      ),
    );
  }
}
