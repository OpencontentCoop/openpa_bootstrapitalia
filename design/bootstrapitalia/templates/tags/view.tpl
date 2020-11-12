{def $limit = 20}

<h1>{$tag.keyword|wash}</h1>

{def $nodes_count = fetch( content, tree_count, hash( parent_node_id, 1,
                                                      extended_attribute_filter, hash( id, TagsAttributeFilter,
                                                                                       params, hash( tag_id, $tag.id, include_synonyms, true() ) ),
                                                      main_node_only, true() ) )}

{if $nodes_count}
    {def $nodes = fetch( content, tree, hash( parent_node_id, 1,
                                              extended_attribute_filter,
                                              hash( id, TagsAttributeFilter,
                                                    params, hash( tag_id, $tag.id, include_synonyms, true() ) ),
                                              offset, first_set( $view_parameters.offset, 0 ), limit, $limit,
                                              main_node_only, true(),
                                              sort_by, array( modified, false() ) ) )}
    {include uri='design:atoms/grid.tpl'
             items_per_row='auto'
             i_view=card_teaser
             image_class=large
             items=$nodes}

    {undef $nodes}
{/if}

{include uri='design:navigator/google.tpl'
         page_uri=concat( '/tags/view/', $tag.url )
         item_count=$nodes_count
         view_parameters=$view_parameters
         item_limit=$limit}

   
{undef $limit $nodes_count}