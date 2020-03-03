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

{if $openpa.content_tag_menu.current_view_tag}
    {set $params = $params|merge(hash(
      'extended_attribute_filter', hash(
          'id', TagsAttributeFilter,
          'params', hash(
              'tag_id', $openpa.content_tag_menu.current_view_tag.id,
              'include_synonyms', true()
          )
      )
    ))}
    {set $fetch_type = 'tree'}
{/if}

{def $children_count = fetch( content, concat( $fetch_type, '_count' ), hash( 'parent_node_id', $parent_node.node_id )|merge( $params ) )}

{if $children_count}
    {if $children_count|eq(2)}{set $items_per_row = 2}{/if}
    {def $children = fetch( content, $fetch_type, hash( 'parent_node_id', $parent_node.node_id,
                                                       'offset', $view_parameters.offset,
                                                       'sort_by', $parent_node.sort_array,
                                                       'limit', $page_limit )|merge( $params ) )}
    <section id="{if $node|has_attribute('menu_name')}{$node|attribute('menu_name').content|slugize}{else}{$parent_node.name|slugize}{/if}">
      <div class="py-5">
        <div class="container">
            {if $node|has_attribute('menu_name')}
                <div class="row">
                    <div class="col-md-12">
                        <h3 class="mb-4 text-primary">{$node|attribute('menu_name').content|wash()}</h3>
                    </div>
                </div>
            {/if}

            {include uri='design:atoms/grid.tpl'
                     items_per_row=$items_per_row
                     i_view=card
                     image_class=large
                     show_icon = false()
                     items=$children}

            {include name=navigator
                   uri='design:navigator/google.tpl'
                   page_uri=$node.url_alias
                   item_count=$children_count
                   view_parameters=$view_parameters
                   item_limit=$page_limit}

        </div>
      </div>
    </section>

    {undef $children}
{/if}


{undef $params $children_count}

{unset_defaults( array(
    'page_limit',
    'exclude_classes',
    'include_classes',
    'type',
    'fetch_type',
    'parent_node',
    'items_per_row'
) )}
