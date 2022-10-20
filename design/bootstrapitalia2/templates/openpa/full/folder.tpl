{ezpagedata_set( 'has_container', true() )}

<section class="container">
    <h1>{$node.name|wash()}</h1>

    {include uri='design:openpa/full/parts/main_attributes.tpl'}

    {if $node|has_attribute('description')}
        {attribute_view_gui attribute=$node|attribute('description')}
    {/if}
</section>

<div class="section section-muted section-inset-shadow p-4">
{if and(fetch(user, current_user).is_logged_in|not(), $node.object.remote_id|eq('restricted_areas'))}
    {set-block scope=root variable=cache_ttl}0{/set-block}
    {include uri='design:user/login.tpl' site_access=hash('allowed', true()) redirect_uri=concat($node.url_alias, '?l=', rand(19771205))|ezurl(no)}
{/if}

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
                     image_class=medium
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
</div>
