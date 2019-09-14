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
            {def $tag_menu_children = $tag_menu_root.children}
            {if $tag_menu_root.children_count|gt(8)}
                {foreach $tag_menu_children as $menu_item max 6}
                    {include name=side_menu uri='design:openpa/full/parts/tag_side_menu_item.tpl' menu_item=$menu_item root_node=$openpa.control_menu.side_menu.root_node current_view_tag=$current_view_tag max_recursion=1 recursion=1}
                {/foreach}
                <li>
                  <a class="list-item large medium left-icon collapsed" href="#more-menu" data-toggle="collapse" aria-expanded="false" aria-controls="more-menu">
                    {display_icon('it-more-items', 'svg', 'icon icon-primary right')}                    
                  </a>
                  <ul class="link-sublist px-0 collapse" id="more-menu">
                    {foreach $tag_menu_children as $menu_item offset 6}
                        {include name=side_menu uri='design:openpa/full/parts/tag_side_menu_item.tpl' menu_item=$menu_item root_node=$openpa.control_menu.side_menu.root_node current_view_tag=$current_view_tag max_recursion=1 recursion=1}
                    {/foreach}
                  </ul>
                </li>
                {if and($menu_title, $current_view_tag)}
                <li>
                    <a class="list-item medium" href="{$openpa.control_menu.side_menu.root_node.url_alias|ezurl(no)}">{$menu_title}</a>
                </li>
                {/if}
            {else}
                {foreach $tag_menu_children as $menu_item}
                    {include name=side_menu uri='design:openpa/full/parts/tag_side_menu_item.tpl' menu_item=$menu_item root_node=$openpa.control_menu.side_menu.root_node current_view_tag=$current_view_tag max_recursion=1 recursion=1}
                {/foreach}
            {/if}
            {undef $tag_menu_children}
        </ul>
    </nav>
</aside>


{undef $menu_title}