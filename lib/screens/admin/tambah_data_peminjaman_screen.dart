import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class TambahDataPeminjamanScreen extends StatefulWidget {
  const TambahDataPeminjamanScreen({super.key});

  @override
  State<TambahDataPeminjamanScreen> createState() =>
      _TambahDataPeminjamanScreenState();
}

class _TambahDataPeminjamanScreenState
    extends State<TambahDataPeminjamanScreen> {
  final PenggunaService _penggunaService = PenggunaService();
  final AlatService _alatService = AlatService();
  final PeminjamanService _peminjamanService = PeminjamanService();

  List<ModelPengguna> listPengguna = [];
  List<ModelAlat> listAlat = [];

  bool isLoading = false;

  ModelPengguna? peminjamTerpilih;
  DateTime? tglPinjam;
  DateTime? tglRencanaKembali;

  // State utama: List ini menampung object alat yang sedang diedit di form
  List<Map<String, dynamic>> barisAlat = [
    {"alat": null, "qty": 0}, // Baris pertama default
  ];

  Future<void> _loadData() async {
    try {
      final pengguna = await _penggunaService.ambilPengguna();
      final alat = await _alatService.ambilAlat();

      setState(() {
        listPengguna = pengguna;
        listAlat = alat;
      });
    } catch (e) {
      debugPrint("Gagal load data: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  Future<void> _simpanPeminjaman() async {
    try {
      // ================= VALIDASI =================
      if (peminjamTerpilih == null) {
        throw Exception("Peminjam belum dipilih");
      }

      if (tglPinjam == null || tglRencanaKembali == null) {
        throw Exception("Tanggal belum lengkap");
      }

      final alatValid = barisAlat.where((e) => e['alat'] != null).toList();
      if (alatValid.isEmpty) {
        throw Exception("Minimal pilih 1 alat");
      }

      for (var item in alatValid) {
        final ModelAlat alat = item['alat'];
        final int qty = item['qty'];
        if (qty > alat.stokAlat) {
          throw Exception(
            "Stok ${alat.namaAlat} tidak cukup. Tersedia: ${alat.stokAlat}, diminta: $qty",
          );
        }
      }

      setState(() => isLoading = true);

      // ================= FORMAT DETAIL =================
      final detailAlat = alatValid.map((e) {
        final ModelAlat alat = e['alat'];
        final int qty = e['qty'];

        return {'id_alat': alat.idAlat, 'qty': qty};
      }).toList();

      // ================= SIMPAN =================
      await _peminjamanService.tambahPeminjaman(
        idUser: peminjamTerpilih!.idUser!,
        tglPinjam: tglPinjam!,
        tglRencanaKembali: tglRencanaKembali!,
        detailAlat: detailAlat,
      );

      if (mounted) Navigator.pop(context);
      AlertHelper.showSuccess(context, "Berhasil menyimpan data peminjaman");
    } catch (e) {
      debugPrint("Gagal simpan: $e");
      AlertHelper.showError(
        context,
        'Gagal menyimpan data peminjaman',
        onOk: () {
          Navigator.pop(context);
          setState(() {});
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        judulAppBar: "Tambah\nPeminjaman",
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

            // MENGGUNAKAN LIST GENERATE UNTUK MEMBUAT BARIS INPUT DINAMIS
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
              onTap: () => _selectDateTime(context, true),
            ),
            const SizedBox(height: 20),
            _tanggalField(
              label: "Rencana tanggal pengembalian:",
              selectedDate: tglRencanaKembali,
              onTap: () => _selectDateTime(context, false),
            ),
            const SizedBox(height: 100),
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
              onPressed: isLoading ? null : _simpanPeminjaman,
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
                      "Buat Peminjaman",
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
                    child: DropdownButton<ModelAlat>(
                      value: barisAlat[index]['alat'],
                      hint: Text(
                        "Pilih alat",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      dropdownColor: Theme.of(context).colorScheme.secondary,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      isExpanded: true,
                      items: listAlat.map((alat) {
                        return DropdownMenuItem<ModelAlat>(
                          value: alat,
                          child: Text(alat.namaAlat),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() => barisAlat[index]['alat'] = v);
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
      ),
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
            barisAlat.add({"alat": null, "qty": 0});
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
          hint: Text(
            "Pilih Siswa",
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          dropdownColor: Theme.of(context).colorScheme.secondary,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          isExpanded: true,
          items: listPengguna.map((item) {
            return DropdownMenuItem<ModelPengguna>(
              value: item,
              child: Text(item.userName ?? "-"),
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

  Future<void> _selectDateTime(BuildContext context, bool isPinjam) async {
    // Pilih tanggal dulu
    final DateTime? tanggalTerpilih = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (tanggalTerpilih != null) {
      // Pilih waktu
      final TimeOfDay? waktuTerpilih = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (waktuTerpilih != null) {
        // Gabungkan tanggal dan waktu menjadi DateTime
        final DateTime tanggalDanWaktu = DateTime(
          tanggalTerpilih.year,
          tanggalTerpilih.month,
          tanggalTerpilih.day,
          waktuTerpilih.hour,
          waktuTerpilih.minute,
        );

        setState(() {
          if (isPinjam) {
            tglPinjam = tanggalDanWaktu;
          } else {
            tglRencanaKembali = tanggalDanWaktu;
          }
        });
      }
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
