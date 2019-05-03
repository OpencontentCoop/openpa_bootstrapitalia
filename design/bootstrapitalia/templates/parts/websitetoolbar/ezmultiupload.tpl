{if and(
        or( ezini( 'MultiUploadSettings', 'AvailableSubtreeNode', 'ezmultiupload.ini' )|contains( $current_node.node_id ),
            ezini( 'MultiUploadSettings', 'AvailableClasses', 'ezmultiupload.ini' )|contains( $current_node.class_identifier ) ) ,
        and( $content_object.can_create, $is_container)
     )}
<li>
    <a class="list-item left-icon"
       href="{concat("/ezmultiupload/upload/",$current_node.node_id)|ezurl(no)}"
       title="{'Multiupload'|i18n('extension/ezmultiupload')}">
        <i class="fa fa-upload"></i>
        Multi-Upload
    </a>
</li>
{/if}
