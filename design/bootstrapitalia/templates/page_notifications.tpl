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
<script>var NeedCookieConsent = false;</script>
{elseif openpaini('CookiesSettings', 'Consent', 'advanced')|eq('advanced')}
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
var CookieConsentServices = {};
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
    if (HasGoogleAnalytics){
        CookieConsentServices.google = {
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
        };
    }
    if (HasWebAnalyticsItalia){
        CookieConsentServices.piwik = {
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
        };
    }
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
    CookieConsentServices.multimedia= {
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
    };
}if (NeedCookieConsent) {
    setTimeout(function() {
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
    }, 1000);
}
{/literal}
{*
setTimeout(function() {
var cookieList = [];
document.cookie.split(';').map(function (a) {
    cookieList.push(a.split('=')[0].replace(/(^\s*)|(\s*&)/, ''));
});
console.log(cookieList);
function objectType(obj) {
    return Object.prototype.toString.call(obj).slice(8, -1);
}
for (var service in CookieConsentServices) {
    if (objectType(CookieConsentServices[service].cookies) === 'Array') {
        // Remove cookies if they are not wanted by user
        if (!CookieConsentCategories[CookieConsentServices[service].category].wanted) {
            for (var i in CookieConsentServices[service].cookies) {
                var type = objectType(CookieConsentServices[service].cookies[i].name);

                if (type === 'String') {
                    if (cookieList.indexOf(CookieConsentServices[service].cookies[i].name) > -1) {
                        console.log('remove string ' + CookieConsentServices[service].cookies[i], cookieDef);
                    }
                } else if (type === 'RegExp') {
                    // Searching cookie list for cookies matching specified RegExp
                    var cookieDef = CookieConsentServices[service].cookies[i];

                    for (var c in cookieList) {
                        if (cookieList[c].match(cookieDef.name)) {
                            console.log('remove regex ' + cookieList[c], cookieDef);
                        }
                    }
                }
            }
        }
    }
}
}, 800);
*}
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
