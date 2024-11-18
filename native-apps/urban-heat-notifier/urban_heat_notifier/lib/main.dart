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
  bool _showHriDetails = false;
  Feature? _currentLocationFeature;
  String _hriDetails = '';
  Map<String, String> _fieldAliases = {};
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
        appBar: AppBar(title: Text(Env.title)),
        body: Stack(children: [
          ArcGISMapView(
              controllerProvider: () => _mapViewController,
              onMapViewReady: onMapViewReady),
          Positioned(
            bottom: 30,
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
          Positioned(
            bottom: 65,
            right: 16,
            child: Row(
              children: [
                Text('Show HRI Details'),
                Switch(
                  value: _showHriDetails,
                  onChanged: (value) {
                    setState(() {
                      _showHriDetails = value;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_showHriDetails)
            Positioned(
              bottom: 30,
              left: 10,
              child: Container(
                width: 200,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HRI Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 0),
                    Text(
                      _hriDetails,
                    ),
                  ],
                ),
              ),
            ),
        ]));
  }

  void onMapViewReady() async {
    BasemapStyle basemapStyle =
        BasemapStyle.values.firstWhere((e) => e.toString() == Env.basemap);
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

    var portalItem = PortalItem.withPortalAndItemId(
        portal: Portal.arcGISOnline(),
        itemId: Env.hriVectorTileServicePortalItemID);
    _hriVectorTiledLayer = ArcGISVectorTiledLayer.withItem(portalItem);
    map.operationalLayers.add(_hriVectorTiledLayer);

    portalItem = PortalItem.withPortalAndItemId(
        portal: Portal.arcGISOnline(),
        itemId: Env.hriFeatureServicePortalItemID);

    _hriFeatureLayer =
        FeatureLayer.withItem(featureServiceItem: portalItem, layerId: 0);
    _hriFeatureLayer.definitionExpression = "hri >= 9";
    _hriFeatureLayer.opacity = .5;
    map.operationalLayers.add(_hriFeatureLayer);

    await _hriFeatureLayer.load();
    setState(() {
      _fieldAliases = {
        for (var field in _hriFeatureLayer.featureTable!.fields)
          field.name: field.alias
      };
    });

    _mapViewController.arcGISMap = map;

    // Set the initial system location data source and auto-pan mode.
    _mapViewController.locationDisplay.dataSource = SystemLocationDataSource();
    _mapViewController.locationDisplay.autoPanMode =
        LocationDisplayAutoPanMode.compassNavigation;
    _mapViewController.locationDisplay.initialZoomScale = 2000;

    _mapViewController.locationDisplay.onLocationChanged
        .listen((location) async {
          
      _hriFeatureLayer.clearSelection();
      final locationGeometryProjected = GeometryEngine.project(
          location.position,
          outputSpatialReference: SpatialReference.webMercator);

      final queryParameters = QueryParameters();
      queryParameters.geometry = locationGeometryProjected;
      queryParameters.maxFeatures = 1;
      queryParameters.returnGeometry = false;

      ServiceFeatureTable sfTable =
          _hriFeatureLayer.featureTable as ServiceFeatureTable;

      final queryResult = await sfTable.queryFeaturesWithFieldOptions(
          parameters: queryParameters,
          queryFeatureFields: QueryFeatureFields.loadAll);

      if (!queryResult.features().isEmpty) {
        final locationFeature = queryResult.features().first;

        _currentLocationFeature = locationFeature;
        _hriFeatureLayer.selectFeature(feature: locationFeature);

        setState(() {
          _hriDetails = _currentLocationFeature!.attributes.entries
              .where((entry) => ['HRI', 'PCT_built_up_area', 'PCT_Tree_Cover']
                  .contains(entry.key))
              .map((entry) {
            final value = entry.value;
            final displayValue =
                value is double ? value.toStringAsFixed(2) : value.toString();
            return '${_fieldAliases[entry.key] ?? entry.key}: $displayValue';
          }).join('\n');
        });
      } else {
        setState(() {
          _hriDetails = '';
        });
      }
    });

    _mapViewController.onScaleChanged.listen((scale) {
      _toggleUserLocation();
      _toggleLayerVisibility(scale);
    });
  }

  void _toggleUserLocation() async {
    if (_switchValue) {
      _mapViewController.locationDisplay.autoPanMode =
          LocationDisplayAutoPanMode.compassNavigation;
      _mapViewController.locationDisplay.start();
    } else {
      _mapViewController.locationDisplay.autoPanMode =
          LocationDisplayAutoPanMode.off;
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
