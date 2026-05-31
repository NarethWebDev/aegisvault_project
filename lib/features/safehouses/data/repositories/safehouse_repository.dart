import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/safehouse_model.dart';

/// Repositorio encargado de obtener los refugios desde Supabase.
class SafehouseRepository {
  final SupabaseClient _supabase;

  SafehouseRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  /// Consulta la tabla [safehouses] en Supabase y retorna la lista de refugios.
  /// Lanza una [Exception] si la consulta falla.
  Future<List<Safehouse>> fetchSafehouses() async {
    final response = await _supabase
        .from('safehouses')
        .select()
        .order('created_at', ascending: true);

    return (response as List<dynamic>)
        .map((json) => Safehouse.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}