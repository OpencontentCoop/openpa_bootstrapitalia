<script src="{'javascript/bootstrap-italia.bundle.min.js'|ezdesign( 'no' )}"></script>
<script>window.__PUBLIC_PATH__ = "https://static.opencityitalia.it/fonts";bootstrap.loadFonts()</script>

{if openpaini('ImageSettings', 'LazyLoadImages', 'disabled')|eq('enabled')}
  <script src="{'javascript/ls.rias.min.js'|ezdesign(no)}" async=""></script>
  <script src="{'javascript/lazysizes.min.js'|ezdesign(no)}" async=""></script>
  <script>
    window.lazySizesConfig = window.lazySizesConfig || {ldelim}{rdelim};
    window.lazySizesConfig.rias = window.lazySizesConfig.rias || {ldelim}{rdelim};
    window.lazySizesConfig.rias.widths = [320, 480, 800, 1200];
    document.addEventListener('lazybeforeunveil', function(e){ldelim}var bg = e.target.getAttribute('data-bg');if(bg){ldelim}e.target.style.backgroundImage = 'url(' + bg + ')';{rdelim}{rdelim});
    document.addEventListener('lazyriasmodifyoptions', function(e){ldelim}
      if (e.target.parentElement.getAttribute("class").includes('img-full')) e.detail.widths = [1200];
      {rdelim});
  </script>
{/if}

{if fetch('user','current_user').is_logged_in|not()}{$footer_script_loader}{/if}
{$footer_css_loader}

{if openpaini( 'Seo', 'GoogleAnalyticsAccountID', false() )}
  <script async src="https://www.googletagmanager.com/gtag/js?id={openpaini( 'Seo', 'GoogleAnalyticsAccountID' )}"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){ldelim}dataLayer.push(arguments);{rdelim}
    gtag('js', new Date());
    gtag('config', '{openpaini( 'Seo', 'GoogleAnalyticsAccountID' )}', {ldelim}{if openpaini('Seo', 'GoogleCookieless')|eq('enabled')}client_storage: 'none', {/if}anonymize_ip: true {rdelim});
  </script>
{/if}

{if openpaini( 'Seo', 'webAnalyticsItaliaID', false() )}
  {* see https://matomo.org/faq/general/faq_157/ *}
  <script type="text/javascript">
    var _paq = window._paq || [];
    {if openpaini('Seo', 'WebAnalyticsItaliaCookieless')|eq('enabled')}_paq.push(['disableCookies']);{/if}
    _paq.push(['trackPageView']);
    _paq.push(['enableLinkTracking']);
    (function() {ldelim}
      var u="https://ingestion.webanalytics.italia.it/";
      _paq.push(['setTrackerUrl', u+'matomo.php']);
      _paq.push(['setSiteId', '{openpaini( 'Seo', 'webAnalyticsItaliaID' )}']);
      var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
      g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
      {rdelim})();
  </script>
  <!-- End Matomo Code -->
{/if}

{if openpaini('CookiesSettings', 'Consent', 'advanced')|eq('advanced')}
    <script>
      var CookieConsentText = {cookie_consent_config_translations()};
      var HasGoogleAnalytics = {cond(and( openpaini('Seo', 'GoogleAnalyticsAccountID'), openpaini('Seo', 'GoogleCookieless')|eq('disabled') ), 'true', 'false')};
      var HasWebAnalyticsItalia = {cond(and( openpaini('Seo', 'webAnalyticsItaliaID'), openpaini('Seo', 'WebAnalyticsItaliaCookieless')|eq('disabled') ), 'true', 'false')};
      var NeedCookieConsentForAnalytics = HasGoogleAnalytics || HasWebAnalyticsItalia;
      var NeedCookieConsentForMultimedia = {cond(openpaini('Seo', 'CookieConsentMultimedia')|eq('enabled'), 'true', 'false')};
      var CookieConsentServicesForMultimedia = "{openpaini('Seo', 'CookieConsentMultimediaText', 'YouTube, Vimeo, Slideshare, Isuu, Facebook, Twitter, Linkedin, Instagram, Whatsapp')}";
      var NeedCookieConsent = NeedCookieConsentForAnalytics || NeedCookieConsentForMultimedia;
      {literal}
      function documentIsReady(fn) {
        if (document.attachEvent ? document.readyState === "complete" : document.readyState !== "loading") {
          fn();
        } else {
          document.addEventListener('DOMContentLoaded', fn);
        }
      }
      var showIframes = function(){
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
        var iframesTags = document.querySelectorAll('iframe[data-coookieconsent="multimedia"]');
        for (var iframesTag of iframesTags) {
          iframesTag.setAttribute('src', iframesTag.getAttribute('data-preview'));
        }
        var customTags = document.querySelectorAll('[data-coookieconsent="custom"]');
        for (var customTag of customTags) {
          customTag.setAttribute('data-src', customTag.getAttribute('src'));
        }
      }
      window.addEventListener('cconsent-setCookie', function (e) {
        if (e.detail.categories.multimedia){
          e.detail.categories.multimedia.wanted ? showIframes() : hideIframes();
        }
      }, false);
      var CookieConsentCategories = {
        necessary: {
          needed: true,
          wanted: true,
          checked: true,
          language: {
            locale: {
              i18n: CookieConsentText.necessary
            }
          }
        }
      };
      var CookieConsentServices = {
        ezsessid: {
          category: 'necessary',
          language: {
            locale: {
              i18n: {
                name: 'Individuazione dell’utente che ha effettuato un’autenticazione o un’interazione con il sito: `eZSESSID` e/o `PHPSESSID` scade alla chiusura del browser'
              }
            }
          }
        },
        cconsent: {
          category: 'necessary',
          language: {
            locale: {
              i18n: {
                name: 'Salvataggio delle scelte dell’utente in merito ai cookie: `cconsent` scade dopo un anno dal primo salvataggio'
              }
            }
          }
        },
        google: {
          category: 'analytics',
          type: 'dynamic-script',
          cookies: [
            {
              name: /^_gid/,
              domain: `.${window.location.hostname}`
            },
            {
              name: /^_gat/,
              domain: `.${window.location.hostname}`
            },
            {
              name: /^_ga/,
              domain: `.${window.location.hostname}`
            },
            {
              name: /^_gid/,
              domain: `.${window.location.hostname.split('.').slice(1).join('.')}`
            },
            {
              name: /^_gat/,
              domain: `.${window.location.hostname.split('.').slice(1).join('.')}`
            },
            {
              name: /^_ga/,
              domain: `.${window.location.hostname.split('.').slice(1).join('.')}`
            }
          ],
          language: {
            locale: {
              i18n: {
                name: 'Google Analytics'
              }
            }
          }
        },
        piwik:  {
          category: 'analytics',
          type: 'dynamic-script',
          cookies: [
            {
              name: '__utma',
              domain: `${window.location.hostname}`
            },
            {
              name: /^_pk/,
              domain: `${window.location.hostname}`
            },
            {
              name: /^_pk_id/,
              domain: `${window.location.hostname}`
            },
            {
              name: /^_pk_ses/,
              domain: `${window.location.hostname}`
            },
            {
              name: '__utma',
              domain: `.${window.location.hostname}`
            },
            {
              name: /^_pk/,
              domain: `.${window.location.hostname}`
            },
            {
              name: /^_pk_id/,
              domain: `.${window.location.hostname}`
            },
            {
              name: /^_pk_ses/,
              domain: `.${window.location.hostname}`
            },
            {
              name: '__utma',
              domain: `.${window.location.hostname.split('.').slice(1).join('.')}`
            },
            {
              name: /^_pk/,
              domain: `.${window.location.hostname.split('.').slice(1).join('.')}`
            },
            {
              name: /^_pk_id/,
              domain: `.${window.location.hostname.split('.').slice(1).join('.')}`
            },
            {
              name: /^_pk_ses/,
              domain: `.${window.location.hostname.split('.').slice(1).join('.')}`
            },
          ],
          language: {
            locale: {
              i18n: {
                name: 'Web Analytics Italia'
              }
            }
          }
        },
        multimedia: {
          category: 'multimedia',
          type: 'wrapped',
          search: 'wrapped',
          language: {
            locale: {
              i18n: {
                name: CookieConsentServicesForMultimedia
              }
            }
          }
        }
      };
      if (NeedCookieConsentForAnalytics){
        CookieConsentCategories.analytics = {
          needed: false,
          wanted: false,
          checked: false,
          language: {
            locale: {
              i18n: CookieConsentText.analytics
            }
          }
        };
      }
      if (NeedCookieConsentForMultimedia){
        CookieConsentCategories.multimedia = {
          needed: false,
          wanted: false,
          checked: false,
          language: {
            locale: {
              i18n: CookieConsentText.multimedia
            }
          }
        };
      }if (NeedCookieConsent) {
        documentIsReady(function () {
          setTimeout(function () {
            window.CookieConsent.init({
              modalMainTextMoreLink: CookieConsentText.modalMainTextMoreLink,
              barTimeout: 1000,
              language: {
                current: 'i18n',
                locale: {
                  i18n: {
                    barMainText: CookieConsentText.barMainText,
                    barLinkSetting: CookieConsentText.barLinkSetting,
                    barBtnAcceptAll: CookieConsentText.barBtnAcceptAll,
                    barBtnRefuseAll: CookieConsentText.barBtnRefuseAll,
                    modalMainTitle: CookieConsentText.modalMainTitle,
                    modalMainText: CookieConsentText.modalMainText,
                    modalBtnSave: CookieConsentText.modalBtnSave,
                    modalBtnAcceptAll: CookieConsentText.modalBtnAcceptAll,
                    modalBtnRefuseAll: CookieConsentText.modalBtnRefuseAll,
                    modalAffectedSolutions: CookieConsentText.modalAffectedSolutions,
                    learnMore: CookieConsentText.learnMore,
                    on: CookieConsentText.on,
                    off: CookieConsentText.off,
                  }
                }
              },
              categories: CookieConsentCategories,
              services: CookieConsentServices
            });
            CookieConsent.wrapper('wrapped', function () {
              documentIsReady(function () {
                showIframes();
              })
            });
          }, 10);
        });
      }
      {/literal}
    </script>
{literal}
    <style>
        #cconsent-bar .ccb__wrapper{
            padding: 35px !important;
        }
        #cconsent-bar .close{
            float:right;
        }
        #cconsent-bar{
            max-width:900px !important;
        }
    </style>
{/literal}
{/if}