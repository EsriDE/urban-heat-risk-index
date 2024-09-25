import Accessor from "@arcgis/core/core/Accessor";
import {
  property,
  subclass,
} from "@arcgis/core/core/accessorSupport/decorators";
import IdentityManager from "@arcgis/core/identity/IdentityManager";
import OAuthInfo from "@arcgis/core/identity/OAuthInfo";
import Portal from "@arcgis/core/portal/Portal";
import PortalUser from "@arcgis/core/portal/PortalUser";

const info = new OAuthInfo({
  appId: "KojZjH6glligLidj",
  popup: true,
  popupCallbackUrl: `${document.location.origin}${document.location.pathname}oauth-callback-api.html`,
});

IdentityManager.registerOAuthInfos([info]);

(window as any).setOAuthResponseHash = (responseHash: string) => {
  IdentityManager.setOAuthResponseHash(responseHash);
};

@subclass("arcgis-core-template.UserStore")
class UserStore extends Accessor {
  @property()
  get authenticated() {
    return !!this.user;
  }

  @property()
  user: PortalUser | null;

  constructor() {
    super();

    IdentityManager.on("credential-create", (e) => {
      const portal = new Portal();
      portal.authMode = "immediate";

      portal.load().then(() => {
        this.user = portal.user;
      });
    });
  }

  signIn() {
    IdentityManager.getCredential(info.portalUrl + "/sharing", {
      oAuthPopupConfirmation: false,
    });
  }

  signOut() {
    IdentityManager.destroyCredentials();
    this.user = null;
  }
}

export default UserStore;
