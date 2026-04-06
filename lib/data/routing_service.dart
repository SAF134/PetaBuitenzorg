import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class RoutingService {
  /// Cache to store calculated distances and avoid redundant API calls
  static final Map<String, double> _distanceCache = {};

  /// Retrieves the driving distance between two points using OSRM.
  /// Falls back to straight-line distance if the API request fails.
  static Future<double> getRouteDistance(LatLng start, LatLng end) async {
    // Generate a unique cache key for these coordinates
    // We round to 4 decimal places (~11 meters precision) to reuse nearby requests
    final String cacheKey = '${start.latitude.toStringAsFixed(5)},${start.longitude.toStringAsFixed(5)}-${end.latitude.toStringAsFixed(5)},${end.longitude.toStringAsFixed(5)}';

    if (_distanceCache.containsKey(cacheKey)) {
      return _distanceCache[cacheKey]!;
    }

    try {
      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}?overview=false'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final double distanceInMeters = (data['routes'][0]['distance'] as num).toDouble();
          _distanceCache[cacheKey] = distanceInMeters;
          return distanceInMeters;
        }
      }
    } catch (e) {
      debugPrint('OSRM Error: $e');
    }

    // Fallback to straight line if API fails or times out
    final straightLineDist = Geolocator.distanceBetween(
      start.latitude, start.longitude,
      end.latitude, end.longitude,
    );
    
    // Cache the fallback so we don't keep hitting the failing API
    _distanceCache[cacheKey] = straightLineDist; 
    
    return straightLineDist;
  }

  /// Calculates straight line distance between two points locally
  static double getStraightLineDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude, start.longitude,
      end.latitude, end.longitude,
    );
  }
}
