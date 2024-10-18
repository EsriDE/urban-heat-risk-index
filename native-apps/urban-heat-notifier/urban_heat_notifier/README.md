# urban_heat_notifier

## Overview

This project is based on the ArcGIS Maps SDK for Flutter (Beta 2) and ArcGIS Location Platform. Users will be notified when they are in a heat-risk area. They can display POIs with options for cooling down/drinking or where they can get help and can navigate there with a compass.

## Getting Started

To build this app, you will require the following:

1. Install Flutter: Follow the instructions on the Flutter documentation [get started guide](https://docs.flutter.dev/get-started/install). Xcode and Android Studio are required for their respective platforms, and Visual Studio Code is the recommended IDE.

2. Download the ArcGIS Maps SDK for Flutter beta: Access the beta by registering on Esri’s [Early Adopter website](https://earlyadopter.esri.com/project/home.html?cap=%7Bdd2444fc-5d36-44bb-8384-4a56046b9580%7D). Refer to the documentation there on how to get started.

3. API key: You will require an API key access token to authenticate the basemap services used in this application. Learn how to create one on the Esri [Developers website](https://developers.arcgis.com/documentation/security-and-authentication/api-key-authentication/tutorials/create-an-api-key/)


Step 1: Download ArcGIS Maps SDK for Flutter Beta 2

Unpack the arcgis_maps_package archive into the same parent directory as your app:

parent_directory
   |
   |__ urban_heat_notifier
   |
   |__ arcgis_maps_package


Navigate to the `urban_heat_notifier` directory.

```
cd urban_heat_notifier
```

Use `flutter pub upgrade` to configure the dependencies.

```
flutter pub upgrade
```

Step 2: Configure environment variables (based on [ENVied](https://pub.dev/packages/envied))

Edit the .env configuration file

    - insert your API Key --> APIKEY=......
    -
    -

Use `dart run build_runner build` to run the generator:

```
dart run build_runner build
```

Step 3 Run the application

```
flutter run
```

## Licensing

Copyright 2024 Esri Deutschland GmbH

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

A copy of the license is available in the repository's LICENSE file.


[ENVied](https://pub.dev/packages/envied):
MIT © Peter Cinibulk
