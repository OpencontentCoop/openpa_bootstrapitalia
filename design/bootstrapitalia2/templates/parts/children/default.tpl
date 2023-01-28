{set_defaults( hash(
  'page_limit', 24,
  'exclude_classes', openpaini( 'ExcludedClassesAsChild', 'FromFolder', array( 'image', 'infobox', 'global_layout' ) ),
  'include_classes', array(),
  'type', 'exclude',
  'fetch_type', 'list',
  'parent_node', $node,
  'items_per_row', 3,
  'view_variation', '',
  'view', 'card_teaser'
))}

{if and(
    array('ea708fa69006941b4dc235a348f1431d', '16a65071f99a1be398a677e5e4bef93f', '9a1756e11164d0d550ee950657154db8')|contains($node.object.remote_id)|not(),
    or(
        openpaini( 'TopMenu', 'NodiCustomMenu', array() )|contains($node.parent_node_id),
            openpaini( 'TopMenu', 'NodiCustomMenu', array() )|contains($node.node_id),
            $node.object.remote_id|eq('topics')
    )
)}
    {set $view = 'card_simple'}
{/if}

{if $openpa.content_tag_menu.current_view_tag}
    {def $blocks = array()}
    {if and($node.object.remote_id|eq('all-services'), $openpa.content_tag_menu.current_view_tag)}
        {set $blocks = array(page_block(
            "",
            "OpendataRemoteContents",
            "default",
            hash(
                "remote_url", "",
                "query", concat("raw[ezf_df_tag_ids] = ", $openpa.content_tag_menu.current_view_tag.id, " and classes [public_service]"),
                "show_grid", "1",
                "show_map", "1",
                "show_search", "1",
                "limit", "4",
                "items_per_row", "2",
                "facets", "Ufficio:holds_role_in_time_ufficio.name,Argomenti:topics.name",
                "view_api", "card_teaser",
                "color_style", "bg-100",
                "fields", "",
                "template", "",
                "simple_geo_api", "0",
                "input_search_placeholder", ""
                )
            )
        )}
    {elseif and($node.object.remote_id|eq('all-places'), $openpa.content_tag_menu.current_view_tag)}
        {set $blocks = array(page_block(
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
                "facets", "Argomenti:topics.name",
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
    {if count($blocks)}
        {include uri='design:zone/default.tpl' zones=array(hash('blocks', $blocks))}
    {/if}
    {undef $blocks}
{/if}

{if or($openpa.content_tag_menu.show_tag_cards|not(), $openpa.content_tag_menu.current_view_tag)}
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
                                                           'sort_by', $parent_node.sort_array,
                                                           'limit', $page_limit )|merge( $params ) )}
        <section id="{if $node|has_attribute('menu_name')}{$node|attribute('menu_name').content|slugize}{else}{$parent_node.name|slugize}{/if}">
            <div class="container {$view_variation}">
                {if and($openpa.content_tag_menu.current_view_tag|not(), $node|has_attribute('menu_name'))}
                    <h2 class="title-xxlarge mb-4">{$node|attribute('menu_name').content|wash()}</h2>
                {/if}

                {include uri='design:atoms/grid.tpl'
                         items_per_row=$items_per_row
                         i_view=cond($openpa.content_tag_menu.current_view_tag, 'card_teaser', $view)
                         image_class='large'
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

    {def $locale = ezini('RegionalSettings', 'Locale')
         $tag_menu_children = array()
         $prefix = ''}
    {if $openpa.content_tag_menu.current_view_tag}
        {set $tag_menu_children = $openpa.content_tag_menu.current_view_tag.children
             $prefix = concat($openpa.content_tag_menu.current_view_tag.keyword, '/')}
    {else}
        {set $tag_menu_children = $openpa.content_tag_menu.tag_menu_root.children}
    {/if}
    {def $clean_tag_menu_children = array()}
    {foreach $tag_menu_children as $tag}
        {if tag_tree_has_contents($tag)}
            {set $clean_tag_menu_children = $clean_tag_menu_children|append($tag)}
        {/if}
    {/foreach}
    {if $clean_tag_menu_children|count()}
        <section id="{if $node|has_attribute('menu_name')}{$node|attribute('menu_name').content|slugize}{else}{$parent_node.name|slugize}{/if}">
            <div class="container {$view_variation}">
                {if $node|has_attribute('menu_name')}
                    <h2 class="title-xxlarge mb-4">{$node|attribute('menu_name').content|wash()}</h2>
                {/if}
                <div class="row g-4">
                    {foreach $clean_tag_menu_children as $tag}
                        <div class="col-12 col-md-6 col-lg-4">
                            <div class="cmp-card-simple card-wrapper pb-0 rounded border border-light">
                                <div class="card shadow-sm rounded">
                                    <div class="card-body">
                                        <a href="{concat($openpa.content_tag_menu.tag_menu_root_node.url_alias, '/(view)/', $prefix, $tag.keyword)|ezurl(no)}"
                                           {if $node.object.remote_id|eq('all-services')}data-element="service-category-link"{/if}
                                           class="text-decoration-none" data-focus-mouse="false">
                                            <h3 class="card-title t-primary title-xlarge">{$tag.keyword|wash()}</h3>
                                        </a>
                                        <p class="titillium text-paragraph mb-0">
                                            <span class="tag-description">{tag_description($tag.id, $locale)|wash()|nl2br}</span>
                                            {if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'edit_tag_description' ) )}
                                                <a href="#" data-edit_tag="{$tag.id}" data-locale="{$locale}">
                                                    <span class="fa-stack">
                                                      <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
                                                      <i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i>
                                                    </span>
                                                </a>
                                            {/if}
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    {/foreach}
                </div>
            </div>
        </section>

        {if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'edit_tag_description' ) )}
            <script>{literal}
              $(document).ready(function () {
                $('[data-edit_tag]').on('click', function (e) {
                  let button = $(this);
                  let tagId = button.data('edit_tag');
                  let locale = button.data('locale');
                  let container = $(this).parent('p');
                  let text = container.find('span.tag-description').text();
                  container.hide();
                  let editContainer = $('<div></div>');
                  let textarea = $('<textarea rows="6" class="form-control form-control-sm text-sans-serif">'+$.trim(text)+'</textarea>')
                    .appendTo(editContainer);
                  let submitButton = $('<a href="#" data-tag="'+tagId+'" data-locale="'+locale+'" class="pull-right btn btn-xs btn-success py-1 px-2 text-sans-serif mt-2">Salva</a>')
                    .appendTo(editContainer)
                    .on('click', function (e) {
                      let tagId = $(this).data('tag');
                      let locale = $(this).data('locale');
                      $.ez('ezjscedittagdescription::edit::'+tagId+'::'+locale+'::{/literal}{$node.contentobject_id}{literal}', {text: textarea.val()}, function (response) {
                        if (response.result === 'success'){
                          $('[data-edit_tag="'+response.tag+'"]').parent('p').find('span.tag-description').text(response.text);
                        }
                        editContainer.remove();
                        container.show();
                      })
                      e.preventDefault();
                    });
                  let cancelButton = $('<a href="#" class="pull-right btn btn-xs btn-info py-1 px-2 text-sans-serif mt-2 mr-2 me-2">Annulla</a>')
                    .appendTo(editContainer)
                    .on('click', function (e) {
                      editContainer.remove();
                      container.show();
                      e.preventDefault();
                    });
                  editContainer.insertBefore(container);
                  e.preventDefault();
                });
              })
            {/literal}</script>
        {/if}
    {/if}
    {undef $tag_menu_children $locale $clean_tag_menu_children}
{/if}

{unset_defaults( array(
    'page_limit',
    'exclude_classes',
    'include_classes',
    'type',
    'fetch_type',
    'parent_node',
    'items_per_row'
) )}