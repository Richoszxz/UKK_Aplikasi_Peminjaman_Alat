import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class EditDataPengembalianScreen extends StatefulWidget {
  final ModelPengembalian data;

  const EditDataPengembalianScreen({super.key, required this.data});

  @override
  State<EditDataPengembalianScreen> createState() =>
      _EditDataPengembalianScreenState();
}

class _EditDataPengembalianScreenState
    extends State<EditDataPengembalianScreen> {
  String? selectedKode;
  DateTime? tglKembali;
  List<ModelDetailPeminjaman> daftarAlat = [];
  Map<String, String> kondisiAlat = {};
  bool isLoading = false;

  int terlambatHari = 0;
  int dendaTerlambat = 0;
  int dendaKerusakan = 0;
  int totalDenda = 0;

  @override
  void initState() {
    super.initState();
    selectedKode = widget.data.peminjaman?.kodePeminjaman;
    daftarAlat = widget.data.peminjaman!.detailPeminjaman;

    for (var item in daftarAlat) {
      kondisiAlat[item.namaAlat] = item.kondisiKembali ?? "Baik";
    }
  }

  int hitungDendaKerusakan() {
    int total = 0;
    for (var item in daftarAlat) {
      if (item.kondisiKembali?.toLowerCase() == 'rusak') total += 50000;
    }
    return total;
  }

  Future<void> _previewDendaTerlambat() async {
    final idPeminjaman = widget.data.peminjaman?.idPeminjaman;
    if (idPeminjaman == null || tglKembali == null) return;

    final res = await SupabaseService.client.rpc(
      'preview_denda_terlambat',
      params: {
        'p_id_peminjaman': idPeminjaman,
        'p_tanggal_kembali': tglKembali!.toIso8601String(),
      },
    );

    if (res != null && res.isNotEmpty) {
      setState(() {
        terlambatHari = res[0]['terlambat_hari'] ?? 0;
        dendaTerlambat = res[0]['denda_terlambat'] ?? 0;
        dendaKerusakan = hitungDendaKerusakan();
        totalDenda = dendaTerlambat + dendaKerusakan;
      });
    }
  }

  Future<void> _updatePengembalian() async {
    if (tglKembali == null || isLoading) return;

    try {
      final userId = SupabaseService.client.auth.currentUser!.id;

      // Update pengembalian
      await SupabaseService.client
          .from('pengembalian')
          .update({
            'tanggal_kembali_asli': tglKembali!.toIso8601String(),
            'dikonfirmasi_oleh': userId,
          })
          .eq('id_pengembalian', widget.data.idPengembalian);

      // Update kondisi alat
      for (var item in daftarAlat) {
        await SupabaseService.client
            .from('detail_peminjaman')
            .update({'kondisi_kembali': item.kondisiKembali})
            .eq('id_detail_peminjaman', item.idDetailPeminjaman);
      }

      if (mounted) Navigator.pop(context);
      AlertHelper.showSuccess(context, 'Berhasil update pengembalian!');
    } catch (e) {
      AlertHelper.showError(context, 'Gagal update pengembalian!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        judulAppBar: "Edit\nPengembalian",
        tombolKembali: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Kode peminjaman:"),
            _buildDropdownKodePeminjaman(), // Buat dropdown disabled agar kode tidak bisa diganti
            const SizedBox(height: 20),
            _tanggalField(
              label: "Tanggal pengembalian:",
              selectedDate: widget.data.tanggalKembaliAsli,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            _buildLabel("Daftar alat:"),
            Column(children: daftarAlat.map(_buildItemCard).toList()),
            const SizedBox(height: 20),
            _buildLabel("Ringkasan Denda:"),
            _buildDendaCard(
              terlambatHari,
              dendaTerlambat,
              dendaKerusakan,
              totalDenda,
            ), // Hitung ulang denda jika tglKembali berubah
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _updatePengembalian,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "Simpan Perubahan",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
              ),
      ),
    );
  }

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
          isExpanded: true,
          items: [
            DropdownMenuItem(value: selectedKode, child: Text('$selectedKode')),
          ],
          onChanged: null,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          tglKembali ?? widget.data.tanggalKembaliAsli ?? DateTime.now(),
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

  Widget _buildDropdownKondisi(ModelDetailPeminjaman item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 25,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: item.kondisiKembali ?? item.kondisiAlat,
          dropdownColor: Theme.of(context).colorScheme.primary,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 16,
          ),
          items: ["baik", "rusak"]
              .map(
                (val) => DropdownMenuItem(
                  value: val,
                  child: Text(
                    val,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              )
              .toList(),
          onChanged: (newVal) {
            setState(() {
              item.kondisiKembali = newVal;
            });
          },
        ),
      ),
    );
  }

  Widget _buildItemCard(ModelDetailPeminjaman item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
                  "${item.namaAlat} (x${item.jumlahPeminjaman})",
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
                      "Kondisi alat: ",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    const SizedBox(width: 5),
                    _buildDropdownKondisi(item),
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
