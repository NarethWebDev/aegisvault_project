import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Credenciales del proyecto Supabase - Aegis Vault
const String _supabaseUrl = 'https://gbgvtwkhmagupynpvdkb.supabase.co';
const String _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdiZ3Z0d2tobWFndXB5bnB2ZGtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyNDA2MzcsImV4cCI6MjA5NTgxNjYzN30.c4fdDDszLLKkgI3-4WHnp5aVs2rxuX94C0GQdqWrrso';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase con las credenciales del proyecto
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  runApp(const AegisVaultApp());
}

/// Punto de entrada de la aplicación Aegis Vault.
class AegisVaultApp extends StatelessWidget {
  const AegisVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FF41),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'AEGIS VAULT',
            style: TextStyle(
              color: Color(0xFF00FF41),
              fontSize: 24,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}