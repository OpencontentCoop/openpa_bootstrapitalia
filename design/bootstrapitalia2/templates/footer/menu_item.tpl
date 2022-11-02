{if $menu_item.item.internal}
    {def $href = $menu_item.item.url|ezurl(no)}
{else}
    {def $href = $menu_item.item.url}
{/if}
{def $has_children = $menu_item.has_children}
{def $count_children = count($menu_item.children)}

{if $show_main_link}
<h3 class="footer-heading-title">
    <a href="{$href}" title="{'Go to page'|i18n('bootstrapitalia')}: {$menu_item.item.name|wash()}">{$menu_item.item.name|wash()}</a>
</h3>
{/if}
{if $has_children}
<ul class="footer-list">
    {foreach $menu_item.children as $child max $max offset $offset}
        {if $child.item.internal}
            {def $child_href = $child.item.url|ezurl(no)}
        {else}
            {def $child_href = $child.item.url}
        {/if}
        <li><a {*data-element="{$child.item.remote_id}" *}href="{$child_href}" title="{'Go to page'|i18n('bootstrapitalia')}: {$child.item.name|wash()}">{$child.item.name|wash()}</a></li>
        {undef $child_href}
    {/foreach}
    {if and( $show_more, $count_children|gt($max|sum($offset)))}
        <li>
            <a href="{$href}"><em>{'See more'|i18n('bootstrapitalia')}</em></a>
        </li>
    {/if}
</ul>
{/if}

{undef $href $has_children $count_children}