{def $path_array = $current_node.path_string|explode( '/' )
     $current_node_id = $current_node.node_id
     $is_current = cond($menu_item.item.node_id|eq($current_node_id), true(), false())
     $is_active = cond($path_array|contains($menu_item.item.node_id), true(), false())}

<li>

    {if and($max_recursion|gt($recursion), $menu_item.has_children)}
        {set $recursion = $recursion|inc()}
        <a class="list-item right-icon{if or($is_active, $is_current)} medium{/if}" href="#menu-dropdown-{$menu_item.item.node_id}" data-toggle="collapse" aria-expanded="{if or($is_active, $is_current)}true{else}false{/if}" aria-controls="menu-dropdown-{$menu_item.item.node_id}">
            <span>{$menu_item.item.name|wash()}</span>
            {display_icon('it-expand', 'svg', 'icon icon-primary right m-0')}
        </a>
        <ul class="link-sublist{if or($is_active, $is_current)|not()} collapse{/if}" id="menu-dropdown-{$menu_item.item.node_id}">
            {foreach $menu_item.children as $child}
                {include name="side_sub_menu"
                         uri='design:openpa/full/parts/side_menu_item.tpl'
                         menu_item=$child
                         current_node=$current_node
                         recursion=$recursion
                         max_recursion=$max_recursion}
            {/foreach}
        </ul>
    {else}
        <a href="{if $menu_item.item.internal}{$menu_item.item.url|ezurl(no)}{else}{$menu_item.item.url}{/if}"
           {if $menu_item.item.target}target="{$menu_item.item.target}"{/if}
           class="list-item{if or($is_active, $is_current)} medium{/if}"
           title="Vai a {$menu_item.item.name|wash()}">
            {$menu_item.item.name|wash()}
        </a>
    {/if}
</li>

{undef $path_array $current_node_id $is_current $is_active}
