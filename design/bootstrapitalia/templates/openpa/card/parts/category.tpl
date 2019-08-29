{if and($view_variation|eq('alt'), $show_icon)}

    {if $openpa.content_icon.context_icon}
        <div class="category-top">
            {display_icon($openpa.content_icon.context_icon.icon_text, 'svg', 'icon')}
            <a class="category" href="{$openpa.content_icon.context_icon.node.url_alias|ezurl(no)}">{$openpa.content_icon.context_icon.node.name|wash()}</a>
            {if and(class_extra_parameters($node.object.class_identifier, 'table_view').show|contains('content_show_published'), $node.object.published|gt(0))}
                <span class="data">{$node.object.published|datetime( 'custom', '%j %M %Y' )}</span>
            {/if}
        </div>
    {elseif $openpa.content_icon.class_icon}
        <div class="category-top">
            {display_icon($openpa.content_icon.class_icon.icon_text, 'svg', 'icon')}
            <a class="category" href="{concat('content/search?Class[]=', $node.object.contentclass_id)|ezurl(no)}">{$node.class_name|wash()}</a>
        </div>
    {/if}

{/if}