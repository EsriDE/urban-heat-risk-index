import {
  property,
  subclass,
} from "@arcgis/core/core/accessorSupport/decorators";
import AppStore from "../stores/AppStore";
import { Widget } from "./Widget";

import { tsx } from "@arcgis/core/widgets/support/widget";

import "@esri/calcite-components/dist/components/calcite-action";
import "@esri/calcite-components/dist/components/calcite-button";
import "@esri/calcite-components/dist/components/calcite-menu";
import "@esri/calcite-components/dist/components/calcite-menu-item";
import "@esri/calcite-components/dist/components/calcite-navigation";
import "@esri/calcite-components/dist/components/calcite-navigation-logo";
import "@esri/calcite-components/dist/components/calcite-navigation-user";
import * as Config from '../../configs/config.json'
import { CalciteButton } from "@esri/calcite-components/dist/components/calcite-button";

type HeaderProperties = Pick<Header, "store">;

@subclass("arcgis-core-template.Header")
class Header extends Widget<HeaderProperties> {
  @property()
  store: AppStore;

  constructor(props: HeaderProperties) {
    super(props);
  }

  render() {
    return (
      <div>
        <calcite-navigation slot="header">
          <calcite-navigation-logo
            slot="logo"
            heading={Config.title}
            description={Config.description}
            active={false}
            onclick={() => {
            }}
          ></calcite-navigation-logo>
          <calcite-button
            scale="l"
            appearance="transparent"
            slot="content-end"
            icon-start="information"
            href="https://github.com/EsriDE/urban-heat-risk-index"
            target="_blank"
            label="Info">
          </calcite-button>
        </calcite-navigation>
      </div>
    );
  }
}

export default Header;
