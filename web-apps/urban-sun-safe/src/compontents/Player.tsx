import {
  property,
  subclass,
} from "@arcgis/core/core/accessorSupport/decorators";

import { tsx } from "@arcgis/core/widgets/support/widget";

import "@esri/calcite-components/dist/components/calcite-action";
import "@esri/calcite-components/dist/components/calcite-block";
import "@esri/calcite-components/dist/components/calcite-block-section";
import "@esri/calcite-components/dist/components/calcite-button";
import "@esri/calcite-components/dist/components/calcite-label";
import "@esri/calcite-components/dist/components/calcite-notice";
import "@esri/calcite-components/dist/components/calcite-pagination";
import "@esri/calcite-components/dist/components/calcite-panel";
import "@esri/calcite-components/dist/components/calcite-radio-button";
import "@esri/calcite-components/dist/components/calcite-radio-button-group";
import "@esri/calcite-components/dist/components/calcite-segmented-control";
import "@esri/calcite-components/dist/components/calcite-segmented-control-item";
import "@esri/calcite-components/dist/components/calcite-slider";
import "@esri/calcite-components/dist/components/calcite-switch";

import { watch } from "@arcgis/core/core/reactiveUtils";
import PlayerStore from "../stores/PlayerStore";
import { Widget } from "./Widget";

type PlayerProperties = Pick<Player, "store">;

const SPEED_FACTORS = [0.1, 0.2, 0.5, 1, 2, 3, 5];

@subclass("arcgis-core-template.Player")
class Player extends Widget<PlayerProperties> {
  @property()
  store: PlayerStore;

  @property()
  get quality() {
    return this.store.view.qualityProfile;
  }
  set quality(quality: "high" | "medium" | "low") {
    this.store.view.qualityProfile = quality;
  }

  @property()
  private selectedSpeedFactor = SPEED_FACTORS.indexOf(1);

  postInitialize() {
    this.addHandles([
      watch(
        () => this.selectedSpeedFactor,
        (selectedSpeedFactor) => {
          this.store.speedFactor = SPEED_FACTORS[selectedSpeedFactor];
        }
      ),
    ]);
  }

  render() {
    const slides = this.store.slides;

    const loading = !slides;

    const disabled = slides && slides.length === 0;
    const reverseDisabled = !this.store.canReverse;
    const forwardDisabled = !this.store.canForward;

    const animating = this.store.state !== "ready";

    return (
      <div>
        <calcite-panel heading="Slides" loading={loading} style="width: 300px;">
          <calcite-action
            icon="refresh"
            text="Previous slide"
            slot="header-actions-end"
            disabled={disabled}
            onclick={() => this.store.reset()}
          ></calcite-action>
          <calcite-action
            icon="reverse"
            text="Previous slide"
            slot="header-actions-end"
            disabled={reverseDisabled}
            onclick={() => this.store.reverse()}
          ></calcite-action>
          <calcite-action
            icon="forward"
            text="Nesxt slide"
            slot="header-actions-end"
            disabled={forwardDisabled}
            onclick={() => this.store.forward()}
          ></calcite-action>

          {this.renderStaging(animating ? "" : "hide")}

          {this.renderSettings(animating ? "hide" : "")}

          <calcite-button
            width="full"
            slot="footer"
            appearance="outline"
            disabled={disabled}
            onclick={() => this.store.stop()}
            class={animating ? "" : "hide"}
          >
            Cancel
          </calcite-button>
          <calcite-button
            width="full"
            slot="footer"
            icon-start="video-web"
            disabled={disabled}
            onclick={() => this.store.play()}
            class={animating ? "hide" : ""}
          >
            Play
          </calcite-button>
        </calcite-panel>
      </div>
    );
  }

  private renderStaging(classString: string) {
    return (
      <calcite-block open class={classString}>
        <calcite-loader
          label="Animation starting"
          text="Animation starting"
          class="player-loader"
        ></calcite-loader>

        <calcite-notice open icon="information" scale="s">
          <div slot="message">
            Interrupt by pressing space bar or interacting with scene.
          </div>
        </calcite-notice>
      </calcite-block>
    );
  }

  private renderSettings(classString: string) {
    const speedFactor = this.store.speedFactor;
    let speedFactorLabel;
    if (speedFactor === 1) {
      speedFactorLabel = "normal";
    } else if (speedFactor < 1) {
      speedFactorLabel = `${1 / speedFactor}x slower`;
    } else {
      speedFactorLabel = `${speedFactor}x faster`;
    }

    const disablePause = this.store.transition === "linear";

    const pauseValue =
      this.store.transition === "linear"
        ? "None"
        : this.store.pauseBetweenSlides;
    const pauseOptions = ["None", "Short", "Long"].map((option) => ({
      value: option,
      checked: option === pauseValue,
    }));

    const waitForUpdates =
      this.store.transition !== "linear" && this.store.waitForUpdates;

    return (
      <div class={classString}>
        <calcite-block
          collapsible
          heading="Animation"
          description="Adjust speed and transitions"
        >
          <calcite-icon scale="s" slot="icon" icon="effects"></calcite-icon>

          <calcite-label>
            Speed ({speedFactorLabel})
            <calcite-slider
              value={this.selectedSpeedFactor}
              min="0"
              label-handles
              max={SPEED_FACTORS.length - 1}
              ticks="1"
              onCalciteSliderInput={(e: any) =>
                (this.selectedSpeedFactor = e.target.value)
              }
            ></calcite-slider>
          </calcite-label>

          <calcite-label>
            Transitions
            <calcite-radio-button-group
              name="Transition"
              layout="horizontal"
              onCalciteRadioButtonChange={(e: any) => {
                this.store.transition = e.target.value;
              }}
            >
              <calcite-label layout="inline">
                <calcite-radio-button
                  value="bounce"
                  checked
                ></calcite-radio-button>
                Bounce
              </calcite-label>
              <calcite-label layout="inline">
                <calcite-radio-button value="linear"></calcite-radio-button>
                Linear
              </calcite-label>
            </calcite-radio-button-group>
          </calcite-label>

          <calcite-label>
            Pause between slides
            <calcite-segmented-control
              width="full"
              onCalciteSegmentedControlChange={(e: any) => {
                this.store.pauseBetweenSlides = e.target.value;
              }}
              disabled={disablePause}
            >
              {pauseOptions.map((option) => (
                <calcite-segmented-control-item
                  value={option.value}
                  checked={option.checked}
                >
                  {option.value}
                </calcite-segmented-control-item>
              ))}
            </calcite-segmented-control>
          </calcite-label>

          <calcite-label layout="inline-space-between">
            Wait for view to update
            <calcite-switch
              onCalciteSwitchChange={(e: any) => {
                this.store.waitForUpdates = !this.store.waitForUpdates;
              }}
              checked={waitForUpdates}
              disabled={disablePause}
            ></calcite-switch>
          </calcite-label>
        </calcite-block>

        <calcite-block
          collapsible
          heading="Settings"
          description="Change visuals"
        >
          <calcite-icon scale="s" slot="icon" icon="gear"></calcite-icon>

          <calcite-label layout="inline-space-between">
            High quality
            <calcite-switch
              onCalciteSwitchChange={(e: any) => {
                this.quality = e.target.checked ? "high" : "medium";
              }}
            ></calcite-switch>
          </calcite-label>

          <calcite-label>
            Camera angle ({Math.floor(this.store.fov)}°)
            <calcite-slider
              value={this.store.fov}
              min="1"
              label-handles
              label-ticks
              max="165"
              ticks="54"
              precise
              onCalciteSliderInput={(e: any) => {
                this.store.fov = e.target.value;
              }}
            ></calcite-slider>
          </calcite-label>
        </calcite-block>
      </div>
    );
  }
}

export default Player;
