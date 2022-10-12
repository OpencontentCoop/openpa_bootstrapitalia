{def $show_date = cond(and(class_extra_parameters($node.object.class_identifier, 'table_view').show|contains('content_show_published'), $node.object.published|gt(0)), true(), false())}
{if $show_icon}
    {if $openpa.content_icon.context_icon}
        <div class="category-top cmp-list-card-img__body">
            {display_icon($openpa.content_icon.context_icon.icon_text, 'svg', 'icon icon-sm')}
            <a class="text-decoration-none fw-bold cmp-list-card-img__body-heading-title" href="{$openpa.content_icon.context_icon.node.url_alias|ezurl(no)}">
                {include uri='design:openpa/card/parts/icon_label.tpl' fallback=$openpa.content_icon.context_icon.node.name}
            </a>
            {if $show_date}
                <span class="data fw-normal">{$node.object.published|l10n( 'shortdate' )}</span>
            {/if}
        </div>
    {elseif $openpa.content_icon.class_icon}
        <div class="category-top cmp-list-card-img__body">
            {display_icon($openpa.content_icon.class_icon.icon_text, 'svg', 'icon icon-sm')}
            <a class="text-decoration-none fw-bold cmp-list-card-img__body-heading-title" href="{concat('content/search?Class[]=', $node.object.contentclass_id)|ezurl(no)}">
                {include uri='design:openpa/card/parts/icon_label.tpl' fallback=$node.class_name}
            </a>
        </div>
    {/if}
{elseif $show_date}
    <div class="category-top cmp-list-card-img__body">
        <span class="data">{$node.object.published|l10n( 'date' )}</span>
    </div>
{/if}
{undef $show_date}