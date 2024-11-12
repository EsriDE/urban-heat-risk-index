import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'env/env.dart';

void main() {
  ArcGISEnvironment.apiKey = Env.apikey;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _switchValue = false;
  final _mapViewController = ArcGISMapView.createController();

  @override
  void initState() {
    super.initState();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onMapViewReady: onMapViewReady
      ),
      Positioned(
            bottom: 25,
            right: 16,
            child: Row(
              children: [
                Text('Show Location'),
                Switch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                      _toggleUserLocation();
                    });
                  },
                ),
              ],
            ),
          ),
      ])
    );
  }

    void onMapViewReady() {
      _mapViewController.arcGISMap = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISLightGray);

      // Set the initial system location data source and auto-pan mode.
      _mapViewController.locationDisplay.dataSource = SystemLocationDataSource();
      _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.compassNavigation;
  }

    void _toggleUserLocation() {
      if (_switchValue) {
        _mapViewController.locationDisplay.start();
      } else {
        _mapViewController.locationDisplay.stop();
      }
  }
}