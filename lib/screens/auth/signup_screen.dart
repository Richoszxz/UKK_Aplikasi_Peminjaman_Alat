import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import 'package:creaventory/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State tambahan untuk UI
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    // Membersihkan controller saat widget dihapus dari memori
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await _authService.signUp(
          emailController.text,
          passwordController.text,
          usernameController.text,
        );

        if (response.user != null) {
          if (!mounted) return;
          
           // Kembali ke halaman Login

          AlertHelper.showSuccess(
            context,
            "Registrasi Berhasil! Silahkan tunggu aktivasi akun oleh admin.",
            onOk: () => Navigator.pushNamed(context, '/login'),
          );
        }
      } catch (e) {
        if (!mounted) return;
        AlertHelper.showError(context, "Terjadi kesalahan: ${e.toString()}");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_login_page.png',
              fit: BoxFit.cover,
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/app_icon.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Creaventory",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF073D1C),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Go To\nSign Up !",
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF073D1C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Pengelolaan Peminjaman Barang/Alat Desain Komunikasi Visual (DKV)",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF073D1C),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// USERNAME
                            Text(
                              "Username",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFF424242),
                              ),
                            ),
                            TextFormField(
                              controller: usernameController,
                              style: GoogleFonts.poppins(
                                color: Color(0xFF424242),
                              ),
                              decoration: InputDecoration(
                                hintText: "masukkan username",
                                hintStyle: GoogleFonts.poppins(
                                  color: const Color(0xFFD1D1D1),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Username wajib diisi';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),

                            /// EMAIL
                            Text(
                              "Email",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFF424242),
                              ),
                            ),
                            TextFormField(
                              controller: emailController,
                              style: GoogleFonts.poppins(
                                color: Color(0xFF424242),
                              ),
                              decoration: InputDecoration(
                                hintText: "email@example.com",
                                hintStyle: GoogleFonts.poppins(
                                  color: const Color(0xFFD1D1D1),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email wajib diisi';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),

                            /// PASSWORD
                            Text(
                              "Password",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFF424242),
                              ),
                            ),
                            TextFormField(
                              controller: passwordController,
                              obscureText: _isObscured,
                              style: GoogleFonts.poppins(
                                color: Color(0xFF424242),
                              ),
                              decoration: InputDecoration(
                                hintText: "masukkan password",
                                hintStyle: GoogleFonts.poppins(
                                  color: const Color(0xFFD1D1D1),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() {
                                    _isObscured = !_isObscured;
                                  }),
                                  icon: Icon(
                                    _isObscured
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  color: Color(0xFF073D1C),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password wajib diisi';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 25),

                            /// BUTTON SIGN UP
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF073D1C),
                                      Color(0xFF2D8241),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : handleSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          "Sign Up",
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// BACK TO LOGIN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Sudah punya akun?",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(width: 5),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              "Login",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF424242),
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
