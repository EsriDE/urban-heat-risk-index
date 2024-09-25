import WebScene from "@arcgis/core/WebScene";
import Accessor from "@arcgis/core/core/Accessor";
import {
  property,
  subclass,
} from "@arcgis/core/core/accessorSupport/decorators";
import { whenOnce } from "@arcgis/core/core/reactiveUtils";
import SceneView from "@arcgis/core/views/SceneView";
import PlayerStore from "./PlayerStore";
import UserStore from "./UserStore";

type AppStoreProperties = Pick<AppStore, "view">;

@subclass("arcgis-core-template.AppStore")
class AppStore extends Accessor {
  @property({ aliasOf: "view.map" })
  map: WebScene;

  @property({ constructOnly: true })
  view: SceneView;

  @property({ constructOnly: true })
  userStore = new UserStore();

  @property({ constructOnly: true })
  playerStore: PlayerStore;

  constructor(props: AppStoreProperties) {
    super(props);

    this.playerStore = new PlayerStore({ view: props.view });

    whenOnce(() => this.map).then(async (map) => {
      await map.load();
      document.title = map.portalItem.title;

      await map.loadAll();

      this.playerStore.slides = map.presentation.slides;
    });
  }
}

export default AppStore;
