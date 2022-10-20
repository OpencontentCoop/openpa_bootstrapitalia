{if and($view_variation|ne('big'), $show_icon)}

    {if $openpa.content_icon.context_icon}
        <div class="category-top">
            {display_icon($openpa.content_icon.context_icon.icon_text, 'svg', 'icon icon-sm')}
            <a class="text-decoration-none" href="{$openpa.content_icon.context_icon.node.url_alias|ezurl(no)}">
                <span class="title-xsmall-semi-bold fw-semibold">{include uri='design:openpa/card/parts/icon_label.tpl' fallback=$openpa.content_icon.context_icon.node.name}</span>
            </a>
            {if and(class_extra_parameters($node.object.class_identifier, 'table_view').show|contains('content_show_published'), $node.object.published|gt(0))}
                <span class="data fw-normal">{$node.object.published|l10n( 'shortdate' )}</span>
            {/if}
        </div>
    {elseif $openpa.content_icon.class_icon}
        <div class="category-top">
            {display_icon($openpa.content_icon.class_icon.icon_text, 'svg', 'icon icon-sm')}
            <a class="text-decoration-none" href="{concat('content/search?Class[]=', $node.object.contentclass_id)|ezurl(no)}">
                <span class="title-xsmall-semi-bold fw-semibold">{include uri='design:openpa/card/parts/icon_label.tpl' fallback=$node.class_name}</span>
            </a>
        </div>
    {/if}

{/if}