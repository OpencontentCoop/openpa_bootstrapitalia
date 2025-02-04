<script src={"javascript/cookieconsent.umd.js"|ezdesign}></script>
{literal}
<script>
  var CookieConsentSettings = {/literal}{cookie_consent_config_translations()}{literal}
  CookieConsent.run({
    guiOptions: {
      consentModal: {
        layout: 'box wide',
        position: 'bottom center',
        equalWeightButtons: true,
        flipButtons: false
      },
      preferencesModal: {
        layout: 'box',
        equalWeightButtons: true,
        flipButtons: false
      }
    },
    categories: {
      necessary: {
        readOnly: true  // this category cannot be disabled
      },
      analytics: {},
      marketing: {}
    },
    language: {
      default: '{/literal}{$site.http_equiv.Content-language|wash}{literal}',
      translations: {
        {/literal}{$site.http_equiv.Content-language|wash}{literal}: {
          consentModal: {
            title: '   ',
            description: CookieConsentSettings.barMainText,
            closeIconLabel: "X",
            acceptAllBtn: 'Accept all',
            acceptNecessaryBtn: 'Rifiuta tutti',
            showPreferencesBtn: 'Manage Individual preferences',
          },
          preferencesModal: {
            title: "Consent Preferences Center",
            closeIconLabel: "Close modal",
            acceptAllBtn: "Accept all",
            acceptNecessaryBtn: "Reject all",
            savePreferencesBtn: "Save preferences",
            serviceCounterLabel: "Service|Services",
            sections: [
              {
                title: "Cookie Usage",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
              },
              {
                title: "Strictly Necessary Cookies <span class=\"pm__badge\">Always Enabled</span>",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                linkedCategory: "necessary"
              },
              {
                title: "Functionality Cookies",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                linkedCategory: "functionality"
              },
              {
                title: "Analytics Cookies",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                linkedCategory: "analytics"
              },
              {
                title: "Advertisement Cookies",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                linkedCategory: "marketing"
              },
              {
                title: "More information",
                description: "For any query in relation to my policy on cookies and your choices, please <a class=\"cc__link\" href=\"#yourdomain.com\">contact me</a>."
              }
            ]
          }
        }
      }
    }
  });
</script>
  <style>
    #cc-main .cm,
    #cc-main .pm {
      border-radius: 0;
      font-size: 1rem;
    }

    #cc-main .pm__btn {
      font-size: 1rem
    }

    #cc-main .pm__section--toggle .pm__section-desc-wrapper,
    #cc-main .pm__section-title {
      border-radius: 0
    }

    #cc-main .pm__section--toggle,
    #cc-main .pm__section--toggle .pm__section-title:hover,
    #cc-main .pm__section:not(:first-child):hover,
    #cc-main .pm__section--expandable .pm__section-arrow {
      background: none
    }

    .pm__close-btn,
    .pm__close-btn:hover {
      border: none;
      background: none
    }

    .pm__title {
      font-size: 1.3rem;
      font-weight: 800
    }

    .pm__section-desc-wrapper,
    #cc-main .cm__title {
      font-size: 1rem
    }

    #cc-main .cm__desc {
      font-size: 1rem
    }

    #cc-main .cm--cloud .cm__btn {
      min-width: inherit
    }

    .cm__btn {
      border-radius: var(--bs-btn-border-radius);
      font-size: 1rem;
      background: #ff00000;
      padding: 12px 24px;
    }
  </style>
{/literal}