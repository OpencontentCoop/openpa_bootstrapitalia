<script src={"javascript/cookieconsent.umd.js"|ezdesign}></script>
{literal}
<script>
  CookieConsent.run({
    guiOptions: {
      consentModal: {
        layout: 'cloud',
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
        enabled: true,  // this category is enabled by default
        readOnly: true  // this category cannot be disabled
      },
      analytics: {}
    },
    language: {
      default: 'en',
      translations: {
        en: {
          consentModal: {
            title: 'We use cookies',
            description: 'Cookie modal description',
            acceptAllBtn: 'Accept all',
            acceptNecessaryBtn: 'Reject all',
            showPreferencesBtn: 'Manage Individual preferences'
          },
          preferencesModal: {
            title: 'Manage cookie preferences',
            acceptAllBtn: 'Accept all',
            acceptNecessaryBtn: 'Reject all',
            savePreferencesBtn: 'Accept current selection',
            closeIconLabel: 'Close modal',
            sections: [
              {
                title: 'Somebody said ... cookies?',
                description: 'I want one!'
              },
              {
                title: 'Strictly Necessary cookies',
                description: 'These cookies are essential for the proper functioning of the website and cannot be disabled.',

                //this field will generate a toggle linked to the 'necessary' category
                linkedCategory: 'necessary'
              },
              {
                title: 'Performance and Analytics',
                description: 'These cookies collect information about how you use our website. All of the data is anonymized and cannot be used to identify you.',
                linkedCategory: 'analytics'
              },
              {
                title: 'More information',
                description: 'For any queries in relation to my policy on cookies and your choices, please <a href="#contact-page">contact us</a>'
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