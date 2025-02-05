<script src={"javascript/cookieconsent.umd.js"|ezdesign}></script>
{literal}
<script>
  var CookieConsentSettings = {/literal}{cookie_consent_config_translations()}{literal}
  var showIframes = function(){
    console.log('showIframes')
    var iframesTags = document.querySelectorAll('iframe[data-coookieconsent="multimedia"]');
    for (var iframesTag of iframesTags) {
      iframesTag.setAttribute('src', iframesTag.getAttribute('data-src'));
    }
    var customTags = document.querySelectorAll('[data-coookieconsent="custom"]');
    for (var customTag of customTags) {
      customTag.setAttribute('src', customTag.getAttribute('data-src'));
    }
  }
  var hideIframes = function(){
    console.log('hideIframes')
    var iframesTags = document.querySelectorAll('iframe[data-coookieconsent="multimedia"]');
    for (var iframesTag of iframesTags) {
      iframesTag.setAttribute('src', iframesTag.getAttribute('data-preview'));
    }
    var customTags = document.querySelectorAll('[data-coookieconsent="custom"]');
    for (var customTag of customTags) {
      customTag.setAttribute('data-src', customTag.getAttribute('src'));
    }
  }
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
      marketing: {
        services: {
            multimedia: {
              onAccept: () => showIframes(),
              onReject: () => hideIframes()
            }
        }
      }
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
    #cc-main {
      --cc-font-family: 'Titillium Web';
      --cc-bg: #435a70;
      --cc-primary-color: white;
      --cc-secondary-color: white;
      --cc-rev-color: black;
      --cc-rev-hover-color: #4b4b4b;
      --cc-rev-bg: #e5e5e5;
      --cc-rev-border: #cdcfd0;
      --cc-btn-border-radius: var(--bs-btn-border-radius, 4px);

      --cc-btn-primary-bg: transparent;
      --cc-btn-primary-color: var(--cc-primary-color);
      --cc-btn-primary-border-color: var(--cc-primary-color);
      --cc-btn-primary-hover-bg: transparent;
      --cc-btn-primary-hover-color: hsl(0,0%,90%);
      --cc-btn-primary-hover-border-color: hsl(0,0%,90%);

      --cc-btn-secondary-bg: transparent;
      --cc-btn-secondary-color: var(--cc-primary-color);
      --cc-btn-secondary-border-color: var(--cc-primary-color);
      --cc-btn-secondary-hover-bg: transparent;
      --cc-btn-secondary-hover-color: hsl(0,0%,90%);
      --cc-btn-secondary-hover-border-color: hsl(0,0%,90%);
      
      --cc-cookie-category-block-color: var(--cc-rev-border);
      --cc-cookie-category-block-bg: var(--cc-primary-color);
      --cc-cookie-category-block-border: var(--cc-rev-border);
      --cc-cookie-category-block-hover-bg: var(--cc-primary-color);
      --cc-cookie-category-block-hover-border: var(--cc-rev-border);
      --cc-cookie-category-expanded-block-hover-bg: var(--cc-primary-color);
      --cc-cookie-category-expanded-block-bg: var(--cc-primary-color);
      --cc-toggle-readonly-bg: #2f3132;
      --cc-overlay-bg: rgba(0, 0, 0, 0.9)!important;

      --cc-toggle-on-knob-bg: var(--cc-primary-color);
      --cc-toggle-readonly-knob-bg: var( --cc-cookie-category-block-bg);

      --cc-separator-border-color: transparent;
      --cc-modal-border-radius: 0;

      --cc-footer-border-color: #212529;
      --cc-footer-bg: var(--cc-rev-color);
      --cc-link-color: var(--cc-rev-color)
    }
    #cc-main,
    #cc-main .cm__btn,
    #cc-main .cm__desc,
    #cc-main .pm__btn,
    #cc-main .pm__section-title {
      font-size: inherit;
    }

    #cc-main .cm--box.cm--wide {
      max-width: 50rem;
    }

    #cc-main .cm__btn--close,
    #cc-main .cm__btn--close:hover,
    #cc-main .pm__close-btn,
    #cc-main .pm__close-btn:hover {
      border-color: transparent;
    }

    #cc-main .pm__service-title,
    #cc-main .pm__section--toggle {
      border-radius: 0;
    }

    #cc-main .pm__badge,
    #cc-main .pm__service-title {
      color: var(--cc-rev-color);
    }
    
    #cc-main .pm__section,
    #cc-main .pm__section:not(:first-child):hover {
      background: none;
      border-color: var(--cc-cookie-category-block-hover-border)
    }

    #cc-main .pm,
    #cc-main .pm__section-desc-wrapper {
      background-color: var(--cc-rev-bg);
      color: var(--cc-rev-color);
    }
    
    #cc-main .pm__section--expandable .pm__section-desc-wrapper {
      background-color: var(--cc-primary-color);
    }

    #cc-main .pm__section--toggle {
      background: none;
    }
    
    #cc-main .cm,
    #cc-main .pm {
      border: 1px solid var(--cc-separator-border-color);
    }
    
    #cc-main .pm__title {
      font-size: 1.6rem;
    }

    #cc-main .pm__btn {
      color: var(--cc-rev-color);
      border-color: var(--cc-rev-color);
    }
    
    #cc-main .pm__btn:hover {
      color: var(--cc-rev-hover-color);
      border-color: var(--cc-rev-hover-color);
    }

    #cc-main .pm__close-btn {
      margin-top: -12px;
      margin-right: -20px;
    }

    #cc-main .pm__close-btn svg,
    #cc-main .pm__close-btn:hover svg {
      stroke: var(--cc-rev-color)
    }

    #cc-main .cc__link:hover {
      color: var(--cc-link-color)
    }
  </style>
{/literal}