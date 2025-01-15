{ezpagedata_set( 'has_container', true() )}

<section class="container cmp-heading">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {if $node|has_attribute('short_title')}
                <h4 class="py-2">{$node|attribute('short_title').content|wash()}</h4>
            {/if}

            {include uri='design:openpa/full/parts/main_attributes.tpl'}

            {include uri='design:openpa/full/parts/info.tpl'}

        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>

{def $children_count = $node.children_count}
{if $children_count}

    {def $page_limit = 54
         $children = fetch( content, list, hash( 'parent_node_id', $node.node_id,
                                                        'offset', $view_parameters.offset,
                                                        'sort_by', $node.sort_array,
                                                        'limit', $page_limit ) )}

    <div class="container">
        <div class="it-grid-list-wrapper it-image-label-grid it-masonry">
            <div class="card-columns">
            {foreach $children as $item}
                <div class="col-12">
                    {node_view_gui content_node=$item view=card_image image_class=imagelargeoverlay show_icon=false() view_variation=gallery}
                </div>
            {/foreach}
            </div>
        </div>
    </div>

    {include name=navigator
           uri='design:navigator/google.tpl'
           page_uri=$node.url_alias
           item_count=$children_count
           view_parameters=$view_parameters
           item_limit=$page_limit}

    {undef $children $page_limit}

{/if}

{if $openpa['content_tree_related'].full.exclude|not()}
    {include uri='design:openpa/full/parts/related.tpl' object=$node.object}
{/if}

{undef $children_count}