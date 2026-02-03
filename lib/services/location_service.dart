import 'package:geolocator/geolocator.dart';

class LocationService {
  // Universidad Continental coordinates (example: main campus in Huancayo, Peru)
  static const double _universityLatitude =
      -12.1380; //-12.04802065778313, -75.19865616814968  conti
  static const double _universityLongitude =
      -75.2223; //-12.138047776312773, -75.22232369203437  casa
  static const double _maxDistanceInMeters =
      100; // User must be within 100 meters

  Future<bool> isUserInUniversity() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permission
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

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Calculate distance to university
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _universityLatitude,
      _universityLongitude,
    );

    // Return true if user is within the allowed distance
    return distance <= _maxDistanceInMeters;
  }
}
