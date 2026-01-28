import 'package:creaventory/export.dart';

class SupabaseService {
  static const String _supabaseUrl = 'https://iugpkeuooyqgpevykxux.supabase.co';
  static const String _supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml1Z3BrZXVvb3lxZ3BldnlreHV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyNTE4NzksImV4cCI6MjA4MzgyNzg3OX0.sUVUeD9emvPhTs7Igq_Ntd_13f6lvnRwk3EGEV1AzXg';

  static Future<void> init() async {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
