{if openpaini('CookiesSettings', 'Consent', 'advanced')|eq('simple')}
<div class="cookiebar">
    {if $pagedata.homepage|has_attribute('cookie_alert_text')}
        <p>{attribute_view_gui attribute=$pagedata.homepage|attribute('cookie_alert_text')}</p>
    {else}
    <p>
        {'This site uses technical, analytics and third-party cookies.'|i18n('bootstrapitalia')}
        <br />{'By continuing to browse, you accept the use of cookies.'|i18n('bootstrapitalia')}
    </p>
    {/if}
    <div class="cookiebar-buttons">
        <a href="{if $pagedata.homepage|has_attribute('cookie_alert_info_button_link')}{$pagedata.homepage|attribute('cookie_alert_info_button_link').content}{else}{'openpa/cookie'|ezurl(no)}{/if}" class="cookiebar-btn">
            {if $pagedata.homepage|has_attribute('cookie_alert_info_button_text')}{$pagedata.homepage|attribute('cookie_alert_info_button_text').content}{else}{'Informations'|i18n('bootstrapitalia')}{/if}
        </a>
        <button data-accept="cookiebar" class="cookiebar-btn cookiebar-confirm" title="{'Accept'|i18n('bootstrapitalia')}">
            {if $pagedata.homepage|has_attribute('cookie_alert_accept_button_text')}{$pagedata.homepage|attribute('cookie_alert_accept_button_text').content}{else}{'Accept'|i18n('bootstrapitalia')}{/if}
        </button>
    </div>
</div>
{elseif openpaini('CookiesSettings', 'Consent', 'advanced')|eq('advanced')}
<script>
var CookieConsentText = {cookie_consent_config_translations()};
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
window.addEventListener('cconsent-setCookie', function (e) {e.detail.categories.multimedia.wanted ? showIframes() : hideIframes();}, false);
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
    categories: {
        necessary: {
            needed: true,
            wanted: true,
            checked: true,
            language: {
                locale: {
                    i18n: CookieConsentText.necessary
                }
            }
        },
        analytics: {
            needed: false,
            wanted: false,
            checked: false,
            language: {
                locale: {
                    i18n: CookieConsentText.analytics
                }
            }
        },
        multimedia: {
            needed: false,
            wanted: false,
            checked: false,
            language: {
                locale: {
                    i18n: CookieConsentText.multimedia
                }
            }
        }
    },
    services: {
        google: {
            category: 'analytics',
            type: 'dynamic-script',
            cookies: [
                {
                    name: '_gid',
                    domain: `.${window.location.hostname}`
                },
                {
                    name: '_gat',
                    domain: `.${window.location.hostname}`
                },
                {
                    name: /^_ga/,
                    domain: `.${window.location.hostname}`
                },
                {
                    name: '_gid',
                    domain: `.${window.location.hostname.split('.').slice(1).join('.')}`
                },
                {
                    name: '_gat',
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
        piwik: {
            category: 'analytics',
            type: 'dynamic-script',
            cookies: [
                {
                    name: '__utma',
                    domain: `.${window.location.hostname}`
                },
                {
                    name: /^_pk/,
                    domain: `.${window.location.hostname}`
                },
                {
                    name: '__utma',
                    domain: `.${window.location.hostname.split('.').slice(1).join('.')}`
                },
                {
                    name: /^_pk/,
                    domain: `.${window.location.hostname.split('.').slice(1).join('.')}`
                }
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
                        name: 'YouTube, Vimeo, Slideshare, Isuu, Facebook, Twitter, Linkedin, Instagram, Whatsapp'
                    }
                }
            }
        }
    }
});
CookieConsent.wrapper('wrapped', function() {
    documentIsReady(function (){
        showIframes();
    })
});
{/literal}
</script>
{/if}
