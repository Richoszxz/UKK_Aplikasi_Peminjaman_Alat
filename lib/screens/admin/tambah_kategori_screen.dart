import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class TambahKategoriScreen extends StatefulWidget {
  const TambahKategoriScreen({super.key});

  @override
  State<TambahKategoriScreen> createState() => _TambahKategoriScreenState();
}

class _TambahKategoriScreenState extends State<TambahKategoriScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaKategoriController = TextEditingController();
  final TextEditingController deskripsiKategoriController =
      TextEditingController();

  void simpanData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await KategoriService().tambahKategori(
          namaKategoriController.text,
          deskripsiKategoriController.text,
        );
        if (mounted) Navigator.pop(context);
      } catch (e) {
        AlertHelper.showError(context, 'Gagak menambah kategori');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(judulAppBar: "Tambah Kategori", tombolKembali: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label("Nama kategori"),
                _textField(
                  controller: namaKategoriController,
                  hint: "Nama kategori...",
                ),
                SizedBox(height: 10),
                _label("Deskripsi kategori"),
                _textField(
                  controller: deskripsiKategoriController,
                  hint: "Deskripsi kategori...",
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
                    onPressed: simpanData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      "Tambah",
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
}
