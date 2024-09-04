<script src="{'javascript/bootstrap-italia.bundle.min.js'|ezdesign( 'no' )}"></script>
<script>window.__PUBLIC_PATH__ = "https://static.opencityitalia.it/fonts";bootstrap.loadFonts()</script>

{if fetch('user','current_user').is_logged_in|not()}
{$footer_script_loader}
{else}
    {def $sentry_script_loader = sentry_script_loader()}
    {if $sentry_script_loader}
      <script src="{$sentry_script_loader}" crossorigin="anonymous"></script>
      <script>
        window.Sentry && Sentry.onLoad(function() {ldelim}
          Sentry.init({ldelim}
            environment: "{openpa_instance_identifier()}"
          {rdelim});
        {rdelim});
      </script>
    {/if}
    {undef $sentry_script_loader}
{/if}
{if is_set($footer_css_loader)}{$footer_css_loader}{/if}

{if openpaini( 'StanzaDelCittadinoBridge', 'UseLoginBox', 'disabled' )|ne('disabled')}
  <script src="{built_in_app('login').src}"></script>
{/if}

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

{include uri='design:page_footer_plausible.tpl'}

