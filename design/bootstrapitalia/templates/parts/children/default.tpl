{set_defaults( hash(
  'page_limit', 24,
  'exclude_classes', openpaini( 'ExcludedClassesAsChild', 'FromFolder', array( 'image', 'infobox', 'global_layout' ) ),
  'include_classes', array(),
  'type', 'exclude',
  'fetch_type', 'list',
  'parent_node', $node,
  'items_per_row', 3
))}

{if $openpa.content_tag_menu.show_tag_cards}

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

                {def $tag_menu_children = $openpa.content_tag_menu.tag_menu_root.children
                     $col = 12|div($items_per_row)
                     $locale = ezini('RegionalSettings', 'Locale')}
                <div class="row mx-lg-n3">
                    {foreach $tag_menu_children as $tag}
                        <div class="col-md-6 col-lg-{$col} px-lg-3 pb-3 pb-lg-4">
                            <div class="card shadow p-1 rounded border h-100">
                                <div class="card-body">
                                    <h5 class="card-title mb-2 big-heading">
                                        <a class="text-decoration-none" href="{concat($openpa.control_menu.side_menu.root_node.url_alias, '/(view)/', $tag.keyword)|ezurl(no)}">{$tag.keyword|wash()}</a>
                                    </h5>
                                    <div class="card-text">
                                        <p>
                                            <span class="tag-description">{tag_description($tag.id, $locale)|wash()}</span>
                                            {if fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'edit_tag_description' ) )}
                                                <a href="#" data-edit_tag="{$tag.id}" data-locale="{$locale}">
                                                    <span class="fa-stack">
                                                      <i class="fa fa-circle fa-stack-2x"></i>
                                                      <i class="fa fa-pencil fa-stack-1x fa-inverse"></i>
                                                    </span>
                                                </a>
                                            {/if}
                                        </p>
                                    </div>
                                    <a class="read-more" href="{concat($openpa.control_menu.side_menu.root_node.url_alias, '/(view)/', $tag.keyword)|ezurl(no)}">
                                        <span class="text">{'Go to page'|i18n('bootstrapitalia')}</span>
                                        {display_icon('it-arrow-right', 'svg', 'icon')}
                                    </a>
                                </div>
                            </div>
                        </div>
                    {/foreach}
                </div>
                {undef $tag_menu_children $col $locale}

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
                    let cancelButton = $('<a href="#" class="pull-right btn btn-xs btn-info py-1 px-2 text-sans-serif mt-2 mr-2">Annulla</a>')
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

{else}

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
                         image_class=cond($children_count|eq(2), 'reference', 'large')
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

{/if}