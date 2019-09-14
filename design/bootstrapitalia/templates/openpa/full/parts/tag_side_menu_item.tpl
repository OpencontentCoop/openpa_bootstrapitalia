{def $is_current = cond(and($current_view_tag, $menu_item.keyword|eq($current_view_tag.keyword)), true(), false())
     $is_active = $is_current}

<li>
    {if and($max_recursion|gt($recursion), $menu_item.children_count)}
        {set $recursion = $recursion|inc()}
        <a class="list-item right-icon{if or($is_active, $is_current)} medium{/if}" href="#menu-dropdown-{$menu_item.id}" data-toggle="collapse" aria-expanded="{if or($is_active, $is_current)}true{else}false{/if}" aria-controls="menu-dropdown-{$menu_item.id}">
            <span>{$menu_item.keyword|wash()}</span>
            {display_icon('it-expand', 'svg', 'icon icon-primary right m-0')}
        </a>
        <ul class="link-sublist{if or($is_active, $is_current)|not()} collapse{/if}" id="menu-dropdown-{$menu_item.id}">
            {foreach $menu_item.children as $child}
                {include name="side_sub_menu"
                         uri='design:openpa/full/parts/tag_side_menu_item.tpl'
                         menu_item=$child
                         current_view_tag=$current_view_tag
                         root_node=$root_node
                         recursion=$recursion
                         max_recursion=$max_recursion}
            {/foreach}
        </ul>
    {else}
        <a href="{concat($root_node.url_alias, '/(view)/', $menu_item.keyword)|ezurl(no)}"
           class="list-item{if or($is_active, $is_current)} medium{/if}"
           title="Vai a {$menu_item.keyword|wash()}">
            {$menu_item.keyword|wash()}
        </a>
    {/if}
</li>

{undef $is_current $is_active}
