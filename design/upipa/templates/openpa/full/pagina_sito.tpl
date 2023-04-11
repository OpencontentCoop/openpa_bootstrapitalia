{ezpagedata_set( 'has_container', true() )}

{def $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array() )
     $show_left = false()
     $side_menu_root_node = $openpa.control_menu.side_menu.root_node
     $current_view_tag = $openpa.content_tag_menu.current_view_tag}

{if $openpa.content_tag_menu.has_tag_menu}
    {set $show_left = true()}    
    {if $openpa.content_tag_menu.current_view_tag}    
        {ezpagedata_set( 'current_view_tag_keyword', $openpa.content_tag_menu.current_view_tag.keyword )}
        {ezpagedata_set( 'view_tag_root_node_url', $openpa.content_tag_menu.tag_menu_root_node.url_alias )}
    {/if}
{else}
    {if $top_menu_node_ids|contains($side_menu_root_node.node_id)}
        {if $side_menu_root_node.node_id|ne($node.node_id)}
            {def $tree_menu_node_id = $node.path_string|explode($side_menu_root_node.path_string)[1]|explode('/')[0]}
            {def $tree_menu = tree_menu( hash( 'root_node_id', $tree_menu_node_id, 'user_hash', $openpa.control_menu.side_menu.user_hash, 'scope', 'side_menu' ))}
            {set $show_left = cond(count( $tree_menu.children )|gt(0), true(), false())}
        {/if}
    {/if}
{/if}

{if $show_left}
    {ezpagedata_set( 'has_section_menu', true() )}
{/if}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            
            {if $current_view_tag}
                <h1>{$current_view_tag.keyword|wash()}</h1>
            {else}
                <h1>{$node.name|wash()}</h1>
                {include uri='design:openpa/full/parts/main_attributes.tpl'}
            {/if}

            {if $node|has_attribute('show_search_form')}
                {if $top_menu_node_ids|contains($side_menu_root_node.node_id)}
                    {if $node.depth|lt(3)}
                        {include uri='design:openpa/full/parts/search_form.tpl' current_node=$node}
                    {else}
                        {include uri='design:openpa/full/parts/search_form.tpl' current_node=$node.path[1] subtree_preselect=$node.node_id}
                    {/if}            
                {/if} 
            {/if}

            {include uri='design:openpa/full/parts/main_image.tpl'}

            {if and($current_view_tag|not(), $node|has_attribute('description'))}
                {attribute_view_gui attribute=$node|attribute('description')}
            {/if}


        </div>
        <div class="col-lg-3 offset-lg-1">
            {if $show_left}  
                {if $openpa.content_tag_menu.has_tag_menu|not()}
                    {include uri='design:openpa/full/parts/side_menu.tpl' }
                {else}
                    {include uri='design:openpa/full/parts/tag_side_menu.tpl'}
                {/if}
            {/if}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}                
        </div>
    </div>
</section>

{if and($current_view_tag|not(), $node|has_attribute('layout'))}
    {attribute_view_gui attribute=$node|attribute('layout')}
{/if}

{node_view_gui content_node=$node view=children view_parameters=$view_parameters}

{if $node|has_attribute('show_topics')}
    {include uri='design:openpa/full/parts/topic_facets.tpl' current_node=$node}   
{/if}