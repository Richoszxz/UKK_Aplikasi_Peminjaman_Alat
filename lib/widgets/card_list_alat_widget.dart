import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardListAlatWidget extends StatefulWidget {
  final String namaAlat;
  final String spesifikasiAlat;
  final String? gambarUrl;
  final List<Widget> tombolAksi;
  final String? heroTag;
  final VoidCallback? onTap;

  const CardListAlatWidget({
    super.key,
    required this.tombolAksi,
    required this.namaAlat,
    required this.spesifikasiAlat,
    this.gambarUrl,
    this.heroTag,
    this.onTap,
  });

  @override
  State<CardListAlatWidget> createState() => _CardListAlatWidgetState();
}

class _CardListAlatWidgetState extends State<CardListAlatWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: widget.heroTag == null
          ? _buildCard()
          : Hero(tag: widget.heroTag!, child: _buildCard()),
    );
  }

  Widget _buildCard() {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFF248250),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: (widget.gambarUrl == null || widget.gambarUrl!.isEmpty)
                    ? Container(
                        height: 140,
                        decoration: const BoxDecoration(
                          color: Color(0xFF248250),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      )
                    : Image.network(
                        widget.gambarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Jika URL salah/error, tampilkan icon agar tidak kosong melompong
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 40,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
              ),
            ),

            // ================= BODY =================
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFD0E6D1),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.namaAlat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF248250),
                      ),
                    ),
                    Text(
                      widget.spesifikasiAlat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF248250),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ================= ACTION BUTTON =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: widget.tombolAksi,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
