import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BarPencarianWidget extends StatefulWidget {
  final String hintText;
  final Function(String)? onSearch;
  const BarPencarianWidget({super.key, required this.hintText, this.onSearch});

  @override
  State<BarPencarianWidget> createState() => _BarPencarianWidgetState();
}

class _BarPencarianWidgetState extends State<BarPencarianWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _controller,
          onChanged: (value) {
            widget.onSearch!(value);
          },
          decoration: InputDecoration(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.primary,
            ),
            hintText: widget.hintText,
            hintStyle: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 16,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
