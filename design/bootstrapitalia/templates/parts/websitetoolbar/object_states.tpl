{if $content_object.allowed_assign_state_list|count}
<li>
    <a class="list-item left-icon"
       href="{concat( "/state/assign/", $content_object.id )|ezurl(no)}"
       title="{'Edit object states'|i18n( 'design/standard/parts/website_toolbar' )}">
        <i aria-hidden="true" class="fa fa-fw fa-toggle-on"></i>
        <span class="toolbar-item-label">{'Edit object states'|i18n( 'design/standard/parts/website_toolbar' )}</span>
    </a>
</li>
{/if}
