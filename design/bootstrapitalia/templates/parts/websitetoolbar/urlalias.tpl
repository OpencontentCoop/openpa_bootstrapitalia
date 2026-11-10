{if $content_object.can_edit}
    <li>
        <a class="list-item left-icon"
           href="{concat( "/content/urlalias/", $content_object.main_node_id )|ezurl(no)}"
           title="{'Manage URL aliases'|i18n( 'design/admin/popupmenu' )}">
            <i aria-hidden="true" class="fa fa-fw fa-link"></i>
            <span class="toolbar-item-label">{'Manage URL aliases'|i18n( 'design/admin/popupmenu' )}</span>
        </a>
    </li>
{/if}