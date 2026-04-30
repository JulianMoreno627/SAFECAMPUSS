import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import '../models/reporte.dart';

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

  Future<RouteResult?> getRoute(LatLng origin, LatLng dest, {List<Reporte>? reportesCercanos}) async {
    final hasReports = reportesCercanos != null && reportesCercanos.isNotEmpty;
    final url =
        '$_osrm/${origin.longitude},${origin.latitude};${dest.longitude},${dest.latitude}'
        '?overview=full&geometries=geojson&steps=false${hasReports ? '&alternatives=3' : ''}';
    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;

      final parsedRoutes = routes.map((route) {
        final r = route as Map<String, dynamic>;
        final coords = (r['geometry']['coordinates'] as List).map((c) {
          return LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble());
        }).toList();
        return RouteResult(
          points: coords,
          distanceMeters: (r['distance'] as num).toDouble(),
          durationSeconds: (r['duration'] as num).toDouble(),
        );
      }).toList();

      if (!hasReports || parsedRoutes.length == 1) {
        return parsedRoutes.first;
      }

      // Evaluar la ruta más segura
      RouteResult bestRoute = parsedRoutes.first;
      double lowestPenalty = double.infinity;
      const distance = Distance();

      for (final r in parsedRoutes) {
        double penalty = 0.0;
        
        // Revisar cada punto de la ruta contra las zonas de peligro
        // Evaluamos 1 de cada 10 puntos para optimizar rendimiento
        for (int i = 0; i < r.points.length; i += 10) {
          final p = r.points[i];
          for (final rep in reportesCercanos) {
            if (rep.nivelUrgencia == NivelUrgencia.bajo) continue;
            
            final distToDanger = distance.as(LengthUnit.Meter, p, LatLng(rep.lat, rep.lng));
            final double dangerRadius = rep.nivelUrgencia == NivelUrgencia.critico ? 250 : 150;
            
            if (distToDanger < dangerRadius) {
              // Aumentar penalidad fuertemente si entra en la zona roja
              penalty += (dangerRadius - distToDanger) * (rep.nivelUrgencia == NivelUrgencia.critico ? 5 : 2);
            }
          }
        }
        
        // Sumar una penalidad leve por la distancia extra (para que no elija una ruta absurdamente larga si no hay peligro)
        penalty += r.distanceMeters * 0.1;

        if (penalty < lowestPenalty) {
          lowestPenalty = penalty;
          bestRoute = r;
        }
      }

      return bestRoute;
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
