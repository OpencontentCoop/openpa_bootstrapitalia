{def $available_for_classes = ezini( 'TimelineSettings', 'AvailableForClasses', 'timeline.ini' )}

{if $available_for_classes|contains( $content_object.content_class.identifier )}
    <li>
        <a class="list-item left-icon" href={concat( "/ezflow/timeline/", $current_node.node_id )|ezurl} title="{'Timeline'|i18n( 'design/ezflow/parts/website_toolbar' )}">
            <i class="fa fa-circle"></i>
            {'Timeline'|i18n( 'design/ezflow/parts/website_toolbar' )}
        </a>
    </li>
{/if}