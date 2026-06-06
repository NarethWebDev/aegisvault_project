import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/safehouses/data/repositories/safehouse_repository.dart';
import 'features/safehouses/presentation/screens/safehouse_screen.dart';

const String _supabaseUrl = 'https://gbgvtwkhmagupynpvdkb.supabase.co';
const String _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdiZ3Z0d2tobWFndXB5bnB2ZGtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyNDA2MzcsImV4cCI6MjA5NTgxNjYzN30.c4fdDDszLLKkgI3-4WHnp5aVs2rxuX94C0GQdqWrrso';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  final safehouseRepository = SafehouseRepository(
    supabase: Supabase.instance.client,
    secureStorage: const FlutterSecureStorage(),
  );

  runApp(AegisVaultApp(repository: safehouseRepository));
}

class AegisVaultApp extends StatelessWidget {
  final SafehouseRepository repository;

  const AegisVaultApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,                    // ← activa Material 3
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FF41),  // ← color base del esquema
          brightness: Brightness.dark,
        ),
      ),
      home: SafehouseScreen(repository: repository),
    );
  }
}