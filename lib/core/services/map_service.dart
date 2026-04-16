import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapService {
  final String _apiKey = dotenv.env['HERE_API_KEY'] ?? '';

  Future<LatLng?> getCoordinates(String address) async {
    if (_apiKey.isEmpty) return null;

    final normalized = address.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) return null;

    Future<LatLng?> geocode(String q) async {
      final url = Uri.parse(
        'https://geocode.search.hereapi.com/v1/geocode?q=${Uri.encodeComponent(q)}&apiKey=$_apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final position = data['items'][0]['position'];
          return LatLng(position['lat'], position['lng']);
        }
      }
      return null;
    }

    String simplify(String q) {
      var v = q;
      v = v.replaceAll(RegExp(r'\b(unit|apt|apartment|suite|ste|#)\s*\w+\b', caseSensitive: false), '');
      v = v.replaceAll(RegExp(r',\s*,'), ',');
      v = v.replaceAll(RegExp(r'\s+,',), ',');
      v = v.replaceAll(RegExp(r',\s+'), ', ');
      v = v.replaceAll(RegExp(r'\s+'), ' ').trim();
      v = v.replaceAll(RegExp(r'^,|,$'), '').trim();
      return v;
    }

    try {
      final first = await geocode(normalized);
      if (first != null) return first;

      final simplified = simplify(normalized);
      if (simplified != normalized && simplified.isNotEmpty) {
        final second = await geocode(simplified);
        if (second != null) return second;
      }
    } catch (e) {
      // Ignored
    }
    return null;
  }

  Future<Map<String, dynamic>?> getRoute(
    LatLng start,
    LatLng destination,
  ) async {
    if (_apiKey.isEmpty) return null;

    final url = Uri.parse(
      'https://router.hereapi.com/v8/routes?transportMode=car&origin=${start.latitude},${start.longitude}&destination=${destination.latitude},${destination.longitude}&return=polyline,summary&apiKey=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final section = data['routes'][0]['sections'][0];
          return {
            'distance': section['summary']['length'], // in meters
            'polyline': section['polyline'],
          };
        }
      }
    } catch (e) {
      // Ignored
    }
    return null;
  }
}
