{def $cookie_management = false()}
{if and(openpaini('CookiesSettings', 'Consent', 'advanced')|eq('advanced'),
  openpaini('Seo', 'CookieConsentMultimedia')|eq('enabled'))}
  {set $cookie_management = true()}
{/if}
<html>
  <head>
    <link rel="stylesheet" href="{concat('stylesheets/', current_theme(),'.css')|ezdesign(no)}" media="all"/>
  </head>
  <body>
    <div class="overlay-wrapper d-block font-sans-serif h-100" style="min-height: 200px">
      <div class="overlay-panel overlay-icon bg-dark text-center">
        <div>
          <div class="{if $cookie_management} d-none d-sm-block {/if} mb-2">
            {display_icon('it-video', 'svg', 'icon icon-xl')}
          </div>
          {if $cookie_management}
            <div class="mb-3 d-none d-sm-block">
              <p style="font-size: 14px;">
                  {'The embedding of multimedia content is not enabled by respecting your cookie preferences.'|i18n('bootstrapitalia/cookieconsent')}<br />
              </p>
            </div>
          {/if}
          <a
            class="btn btn-outline-primary btn-xs mb-3"
            target="_blank"
            rel="noopener noreferrer"
            href={$url}
            >
            {'Watch this content on %provider'|i18n('bootstrapitalia/cookieconsent',,hash('%provider', $oembed.provider_name))} 
          </a>
          {if $cookie_management}
            <div>
              <a
                class="d-inline-block text-white"
                style="font-size: 14px;"
                role="button"
                href="#"
                onclick="openPref()">
                {'Cookie settings'|i18n('bootstrapitalia/cookieconsent')}
              </a>
            </div>
          {/if}
        </div>
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
</html>
{undef $cookie_management}


