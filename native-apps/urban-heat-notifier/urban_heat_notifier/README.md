# urban_heat_notifier

## Overview

This project is based on the ArcGIS Maps SDK for Flutter 200.6 and ArcGIS Location Platform. Users will be notified when they are in a heat-risk area. They can display POIs with options for cooling down/drinking or where they can get help and can navigate there with a compass.

## Getting Started

To build this app, you will require the following:

https://developers.arcgis.com/flutter/get-started/


Step 1: Get the SDK and dependencies

Navigate to the `urban_heat_notifier` directory.

Run: dart pub add arcgis_maps
Run: flutter pub upgrade
Run: dart run arcgis_maps install


Step 2: Configure environment variables (based on [ENVied](https://pub.dev/packages/envied))

Edit the .env configuration file

    - insert your API Key --> APIKEY=......
    -
    -

Use `dart run build_runner build` to run the generator:

```
dart run build_runner build
```

When modifying the .env file, the generator might not pick up the change. If that happens simply clean the build cache and run the generator again.

```
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
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
