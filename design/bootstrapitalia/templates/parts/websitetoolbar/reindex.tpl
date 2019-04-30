{if fetch( 'user', 'has_access_to', hash( 'module', 'index', 'function', 'object' ) )}
    <li>
        <a class="list-item left-icon"
           href="{concat( "/index/object/", $content_object.id )|ezurl(no)}"
           title="Controlla indicizzazione">
            <i class="fa fa-search-plus"></i>
            Controlla indicizzazione
        </a>
    </li>
{/if}