<div class="container text-secondary x-small mt-1 mb-1 text-right">
    &copy; {currentdate()|datetime( 'custom', '%Y' )} {ezini('SiteSettings','SiteName')}
    powered by
    <a class="text-secondary" href="{openpaini('CreditsSettings', 'Url', 'http://www.opencontent.it/openpa')}" title="{openpaini('CreditsSettings', 'Title', 'OpenPA - Strumenti di comunicazione per la pubblica amministrazione')}">
        {openpaini('CreditsSettings', 'Name', 'OpenCity')} {if openpaini('CreditsSettings', 'CodeVersion', false())}<a href="{openpaini('CreditsSettings', 'CodeUrl', false())}">{openpaini('CreditsSettings', 'CodeVersion', false())}</a>{/if}
    </a>    
</div>