import * as kernel from "@arcgis/core/kernel";
import Map from "@arcgis/core/Map";
import SceneView from "@arcgis/core/views/SceneView";
import SceneLayer from "@arcgis/core/layers/SceneLayer";
import VectorTileLayer from "@arcgis/core/layers/VectorTileLayer";
import FeatureLayer from "@arcgis/core/layers/FeatureLayer";
import esriConfig from "@arcgis/core/config";
import "@esri/calcite-components/dist/calcite/calcite.css";
import * as AuthConfig from '../configs/authconfig.json';
import * as Config from '../configs/config.json'
import App from "./compontents/App";
import AppStore from "./stores/AppStore";
import WebScene from "@arcgis/core/WebScene";

console.log(`Using ArcGIS Maps SDK for JavaScript v${kernel.fullVersion}`);

// setAssetPath("https://js.arcgis.com/calcite-components/1.0.0-beta.77/assets");

esriConfig.apiKey = AuthConfig.apikey;

const hriVtLayer = new VectorTileLayer({
  url: Config.services.hriVectorTileServiceUrl,
  title: "hriVtLayer"
})

const osmBuildingsSceneLayer = new SceneLayer({  
    url: Config.services.osmBuildingsSceneLayerUrl,
    popupEnabled: false
  },
);

const osmTreesSceneLayer = new SceneLayer({
  url: Config.services.osmTreesSceneLayerUrl,
  popupEnabled: false
});

const hriFLayer = new FeatureLayer({
  url: Config.services.hriFeatureServiceUrl,
  definitionExpression: "hri >= 9",
  // opacity: 0.3,
  title: "hriFLayer"
});


const map = new WebScene({
  basemap: Config.services.basemap, // basemap styles service
  ground: Config.services.elevation, //Elevation service
  layers: [hriVtLayer, osmBuildingsSceneLayer, osmTreesSceneLayer, hriFLayer],
});

const view = new SceneView({
  container: "viewDiv",
  map: map,
  camera: {
    position: {
      x: 7.100000, //Longitude
      y: 50.733334, //Latitude
      z: 2000 //Meters
    },
    tilt: 75
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
