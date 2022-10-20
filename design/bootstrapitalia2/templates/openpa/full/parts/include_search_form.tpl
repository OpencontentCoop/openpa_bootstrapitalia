{*if $node|has_attribute('show_search_form')}
    {if and(is_set($top_menu_node_ids), is_set($side_menu_root_node.node_id))}
        {if $top_menu_node_ids|contains($side_menu_root_node.node_id)}
            {if $node.depth|lt(3)}
                {include uri='design:openpa/full/parts/search_form.tpl' current_node=$node}
            {else}
                {include uri='design:openpa/full/parts/search_form.tpl' current_node=$node.path[1] subtree_preselect=$node.node_id}
            {/if}
        {/if}
    {/if}
{/if*}