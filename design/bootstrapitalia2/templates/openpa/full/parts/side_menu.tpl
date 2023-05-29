{def $menu_title = false()}
{if $openpa.control_menu.side_menu.root_node}
    {set $menu_title = $openpa.control_menu.side_menu.root_node.name|wash()}
    {if $openpa.control_menu.side_menu.root_node|has_attribute('menu_name')}
        {set $menu_title = $openpa.control_menu.side_menu.root_node|attribute('menu_name').content|wash()}
    {/if}
{/if}

<aside id="section-menu">
    <nav class="section-menu mb-4">
        <div class="link-list-wrapper">
            <ul class="link-list">
            {if $openpa.control_menu.side_menu.root_node}
                <li>
                    <h3>{$menu_title}</h3>
                </li>
            {/if}
            {def $tree_menu_children = $tree_menu.children}
            {if count($tree_menu_children)|gt(8)}
                
                {foreach $tree_menu_children as $menu_item max 6}
                    {include name=side_menu uri='design:openpa/full/parts/side_menu_item.tpl' menu_item=$menu_item current_node=$node max_recursion=1 recursion=1}
                {/foreach}
                <li>
                  <a class="more-menu-handle list-item large medium left-icon collapsed" href="#more-menu" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="more-menu" aria-label="More items">
                    {display_icon('it-more-items', 'svg', 'icon icon-primary right')}                    
                  </a>
                  <ul class="link-sublist px-0 collapse" id="more-menu">
                    {foreach $tree_menu_children as $menu_item offset 6}
                        {include name=side_menu uri='design:openpa/full/parts/side_menu_item.tpl' menu_item=$menu_item current_node=$node max_recursion=1 recursion=1}
                    {/foreach}
                  </ul>
                </li>
                {if and(
                    $menu_title,
                    $openpa.control_menu.side_menu.root_node.node_id|eq($node.node_id),
                    $openpa.control_children.current_view, $openpa.control_children.current_view|ne('empty')
                )}
                <li>
                    <a class="list-item medium" href="#{$menu_title|slugize}">{$menu_title}</a>
                </li>
                {/if}
            {else}
                {foreach $tree_menu_children as $menu_item}
                    {include name=side_menu uri='design:openpa/full/parts/side_menu_item.tpl' menu_item=$menu_item current_node=$node max_recursion=1 recursion=1}
                {/foreach}
            {/if}
            {undef $tree_menu_children}
        </ul>
    </nav>
</aside>


{undef $menu_title}