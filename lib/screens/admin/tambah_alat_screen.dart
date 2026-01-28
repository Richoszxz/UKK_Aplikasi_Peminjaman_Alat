import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

import 'dart:typed_data'; // Tambahkan import ini
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk cek platform

class TambahAlatScreen extends StatefulWidget {
  const TambahAlatScreen({super.key});

  @override
  State<TambahAlatScreen> createState() => _TambahAlatScreenState();
}

class _TambahAlatScreenState extends State<TambahAlatScreen> {
  final _formKey = GlobalKey<FormState>();
  final AlatService _alatService = AlatService();
  final KategoriService _kategoriService = KategoriService();

  final TextEditingController namaAlatController = TextEditingController();
  final TextEditingController stokAlatController = TextEditingController();
  final TextEditingController spesifikasiAlatController =
      TextEditingController();

  bool _isSaving = false; // Tambahkan ini

  // Ubah kategori menjadi int karena database menyimpan id_kategori
  int? kategoriAlatIdTerpilih;
  String? kondisiAlatTerpilih;
  File? gambar;
  Uint8List? webImage; // Tambahkan ini untuk Web preview

  // List untuk menampung data kategori dari database
  List<ModelKategori> listKategoriDatabase = [];
  final List<String> kondisiList = ["baik", "rusak", "pemeliharaan"];

  @override
  void initState() {
    super.initState();
    _loadKategori(); // Ambil kategori saat halaman dibuka
  }

  Future<void> _loadKategori() async {
    try {
      final data = await _kategoriService.ambilKategori();
      setState(() {
        listKategoriDatabase = data;
      });
    } catch (e) {
      debugPrint("Gagal load kategori: $e");
    }
  }

  /// ================= PICK FILE =================
  Future<void> pilihGambar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (kIsWeb) {
          webImage = result.files.single.bytes;
        } else {
          gambar = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> simpanData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true); // Mulai loading pada tombol

      try {
        String? finalImageUrl;
        // 1. Logika Upload Gambar Hybrid
        if (kIsWeb && webImage != null) {
          // Jika di Web, kirim bytes
          finalImageUrl = await _alatService.uploadGambar(
            bytes: webImage,
            fileName: 'upload_web.jpg',
          );
        } else if (gambar != null) {
          // Jika di Mobile, kirim file
          finalImageUrl = await _alatService.uploadGambar(
            file: gambar,
            fileName: gambar!.path.split('/').last,
          );
        }

        // 2. Siapkan Data untuk Database
        final Map<String, dynamic> dataBaru = {
          'nama_alat': namaAlatController.text,
          'id_kategori': kategoriAlatIdTerpilih, // Mengirim ID (int)
          'stok_alat': int.parse(stokAlatController.text),
          'kondisi_alat': kondisiAlatTerpilih,
          'spesifikasi_alat': spesifikasiAlatController.text,
          'gambar_url': finalImageUrl,
        };

        // 3. Panggil Service
        await _alatService.tambahAlat(dataBaru);

        AlertHelper.showSuccess(
          context,
          "Berhasil menambah alat!",
          onOk: () => Navigator.pushNamed(context, '/manajemen_alat'),
        );
      } catch (e) {
        AlertHelper.showError(context, 'Gagal menambahkan alat!');
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    namaAlatController.dispose();
    stokAlatController.dispose();
    spesifikasiAlatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Tambah Alat", tombolKembali: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= NAMA ALAT =================
              _label("Nama alat"),
              _textField(
                controller: namaAlatController,
                hint: "Nama alat...",
                validator: (value) =>
                    value!.isEmpty ? "Nama alat wajib diisi" : null,
              ),

              const SizedBox(height: 14),

              /// ================= KATEGORI =================
              _label("Kategori alat"),
              DropdownButtonFormField<int>(
                // Menggunakan int untuk ID
                value: kategoriAlatIdTerpilih,
                hint: Text("Pilih kategori", style: GoogleFonts.poppins()),
                items: listKategoriDatabase.map((kat) {
                  return DropdownMenuItem<int>(
                    value: kat.idKategori, // Value adalah ID
                    child: Text(kat.namaKategori), // Label adalah Nama
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => kategoriAlatIdTerpilih = value);
                },
                validator: (value) =>
                    value == null ? "Wajib pilih kategori" : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.secondary,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
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
              ),

              const SizedBox(height: 14),

              /// ================= STOK =================
              _label("Stok alat"),
              _textField(
                controller: stokAlatController,
                hint: "Jumlah stok...",
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Stok wajib diisi" : null,
              ),

              const SizedBox(height: 14),

              /// ================= KONDISI =================
              _label("Kondisi alat"),
              _dropdown(
                value: kondisiAlatTerpilih,
                hint: "Pilih kondisi",
                items: kondisiList,
                onChanged: (value) {
                  setState(() => kondisiAlatTerpilih = value);
                },
              ),

              const SizedBox(height: 14),

              /// ================= SPESIFIKASI =================
              _label("Spesifikasi alat"),
              _textField(
                controller: spesifikasiAlatController,
                hint: "Masukkan spesifikasi...",
              ),

              const SizedBox(height: 14),

              /// ================= FOTO =================
              _label("Foto alat"),
              _uploadFotoField(),

              const SizedBox(height: 25),

              /// ================= BUTTON SIMPAN =================
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : simpanData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Simpan",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: const Color(0xFF424242),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.primary,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        hint,
        style: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      dropdownColor: Theme.of(context).colorScheme.secondary,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSecondary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Wajib memilih $hint" : null,
    );
  }

  Widget _uploadFotoField() {
    return InkWell(
      onTap: pilihGambar,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: BoxBorder.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Row(
          children: [
            /// Preview Thumbnail
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300,
              ),
              child: (kIsWeb ? webImage == null : gambar == null)
                  ? const Icon(Icons.image_outlined)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb
                          ? Image.memory(
                              webImage!,
                              fit: BoxFit.cover,
                            ) // Gunakan Memory untuk Web
                          : Image.file(gambar!, fit: BoxFit.cover),
                    ),
            ),

            const SizedBox(width: 12),

            /// Nama file
            Expanded(
              child: Text(
                kIsWeb
                    ? (webImage == null
                          ? "Upload foto alat"
                          : "Gambar terpilih (Web)")
                    : (gambar == null
                          ? "Upload foto alat"
                          : gambar!.path.split('/').last),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),

            const Icon(Icons.upload_file),
          ],
        ),
      ),
    );
  }
}
