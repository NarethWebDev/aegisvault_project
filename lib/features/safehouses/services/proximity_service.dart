import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';

const double _neonVaultLat = 4.7068;
const double _neonVaultLng = -74.2210;

const double _alertRadiusMeters = 100.0;

/// Servicio que monitorea la ubicación GPS del dispositivo.
/// Si el usuario está a menos de [_alertRadiusMeters] metros del Neon-Vault,
/// activa ráfagas de vibración intermitente que simulan un contador Geiger.
class ProximityService {
  StreamSubscription<Position>? _positionSubscription;
  bool _isVibrating = false;

  /// Inicia el monitoreo de proximidad.
  /// Llama a [onProximityAlert] con `true` cuando entra al radio
  /// y con `false` cuando sale.
  Future<void> startMonitoring({
    required void Function(bool isNear) onProximityAlert,
  }) async {
    // Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Sin permiso, no hacemos nada
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // actualizar cada 10 metros
      ),
    ).listen((Position position) async {
      final double distanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _neonVaultLat,
        _neonVaultLng,
      );

      final bool isNear = distanceMeters <= _alertRadiusMeters;
      onProximityAlert(isNear);

      if (isNear && !_isVibrating) {
        _isVibrating = true;
        _startGeigerVibration();
      } else if (!isNear && _isVibrating) {
        _isVibrating = false;
        _stopGeigerVibration();
      }
    });
  }

  /// Ráfagas de vibración intermitente que simulan un contador Geiger.
  /// Patrón: vibra 80ms, pausa 120ms, vibra 60ms, pausa 200ms...
  void _startGeigerVibration() async {
    final bool? canVibrate = await Vibration.hasVibrator();
    if (canVibrate != true) return;

    Vibration.vibrate(
      pattern: [0, 80, 120, 60, 200, 100, 90, 50, 300, 80],
      repeat: 0, // repetir desde el índice 0 (loop infinito)
      intensities: [0, 200, 0, 180, 0, 220, 0, 190, 0, 210],
    );
  }

  void _stopGeigerVibration() {
    Vibration.cancel();
    _isVibrating = false;
  }

  /// Detiene el monitoreo y cancela la vibración.
  void dispose() {
    _positionSubscription?.cancel();
    _stopGeigerVibration();
  }
}