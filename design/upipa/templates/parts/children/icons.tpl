{set_defaults( hash(
  'page_limit', 24,
  'exclude_classes', openpaini( 'ExcludedClassesAsChild', 'FromFolder', array( 'image', 'infobox', 'global_layout' ) )
))}

{def $children_count = fetch( content, list_count, hash( 'parent_node_id', $node.node_id, 'class_filter_type', 'exclude', 'class_filter_array', $exclude_classes) )}
{if $children_count}
<div class="container">
    {include uri='design:atoms/grid.tpl'
            items_per_row=3
            i_view=banner
            image_class=medium
            items=fetch( content, list, hash( 'parent_node_id', $node.node_id,
                                              'offset', $view_parameters.offset,
                                              'class_filter_type', 'exclude',
                                              'class_filter_array', $exclude_classes,
                                              'sort_by', $node.sort_array,
                                              'limit', $page_limit ))}
</div>

{include name=navigator
       uri='design:navigator/google.tpl'
       page_uri=$node.url_alias
       item_count=$children_count
       view_parameters=$view_parameters
       item_limit=$page_limit}

{/if}

{undef $children_count}

{unset_defaults( array(
    'page_limit',
    'exclude_classes'
) )}