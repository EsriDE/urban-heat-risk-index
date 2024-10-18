import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'env/env.dart';

void main() {

  ArcGISEnvironment.apiKey = Env.apikey;

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArcGISMapView(
        controllerProvider: () => ArcGISMapView.createController()
          ..arcGISMap = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic),
      ),
    );
  }
}