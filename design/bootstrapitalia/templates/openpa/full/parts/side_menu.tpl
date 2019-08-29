<aside id="section-menu">
    <nav class="section-menu mb-4">
        <div class="link-list-wrapper">
            <ul class="link-list">
            {if $openpa.control_menu.side_menu.root_node}
                {if $openpa.control_menu.side_menu.root_node|has_attribute('menu_name')}
                    <li>
                        <h3>{$openpa.control_menu.side_menu.root_node|attribute('menu_name').content|wash()}</h3>
                    </li>
                {else}
                    <li>
                        <h3>{$openpa.control_menu.side_menu.root_node.name|wash()}</h3>
                    </li>
                {/if}
            {/if}
            {foreach $tree_menu.children as $menu_item}
                {include name=side_menu
                         uri='design:openpa/full/parts/side_menu_item.tpl'
                         menu_item=$menu_item
                         current_node=$node
                         max_recursion=2
                         recursion=1}
            {/foreach}
        </ul>
    </nav>
</aside>
