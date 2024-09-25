import Accessor from "@arcgis/core/core/Accessor";
import Collection from "@arcgis/core/core/Collection";
import {
  property,
  subclass,
} from "@arcgis/core/core/accessorSupport/decorators";
import { when, whenOnce } from "@arcgis/core/core/reactiveUtils";
import SceneView from "@arcgis/core/views/SceneView";
import Slide from "@arcgis/core/webscene/Slide";
import { timeout } from "../utils";

type PlayerStoreProperties = Pick<PlayerStore, "view">;

@subclass("arcgis-core-template.PlayerStore")
class PlayerStore extends Accessor {
  @property({ constructOnly: true })
  view: SceneView;

  @property()
  get state() {
    const state = this._state;
    return state;
  }

  @property()
  slides: Collection<Slide> | null = null;

  @property()
  currentSlide = -1;

  @property()
  speedFactor = 1;

  @property()
  transition: "bounce" | "linear" = "bounce";

  @property()
  pauseBetweenSlides: "None" | "Short" | "Long" = "Short";

  @property()
  waitForUpdates = true;

  @property()
  get fov() {
    const camera = this.view.camera;
    return (camera && camera.fov) || 0;
  }
  set fov(value: number) {
    let camera = this.view.camera;
    if (camera) {
      camera = camera.clone();
      camera.fov = value;
      this.view.camera = camera;
    }
  }

  @property()
  get canReverse() {
    return this.currentSlide > 0;
  }

  @property()
  get canForward() {
    const length = this.slides?.length || 0;
    return this.currentSlide < length - 1;
  }

  @property()
  private _state: "ready" | "start-animation" | "animating" = "ready";

  private _stopAnimation = () => {};

  constructor(props: PlayerStoreProperties) {
    super(props);

    whenOnce(() => this.slides).then((slides) => {
      if (slides.length) {
        this.reset(false);
      }
    });

    const listener = (e: KeyboardEvent) => {
      if (e.key === " ") {
        this.stop();
      }
    };

    window.addEventListener("keydown", listener);

    this.addHandles([
      when(
        () => props.view.interacting,
        () => this.stop()
      ),
      { remove: () => window.removeEventListener("keydown", listener) },
    ]);

    (window as any)["player"] = this;
  }

  private async pauseFor(milliseconds: number) {
    if (this.transition === "linear") {
      return;
    }

    const waitConditions: Promise<any>[] = [];
    if (this.waitForUpdates) {
      waitConditions.push(whenOnce(() => !this.view.updating));
    }

    switch (this.pauseBetweenSlides) {
      case "Short":
        waitConditions.push(timeout(milliseconds * 0.25));
        break;
      case "Long":
        waitConditions.push(timeout(milliseconds * 1));
        break;
      default:
    }

    await Promise.all(waitConditions);
  }

  async play() {
    if (this._state !== "ready") {
      return;
    }

    this._state = "start-animation";

    let animating = true;
    this._stopAnimation = () => {
      if (animating) {
        this._state = "ready";
        animating = false;
        const animation = this.view.animation;
        if (animation) {
          animation.stop();
        }
      }
      this._stopAnimation = () => {};
    };

    try {
      // Show the start animation dialog for at least 3s while we reset the view if we reached the last slide
      if (this.canForward) {
        await timeout(2000);
      } else {
        await Promise.all([this.reset(), timeout(2000)]);
      }
      await timeout(1000);

      // Wait for at least 1s after hiding the start animation dialog and if necessary, until the view has updated
      if (animating) {
        this._state = "animating";
        await Promise.all([this.pauseFor(1000), timeout(1000)]);
      }

      // Iterate through the slides
      while (this.canForward && animating) {
        const now = performance.now();
        await this.forward();
        await this.pauseFor(performance.now() - now);
      }
    } finally {
      if (animating) {
        await timeout(1000);
        this._state = "ready";
      }
    }
  }

  stop() {
    this._stopAnimation();
    this._state = "ready";
  }

  async reset(animate = true) {
    await this.goToSlide(0, animate);
  }

  async reverse(animate = true) {
    await this.goToSlide(this.currentSlide - 1, animate);
  }

  async forward(animate = true) {
    await this.goToSlide(this.currentSlide + 1, animate);
  }

  async goToSlide(slideIndex: number, animate = true) {
    const slides = this.slides;
    if (!slides || slideIndex < 0 || slideIndex >= slides.length) {
      return Promise.reject();
    }

    const slide = slides.getItemAt(slideIndex);

    this.currentSlide = slideIndex;
    const speedFactor = this.speedFactor;
    const options: __esri.GoToOptions3D = {
      animate,
      speedFactor,
    };
    if (this.transition === "linear") {
      options.easing = "linear";
      console.log({ options });
    }
    try {
      await slide.applyTo(this.view, options);
    } catch {
      this.stop();
    }
  }
}

export default PlayerStore;
