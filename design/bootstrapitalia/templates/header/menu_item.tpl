{if $menu_item.item.internal}
    {def $href = $menu_item.item.url|ezurl(no)}
{else}
    {def $href = $menu_item.item.url}
{/if}

{def $is_dropdown = $menu_item.has_children}
{def $count_children = count($menu_item.children)}

<li class="nav-item{if $is_dropdown} dropdown{if $count_children|gt(10)} megamenu{/if}{/if}">
    <a class="nav-link{if $is_dropdown} dropdown-toggle{/if}"
       data-node="{$menu_item.item.node_id}"
       {if $is_dropdown}data-toggle="dropdown" aria-expanded="false"{/if}
       href="{$href}"
       {if $menu_item.item.target}target="{$menu_item.item.target}"{/if}
       title="Vai a {$menu_item.item.name|wash()}">
        <span>{$menu_item.item.name|wash()}</span>
        {if $is_dropdown}
            <svg class="icon icon-xs"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-expand"></use></svg>
        {/if}
    </a>
    {if $is_dropdown}
        <div class="dropdown-menu">
        {if $count_children|gt(10)}
            {if $count_children|gt(30)}
                {set $count_children = 30}
            {/if}
            {def $split = $count_children|div(3)|ceil()}
            <div class="row">
                {for 0 to 2 as $counter}
                <div class="col-12 col-lg-4">
                    <div class="link-list-wrapper">
                        <ul class="link-list">
                            {foreach $menu_item.children as $child max $split offset mul($split, $counter)}
                                {if $child.item.internal}
                                    {def $child_href = $child.item.url|ezurl(no)}
                                {else}
                                    {def $child_href = $child.item.url}
                                {/if}
                                <li>
                                    <a class="list-item"
                                       data-node="{$child.item.node_id}"
                                       {if $child.item.target}target="{$child.item.target}"{/if}
                                       href="{$child_href}">
                                        <span>{$child.item.name|wash()}</span>
                                    </a>
                                </li>
                                {undef $child_href}
                            {/foreach}
                        </ul>
                    </div>
                </div>
                {/for}
            </div>
        {else}
        <div class="link-list-wrapper">
            <ul class="link-list">
                {foreach $menu_item.children as $child}
                    {if $child.item.internal}
                        {def $child_href = $child.item.url|ezurl(no)}
                    {else}
                        {def $child_href = $child.item.url}
                    {/if}
                    <li>
                        <a class="list-item"
                           data-node="{$child.item.node_id}"
                           {if $child.item.target}target="{$child.item.target}"{/if}
                           href="{$child_href}">
                            <span>{$child.item.name|wash()}</span>
                        </a>
                    </li>
                    {undef $child_href}
                {/foreach}
            </ul>
        </div>
        {/if}
    </div>
    {/if}
</li>

{undef $href $is_dropdown $count_children}