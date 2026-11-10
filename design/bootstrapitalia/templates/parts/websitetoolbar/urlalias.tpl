{if $content_object.can_edit}
    <li>
        <a class="list-item left-icon"
           href="{concat( "/content/urlalias/", $content_object.main_node_id )|ezurl(no)}"
           title="{'Manage URL aliases'|i18n( 'design/admin/popupmenu' )}">
            <i aria-hidden="true" class="fa fa-link"></i>
            {'Manage URL aliases'|i18n( 'design/admin/popupmenu' )}
        </a>
    </li>
{/if}