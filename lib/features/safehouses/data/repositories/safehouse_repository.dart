import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/safehouse_model.dart';

/// Repositorio encargado de obtener los refugios desde Supabase
/// y guardarlos encriptados en el almacenamiento local como caché de emergencia.
class SafehouseRepository {
  final SupabaseClient _supabase;
  final FlutterSecureStorage _secureStorage;

  /// Clave bajo la cual se guarda el caché encriptado localmente.
  static const String _cacheKey = 'safehouses_cache';

  SafehouseRepository({
    required SupabaseClient supabase,
    required FlutterSecureStorage secureStorage,
  })  : _supabase = supabase,
        _secureStorage = secureStorage;

  /// Consulta la tabla [safehouses] en Supabase y retorna la lista de refugios.
  /// Si la consulta es exitosa, guarda el resultado encriptado como caché local.
  /// Lanza una [Exception] si la consulta falla.
  Future<List<Safehouse>> fetchSafehouses() async {
    final response = await _supabase
        .from('safehouses')
        .select()
        .order('created_at', ascending: true);

    final safehouses = (response as List<dynamic>)
        .map((json) => Safehouse.fromJson(json as Map<String, dynamic>))
        .toList();

    // Caché de Emergencia: guarda el JSON encriptado localmente
    await _saveCache(safehouses);

    return safehouses;
  }

  /// Lee el caché local encriptado y retorna la lista de refugios guardada.
  /// Retorna una lista vacía si no hay caché disponible.
  Future<List<Safehouse>> fetchFromCache() async {
    final cached = await _secureStorage.read(key: _cacheKey);

    if (cached == null) return [];

    final List<dynamic> jsonList = jsonDecode(cached) as List<dynamic>;

    return jsonList
        .map((json) => Safehouse.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Serializa la lista de refugios a JSON y la guarda encriptada localmente.
  Future<void> _saveCache(List<Safehouse> safehouses) async {
    final jsonString = jsonEncode(
      safehouses.map((s) => s.toJson()).toList(),
    );
    await _secureStorage.write(key: _cacheKey, value: jsonString);
  }
}