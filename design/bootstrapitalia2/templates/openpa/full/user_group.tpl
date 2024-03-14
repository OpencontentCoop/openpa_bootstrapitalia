{ezpagedata_set( 'has_container', true() )}

<section class="container">
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


{include uri='design:openpa/full/parts/main_image.tpl'}

<section class="container">
    {include uri='design:openpa/full/parts/attributes.tpl' object=$node.object}
</section>

<div class="section section-muted section-inset-shadow p-4">
{def $children_count = fetch( content, 'list_count', hash( 'parent_node_id', $node.node_id ) )
     $page_limit = 20}

{if $children_count}
    {def $children = fetch( content, list, hash( 'parent_node_id', $node.node_id,
                                                'offset', $view_parameters.offset,
                                                'sort_by', $node.sort_array,
                                                'limit', $page_limit ) )}
    <section>
      <div class="py-5">
        <div class="container">

            {include uri='design:atoms/grid.tpl'
                     items_per_row=4
                     i_view=banner
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

{undef $children_count $page_limit}
</section>
