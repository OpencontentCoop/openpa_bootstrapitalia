{if $content_object.allowed_assign_state_list|count}
<li>
    <a class="list-item left-icon"
       href="{concat( "/state/assign/", $content_object.id )|ezurl(no)}"
       title="{'Edit object states'|i18n( 'design/standard/parts/website_toolbar' )}">
        <i aria-hidden="true" class="fa fa-toggle-on"></i>
        {'Edit object states'|i18n( 'design/standard/parts/website_toolbar' )}
    </a>
</li>
{/if}
