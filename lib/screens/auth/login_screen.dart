import 'package:flutter/material.dart';
import 'package:creaventory/export.dart';
import 'package:creaventory/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // State tambahan untuk UI
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    // Membersihkan controller saat widget dihapus dari memori
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _authService.signIn(
          emailController.text
              .trim(), // Gunakan trim untuk hapus spasi tak sengaja
          passwordController.text,
        );

        if (response.session != null) {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        } else {
          if (!mounted) return;
          AlertHelper.showError(
            context,
            'Login gagal! Periksa email dan password.',
          );
        }
      } on AuthException catch (e) {
        if (!mounted) return;
        final errorTxt = e.message.toLowerCase();
        AlertHelper.showError(
          context,
          errorTxt.contains('invalid login credentials')
              ? "Email atau password salah!"
              : e.message,
        );
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
              fit: BoxFit.cover
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/app_icon.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Creaventory",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF073D1C),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Login to\nyour account",
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF073D1C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Pengelolaan Peminjaman Barang/Alat Desain Komunikasi Visual (DKV)",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Color(0xFF073D1C),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 50,
                  ),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Color(0xFF424242),
                              ),
                            ),
                            TextFormField(
                              controller: emailController,
                              style: GoogleFonts.poppins(
                                color: Color(0xFF424242)
                              ),
                              decoration: InputDecoration(
                                hintText: "email@example.com",
                                hintStyle: GoogleFonts.poppins(
                                  color: Color(0xFFD1D1D1),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary
                                  )
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Password",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Color(0xFF424242),
                              ),
                            ),
                            TextFormField(
                              controller: passwordController,
                              style: GoogleFonts.poppins(
                                color: Color(0xFF424242)
                              ),
                              obscureText: _isObscured,
                              decoration: InputDecoration(
                                hintText: "masukkan password",
                                hintStyle: GoogleFonts.poppins(
                                  color: Color(0xFFD1D1D1),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscured
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF073D1C),
                                  ),
                                  onPressed: () => setState(
                                    () => _isObscured = !_isObscured,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary
                                  )
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 45),
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
                                  onPressed: _isLoading ? null : handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.transparent, // wajib transparan
                                    shadowColor: Colors
                                        .transparent, // hilangkan shadow default
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
                                          "Login",
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
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Belum punya akun?",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Color(0xFF424242),
                            ),
                          ),
                          SizedBox(width: 5),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.poppins(
                                color: Color(0xFF424242),
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
