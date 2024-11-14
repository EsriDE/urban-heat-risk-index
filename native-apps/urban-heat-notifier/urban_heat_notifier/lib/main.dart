import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'dart:convert';
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
  late ArcGISVectorTiledLayer _hriVectorTiledLayer;
  late FeatureLayer _hriFeatureLayer;
  

  @override
  void initState() {
    super.initState();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Env.title)
      ),
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

      BasemapStyle basemapStyle = BasemapStyle.values.firstWhere((e) => e.toString() == Env.basemap);
      var map = ArcGISMap.withBasemapStyle(basemapStyle);


      final parsedInitialViewPoint = jsonDecode(Env.initialViewPont);

      map.initialViewpoint = Viewpoint.fromCenter(
      ArcGISPoint(
        x: double.parse(parsedInitialViewPoint["lon"].toString()),
        y: double.parse(parsedInitialViewPoint["lat"].toString()),
        spatialReference: SpatialReference.wgs84,
      ),
      scale: double.parse(parsedInitialViewPoint["scale"].toString()),
    );


      var portalItem = PortalItem.withPortalAndItemId(portal: Portal.arcGISOnline(), itemId: Env.hriVectorTileServicePortalItemID);
      _hriVectorTiledLayer = ArcGISVectorTiledLayer.withItem(portalItem);
      map.operationalLayers.add(_hriVectorTiledLayer);

      portalItem = PortalItem.withPortalAndItemId(portal: Portal.arcGISOnline(), itemId: Env.hriFeatureServicePortalItemID);
      _hriFeatureLayer = FeatureLayer.withFeatureLayerItem(portalItem);
      _hriFeatureLayer.definitionExpression = "hri >= 9";
      _hriFeatureLayer.opacity = .5;
      map.operationalLayers.add(_hriFeatureLayer);

      _mapViewController.arcGISMap = map;

      // Set the initial system location data source and auto-pan mode.
      _mapViewController.locationDisplay.dataSource = SystemLocationDataSource();
      _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.compassNavigation;
      _mapViewController.locationDisplay.initialZoomScale = 2000;

      _mapViewController.onScaleChanged.listen((scale){
        _toggleUserLocation();
        _toggleLayerVisibility(scale);
      });
  }

    void _toggleUserLocation() async {
      if (_switchValue) {
        _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.compassNavigation;
        _mapViewController.locationDisplay.start();
      } else {
        _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.off;
        _mapViewController.locationDisplay.stop();
      }
  }

      void _toggleLayerVisibility(double scale) async {
      if (scale <= 10000) {
        _hriVectorTiledLayer.isVisible = false;
        _hriFeatureLayer.isVisible = true;
      } else {
        _hriVectorTiledLayer.isVisible = true;
        _hriFeatureLayer.isVisible = false;
      }
  }
}