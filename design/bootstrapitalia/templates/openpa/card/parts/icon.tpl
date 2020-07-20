{if and($view_variation|eq('big'), $show_icon, $has_media|not())}

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
            <span>{include uri='design:openpa/card/parts/icon_label.tpl' fallback=$openpa.content_icon.context_icon.node.name}</span>
        </div>
    {elseif $openpa.content_icon.class_icon}
        <div class="etichetta">
            {display_icon($openpa.content_icon.class_icon.icon_text, 'svg', 'icon')}
            <span>{include uri='design:openpa/card/parts/icon_label.tpl' fallback=$node.class_name}</span>
        </div>
    {/if}

{/if}