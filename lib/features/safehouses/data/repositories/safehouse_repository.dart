import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/safehouse.dart';

class SafehouseRepository {
  final SupabaseClient _supabase;
  final FlutterSecureStorage _secureStorage;

  
  static const String _cacheKey = 'safehouses_cache';

  SafehouseRepository({
    required SupabaseClient supabase,
    required FlutterSecureStorage secureStorage,
  })  : _supabase = supabase,
        _secureStorage = secureStorage;

  Future<List<Safehouse>> fetchSafehouses() async {
    final response = await _supabase
        .from('safehouses')
        .select()
        .order('created_at', ascending: true);

    final safehouses = (response as List<dynamic>)
        .map((json) => Safehouse.fromJson(json as Map<String, dynamic>))
        .toList();

    await _saveCache(safehouses);

    return safehouses;
  }

  Future<List<Safehouse>> fetchFromCache() async {
    final cached = await _secureStorage.read(key: _cacheKey);

    if (cached == null) return [];

    final List<dynamic> jsonList = jsonDecode(cached) as List<dynamic>;

    return jsonList
        .map((json) => Safehouse.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveCache(List<Safehouse> safehouses) async {
    final jsonString = jsonEncode(
      safehouses.map((s) => s.toJson()).toList(),
    );
    await _secureStorage.write(key: _cacheKey, value: jsonString);
  }
}