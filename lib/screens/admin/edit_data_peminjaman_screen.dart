import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class EditDataPeminjamanScreen extends StatefulWidget {
  final ModelPeminjaman data; // Menerima data lama

  const EditDataPeminjamanScreen({super.key, required this.data});

  @override
  State<EditDataPeminjamanScreen> createState() =>
      _EditDataPeminjamanScreenState();
}

class _EditDataPeminjamanScreenState extends State<EditDataPeminjamanScreen> {
  String? peminjamTerpilih;
  DateTime? tglPinjam;
  DateTime? tglRencanaKembali;
  List<Map<String, dynamic>> barisAlat = [];

  final PenggunaService _penggunaService = PenggunaService();
  List<ModelPengguna> listPengguna = [];

  final AlatService _alatService = AlatService();
  List<ModelAlat> listAlat = [];

  Future<void> loadPengguna() async {
    try {
      final result = await _penggunaService.ambilPengguna();
      setState(() {
        listPengguna = result;
      });
    } catch (e) {
      debugPrint("Gagal load pengguna: $e");
    }
  }

  Future<void> loadAlat() async {
    try {
      final result = await _alatService.ambilAlat();
      setState(() {
        listAlat = result;
      });
    } catch (e) {
      debugPrint("Gagal load alat: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    peminjamTerpilih = widget.data.namaUser;
    tglPinjam = widget.data.tanggalPeminjaman;
    tglRencanaKembali = widget.data.tanggalKembaliRencana;

    loadPengguna();
    loadAlat();

    // ✅ Ambil data alat lama
    if (widget.data.detailPeminjaman.isNotEmpty) {
      barisAlat = widget.data.detailPeminjaman
          .map<Map<String, dynamic>>(
            (e) => {"nama": e.namaAlat, "qty": e.jumlahPeminjaman},
          )
          .toList();
    } else {
      // fallback jika belum ada detail alat
      barisAlat = [
        {"nama": null, "qty": 1},
      ];
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
        onPressed: () {
          // Logika Update Simpan
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        child: Text(
          "Simpan Perubahan",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  // WIDGET BARIS INPUT (Dropdown + Jumlah)
  Widget _buildBarisInputAlat(int index) {
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
                if (index == 0)
                  _buildLabel(
                    "Pilih alat:",
                  ), // Label cuma muncul di baris pertama
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: _fieldDecoration(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: barisAlat[index]['nama'],
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 15
                      ),
                      hint: Text(
                        "Pilih alat",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      isExpanded: true,
                      items: listAlat.map((alat) {
                        return DropdownMenuItem<String>(
                          value: alat.namaAlat,
                          child: Text(alat.namaAlat),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() => barisAlat[index]['nama'] = v);
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
                if (index == 0)
                  _buildLabel("Jumlah:"), // Label cuma muncul di baris pertama
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
                      barisAlat[index]['qty'] = int.tryParse(v) ?? 1;
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: barisAlat[index]['qty'].toString(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tombol Hapus Baris (jika baris lebih dari 1)
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
            barisAlat.add({"nama": null, "qty": 0});
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
        child: DropdownButton<String>(
          value: peminjamTerpilih,
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 15
          ),
          hint: Text(
            "Pilih Siswa",
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          isExpanded: true,
          items: listPengguna.map((item) {
            return DropdownMenuItem<String>(
              value: item.userName, // sesuaikan field modelmu
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
