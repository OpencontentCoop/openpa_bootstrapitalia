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
{/if}
