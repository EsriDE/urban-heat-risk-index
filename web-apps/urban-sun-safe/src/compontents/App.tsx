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
import SceneLayer from "@arcgis/core/layers/SceneLayer";

type AppProperties = Pick<App, "store">;

@subclass("arcgis-core-template.App")
class App extends Widget<AppProperties> {
  @property()
  store: AppStore;

  postInitialize(): void {
    const view = this.store.view;
    
    // Shadow Cast Panel
    const container = document.createElement('div')
    container.classList.add('shadowPanel')
    // Search
    const searchContainer = this.createShadowPanelElement(container, Config.shadowPanel.labelSearch)
    new Search({view: view, container: searchContainer})
    // Shadow Cast
    const shadowContainer = this.createShadowPanelElement(container, Config.shadowPanel.labelShadow)
    const shadow = new ShadowCast({
      view: view,
      visibleElements: {
        'visualizationOptions': false
      },
      container: shadowContainer
    })
    shadow.viewModel.date = new Date("June 21, 2024");
    shadow.viewModel.visualizationType = "duration";
    shadow.visible = false
    // Sketch
    const sketchContainer = this.createShadowPanelElement(container, Config.shadowPanel.labelDraw)
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
    const buildingLayer = view.map.allLayers.find(function(layer) {
      return layer.title === Config.services.osmBuildingTitle
     }) as SceneLayer;
    new Sketch({
      layer: graphicsLayer,
      view: view,
      visibleElements: {
        createTools: {
          circle: false,
          polyline: false,
          point:false
        }
      },
      snappingOptions: {
        enabled: true,
        selfEnabled: true,
        featureSources: [{ layer: buildingLayer, enabled: true}]
      },
      viewModel: sketchViewModel,
      container: sketchContainer
    });
    // Expand
    const expandShadow = new Expand({
      expandIcon: "brightness",
      expandTooltip: "Shadow Cast",
      view: view,
      content: container
    })
    view.ui.add(expandShadow, 'top-left')
    // Hide Shadow when panel closed
    expandShadow.watch('expanded', (expanded) =>{
      if (expanded) {
        shadow.visible = true
      } else {
        shadow.visible = false
      }
    });

    // Map Tools
    view.ui.move([ "zoom", "compass", "navigation-toggle" ], "top-right");
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
    view.ui.add({component: expandLegend, position: "top-right", index: 0})

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
    view.ui.add({component: expandLayerList, position: "top-right", index: 1})
  }

  createShadowPanelElement(parentContainer: HTMLDivElement, header: string): HTMLDivElement {
    const container = document.createElement('div')
    container.classList.add('shadowPanelElement')
    const label = document.createElement('div')
    label.classList.add('shadowPanelElementLabel')
    label.innerHTML = header
    container.appendChild(label)
    parentContainer.appendChild(container)
    return container
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
