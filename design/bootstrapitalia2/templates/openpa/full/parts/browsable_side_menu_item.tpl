{def $path_array = $current_node.path_string|explode( '/' )
     $current_node_id = $current_node.node_id
     $is_current = cond($menu_item.item.node_id|eq($current_node_id), true(), false())
     $is_active = cond($path_array|contains($menu_item.item.node_id), true(), false())}

<li>

    {if and($max_recursion|gt($recursion), $menu_item.has_children)}
        <a class="browsable-menu-item d-inline-block py-2 pr-3 pe-3 pl-2 ps-2 pull-right {if or($is_active, $is_current)} font-weight-bold{else} collapsed{/if}"
           style="z-index:10;line-height: 1.7em"
           href="#menu-dropdown-{$menu_item.item.node_id}"
           data-toggle="collapse" data-bs-toggle="collapse"
           aria-expanded="{if or($is_active, $is_current)}true{else}false{/if}"
           aria-controls="menu-dropdown-{$menu_item.item.node_id}">
            {if or($is_active, $is_current)}<i aria-hidden="true" class="fa fa-minus-square-o"></i>{else}<i aria-hidden="true" class="fa fa-plus-square-o"></i>{/if}
        </a>
    {/if}

    <a href="{if $menu_item.item.internal}{$menu_item.item.url|ezurl(no)}{else}{$menu_item.item.url}{/if}"
       {if $menu_item.item.target}target="{$menu_item.item.target}"{/if}
       class="list-item{if or($is_active, $is_current)} medium{/if} py-2 pl-2 ps-2" style="line-height: 1.7em; border-bottom:1px solid #eee"
       title="{'Go to content'|i18n('bootstrapitalia')} {$menu_item.item.name|wash()}">
        {$menu_item.item.name|wash()}
    </a>

    {if and($max_recursion|gt($recursion), $menu_item.has_children)}
        {set $recursion = $recursion|inc()}
        <ul class="link-sublist{if or($is_active, $is_current)|not()} collapse{else} collapse show{/if}" id="menu-dropdown-{$menu_item.item.node_id}">
            {foreach $menu_item.children as $child}
                {include name="side_sub_menu"
                         uri='design:openpa/full/parts/browsable_side_menu_item.tpl'
                         menu_item=$child
                         current_node=$current_node
                         recursion=$recursion
                         max_recursion=$max_recursion}
            {/foreach}
        </ul>
    {/if}

    {run-once}
        <script>
            $(document).ready(function (){ldelim}
                $('.browsable-menu-item').on('click', function (e){ldelim}
                    if ($(this).hasClass('collapsed')){ldelim}
                        $(this).find('> i').removeClass('fa-plus-square-o').addClass('fa-minus-square-o');
                        {rdelim}else{ldelim}
                        $(this).find('> i').removeClass('fa-minus-square-o').addClass('fa-plus-square-o');
                        {rdelim}
                    {rdelim})
                {rdelim})
        </script>
    {/run-once}

</li>

{undef $path_array $current_node_id $is_current $is_active}