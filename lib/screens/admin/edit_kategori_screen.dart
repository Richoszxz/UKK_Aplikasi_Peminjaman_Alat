import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class EditKategoriScreen extends StatefulWidget {
  const EditKategoriScreen({super.key});

  @override
  State<EditKategoriScreen> createState() => _EditKategoriScreenState();
}

class _EditKategoriScreenState extends State<EditKategoriScreen> {
  final _formKey = GlobalKey<FormState>();
  late ModelKategori kategori; // Simpan data dari argumen
  
  final TextEditingController namaKategoriController = TextEditingController();
  final TextEditingController deskripsiKategoriController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ambil data yang dikirim dari screen sebelumnya
    kategori = ModalRoute.of(context)!.settings.arguments as ModelKategori;
    namaKategoriController.text = kategori.namaKategori;
    deskripsiKategoriController.text = kategori.deskripsiKategori ?? "";
  }

  void simpanPerubahan() async {
    if (_formKey.currentState!.validate()) {
      try {
        await KategoriService().editKategori(
          kategori.idKategori!,
          namaKategoriController.text,
          deskripsiKategoriController.text,
        );
        if (mounted) Navigator.pop(context);
        AlertHelper.showSuccess(context, 'Berhasil menyimpan perubahan');
      } catch (e) {
        AlertHelper.showError(context, 'Gagal menyimpan perubahan');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Edit Kategori", tombolKembali: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label("Nama kategori"),
                _textField(
                  controller: namaKategoriController,
                  hint: "Nama kategori...",
                  validator: (value) =>
                      value!.isEmpty ? "Nama kategori wajib diisi" : null,
                ),

                const SizedBox(height: 10),

                _label("Deskripsi kategori"),
                _textField(
                  controller: deskripsiKategoriController,
                  hint: "Deskripsi kategori...",
                  validator: (value) =>
                      value!.isEmpty ? "Deskripsi wajib diisi" : null,
                ),

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
                    onPressed: simpanPerubahan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      "Simpan Perubahan",
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
      ),
    );
  }

  // ================= REUSABLE UI =================

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
      style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.primary),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.primary,
        ),
        contentPadding: const EdgeInsets.symmetric(
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
    );
  }
}
