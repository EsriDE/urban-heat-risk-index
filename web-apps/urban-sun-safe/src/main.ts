import * as kernel from "@arcgis/core/kernel";
import Map from "@arcgis/core/Map";
import SceneView from "@arcgis/core/views/SceneView";
import SceneLayer from "@arcgis/core/layers/SceneLayer";
import VectorTileLayer from "@arcgis/core/layers/VectorTileLayer";
import FeatureLayer from "@arcgis/core/layers/FeatureLayer";
import esriConfig from "@arcgis/core/config";
import "@esri/calcite-components/dist/calcite/calcite.css";
import * as Config from '../configs/config.json'
import App from "./compontents/App";
import AppStore from "./stores/AppStore";
import WebScene from "@arcgis/core/WebScene";
import GraphicsLayer from "@arcgis/core/layers/GraphicsLayer";

console.log(`Using ArcGIS Maps SDK for JavaScript v${kernel.fullVersion}`);

// setAssetPath("https://js.arcgis.com/calcite-components/1.0.0-beta.77/assets");

esriConfig.apiKey = Config.apikey;

const hriVtLayer = new VectorTileLayer({
  url: Config.services.hriVectorTileServiceUrl,
  title: Config.services.hriVectorTileServiceTitle
})

const osmBuildingsSceneLayer = new SceneLayer({  
    url: Config.services.osmBuildingsSceneLayerUrl,
    popupEnabled: false,
    title: Config.services.osmBuildingTitle
  },
);

const osmTreesSceneLayer = new SceneLayer({
  url: Config.services.osmTreesSceneLayerUrl,
  popupEnabled: false,
  title: Config.services.osmTreesTitle
});

const hriFLayer = new FeatureLayer({
  portalItem: {
    id: Config.services.hriFeatureServicePortalItem
  },
  elevationInfo: {
    mode: 'relative-to-ground',
    offset: 3
  },
  opacity: 0.5,
  minScale: 3000,
  title: Config.services.hriFeatureServiceTitle
});

  const sketchLayer = new GraphicsLayer({
    elevationInfo: {
      mode: "relative-to-ground"
    },
    title: "Sketched geometries",
    listMode: 'hide'
  })


const webMap = new WebScene({
  basemap: Config.services.basemap, // basemap styles service
  ground: Config.services.elevation, //Elevation service
  layers: [hriVtLayer, osmBuildingsSceneLayer, osmTreesSceneLayer, hriFLayer, sketchLayer]
});

const view = new SceneView({
  container: "viewDiv",
  map: webMap,
  camera: {
    position: {
      x: 7.10, //Longitude
      y: 50.71, //Latitude
      z: 2000 //Meters
    },
    tilt: 60
  }
  });

(window as any)["view"] = view;

const store = new AppStore({
  view,
});

const app = new App({
  container: "app",
  store,
});
