{if $menu_item.item.internal}
    {def $href = $menu_item.item.url|ezurl(no)}
{else}
    {def $href = $menu_item.item.url}
{/if}
{def $has_children = $menu_item.has_children}
{def $count_children = count($menu_item.children)}
{def $children_max_items = 5}

<div class="col-lg-3 col-md-3 col-sm-6 pb-2">
    <h4>
        <a href="{$href}" title="{'Go to page'|i18n('bootstrapitalia')}: {$menu_item.item.name|wash()}">{$menu_item.item.name|wash()}</a>
    </h4>
    {if $has_children}
    <div class="link-list-wrapper">
        <ul class="footer-list link-list clearfix">
            {foreach $menu_item.children as $child max $children_max_items}
                {if $child.item.internal}
                    {def $child_href = $child.item.url|ezurl(no)}
                {else}
                    {def $child_href = $child.item.url}
                {/if}
                <li><a class="list-item" href="{$child_href}" title="{'Go to page'|i18n('bootstrapitalia')}: {$child.item.name|wash()}">{$child.item.name|wash()}</a></li>
                {undef $child_href}
            {/foreach}
            {if $count_children|gt($children_max_items)}
                <li class="list-item">
                    <a href="{$href}"><em>{'See more'|i18n('bootstrapitalia')}</em></a>
                </li>
            {/if}
        </ul>
    </div>
    {/if}
</div>

{undef $href $has_children $count_children $children_max_items}