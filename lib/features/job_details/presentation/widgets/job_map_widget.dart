import 'package:flexible_polyline_dart/flutter_flexible_polyline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/job_detail_entity.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/services/map_service.dart';

class JobMapWidget extends StatefulWidget {
  final List<AddressDetail> pickups;
  final List<AddressDetail> deliveries;

  const JobMapWidget({
    super.key,
    required this.pickups,
    required this.deliveries,
  });

  @override
  State<JobMapWidget> createState() => _JobMapWidgetState();
}

class _JobMapWidgetState extends State<JobMapWidget> {
  final MapService _mapService = MapService();
  final MapController _mapController = MapController();
  LatLng? _startCoord;
  LatLng? _destCoord;
  final List<LatLng> _pickupCoords = [];
  final List<LatLng> _deliveryCoords = [];
  List<LatLng> _polylinePoints = [];
  bool _isLoading = true;
  String? _distanceMiles;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);
    _pickupCoords.clear();
    _deliveryCoords.clear();

    for (var p in widget.pickups) {
      final coord = await _mapService.getCoordinates(p.fullAddress);
      if (coord != null) _pickupCoords.add(coord);
    }
    for (var d in widget.deliveries) {
      final coord = await _mapService.getCoordinates(d.fullAddress);
      if (coord != null) _deliveryCoords.add(coord);
    }

    if (_pickupCoords.isNotEmpty && _deliveryCoords.isNotEmpty) {
      final start = _pickupCoords.first;
      final dest = _deliveryCoords.last;

      final routeData = await _mapService.getRoute(start, dest);

      List<LatLng> points = [];
      if (routeData != null && routeData['polyline'] != null) {
        try {
          final decoded = FlexiblePolyline.decode(
            routeData['polyline'] as String,
          );
          points = decoded.map((p) => LatLng(p.lat, p.lng)).toList();
        } catch (e) {
          points = [start, dest];
        }
      }

      setState(() {
        _startCoord = start;
        _destCoord = dest;
        _polylinePoints = points;
        if (routeData != null) {
          final distMeters = routeData['distance'] as int;
          final distMiles = distMeters * 0.000621371;
          _distanceMiles = '${distMiles.toStringAsFixed(1)} miles';
        }
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitBounds();
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _fitBounds() {
    if (_pickupCoords.isEmpty && _deliveryCoords.isEmpty) return;

    final allPoints = [
      ..._pickupCoords,
      ..._deliveryCoords,
      ..._polylinePoints,
    ];

    if (allPoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(allPoints);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_startCoord == null || _destCoord == null) {
      return Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Could not resolve addresses')),
      );
    }

    final apiKey = dotenv.env['HERE_API_KEY'] ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mapStyle = isDark ? 'explore.night' : 'explore.day';

    return Container(
      height: 350,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                (_startCoord!.latitude + _destCoord!.latitude) / 2,
                (_startCoord!.longitude + _destCoord!.longitude) / 2,
              ),
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://maps.hereapi.com/v3/base/mc/{z}/{x}/{y}/png8?apiKey=$apiKey&style=$mapStyle',
                userAgentPackageName: 'com.movers.app',
              ),
              if (_polylinePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polylinePoints,
                      strokeWidth: 4.0,
                      color: const Color(0xFF4F46E5),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  ..._pickupCoords.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final point = entry.value;
                    return Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 40,
                          ),
                          Positioned(
                            top: 6,
                            child: Text(
                              'P${idx + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  ..._deliveryCoords.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final point = entry.value;
                    return Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40,
                          ),
                          Positioned(
                            top: 6,
                            child: Text(
                              'D${idx + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          // Distance overlay
          if (_distanceMiles != null)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.adaptiveSurface(context),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_car,
                      size: 16,
                      color: Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _distanceMiles!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.adaptiveTextPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Refresh button
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: _loadMapData,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.adaptiveSurface(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.refresh,
                  size: 20,
                  color: AppColors.adaptiveTextSecondary(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
