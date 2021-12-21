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
var modalMainTextMoreLink = "{if $pagedata.homepage|has_attribute('cookie_alert_info_button_link')}{$pagedata.homepage|attribute('cookie_alert_info_button_link').content}{/if}";
var learnMore = "{if $pagedata.homepage|has_attribute('cookie_alert_info_button_text')}{$pagedata.homepage|attribute('cookie_alert_info_button_text').content}{else}{'Cookie policy'|i18n('bootstrapitalia/cookieconsent')}{/if}";
var barMainText = "{if $pagedata.homepage|has_attribute('cookie_alert_text')}{attribute_view_gui attribute=$pagedata.homepage|attribute('cookie_alert_text')|wash(javascript)}{else}{'This website uses cookies to ensure you get the best experience on our website.'|i18n('bootstrapitalia/cookieconsent')}{/if}"
var barBtnAcceptAll = "{if $pagedata.homepage|has_attribute('cookie_alert_accept_button_text')}{$pagedata.homepage|attribute('cookie_alert_accept_button_text').content}{else}{'Accept all cookies'|i18n('bootstrapitalia/cookieconsent')}{/if}";
var modalMainText = "{"Cookies are small piece of data sent from a website and stored on the user's computer by the user's web browser while the user is browsing. Your browser stores each message in a small file, called cookie. When you request another page from the server, your browser sends the cookie back to the server. Cookies were designed to be a reliable mechanism for websites to remember information or to record the user's browsing activity."|i18n('bootstrapitalia/cookieconsent')} ";
var modalMainTitle = "{'Cookie information and preferences '|i18n('bootstrapitalia/cookieconsent')}";
var barLinkSetting = "{'Cookie settings'|i18n('bootstrapitalia/cookieconsent')}";
var modalBtnSave = "{'Save current settings'|i18n('bootstrapitalia/cookieconsent')}";
var modalBtnAcceptAll = "{'Accept all cookies and close'|i18n('bootstrapitalia/cookieconsent')}";
var modalAffectedSolutions = "{'Affected solutions:'|i18n('bootstrapitalia/cookieconsent')}";
var on = "{'On'|i18n('bootstrapitalia/cookieconsent')}";
var off = "{'Off'|i18n('bootstrapitalia/cookieconsent')}";
var necessary = {ldelim}
    name: "{'Strictly Necessary Cookies'|i18n('bootstrapitalia/cookieconsent')}",
    description: "{'They are necessary for the proper functioning of the site. They allow the browsing of the pages, the storage of a user\'s sessions (to keep them active while browsing). Without these cookies, the services for which users access the site could not be provided.'|i18n('bootstrapitalia/cookieconsent')}",
{rdelim};
var analytics = {ldelim}
    name: "{'Cookie analytics'|i18n('bootstrapitalia/cookieconsent')}",
    description: "{'The analytics cookies are used to collect information on the number of users and how they visit the website and then process general statistics on the service and its use. The data is collected anonymously.'|i18n('bootstrapitalia/cookieconsent')}",
{rdelim};
var multimedia = {ldelim}
    name: "{'Automatic embedding of multimedia contents'|i18n('bootstrapitalia/cookieconsent')}",
    description: "{'This system uses the oEmbed specification to automatically embed multimedia content into pages. Each content provider (for example YouTube or Vimeo) may release technical, analytical and profiling cookies based on the settings configured by the video maker. If this setting is disabled, the multimedia contents will not be automatically incorporated into the site and instead a link will be displayed to be able to view them directly at the source.'|i18n('bootstrapitalia/cookieconsent')}",
{rdelim};
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
}
var hideIframes = function(){
    var iframesTags = document.querySelectorAll('iframe[data-coookieconsent="multimedia"]');
    for (var iframesTag of iframesTags) {
        iframesTag.setAttribute('src', iframesTag.getAttribute('data-preview'));
    }
}
window.addEventListener('cconsent-setCookie', function (e) {e.detail.categories.multimedia.wanted ? showIframes() : hideIframes();}, false);
window.CookieConsent.init({
    modalMainTextMoreLink: modalMainTextMoreLink,
    barTimeout: 1000,
    language: {
        current: 'i18n',
        locale: {
            i18n: {
                barMainText: barMainText,
                barLinkSetting: barLinkSetting,
                barBtnAcceptAll: barBtnAcceptAll,
                modalMainTitle: modalMainTitle,
                modalMainText: modalMainText,
                modalBtnSave: modalBtnSave,
                modalBtnAcceptAll: modalBtnAcceptAll,
                modalAffectedSolutions: modalAffectedSolutions,
                learnMore: learnMore,
                on: on,
                off: off,
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
                    i18n: necessary
                }
            }
        },
        analytics: {
            needed: false,
            wanted: true,
            checked: true,
            language: {
                locale: {
                    i18n: analytics
                }
            }
        },
        multimedia: {
            needed: false,
            wanted: false,
            checked: false,
            language: {
                locale: {
                    i18n: multimedia
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
                        name: 'YouTube, Vimeo, Slideshare, Isuu'
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
