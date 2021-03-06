<div class="container text-secondary x-small mt-1 mb-1 text-right">
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

    {if and($pagedata.homepage|has_attribute('hide_access_menu'), $pagedata.homepage|attribute('hide_access_menu').data_int|eq(1))}
        &middot; <a data-login-bottom-button href="{"/user/login"|ezurl(no)}" class="text-decoration-none">{'Site editors access'|i18n('bootstrapitalia')}</a>
        {literal}
        <script>
            $(document).ready(function(){
                var trimmedPrefix = UriPrefix.replace(/~+$/g,"");
                if(trimmedPrefix === '/') trimmedPrefix = '';
                var login = $('[data-login-bottom-button]');
                if(CurrentUserIsLoggedIn) {
                    login.attr('href', trimmedPrefix+'/user/logout');
                    login.html('{/literal}{'Logout'|i18n('bootstrapitalia')}{literal}');
                }else{
                    login.attr('href', trimmedPrefix+'/user/login');
                    login.html('{/literal}{'Site editors access'|i18n('bootstrapitalia')}{literal}');
                }
            });
        </script>
        {/literal}
    {/if}

</div>