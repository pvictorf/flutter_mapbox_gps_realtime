import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:location/location.dart';

class FullScreenMap extends StatefulWidget {
  const FullScreenMap({Key key}) : super(key: key);

  @override
  _FullScreenMapState createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  MapboxMapController mapController;
  MinMaxZoomPreference _minMaxZoomPreference = MinMaxZoomPreference.unbounded;
  CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  List<Object> _featureQueryFilter;
  bool _isMoving = false;
  bool _scrollGesturesEnabled = true;
  bool _tiltGesturesEnabled = true;
  bool _zoomGesturesEnabled = true;
  bool _myLocationEnabled = true;
  bool _rotateGesturesEnabled = true;
  bool _compassEnabled = true;
  bool _trackCameraPosition = true;
  LatLng _currentLocation = LatLng(-22.4891277, -43.4798553);
  LatLng _userPosition;

  void _getUserLocation() async {
    Location location = Location();
    PermissionStatus hasPermissions = await location.hasPermission();

    if (hasPermissions != PermissionStatus.granted) {
      hasPermissions = await location.requestPermission();
    }

    if (hasPermissions != PermissionStatus.denied) {
      var locationData = await location.getLocation();
      _userPosition = LatLng(locationData.latitude, locationData.longitude);
    }
  }

  void _moveCameraToUser(LatLng latLng) {
    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(latLng));
    }
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController.setTelemetryEnabled(false);
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: MapboxMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition:
              CameraPosition(target: _currentLocation, zoom: 15),
          myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
          myLocationRenderMode: MyLocationRenderMode.GPS,
          myLocationEnabled: _myLocationEnabled,
          zoomGesturesEnabled: _zoomGesturesEnabled,
          tiltGesturesEnabled: _tiltGesturesEnabled,
          scrollGesturesEnabled: _scrollGesturesEnabled,
          rotateGesturesEnabled: _rotateGesturesEnabled,
          minMaxZoomPreference: _minMaxZoomPreference,
          trackCameraPosition: _trackCameraPosition,
          compassEnabled: _compassEnabled,
          cameraTargetBounds: _cameraTargetBounds,
          onMapClick: (point, latLng) async {
            print(
                "Map click: ${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}");
            print("Filter $_featureQueryFilter");
            List features = await mapController.queryRenderedFeatures(
                point, [], _featureQueryFilter);
            if (features.length > 0) {
              print(features[0]);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _moveCameraToUser(_userPosition);
        },
        child: Icon(Icons.gps_fixed),
      ),
    );
  }
}
