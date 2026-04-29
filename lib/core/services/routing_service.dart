import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

class PlaceResult {
  final LatLng position;
  final String displayName;
  PlaceResult({required this.position, required this.displayName});
}

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  String get distanceLabel {
    if (distanceMeters < 1000) return '${distanceMeters.toInt()} m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  String get durationLabel {
    final minutes = (durationSeconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60}h ${minutes % 60}min';
  }
}

class RoutingService {
  static final RoutingService _instance = RoutingService._internal();
  factory RoutingService() => _instance;
  RoutingService._internal();

  final _logger = Logger();

  static const _osrm =
      'http://router.project-osrm.org/route/v1/driving';
  static const _nominatim =
      'https://nominatim.openstreetmap.org/search';

  // ── Geocoding: address → LatLng ─────────────────────────────────────────

  Future<List<PlaceResult>> searchPlaces(String query) async {
    if (query.trim().length < 3) return [];
    try {
      final uri = Uri.parse(_nominatim).replace(queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '5',
        'addressdetails': '0',
      });
      final res = await http.get(uri, headers: {
        'User-Agent': 'SafeCampusAI/1.0 (safecampus@app)',
        'Accept-Language': 'es',
      }).timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body) as List;
      return data.map((item) {
        return PlaceResult(
          position: LatLng(
            double.parse(item['lat'].toString()),
            double.parse(item['lon'].toString()),
          ),
          displayName: _shortenName(item['display_name']?.toString() ?? ''),
        );
      }).toList();
    } catch (e) {
      _logger.e('searchPlaces error: $e');
      return [];
    }
  }

  // ── Routing: LatLng pair → polyline ──────────────────────────────────────

  Future<RouteResult?> getRoute(LatLng origin, LatLng dest) async {
    final url =
        '$_osrm/${origin.longitude},${origin.latitude};${dest.longitude},${dest.latitude}'
        '?overview=full&geometries=geojson&steps=false';
    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final coords =
          (route['geometry']['coordinates'] as List).map((c) {
        return LatLng(
          (c[1] as num).toDouble(),
          (c[0] as num).toDouble(),
        );
      }).toList();

      return RouteResult(
        points: coords,
        distanceMeters: (route['distance'] as num).toDouble(),
        durationSeconds: (route['duration'] as num).toDouble(),
      );
    } catch (e) {
      _logger.e('getRoute error: $e');
      return null;
    }
  }

  String _shortenName(String name) {
    final parts = name.split(', ');
    if (parts.length <= 3) return name;
    return '${parts.take(3).join(', ')}…';
  }
}
