{def $cookie_management = false()}
{if and(openpaini('CookiesSettings', 'Consent', 'advanced')|eq('advanced'),openpaini('Seo', 'CookieConsentMultimedia')|eq('enabled'))}
  {set $cookie_management = true()}
{/if}
<html>
  <head>
    <link rel="stylesheet" href="{concat('stylesheets/', current_theme(),'.css')|ezdesign(no)}" media="all"/>
  </head>
  <body class="overflow-hidden">
  <div class="acceptoverlayable" style="min-height: 100vh">
    <div class="acceptoverlay acceptoverlay-primary fade show align-items-center">
      <div class="acceptoverlay-inner d-flex flex-column-reverse flex-sm-column">
        <div class="acceptoverlay-icon d-none d-sm-block mb-0">
          {display_icon('it-video', 'svg', 'icon icon-xl')}
        </div>
        {if $cookie_management}
        <p class="text-center text-sm-start mt-sm-5">
          <span class="d-none d-sm-inline">
            {'The embedding of multimedia content is not enabled by respecting your cookie preferences.'|i18n('bootstrapitalia/cookieconsent')}
          </span>
          <a
            class="text-white"
            role="button"
            href="#"
            onclick="openPref()">
            {'Cookie settings'|i18n('bootstrapitalia/cookieconsent')}
          </a>
        </p>
        {/if}
        {if $provider}
          <div class="acceptoverlay-buttons bg-dark mb-4 mt-2 mb-sm-0 mt-sm-4 flex-column align-items-center{if $cookie_management} align-items-sm-start{/if}">
              <a
                class="btn btn-primary font-sans-serif"
                target="_blank"
                rel="noopener noreferrer"
                href={$url|wash()}>
                {'Watch this content on %provider'|i18n('bootstrapitalia/cookieconsent',,hash('%provider', $provider|wash()))}
              </a>
          </div>
        {/if}
      </div>
    </div>
    <script>
      {literal}
        const openPref = function() {
          const target = window.parent.document.querySelector("[data-cc='show-preferencesModal']");
          target.click()
          return false
        }
      {/literal}
    </script>
  </body>
  <script src="{'javascript/bootstrap-italia.bundle.min.js'|ezdesign( 'no' )}"></script>
  <script>window.__PUBLIC_PATH__ = "https://static.opencityitalia.it/fonts";bootstrap.loadFonts()</script>
</html>
{undef $cookie_management}