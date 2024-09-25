{def $sdc_href = 'https://developers.italia.it/it/software/opencontent-stanza-del-cittadino-core-410a6e'}
{def $site_href = 'https://developers.italia.it/it/software/opencity-labs-sito-istituzionale-cms-ff4ed2'}
{def $product_link = concat('https://link.opencitylabs.it/footer-credits?utm_source=', openpa_instance_identifier(), '&utm_medium=footer')}
{def $partner = current_partner()}

<div class="container text-secondary x-small mt-1 mb-1">
    <div class="row">
        <div class="col-12 text-end">
        {if openpaini('CreditsSettings', 'UseDearOldCreditsTemplate', 'disabled')|eq('enabled')}
            &copy; {currentdate()|datetime( 'custom', '%Y' )} {ezini('SiteSettings','SiteName')}
            {if openpaini('CreditsSettings', 'ShowCredits', 'enabled')|eq('enabled')}
                powered by
                <a class="text-decoration-none"
                   href="{openpaini('CreditsSettings', 'Url', 'http://www.opencontent.it/openpa')}" title="{openpaini('CreditsSettings', 'Title', 'OpenPA - Strumenti di comunicazione per la pubblica amministrazione')}">
                    {openpaini('CreditsSettings', 'Name', 'OpenCity')}
                </a>
                {if openpaini('CreditsSettings', 'CodeVersion', false())}<a class="text-decoration-none" href="{openpaini('CreditsSettings', 'CodeUrl', false())}">{openpaini('CreditsSettings', 'CodeVersion', false())}</a>{/if}
            {/if}
            &#8212; concept & design by <a class="text-decoration-none" href="https://designers.italia.it/kit/comuni/">{display_icon('it-designers-italia', 'svg', 'icon icon-xs icon-primary')} Designers Italia</a>
        {else}
            <a href="{$site_href|wash()}" title="Opencity Italia - Sito web comunale">Sito web</a>
            {if has_bridge_connection()}
                e <a href="{$sdc_href|wash()}" title="OpenCity Italia - La Stanza del Cittadino">servizi digitali</a>
            {/if}
            <a href="{$product_link|wash()}" title="OpenCity Italia - Servizi pubblici digitali per la tua città">OpenCity Italia</a>
            {if $partner}
                distributed by
                <a href="{$partner.url|wash()}" title="{$partner.name|wash()}">{$partner.name|wash()}</a>
            {/if}
            {if openpaini('CreditsSettings', 'CodeVersion', false())}
            <svg id="product-version"
                 data-bs-toggle="tooltip"
                 data-bs-html="false"
                 class="icon icon-xs"
                 aria-label="{openpaini('CreditsSettings', 'CodeVersion', false())}"
                 title="{openpaini('CreditsSettings', 'CodeVersion', false())}">
                <use href="{'images/svg/sprites.svg'|ezdesign('no')}#it-info-circle"></use>
            </svg>
            {/if}
        {/if}
            &middot; <a data-login-bottom-button href="{"/user/login"|ezurl(no)}" class="text-decoration-none">{'Site editors access'|i18n('bootstrapitalia')}</a>
            {literal}
                <script>
                    $(document).ready(function(){
                      new bootstrap.Tooltip(document.getElementById('product-version'));

                      var trimmedPrefix = UriPrefix.replace(/~+$/g,"");
                        if(trimmedPrefix === '/') trimmedPrefix = '';
                        var login = $('[data-login-bottom-button]');
                        if(CurrentUserIsLoggedIn) {
                            login.attr('href', trimmedPrefix+'/user/logout');
                            login.html('{/literal}{'Logout'|i18n('bootstrapitalia')}{literal}');
                        }else{
                            login.attr('href', trimmedPrefix+'/accesso_redazione?r='+(PathArray[0] || ''));
                            login.html('{/literal}{'Site editors access'|i18n('bootstrapitalia')}{literal}');
                        }
                    });
                </script>
            {/literal}
        </div>
    </div>
</div>
