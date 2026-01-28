import 'package:creaventory/export.dart';

class LogService {
  final _supabaseService = SupabaseService.client;

  Future<List<ModelLog>> ambilLog() async {
    try {
      final response = await _supabaseService
          .from('log_aktivitas')
          .select('*, pengguna(username)');

      return (response as List<dynamic>)
          .map((item) => ModelLog.fromMap(item))
          .toList();
    } on Exception catch (e) {
      throw Exception('Gagal mengambil log $e');
    }
  }
}
