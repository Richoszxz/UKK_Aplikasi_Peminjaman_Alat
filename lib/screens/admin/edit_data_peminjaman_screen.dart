import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class BarisAlat {
  ModelAlat? alat;
  int qty;

  BarisAlat({this.alat, this.qty = 1});
}

class EditDataPeminjamanScreen extends StatefulWidget {
  final ModelPeminjaman data; // Menerima data lama

  const EditDataPeminjamanScreen({super.key, required this.data});

  @override
  State<EditDataPeminjamanScreen> createState() =>
      _EditDataPeminjamanScreenState();
}

class _EditDataPeminjamanScreenState extends State<EditDataPeminjamanScreen> {
  DateTime? tglPinjam;
  DateTime? tglRencanaKembali;
  List<BarisAlat> barisAlat = [BarisAlat()];
  ModelPengguna? peminjamTerpilih;
  ModelAlat? alatDipinjam;
  final PeminjamanService _peminjamanService = PeminjamanService();
  bool isLoading = false;

  final PenggunaService _penggunaService = PenggunaService();
  List<ModelPengguna> listPengguna = [];

  final AlatService _alatService = AlatService();
  List<ModelAlat> listAlat = [];

  Future<void> _loadData() async {
    try {
      final pengguna = await _penggunaService.ambilPengguna();
      final alat = await _alatService.ambilAlat();

      setState(() {
        listPengguna = pengguna;
        listAlat = alat;

        // PREFILL PEMINJAM
        peminjamTerpilih = listPengguna.firstWhere(
          (u) => u.idUser == widget.data.idUser,
        );

        // PREFILL ALAT
        barisAlat = widget.data.detailPeminjaman.map((d) {
          final alatDipinjam = listAlat.firstWhere((a) => a.idAlat == d.idAlat);
          return BarisAlat(alat: alatDipinjam, qty: d.jumlahPeminjaman);
        }).toList();
      });
    } catch (e) {
      debugPrint("Gagal load edit data: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    tglPinjam = widget.data.tanggalPeminjaman;
    tglRencanaKembali = widget.data.tanggalKembaliRencana;

    _loadData();
  }

  Future<void> _editPeminjaman() async {
    try {
      if (peminjamTerpilih == null) {
        throw Exception("Peminjam belum dipilih");
      }

      if (tglPinjam == null || tglRencanaKembali == null) {
        throw Exception("Tanggal belum lengkap");
      }

      final alatValid = barisAlat.where((e) => e.alat != null).toList();
      if (alatValid.isEmpty) {
        throw Exception("Minimal pilih 1 alat");
      }

      final detailAlat = alatValid.map((e) {
        final ModelAlat alat = e.alat!;
        return {'id_alat': alat.idAlat, 'qty': e.qty};
      }).toList();

      await _peminjamanService.editPeminjaman(
        idPeminjaman: widget.data.idPeminjaman,
        idUser: peminjamTerpilih!.idUser!,
        tglPinjam: tglPinjam!,
        tglRencanaKembali: tglRencanaKembali!,
        detailAlat: detailAlat,
      );

      if (mounted) Navigator.pop(context);
      AlertHelper.showSuccess(context, "Berhasil mengupdate peminjaman");
    } catch (e) {
      AlertHelper.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        judulAppBar: "Edit\nPeminjaman",
        tombolKembali: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Nama peminjam:"),
            _buildDropdownSiswa(),
            const SizedBox(height: 20),
            ...List.generate(
              barisAlat.length,
              (index) => _buildBarisInputAlat(index),
            ),
            const SizedBox(height: 10),
            _buildButtonTambahBaris(),
            const SizedBox(height: 25),
            _tanggalField(
              label: "Tanggal peminjaman:",
              selectedDate: tglPinjam,
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 20),
            _tanggalField(
              label: "Rencana tanggal pengembalian:",
              selectedDate: tglRencanaKembali,
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- Gunakan helper methods yang sama dengan TambahDataPeminjaman (Dropdown, Field, dll) ---
  // Pastikan memanggil setState saat mengubah barisAlat atau tanggal

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _editPeminjaman,
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

  // WIDGET BARIS INPUT (Dropdown + Jumlah)
  Widget _buildBarisInputAlat(int index) {
    final baris = barisAlat[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Pilih Alat
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0) _buildLabel("Pilih alat:"),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: _fieldDecoration(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ModelAlat>(
                      value: baris.alat,
                      isExpanded: true,
                      hint: Text("Pilih alat"),
                      dropdownColor: Theme.of(context).colorScheme.secondary,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      items: listAlat.map((alat) {
                        return DropdownMenuItem<ModelAlat>(
                          value: alat,
                          child: Text(alat.namaAlat),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() => baris.alat = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Input Jumlah
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0) _buildLabel("Jumlah:"),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: _fieldDecoration(),
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      setState(() => baris.qty = int.tryParse(v) ?? 1);
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: baris.qty.toString(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (barisAlat.length > 1)
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => setState(() => barisAlat.removeAt(index)),
            ),
        ],
      ),
    );
  }

  Widget _buildButtonTambahBaris() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          setState(() {
            // Menambah "Template" data kosong ke list agar baris baru muncul
            barisAlat.add(BarisAlat());
          });
        },
        child: Text(
          "+ Tambah",
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // --- REUSABLE COMPONENTS ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDropdownSiswa() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: _fieldDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ModelPengguna>(
          value: peminjamTerpilih,
          dropdownColor: Theme.of(context).colorScheme.secondary,
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 15,
          ),
          hint: Text(
            "Pilih Siswa",
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          isExpanded: true,
          items: listPengguna.map((item) {
            return DropdownMenuItem<ModelPengguna>(
              value: item, // sesuaikan field modelmu
              child: Text(item.userName ?? '-'),
            );
          }).toList(),
          onChanged: (v) => setState(() => peminjamTerpilih = v),
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

  Future<void> _selectDate(BuildContext context, bool isPinjam) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(
        () => isPinjam ? tglPinjam = picked : tglRencanaKembali = picked,
      );
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
}
