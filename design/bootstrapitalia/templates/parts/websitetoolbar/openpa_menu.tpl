{if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'editor_tools' ) )}
<li>
    <a class="list-item left-icon"
       href="{'/openpa/refreshmenu/'|ezurl(no)}"
       title="{'Regenerate menu'|i18n( 'bootstrapitalia' )}">
        <i aria-hidden="true" class="fa fa-fw fa-bars"></i>
        <span class="toolbar-item-label">{'Regenerate menu'|i18n( 'bootstrapitalia' )}</span>
    </a>
</li>
{/if}
