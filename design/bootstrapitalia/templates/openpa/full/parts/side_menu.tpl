<aside id="section-menu">
    <nav class="section-menu">
        {if $node|has_attribute('menu_name')}
            <h4>{$node|attribute('menu_name').content|wash()}</h4>
        {elseif $openpa.control_menu.side_menu.root_node}
            <h4>{$openpa.control_menu.side_menu.root_node.name|wash()}</h4>
        {/if}
        <ul class="list-group">
            {foreach $tree_menu.children as $menu_item}
                {include name=side_menu
                         uri='design:openpa/full/parts/side_menu_item.tpl'
                         menu_item=$menu_item
                         current_node=$node
                         max_recursion=1
                         recursion=1}
            {/foreach}
        </ul>
    </nav>
</aside>