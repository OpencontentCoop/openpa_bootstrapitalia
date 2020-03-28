<div class="container text-secondary x-small mt-1 mb-1 text-right">
    &copy; {currentdate()|datetime( 'custom', '%Y' )} {ezini('SiteSettings','SiteName')}
    powered by
    <a class="text-decoration-none" 
       href="{openpaini('CreditsSettings', 'Url', 'http://www.opencontent.it/openpa')}" title="{openpaini('CreditsSettings', 'Title', 'OpenPA - Strumenti di comunicazione per la pubblica amministrazione')}">
        {openpaini('CreditsSettings', 'Name', 'OpenCity')}         
    </a>
    {if openpaini('CreditsSettings', 'CodeVersion', false())}<a class="text-decoration-none" href="{openpaini('CreditsSettings', 'CodeUrl', false())}">{openpaini('CreditsSettings', 'CodeVersion', false())}</a>{/if}
    &#8212; concept & design by <a class="text-decoration-none" href="https://designers.italia.it/kit/comuni/">{display_icon('it-designers-italia', 'svg', 'icon icon-xs icon-primary')} Designers Italia</a>
</div>