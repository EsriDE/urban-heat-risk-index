import {
  property,
  subclass,
} from "@arcgis/core/core/accessorSupport/decorators";

import { tsx } from "@arcgis/core/widgets/support/widget";

import AppStore from "../stores/AppStore";
import Header from "./Header";
import { Widget } from "./Widget";
import Legend from "@arcgis/core/widgets/Legend";
import Expand from "@arcgis/core/widgets/Expand";
import Search from "@arcgis/core/widgets/Search";
import * as Config from '../../configs/config.json'
import FeatureLayer from "@arcgis/core/layers/FeatureLayer";
import LayerList from "@arcgis/core/widgets/LayerList";
import ShadowCast from "@arcgis/core/widgets/ShadowCast";
import Sketch from "@arcgis/core/widgets/Sketch";
import { PolygonSymbol3D, ExtrudeSymbol3DLayer } from "@arcgis/core/symbols";
import SolidEdges3D from "@arcgis/core/symbols/edges/SolidEdges3D";
import SketchViewModel from "@arcgis/core/widgets/Sketch/SketchViewModel";

type AppProperties = Pick<App, "store">;

@subclass("arcgis-core-template.App")
class App extends Widget<AppProperties> {
  @property()
  store: AppStore;

  postInitialize(): void {
    const view = this.store.view;

    // Legend
    const heatLayer = view.map.allLayers.find(function(layer) {
      return layer.title === Config.services.hriFeatureServiceTitle
     });
    const legend = new Legend({ 
      view: view, 
      layerInfos: [
        {
          layer: heatLayer,
          title: ""
        }] 
    })
    const expandLegend = new Expand({
      expandIcon: "color-coded-map", 
      expandTooltip: "Legend Heat Risk Layer",
      view: view,
      content: legend
    })
    view.ui.add({component: expandLegend, position: "top-left", index: 0})

    // Layer List
    const layerList = new LayerList({
      view: view
    })
    const expandLayerList = new Expand({
      expandIcon: "map-contents", 
      expandTooltip: "Layer List",
      view: view,
      content: layerList
    })
    view.ui.add({component: expandLayerList, position: "top-left", index: 1})
    
    // Search
    const search = new Search({view: view})
    view.ui.add({component: search, position: "top-right", index: 0})

    // Sketch
    const graphicsLayer = view.map.allLayers.find(function(layer) {
      return layer.title === 'Sketched geometries'
     });
     const buildingSymbology = new PolygonSymbol3D({
      symbolLayers: [
        new ExtrudeSymbol3DLayer({
          size: 0.5, // extrude by 3.5m meters
          material: {
            color: [255, 255, 255, 0.8]
          },
          edges: new SolidEdges3D({
            size: 1,
            color: [82, 82, 122, 1]
          })
        })
      ]
    });
    const sketchViewModel = new SketchViewModel({
      layer: graphicsLayer,
      view: view,
      polygonSymbol: buildingSymbology,
      valueOptions: {
        directionMode: "absolute"
      },
      tooltipOptions: {
        enabled: true,
        visibleElements: {
          elevation: true,
          area: false,
          coordinates: false,
          direction: false,
          distance: true
        }
      },
      labelOptions: {
        enabled: true
      },
      defaultUpdateOptions: {
        tool: "reshape",
        reshapeOptions: {
          edgeOperation: "offset"
        },
        enableZ: true
      },
      defaultCreateOptions: {
        defaultZ: 3,
        hasZ: true
      }
    })
     const sketch = new Sketch({
      layer: graphicsLayer,
      view: view,
      visibleElements: {
        createTools: {
          circle: false,
          polyline: false,
          point:false
        }
      },
      viewModel: sketchViewModel
    });
    const expandSketch = new Expand({
      expandIcon: "pencil",
      expandTooltip: "Draw",
      view: view,
      content: sketch
    })
    view.ui.add(expandSketch, 'top-right')

    // Shadow Cast
    const shadow = new ShadowCast({
      view: view,
      visibleElements: {
        'visualizationOptions': false
      }
    })
    shadow.viewModel.date = new Date("June 21, 2024");
    shadow.viewModel.visualizationType = "duration";
    const expandShadow = new Expand({
      expandIcon: "measure-building-height-shadow",
      expandTooltip: "Shadow Cast",
      view: view,
      content: shadow
    })
    view.ui.add(expandShadow, 'top-right')
  }

  render() {
    return (
      <div>
        <Header store={this.store}></Header>
      </div>
    );
  }
}

export default App;
