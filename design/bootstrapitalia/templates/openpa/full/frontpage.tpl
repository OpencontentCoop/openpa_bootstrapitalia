{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'narrow_container', true() )}

{def $tree_menu = tree_menu( hash( 'root_node_id', $openpa.control_menu.side_menu.root_node.node_id, 'user_hash', $openpa.control_menu.side_menu.user_hash, 'scope', 'side_menu' ))
     $show_left = cond(count( $tree_menu.children )|gt(0), true(), false())}
{if $show_left}
    {ezpagedata_set( 'has_section_menu', true() )}
{/if}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {include uri='design:openpa/full/parts/main_attributes.tpl'}

            {if $node.depth|lt(3)}
                {include uri='design:openpa/full/parts/search_form.tpl' current_node=$node}
            {else}
                {include uri='design:openpa/full/parts/search_form.tpl' current_node=$node.path[1]}
            {/if}

            {if $node|has_attribute('description')}
                {attribute_view_gui attribute=$node|attribute('description')}
            {/if}
        </div>
        <div class="col-lg-3 offset-lg-1">
            {if $show_left}                
                {include uri='design:openpa/full/parts/side_menu.tpl'}                
            {/if}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}                
        </div>
    </div>
</section>

{if $node|has_attribute('page')}
    {attribute_view_gui attribute=$node|attribute('page')}
{else}
    {node_view_gui content_node=$node view=children view_parameters=$view_parameters}
{/if}