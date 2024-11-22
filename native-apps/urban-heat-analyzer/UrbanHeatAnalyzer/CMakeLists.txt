#-------------------------------------------------
#  Copyright 2024 ESRI
#
#  All rights reserved under the copyright laws of the United States
#  and applicable international laws, treaties, and conventions.
#
#  You may freely redistribute and use this sample code, with or
#  without modification, provided you include the original copyright
#  notice and use restrictions.
#
#  See the Sample code usage restrictions document for further information.
#-------------------------------------------------
cmake_minimum_required(VERSION 3.5)

project(UrbanHeatAnalyzer LANGUAGES CXX)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC OFF)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(IOS)
  set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
  set(CMAKE_OSX_DEPLOYMENT_TARGET "16.0" CACHE STRING "Minimum iOS deployment version" FORCE)
elseif(APPLE)
  set(CMAKE_OSX_DEPLOYMENT_TARGET "13.0" CACHE STRING "Minimum macOS deployment version" FORCE)
endif()

find_package(Qt6 COMPONENTS REQUIRED Core Quick Multimedia Positioning Sensors WebSockets)
if (Qt6Core_VERSION VERSION_LESS 6.5.6)
  message(FATAL_ERROR "This version of the ArcGIS Maps SDK for Qt requires at least Qt 6.5.6")
endif()
if(ANDROID OR IOS)
  find_package(Qt6 COMPONENTS REQUIRED Bluetooth)
endif()
find_package(ArcGISRuntime 200.5.0 COMPONENTS REQUIRED Cpp)

set(SOURCE_FILES
  main.cpp
  UrbanHeatAnalyzer.cpp
  UrbanHeatAnalyzer.h
  HeatRiskListModel.cpp
  HeatRiskListModel.h
  qml/qml.qrc
  Resources/Resources.qrc
  $<$<BOOL:${WIN32}>:Win/Resources.rc>
  $<$<BOOL:${APPLE}>:Mac/AppIcon.icns>)

if(ANDROID)
  qt_add_executable(${PROJECT_NAME} ${SOURCE_FILES})
else()
  qt_add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${SOURCE_FILES})
  # IOS uses static Runtimecore Framework
  if(IOS)
    set_target_properties(${PROJECT_NAME} PROPERTIES INSTALL_RPATH @executable_path/Frameworks 
    XCODE_EMBED_FRAMEWORKS ${ArcGISRuntime_runtimecore_LIB} 
    XCODE_EMBED_FRAMEWORKS_CODE_SIGN_ON_COPY TRUE)
  endif()
  # On MacOSX add icon to app bundle.
  set(MACOSX_BUNDLE_ICON_FILE AppIcon.icns)
  set_source_files_properties(Mac/AppIcon.icns
    PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

  # Copy required dynamic libraries to the build folder as a post-build step.
  if(DEFINED ArcGISRuntime_LIBRARIES)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
      ${ArcGISRuntime_LIBRARIES}
      $<TARGET_FILE_DIR:${PROJECT_NAME}>)
  endif()
endif()

target_compile_definitions(${PROJECT_NAME}
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME} PRIVATE
  Qt6::Core
  Qt6::Quick
  Qt6::Multimedia
  Qt6::Positioning
  Qt6::Sensors
  Qt6::WebSockets
  ArcGISRuntime::Cpp)

# To integrate the toolkit, copy the `toolkitcpp` subdirectory from the toolkit
# into your project's directory. Then uncomment the following lines to add it to your project.
# See https://github.com/Esri/arcgis-maps-sdk-toolkit-qt for details
# add_subdirectory(toolkitcpp)
# target_link_libraries(${PROJECT_NAME} PRIVATE libtoolkitcpp)

if(ANDROID OR IOS)
  target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Bluetooth)
endif()

if(ANDROID)
  target_link_libraries(${PROJECT_NAME} PRIVATE Qt::CorePrivate)

  set(PROJECT_DEPLOYABLE_LIBS
    ${ArcGISRuntime_LIBRARIES})

  list(JOIN PROJECT_DEPLOYABLE_LIBS , PROJECT_DEPLOYABLE_LIBS_STRING)

  # Setup openssl by cloning the repo https://github.com/KDAB/android_openssl More info at https://doc.qt.io/qt-6/android-openssl-support.html
  # QtCreator can also be used to install openssl https://doc.qt.io/qtcreator/creator-developing-android.html#specifying-android-device-settings
  # Uncomment line below and point to your openssl path.

  #include(<your_path_to_android_openssl>/CMakeLists.txt)

  # QtCreator supports the following variables for Android, which are identical
  # to qmake Android variables.
  # Check http://doc.qt.io/qt-6/deployment-android.html for more information.
  # Setting this property changed at Qt6 see doc below.
  # https://doc.qt.io/qt-6/cmake-target-property-qt-android-extra-libs.html

  set_property(TARGET ${PROJECT_NAME} PROPERTY QT_ANDROID_EXTRA_LIBS ${PROJECT_DEPLOYABLE_LIBS_STRING} ${ANDROID_EXTRA_LIBS})
  get_property(EXTRA_LIBS TARGET ${PROJECT_NAME} PROPERTY QT_ANDROID_EXTRA_LIBS)
  if(NOT EXTRA_LIBS MATCHES "libssl" OR NOT EXTRA_LIBS MATCHES "libcrypto")
      message(WARNING "openssl libraries are missing, check the project CMakeLists.txt and set up openssl environment")
  endif()
endif()
