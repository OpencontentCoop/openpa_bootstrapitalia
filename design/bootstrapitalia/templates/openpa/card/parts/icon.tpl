{if and($view_variation|eq('big'), $show_icon, $node|has_attribute('image')|not())}

    <div class="flag-icon invisible"></div>    

    {if $openpa.content_icon.object_icon}
        <div class="etichetta">
            <div class="card-icon">
                {display_icon($openpa.content_icon.object_icon.icon_text, 'svg', 'icon m-0')}
            </div>
        </div>
    {elseif $openpa.content_icon.context_icon}
        <div class="etichetta">
            {display_icon($openpa.content_icon.context_icon.icon_text, 'svg', 'icon')}
            <span>{$openpa.content_icon.context_icon.node.name|wash()}</span>
        </div>
    {elseif $openpa.content_icon.class_icon}
        <div class="etichetta">
            {display_icon($openpa.content_icon.class_icon.icon_text, 'svg', 'icon')}
            <span>{$node.class_name|wash()}</span>
        </div>
    {/if}

{/if}