<div class="it-search-wrapper">
    <span class="d-none d-md-block">{'Search'|i18n('openpa/search')}</span>
    {def $meili_url = ezini('MeilisearchSettings', 'BaseUrl', 'meilisearch.ini')}
    {if ezini('SearchSettings', 'SearchEngine', 'site.ini')|eq('OCSearchEngine')|and($meili_url|ne(''))}
    <a class="search-link rounded-icon" href="{'content/search'|ezurl(no)}">
        {display_icon('it-search', 'svg', 'icon')}
        <span class="visually-hidden">{'Search'|i18n('openpa/search')}</span>
    </a>
    {else}
    <a class="search-link rounded-icon"
       href="{'content/search'|ezurl(no)}"
       data-bs-toggle="modal"
       data-bs-target="#search-modal">
        {display_icon('it-search', 'svg', 'icon')}
        <span class="visually-hidden">{'Search'|i18n('openpa/search')}</span>
    </a>
    {/if}
</div>