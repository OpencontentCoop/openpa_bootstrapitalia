<script src="{'javascript/bootstrap-italia.bundle.min.js'|ezdesign( 'no' )|shared_asset()}"></script>
<script>window.__PUBLIC_PATH__ = "https://static.opencityitalia.it/fonts";bootstrap.loadFonts()</script>

{if openpaini('ImageSettings', 'LazyLoadImages', 'disabled')|eq('enabled')}
  <script src="{'javascript/ls.rias.min.js'|ezdesign(no)|shared_asset()}" async=""></script>
  <script src="{'javascript/lazysizes.min.js'|ezdesign(no)|shared_asset()}" async=""></script>
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
{if is_set($footer_css_loader)}{$footer_css_loader}{/if}

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