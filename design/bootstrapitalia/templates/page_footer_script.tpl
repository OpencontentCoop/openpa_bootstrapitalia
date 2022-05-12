<script>window.__PUBLIC_PATH__ = "{'fonts'|ezdesign(no)}"</script>
<script src="{'javascript/app.min.js'|ezdesign(no)}"></script>

{if openpaini( 'Seo', 'GoogleAnalyticsAccountID', false() )}
    {* see https://goenning.net/2021/02/01/cookieless-google-analytics/ *}
    {*
    <script type="text/javascript">
        (function(i,s,o,g,r,a,m){ldelim}i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){ldelim}
            (i[r].q=i[r].q||[]).push(arguments){rdelim},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
            {rdelim})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
        ga('create', '{openpaini( 'Seo', 'GoogleAnalyticsAccountID' )}', 'auto');
        ga('set', 'anonymizeIp', true);
        ga('set', 'forceSSL', true);
        ga('send', 'pageview');
    </script>
    *}
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
