import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../data/models/safehouse.dart';
import '../../data/repositories/safehouse_repository.dart';
import '../../services/proximity_service.dart';
import '../widgets/network_banner.dart';

///     encriptado y muestra [OfflineBanner].
///  2. VIBRACIÓN POR PROXIMIDAD: inicia [ProximityService] para activar
///     ráfagas Geiger cuando el agente está a <100m del Neon-Vault.
class SafehouseScreen extends StatefulWidget {
  final SafehouseRepository repository;

  const SafehouseScreen({super.key, required this.repository});

  @override       
  State<SafehouseScreen> createState() => _SafehouseScreenState();
}

class _SafehouseScreenState extends State<SafehouseScreen> {
  // ── Estado ──────────────────────────────────────────────────────────────
  List<Safehouse> _safehouses = [];
  bool _isLoading = true;
  bool _isOffline = false;
  bool _nearNeonVault = false;
  String? _errorMessage;

  final ProximityService _proximityService = ProximityService();

  @override
  void initState() {
    super.initState();
    _loadData();
    _startProximityMonitoring();
  }

  @override
  void dispose() {
    _proximityService.dispose();
    super.dispose();
  }

  // ── Carga de datos con bypass de red ────────────────────────────────────

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Verificar conectividad
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool hasInternet = connectivityResult != ConnectivityResult.none;

    if (hasInternet) {
      // Modo online: bajar de Supabase (el repo también guarda el caché)
      try {
        final data = await widget.repository.fetchSafehouses();
        setState(() {
          _safehouses = data;
          _isOffline = false;
          _isLoading = false;
        });
      } catch (e) {
        // Si Supabase falla aun con internet, intentar caché
        await _loadFromCache(fallback: true);
      }
    } else {
      // Modo offline: leer caché encriptado
      await _loadFromCache(fallback: false);
    }
  }

  Future<void> _loadFromCache({required bool fallback}) async {
    try {
      final cached = await widget.repository.fetchFromCache();
      setState(() {
        _safehouses = cached;
        _isOffline = true;
        _isLoading = false;
        if (fallback) {
          _errorMessage = 'Sin conexión a Supabase. Mostrando datos locales.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No hay datos disponibles ni en red ni en caché.';
        _isLoading = false;
        _isOffline = true;
      });
    }
  }

  // ── Proximidad Geiger ────────────────────────────────────────────────────

  void _startProximityMonitoring() {
    _proximityService.startMonitoring(
      onProximityAlert: (bool isNear) {
        if (mounted) {
          setState(() => _nearNeonVault = isNear);
        }
      },
    );
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AEGIS VAULT',
          style: TextStyle(
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FF41),
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          if (_nearNeonVault)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Tooltip(
                message: 'Proximidad Neon-Vault detectada',
                child: Icon(Icons.radar, color: Colors.redAccent, size: 26),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00FF41)),
            onPressed: _loadData,
            tooltip: 'Recargar',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Banner de modo desconectado
          if (_isOffline) const OfflineBanner(),

          // Alerta de proximidad Geiger
          if (_nearNeonVault) _buildGeigerAlert(),

          // Contenido principal
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildGeigerAlert() {
    return Container(
      width: double.infinity,
      color: Colors.deepOrange.shade900,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '⚠ ALERTA GEIGER — Neon-Vault a menos de 100m',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00FF41)),
      );
    }

    if (_errorMessage != null && _safehouses.isEmpty) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }



// ── Tarjeta individual ───────────────────────────────────────────────────────

class _SafehouseCard extends StatelessWidget {
  final Safehouse safehouse;

  const _SafehouseCard({required this.safehouse});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color cardColor = safehouse.isCompromised
        ? colorScheme.errorContainer
        : colorScheme.surfaceVariant;

    final Color textColor = safehouse.isCompromised
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;

    return Semantics(
      label:
          'Refugio ${safehouse.codename}, '
          'ubicado en el sector ${safehouse.sector}, '
          'capacidad para ${safehouse.capacity} agentes',
      child: Card(
        color: cardColor,
        elevation: 4,
        surfaceTintColor: safehouse.isCompromised
            ? colorScheme.error
            : colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    safehouse.isCompromised ? Icons.dangerous : Icons.shield,
                    color: safehouse.isCompromised
                        ? colorScheme.error
                        : const Color(0xFF00FF41),
                    size: 22,
                  ),
                  if (safehouse.isCompromised)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'COMPROMETIDO',
                        style: TextStyle(
                          color: colorScheme.onError,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                safehouse.codename,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 12, color: textColor.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      safehouse.sector,
                      style: TextStyle(
                        color: textColor.withOpacity(0.85),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.group,
                      size: 13, color: textColor.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    '${safehouse.capacity} agentes',
                    style: TextStyle(
                      color: textColor.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}