{if $menu_item.item.internal}
    {def $href = $menu_item.item.url|ezurl(no)}
{else}
    {def $href = $menu_item.item.url}
{/if}

{def $is_dropdown = cond(and($show_children, $menu_item.has_children), true(), false())}
{def $count_children = count($menu_item.children)}
{def $megamenu_min_items = 12}
{def $megamenu_max_items = 18}

<li class="nav-item{if $is_dropdown} dropdown{if $count_children|gt($megamenu_min_items)} megamenu{/if}{/if}">
    <a class="main-nav-link nav-link{if $is_dropdown} dropdown-toggle{/if} text-truncate"
       id="mainMenu{$menu_item.item.node_id}"
       data-element="{$menu_item.item.remote_id}"
       data-node="{$menu_item.item.node_id}"
       {if $is_dropdown}data-bs-toggle="dropdown" aria-expanded="false"{/if}
       href="{$href}"
       {if $menu_item.item.target}target="{$menu_item.item.target}"{/if}
       title="{'Go to page'|i18n('bootstrapitalia')}: {$menu_item.item.name|wash()}">
        <span>{$menu_item.item.name|wash()}</span>
        {if $is_dropdown}
            {display_icon('it-expand', 'svg', 'icon icon-xs')}
        {/if}
    </a>
    {if $is_dropdown}
        <div class="dropdown-menu p-2" role="region" aria-labelledby="mainMenu{$menu_item.item.node_id}" {if $count_children|gt($megamenu_min_items)} style="margin-top: 13px !important;"{/if}>
            <div class="p-2 mb-2 border-bottom text-center">
                <a data-node="{$menu_item.item.node_id}"
                   data-element="{$menu_item.item.remote_id}"
                   href="{$href}"
                    {if $menu_item.item.target}target="{$menu_item.item.target}"{/if}
                   title="{'Go to page'|i18n('bootstrapitalia')}: {$menu_item.item.name|wash()}">
                    <small class="text-uppercase">{$menu_item.item.name|wash()}</small>
                </a>
            </div>
            {if $count_children|gt($megamenu_min_items)}
                {if $count_children|gt($megamenu_max_items)}
                    {set $count_children = $megamenu_max_items}
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
                                {if and($counter|eq(2), count($menu_item.children)|gt($megamenu_max_items))}
                                    <li class="it-more">
                                        <a class="list-item medium" href="{$href}">
                                            <span>{'See more'|i18n('bootstrapitalia')}</span>
                                            {display_icon('it-arrow-right', 'svg', 'icon icon-sm icon-primary right')}
                                        </a>
                                    </li>
                                {/if}
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
