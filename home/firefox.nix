{...}: {
  # Firefox, installed and configured entirely through Home Manager's
  # `programs.firefox`, following the NixOS wiki:
  #   https://wiki.nixos.org/wiki/Firefox
  #
  # `policies` is baked into the package's distribution/policies.json by the
  # module (the macOS-trusted location); `profiles.<name>.settings` becomes the
  # profile's user.js. The binary is copied to ~/Applications/Home Manager Apps.
  programs.firefox = {
    enable = true;

    policies = {
      # macOS-only requirement: unlike Linux/Windows, Firefox does not turn the
      # enterprise-policies engine on just because policies exist — without this
      # about:policies reads "inactive" and ExtensionSettings is never applied.
      EnterprisePoliciesEnabled = true;

      ExtensionSettings = let
        # Resolve an add-on's current latest .xpi from its AMO slug. With
        # `updates_disabled = true` the version installed at first launch is
        # then pinned (no auto-updates).
        moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        forced = short: {
          install_url = moz short;
          installation_mode = "force_installed";
          updates_disabled = true;
        };
      in {
        # Allow installing other add-ons by hand.
        "*".installation_mode = "allowed";

        "ATBC@EasonWong" = forced "adaptive-tab-bar-colour";
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = forced "bitwarden-password-manager";
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = forced "vimium-ff";
        "sponsorBlocker@ajay.app" = forced "sponsorblock";
        "@react-devtools" = forced "react-devtools";
        "gdpr@cavi.au.dk" = forced "consent-o-matic";
        "{3c078156-979c-498b-8990-85f7987dd929}" = forced "sidebery";

        # Privacy Badger — installed but disabled in the old profile.
        # Uncomment to force-install it again.
        # "jid1-MnnxcxisBPnSXQ@jetpack" = forced "privacy-badger17";
      };
    };

    profiles.default = {
      id = 0;
      isDefault = true;

      # Preferences (written to user.js), encoded from the customised prefs.js.
      settings = {
        # Layout: vertical tabs + revamped sidebar, bookmarks toolbar always shown.
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "browser.toolbars.bookmarks.visibility" = "always";

        # Container tabs enabled.
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;

        # Passwords handled by Bitwarden — don't let Firefox save/manage them.
        "signon.rememberSignons" = false;
        "signon.management.page.breach-alerts.enabled" = false;

        # New Tab page: strip out sponsored content, stories and top sites.
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;

        # Search / locale.
        "browser.search.region" = "GB";
        "browser.urlbar.placeholderName" = "Google";
        "browser.urlbar.suggest.trending" = false;
        "intl.regional_prefs.use_os_locales" = true;

        # Privacy.
        "browser.contentblocking.category" = "standard";
        "privacy.clearOnShutdown_v2.formdata" = true;

        # Toolbar / sidebar widget layout (captured from the current profile).
        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["_3c078156-979c-498b-8990-85f7987dd929_-browser-action","sponsorblocker_ajay_app-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","jid1-mnnxcxisbpnsxq_jetpack-browser-action","atbc_easonwong-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","_react-devtools-browser-action","gdpr_cavi_au_dk-browser-action"],"nav-bar":["sidebar-button","back-button","forward-button","stop-reload-button","customizableui-special-spring1","vertical-spacer","urlbar-container","customizableui-special-spring2","downloads-button","fxa-toolbar-menu-button","reset-pbm-toolbar-button","unified-extensions-button","firefox-view-button","alltabs-button"],"TabsToolbar":[],"vertical-tabs":["tabbrowser-tabs"],"PersonalToolbar":["personal-bookmarks"]},"seen":["reset-pbm-toolbar-button","developer-button","screenshot-button","atbc_easonwong-browser-action","jid1-mnnxcxisbpnsxq_jetpack-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","sponsorblocker_ajay_app-browser-action","_react-devtools-browser-action","gdpr_cavi_au_dk-browser-action","_3c078156-979c-498b-8990-85f7987dd929_-browser-action"],"dirtyAreaCache":["nav-bar","vertical-tabs","PersonalToolbar","TabsToolbar","unified-extensions-area"],"currentVersion":24,"newElementCount":2}'';
      };
    };
  };
}
