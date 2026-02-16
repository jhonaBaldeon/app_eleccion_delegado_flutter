import 'package:geolocator/geolocator.dart';

class LocationService {
  // Coordenadas de la Universidad Continental (ejemplo:campus principal en Huancayo, Peru)
  static const double _universityLatitude =
      -12.04802065778313; //-12.04802065778313, -75.19865616814968  conti
  static const double _universityLongitude =
      -75.19865616814968; //-12.138047776312773, -75.22232369203437  casa
  static const double _maxDistanceInMeters =
      100; // El usuario debe estar a menos de 100 metros.

  Future<bool> isUserInUniversity() async {
    // Comprueba si los servicios de ubicación están habilitados
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Verificar permiso de ubicación
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // Obtener posición actual
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Calcular la distancia a la universidad.
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _universityLatitude,
      _universityLongitude,
    );

    // Devuelve verdadero si el usuario está dentro de la distancia permitida
    return distance <= _maxDistanceInMeters;
  }
}
