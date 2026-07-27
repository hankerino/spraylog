class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('Missing SUPABASE_URL');
    }

    if (supabaseAnonKey.isEmpty) {
      throw Exception('Missing SUPABASE_ANON_KEY');
    }
  }
}

