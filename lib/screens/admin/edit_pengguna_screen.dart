import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';

class EditPenggunaScreen extends StatefulWidget {
  const EditPenggunaScreen({super.key});

  @override
  State<EditPenggunaScreen> createState() => _EditPenggunaScreenState();
}

class _EditPenggunaScreenState extends State<EditPenggunaScreen> {
  final PenggunaService _penggunaService = PenggunaService();
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input
  late TextEditingController _namaController;
  late TextEditingController _emailController;

  ModelPengguna? dataPengguna; // Data yang akan diedit
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mengambil data pengguna yang dikirim lewat Navigator
    if (_isInit) {
      dataPengguna =
          ModalRoute.of(context)!.settings.arguments as ModelPengguna;
      _namaController = TextEditingController(text: dataPengguna?.userName);
      _emailController = TextEditingController(text: dataPengguna?.email);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        judulAppBar: 'Edit\nPengguna',
        tombolKembali: true,
      ),
      drawer: const NavigationDrawerWidget(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Nama Pengguna:'),
                _textField(
                  controller: _namaController,
                  hint: 'Masukkan nama baru',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 20),

                _label('Email:'),
                _textField(
                  controller: _emailController,
                  hint: 'Masukkan email baru',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Email tidak valid'
                      : null,
                ),
                const SizedBox(height: 30),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _simpanPerubahan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Simpan Perubahan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  // Fungsi untuk update ke database
  void _simpanPerubahan() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _penggunaService.editPengguna(dataPengguna!.idUser!, {
          'username': _namaController.text,
          'email': _emailController.text,
        });

        if (mounted) {
          AlertHelper.showSuccess(context, 'Berhasil menyimpan perubahan !');
          Navigator.pop(context); // Kembali ke halaman manajemen
        }
      } catch (e) {
        AlertHelper.showError(context, 'Gagal menyimpan perubahan !');
        debugPrint('Error $e');
      }
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
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
      style: GoogleFonts.poppins(
        color: Theme.of(context).colorScheme.onSecondary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none, // Dibuat bersih tanpa border luar
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}
