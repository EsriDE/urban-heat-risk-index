import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:http/http.dart' as http;
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
  late FeatureLayer _dwFeatureLayer;
  bool isButtonVisible = false;
  final _geodeticOverlay = GraphicsOverlay();
  final _placesOverlay = GraphicsOverlay();

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
            onMapViewReady: onMapViewReady,
            onLongPressEnd: onLongPressEnd,
          ),
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
          Positioned(
            bottom: 110,
            right: 18,
            child: Visibility(
              visible: isButtonVisible,
              child: Container(
                height: 30,
                width: 55,
                child: FloatingActionButton(
                  onPressed: onClearButtenPressed,
                  backgroundColor: Colors.grey,
                  child: Text("Clear"),
                ),
              ),
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

  void onLongPressEnd(Offset screenPoint) async {
    if (!isButtonVisible) {
      _hriFeatureLayer.isVisible = false;
      _geodeticOverlay.graphics.clear();
      // Capture the tapped point and convert it to a map point.
      final mapPoint = _mapViewController.screenToLocation(screen: screenPoint);
      if (mapPoint == null) return;

      // Create a geodetic buffer around the tapped point at the specified distance.
      final geodeticGeometry = GeometryEngine.bufferGeodetic(
        geometry: mapPoint,
        distance: double.parse(Env.placesSearchRadius),
        distanceUnit: LinearUnit(unitId: LinearUnitId.meters),
        maxDeviation: double.nan,
        curveType: GeodeticCurveType.geodesic,
      );

      showBuffer(geodeticGeometry);
      showDrinkingWater(geodeticGeometry);
      showPlaces(mapPoint);

      setState(() {
        isButtonVisible = !isButtonVisible;
      });
    }
  }

  void showBuffer(Geometry geodeticGeometry) async {
    final geodeticGraphic = Graphic(geometry: geodeticGeometry);
    _geodeticOverlay.graphics.add(geodeticGraphic);
  }

  void showPlaces(Geometry mapPoint) async {
    final wgs84MapPoint = GeometryEngine.project(mapPoint,
        outputSpatialReference: SpatialReference.wgs84) as ArcGISPoint;

    String url = '${Env.placesServiceUrl}'
        '?f=json'
        '&x=${wgs84MapPoint.x}'
        '&y=${wgs84MapPoint.y}'
        '&radius=${Env.placesSearchRadius}'
        '&categoryIds=${Env.placesCategoryIds}'
        '&pageSize=20'
        '&icon=png'
        '&token=${Env.apikey}';

    List<dynamic> allResults = [];
    bool hasNextPage = true;

    while (hasNextPage) {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final String responseBody = response.body;

        final Map<String, dynamic> jsonResponse = json.decode(responseBody);
        allResults.addAll(jsonResponse['results']);

        if (jsonResponse.containsKey('pagination') &&
            jsonResponse['pagination'].containsKey('nextUrl')) {
          url = jsonResponse['pagination']['nextUrl'];
          url += '&token=${Env.apikey}';
          print('Next URL: $url'); // Debugging-Ausgabe
        } else {
          hasNextPage = false;
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        hasNextPage = false;
      }
    }

    List<Graphic> graphics = allResults.map((result) {
      double x = result['location']['x'];
      double y = result['location']['y'];
      ArcGISPoint point = ArcGISPoint(
        x: x,
        y: y,
        spatialReference: SpatialReference.wgs84,
      );

      ArcGISPoint projectedPoint = GeometryEngine.project(point,
          outputSpatialReference: SpatialReference.webMercator) as ArcGISPoint;

      Map<String, dynamic> attributes = {
        'placeId': result['placeId'],
        'name': result['name'],
        'distance': result['distance'],
        'categoryId': result['categories'][0]['categoryId'],
        'categoryLabel': result['categories'][0]['label'],
      };

      Uri iconUri = Uri.parse(result['icon']['url']);
      PictureMarkerSymbol symbol = PictureMarkerSymbol.withUri(iconUri);
      symbol.width = 30;
      symbol.height = 30;

      return Graphic(
        geometry: projectedPoint,
        symbol: symbol,
        attributes: attributes,
      );
    }).toList();

    _placesOverlay.graphics.addAll(graphics);
  }

  void showDrinkingWater(Geometry geodeticGeometry) async {
    final queryParameters = QueryParameters();
    queryParameters.geometry = geodeticGeometry;
    queryParameters.returnGeometry = false;

    ServiceFeatureTable sfTable =
        _dwFeatureLayer.featureTable as ServiceFeatureTable;

    final queryResult = await sfTable.queryFeatures(
      queryParameters
    );

    var whereClause = '';

    for (var feature in queryResult.features()) {
      whereClause =
          whereClause + 'ObjectId = ${feature.attributes['ObjectId']}';

      if (feature.attributes['ObjectId'] !=
              queryResult.features().first.attributes['ObjectId'] &&
          feature.attributes['ObjectId'] !=
              queryResult.features().last.attributes['objectId']) {
        whereClause = whereClause + ' OR ';
      }
    }

    _dwFeatureLayer.definitionExpression = whereClause;
    await _dwFeatureLayer.retryLoad();
    // _dwFeatureLayer.setFeaturesVisible(features: queryResult.features().toList(), visible: false);
    _dwFeatureLayer.isVisible = true;
  }

  void onClearButtenPressed() {
    _geodeticOverlay.graphics.clear();
    _placesOverlay.graphics.clear();
    _dwFeatureLayer.isVisible = false;
    _hriFeatureLayer.isVisible = true;
    setState(() {
      isButtonVisible = !isButtonVisible;
    });
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
        FeatureLayer.withItem(item: portalItem, layerId: 0);
    _hriFeatureLayer.definitionExpression = "hri >= 9";
    _hriFeatureLayer.opacity = .4;
    map.operationalLayers.add(_hriFeatureLayer);

    await _hriFeatureLayer.load();
    setState(() {
      _fieldAliases = {
        for (var field in _hriFeatureLayer.featureTable!.fields)
          field.name: field.alias
      };
    });

    portalItem = PortalItem.withPortalAndItemId(
        portal: Portal.arcGISOnline(),
        itemId: Env.drinkingWaterFeatureServicePortalItemID);

    _dwFeatureLayer =
        FeatureLayer.withItem(item: portalItem, layerId: 0);
    _dwFeatureLayer.isVisible = false;
    map.operationalLayers.add(_dwFeatureLayer);

    _mapViewController.arcGISMap = map;

    // Configure the graphics overlay for the geodetic buffers.
    _geodeticOverlay.renderer = SimpleRenderer(
      symbol: SimpleFillSymbol(
        style: SimpleFillSymbolStyle.solid,
        color: Colors.grey,
        outline: SimpleLineSymbol(
          style: SimpleLineSymbolStyle.solid,
          color: Colors.red,
          width: 5.0,
        ),
      ),
    );
    _geodeticOverlay.opacity = 0.2;

    _mapViewController.graphicsOverlays.addAll(
      [_geodeticOverlay, _placesOverlay],
    );

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

      if (queryResult.features().isNotEmpty) {
        final locationFeature = queryResult.features().first;

        _currentLocationFeature = locationFeature;
        if (_switchValue) {
          _hriFeatureLayer.selectFeature(locationFeature);
        }

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
    if (!_placesOverlay.graphics.isEmpty) return;

    if (scale <= 10000) {
      _hriVectorTiledLayer.isVisible = false;
      _hriFeatureLayer.isVisible = true;
    } else {
      _hriVectorTiledLayer.isVisible = true;
      _hriFeatureLayer.isVisible = false;
    }
  }
}
