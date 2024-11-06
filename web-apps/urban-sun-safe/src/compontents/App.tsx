import {
  property,
  subclass,
} from "@arcgis/core/core/accessorSupport/decorators";

import { tsx } from "@arcgis/core/widgets/support/widget";

import Fullscreen from "@arcgis/core/widgets/Fullscreen";
import AppStore from "../stores/AppStore";
import Header from "./Header";
import { Widget } from "./Widget";
import Legend from "@arcgis/core/widgets/Legend";
import Expand from "@arcgis/core/widgets/Expand";
import Search from "@arcgis/core/widgets/Search";
import * as Config from '../../configs/config.json'
import FeatureLayer from "@arcgis/core/layers/FeatureLayer";
import LayerList from "@arcgis/core/widgets/LayerList";

type AppProperties = Pick<App, "store">;

@subclass("arcgis-core-template.App")
class App extends Widget<AppProperties> {
  @property()
  store: AppStore;

  postInitialize(): void {
    const view = this.store.view;
    const fullscreen = new Fullscreen({ view });
    view.ui.add(fullscreen, "top-right");

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
    const search = new Search({view: view})
    view.ui.add({component: search, position: "top-right", index: 0})
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
