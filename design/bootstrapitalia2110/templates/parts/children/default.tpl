{set_defaults( hash(
  'page_limit', 12,
  'exclude_classes', openpaini( 'ExcludedClassesAsChild', 'FromFolder', array( 'image', 'infobox', 'global_layout' ) ),
  'include_classes', array(),
  'fetch_type', 'list',
  'parent_node', $node,
  'items_per_row', 3,
  'view_variation', '',
  'view', 'card'
))}

{def $sort_array = $parent_node.sort_array}
{if $parent_node.sort_array[0][0]|eq('published')}
    {set $sort_array = $parent_node.sort_array|merge(array(array('node_id', false())))}
{/if}

{* notizie, comunicati, avvisi, politici, personale*}
{if and(
    array(
        'ea708fa69006941b4dc235a348f1431d',
        '16a65071f99a1be398a677e5e4bef93f',
        '9a1756e11164d0d550ee950657154db8',
        '50f295ca2a57943b195fa8ffc6b909d8',
        '3da91bfec50abc9740f0f3d62c8aaac4'
    )|contains($node.object.remote_id)|not(),
    or(
        openpaini( 'TopMenu', 'NodiCustomMenu', array() )|contains($node.parent_node_id),
        openpaini( 'TopMenu', 'NodiCustomMenu', array() )|contains($node.node_id),
        $node.object.remote_id|eq('topics'),
        ezini( 'NodeSettings', 'MediaRootNode', 'content.ini' )|eq($node.node_id),
        ezini( 'NodeSettings', 'MediaRootNode', 'content.ini' )|eq($node.parent_node_id),
        $node.object.remote_id|eq('punti_di_contatto')
    )
)}
    {set $view = 'card_simple'}
{/if}

{if $node.object.remote_id|eq('cb945b1cdaad4412faaa3a64f7cdd065')} {*documenti e dati*}
    {set $include_classes = array('pagina_sito', 'frontpage')}
{/if}

{def $topic_filter = concat('Topics'i18n('bootstrapitalia'), ':topics.name')}
{def $search_blocks = array()}
{if $openpa.content_tag_menu.current_view_tag}
    {if and($node.object.remote_id|eq('all-services'), $openpa.content_tag_menu.current_view_tag)}
        {set $search_blocks = array(page_block(
            "",
            "OpendataRemoteContents",
            "default",
            hash(
                "remote_url", "",
                "query", concat("raw[ezf_df_tag_ids] = ", $openpa.content_tag_menu.current_view_tag.id, " and classes [public_service] sort [name=>asc]"),
                "show_grid", "1",
                "show_map", "1",
                "show_search", "1",
                "limit", "4",
                "items_per_row", "2",
                "facets", $topic_filter,
                "view_api", "latest_messages_item",
                "color_style", "bg-100",
                "fields", "",
                "template", "",
                "simple_geo_api", "0",
                "input_search_placeholder", ""
                )
            )
        )}
    {elseif and($node.object.remote_id|eq('all-events'), $openpa.content_tag_menu.current_view_tag)}
        {set $search_blocks = array(page_block(
            "",
            "Eventi",
            "default",
            hash(
                "includi_classi", "event",
                "show_facets", "0",
                "topic_node_id", "",
                "tag_id", $openpa.content_tag_menu.current_view_tag.id,
                "size", "medium",
                "calendar_view", "day_grid",
                "color_style", "",
                "container_style", "",
                "max_events", "6",
                "intro_text", "",
                )
            )
        )}
    {elseif and($node.object.remote_id|eq('all-places'), $openpa.content_tag_menu.current_view_tag)}
        {set $search_blocks = array(page_block(
            "",
            "OpendataRemoteContents",
            "default",
            hash(
                "remote_url", "",
                "query", concat("raw[ezf_df_tag_ids] in [", $openpa.content_tag_menu.current_view_tag_tree_list|implode(','), "] and classes [place]"),
                "show_grid", "1",
                "show_map", "1",
                "show_search", "1",
                "limit", "4",
                "items_per_row", "2",
                "facets", $topic_filter,
                "view_api", "card_teaser",
                "color_style", "bg-100",
                "fields", "",
                "template", "",
                "simple_geo_api", "1",
                "input_search_placeholder", ""
                )
            )
        )}
    {/if}
{/if}

{if $node.object.remote_id|eq('howto')}
    {set $search_blocks = array(page_block(
        "",
        "OpendataRemoteContents",
        "default",
        hash(
            "remote_url", "",
            "query", concat("raw[meta_node_id_si] != " , $node.node_id, " and subtree [", $node.node_id, "] sort [name=>asc]"),
            "show_grid", "1",
            "show_map", "0",
            "show_search", "1",
            "limit", "9",
            "items_per_row", "2",
            "facets", $topic_filter,
            "view_api", "card_teaser",
            "color_style", "",
            "fields", "",
            "template", "",
            "simple_geo_api", "0",
            "input_search_placeholder", ""
            )
        )
    )}
{/if}

{if $node.object.remote_id|eq('insight')}
    {set $search_blocks = array(page_block(
        "",
        "OpendataRemoteContents",
        "default",
        hash(
            "remote_url", "",
            "query", concat("raw[meta_node_id_si] != " , $node.node_id, " and subtree [", $node.node_id, "] sort [name=>asc]"),
            "show_grid", "1",
            "show_map", "0",
            "show_search", "1",
            "limit", "9",
            "items_per_row", "2",
            "facets", $topic_filter,
            "view_api", "card_teaser",
            "color_style", "",
            "fields", "",
            "template", "",
            "simple_geo_api", "0",
            "input_search_placeholder", ""
            )
        )
    )}
{/if}

{if and(
    openpaini('ViewSettings', 'ChildrenFilter', 'enabled')|eq('enabled'),
    $node|has_attribute('show_search_form')
)}
    {def $children_filters = openpaini('ChildrenFilters', 'Remotes', array())}
    {if and(is_set($children_filters[$node.object.remote_id]), $children_filters[$node.object.remote_id]|eq('search'))}
        {set $search_blocks = array(page_block(
            "",
            "OpendataRemoteContents",
            "default",
            hash(
                "remote_url", "",
                "query", concat("raw[meta_node_id_si] != " , $node.node_id, " and subtree [", $node.node_id, "] sort [name=>asc]"),
                "show_grid", "1",
                "show_map", "0",
                "show_search", "1",
                "limit", 9,
                "items_per_row", 3,
                "facets", "",
                "view_api", 'card_simple',
                "color_style", "",
                "fields", "",
                "template", "",
                "simple_geo_api", "0",
                "input_search_placeholder", ""
                )
            )
        )}
    {elseif and(is_set($children_filters[$node.object.remote_id]), $children_filters[$node.object.remote_id]|eq('search-roles'))}
        {set $search_blocks = array(page_block(
            "",
            "SearchPeopleByRole",
            "default",
            hash(
                "subtree", $node.node_id,
                "input_search_placeholder", "",
                "limit", 9,
                "items_per_row", 3
                )
            )
        )}
    {/if}
    {undef $children_filters}
{/if}
{if count($search_blocks)}
    {include uri='design:zone/default.tpl' zones=array(hash('blocks', $search_blocks))}
{/if}

{if and(count($search_blocks)|eq(0), or($openpa.content_tag_menu.show_tag_cards|not(), $openpa.content_tag_menu.current_view_tag))}
    {if count($include_classes)}
        {def $params = hash( 'class_filter_type', 'include', 'class_filter_array', $include_classes )}
    {elseif count($exclude_classes)}
        {def $params = hash( 'class_filter_type', 'exclude', 'class_filter_array', $exclude_classes )}
    {/if}

    {if $openpa.content_tag_menu.current_view_tag}
        {set $params = $params|merge(hash(
          'extended_attribute_filter', hash(
              'id', TagsAttributeFilter,
              'params', hash(
                  'tag_id', $openpa.content_tag_menu.current_view_tag_tree_list,
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
                                                           'sort_by', $sort_array,
                                                           'limit', $page_limit )|merge( $params ) )}

        {if $node.object.remote_id|eq('topics')}
            {def $filtered_children = array()}
            {foreach $children as $child}
                {if $child.class_identifier|eq('topic')}
                    {if topic_has_contents($child.contentobject_id)}
                        {set $filtered_children = $filtered_children|append($child)}
                    {/if}
                {/if}
            {/foreach}
            {set $children = $filtered_children}
        {/if}

        <section id="{if $node|has_attribute('menu_name')}{$node|attribute('menu_name').content|slugize}{else}{$parent_node.name|slugize}{/if}">
            <div class="container {$view_variation}">
                {if $openpa.content_tag_menu.current_view_tag|not()}
                    {if $node|has_attribute('menu_name')}
                        <h2 class="title-xxlarge mb-4">{$node|attribute('menu_name').content|wash()}</h2>
                    {else}
                        <h2 class="d-none">{$node.name|wash()}</h2>
                    {/if}
                {/if}

                {include uri='design:atoms/grid.tpl'
                         items_per_row=$items_per_row
                         i_view=cond($openpa.content_tag_menu.current_view_tag, 'card', $view)
                         image_class='imagelargeoverlay'
                         view_variation='w-100'
                         grid_wrapper_class='row g-4'
                         show_icon = false()
                         show_category = false()
                         items=$children}

                {include name=navigator
                       uri='design:navigator/google.tpl'
                       page_uri=$node.url_alias
                       item_count=$children_count
                       view_parameters=$view_parameters
                       item_limit=$page_limit}

            </div>
        </section>
        {undef $children}
    {/if}
    {undef $params $children_count}
{/if}

{if $openpa.content_tag_menu.show_tag_cards}
    {include uri='design:parts/children/tag_cards.tpl'}
{/if}
{undef $search_blocks}

{unset_defaults( array(
    'page_limit',
    'exclude_classes',
    'include_classes',
    'fetch_type',
    'parent_node',
    'items_per_row'
) )}