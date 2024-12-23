{set_defaults( hash(
  'parent_node', $node,
  'view_variation', ''
))}

{def $locale = ezini('RegionalSettings', 'Locale')
     $tag_menu_children = array()
     $prefix = ''}
{if $openpa.content_tag_menu.current_view_tag}
    {set $tag_menu_children = $openpa.content_tag_menu.current_view_tag.children
         $prefix = concat($openpa.content_tag_menu.current_view_tag.clean_url|explode(concat($openpa.content_tag_menu.tag_menu_root.clean_url, '/'))[1], '/')}
{else}
    {set $tag_menu_children = $openpa.content_tag_menu.tag_menu_root.children}
{/if}

{def $show_all_tag_grid = array()} {*'all-services'*}
{if $show_all_tag_grid|contains($node.object.remote_id)|not()}
    {def $clean_tag_menu_children = array()}
    {foreach $tag_menu_children as $tag}
        {if tag_tree_has_contents($tag, $node)}
            {set $clean_tag_menu_children = $clean_tag_menu_children|append($tag)}
        {/if}
    {/foreach}
    {set $tag_menu_children = $clean_tag_menu_children}
{/if}

{if $tag_menu_children|count()}
    <section id="{if $node|has_attribute('menu_name')}{$node|attribute('menu_name').content|slugize}{else}{$parent_node.name|slugize}{/if}">
        <div class="container {$view_variation}">
            {if $node|has_attribute('menu_name')}
                <h2 class="title-xxlarge mb-4">{$node|attribute('menu_name').content|wash()}</h2>
            {/if}
            <div class="row g-4">
                {foreach $tag_menu_children as $tag}
                    <div class="col-12 col-md-6 col-lg-4">
                        <div class="cmp-card-simple card-wrapper pb-0 rounded border border-light">
                            <div class="card shadow-sm rounded">
                                <div class="card-body">
                                    <a href="{concat($openpa.content_tag_menu.tag_menu_root_node.url_alias, '/(view)/', $prefix, $tag.keyword)|ezurl(no)}"
                                       {if $node.object.remote_id|eq('all-services')}data-element="service-category-link"{/if}
                                       class="text-decoration-none" data-focus-mouse="false">
                                        <h3 class="card-title title-xlarge">{$tag.keyword|wash()}</h3>
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
              let submitButton = $('<a href="#" data-tag="'+tagId+'" data-locale="'+locale+'" class="pull-right btn btn-xs btn-primary py-1 px-2 text-sans-serif mt-2">Salva</a>')
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
{undef $tag_menu_children $locale $clean_tag_menu_children $show_all_tag_grid}

{unset_defaults( array(
    'parent_node',
    'view_variation'
) )}