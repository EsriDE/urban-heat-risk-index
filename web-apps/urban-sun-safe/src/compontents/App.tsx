import {
  property,
  subclass,
} from "@arcgis/core/core/accessorSupport/decorators";

import { tsx } from "@arcgis/core/widgets/support/widget";

import { watch } from "@arcgis/core/core/reactiveUtils";
import Fullscreen from "@arcgis/core/widgets/Fullscreen";
import AppStore from "../stores/AppStore";
import Header from "./Header";
import Player from "./Player";
import { Widget } from "./Widget";

type AppProperties = Pick<App, "store">;

@subclass("arcgis-core-template.App")
class App extends Widget<AppProperties> {
  @property()
  store: AppStore;

  postInitialize(): void {
    const view = this.store.view;
    const fullscreen = new Fullscreen({ view });
    view.ui.add(fullscreen, "top-right");

    const player = new Player({
      store: this.store.playerStore,
    });

    view.ui.add(player, "bottom-right");

    this.addHandles(
      watch(
        () => this.store.playerStore.state,
        (state) => {
          if (state === "animating") {
            player.visible = false;
            fullscreen.visible = false;
          } else if (state === "ready") {
            player.visible = true;
            fullscreen.visible = true;
          }
        }
      )
    );
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
