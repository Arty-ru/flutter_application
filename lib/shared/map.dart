import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Position? _currentPosition;
  BitmapDescriptor? _customIcon;

  String? _distanceText;
  String? _durationText;

  StreamSubscription<Position>? _positionStream;
  Marker? _userMarker;
  LatLng? _activeDestination;

  final String googleApiKey =
      'AIzaSyAC63DIUl24Yl-bm25rXUDIuNwxWgutaz4'; // Вставь сюда свой ключ

  final List<Map<String, dynamic>> _locations = [
    {'title': 'ул. Котлярова, 11', 'lat': 45.06733, 'lng': 39.01125},
    {'title': 'ул. Байбакова, 4', 'lat': 45.06974, 'lng': 39.00786},
    {'title': 'ул. Котлярова, 20', 'lat': 45.07000, 'lng': 39.02809},
    {'title': 'ул. Московская, 133', 'lat': 45.09588, 'lng': 39.00079},
  ];

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _setupMap() async {
    await _loadCustomMarkerIcon();
    await _getCurrentLocation();
    _addLocationMarkers();
  }

  Future<void> _loadCustomMarkerIcon() async {
    _customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/pointer.png',
    );
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _userMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Вы здесь'),
    );

    setState(() {
      _markers.add(_userMarker!);
    });

    // Подписываемся на обновления позиции и следим за пользователем
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position newPosition) {
      _currentPosition = newPosition;

      final updatedUserMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(newPosition.latitude, newPosition.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Вы здесь'),
      );

      setState(() {
        _markers.removeWhere((m) => m.markerId.value == 'user_location');
        _markers.add(updatedUserMarker);
        _userMarker = updatedUserMarker;
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(newPosition.latitude, newPosition.longitude),
        ),
      );

      // Автообновление маршрута при движении
      if (_activeDestination != null) {
        _drawRoute(_activeDestination!);
      }
    });
  }

  void _addLocationMarkers() {
    for (var i = 0; i < _locations.length; i++) {
      final data = _locations[i];
      final latLng = LatLng(data['lat'], data['lng']);
      _markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: latLng,
          icon: _customIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: data['title']),
          onTap: () {
            _activeDestination = latLng;
            _drawRoute(latLng);
          },
        ),
      );
    }
    setState(() {});
  }

  Future<void> _drawRoute(LatLng destination) async {
    if (_currentPosition == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates =
          result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: polylineCoordinates,
          ),
        );
      });

      await _fetchDistanceAndDuration(destination);

      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(_getLatLngBounds(polylineCoordinates), 50),
      );
    }
  }

  LatLngBounds _getLatLngBounds(List<LatLng> coords) {
    final swLat = coords.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final swLng = coords
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    final neLat = coords.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final neLng = coords
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(swLat, swLng),
      northeast: LatLng(neLat, neLng),
    );
  }

  Future<void> _fetchDistanceAndDuration(LatLng destination) async {
    final origin =
        '${_currentPosition!.latitude},${_currentPosition!.longitude}';
    final dest = '${destination.latitude},${destination.longitude}';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&key=$googleApiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final leg = data['routes'][0]['legs'][0];
        setState(() {
          _distanceText = leg['distance']['text'];
          _durationText = leg['duration']['text'];
        });
      }
    } else {
      setState(() {
        _distanceText = null;
        _durationText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Карта и маршрут')),
      body:
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      onMapCreated: (controller) => _mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        zoom: 14,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: _markers,
                      polylines: _polylines,
                    ),
                  ),
                  if (_distanceText != null && _durationText != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Расстояние: $_distanceText • Время: $_durationText',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
    );
  }
}
