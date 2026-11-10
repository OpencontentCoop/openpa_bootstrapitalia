{if fetch( 'user', 'has_access_to', hash( 'module', 'index', 'function', 'object' ) )}
    <li>
        <a class="list-item left-icon"
           href="{concat( "/index/object/", $content_object.id )|ezurl(no)}"
           title="{'Check indexing'|i18n( 'bootstrapitalia' )}">
            <i aria-hidden="true" class="fa fa-fw fa-search-plus"></i>
            <span class="toolbar-item-label">{'Check indexing'|i18n( 'bootstrapitalia' )}</span>
        </a>
    </li>
{/if}