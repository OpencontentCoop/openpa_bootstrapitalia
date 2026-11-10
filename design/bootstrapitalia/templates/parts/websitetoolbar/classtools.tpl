{if and(fetch( 'user', 'has_access_to', hash( 'module', 'classtools', 'function', 'class' ) ), ezmodule('classtools','class'))}
    <li>
        <a class="list-item left-icon"
           href="{concat( "classtools/extra/", $content_object.class_identifier )|ezurl(no)}"
           title="{'View settings'|i18n( 'bootstrapitalia' )}">
            <i aria-hidden="true" class="fa fa-window-restore"></i>
            {'View settings'|i18n( 'bootstrapitalia' )}
        </a>
    </li>
{/if}