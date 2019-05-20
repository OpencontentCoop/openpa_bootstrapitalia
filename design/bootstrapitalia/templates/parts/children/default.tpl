{set_defaults( hash(
  'page_limit', 24,
  'exclude_classes', openpaini( 'ExcludedClassesAsChild', 'FromFolder', array( 'image', 'infobox', 'global_layout' ) ),
  'include_classes', array(),
  'type', 'exclude',
  'fetch_type', 'list',
  'parent_node', $node,
  'items_per_row', 3
))}

{if $type|eq( 'exclude' )}
    {def $params = hash( 'class_filter_type', 'exclude', 'class_filter_array', $exclude_classes )}
{else}
    {def $params = hash( 'class_filter_type', 'include', 'class_filter_array', $include_classes )}
{/if}

{def $children_count = fetch( openpa, concat( $fetch_type, '_count' ), hash( 'parent_node_id', $parent_node.node_id )|merge( $params ) )
	 $children = fetch( openpa, $fetch_type, hash( 'parent_node_id', $parent_node.node_id,
												   'offset', $view_parameters.offset,
                                                   'sort_by', $parent_node.sort_array,
                                                   'limit', $page_limit )|merge( $params ) ) }
{if $children_count}
    {include uri='design:atoms/cards.tpl'
             items_per_row=$items_per_row
             i_view=card
             image_class=widemedium
             items=$children}

    {include name=navigator
           uri='design:navigator/google.tpl'
           page_uri=$node.url_alias
           item_count=$children_count
           view_parameters=$view_parameters
           item_limit=$page_limit}
{/if}


{undef $params $children_count $children}

{unset_defaults( array(
    'page_limit',
    'exclude_classes',
    'include_classes',
    'type',
    'fetch_type',
    'parent_node',
    'items_per_row'
) )}
