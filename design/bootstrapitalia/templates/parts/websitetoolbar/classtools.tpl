{if and(fetch( 'user', 'has_access_to', hash( 'module', 'classtools', 'function', 'class' ) ), ezmodule('classtools','class'))}
    <li>
        <a class="list-item left-icon"
           href="{concat( "classtools/extra/", $content_object.class_identifier )|ezurl(no)}"
           title="Impostazioni visualizzazione">
            <i class="fa fa-window-restore"></i>
            Impostazioni visualizzazione
        </a>
    </li>
{/if}