{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'large',
    'view_variation', ''
))}
<div data-object_id="{$node.contentobject_id}" class="banner {$view_variation} {$node|access_style}">
    
    {if $node|has_attribute('image')}
    <div class="banner-image">
        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
    </div>
    {elseif and($show_icon, $openpa.content_icon.icon)}
    <div class="banner-icon">
        <svg class="icon">
            {if $openpa.content_icon.icon}
                {display_icon($openpa.content_icon.icon.icon_text, 'svg', 'icon')}
            {/if}
        </svg>
        <span></span>
    </div>
    {/if}

    <div class="banner-text">
        <h4><a class="stretched-link" href="{$openpa.content_link.full_link}">{$node.name|wash()}</a></h4>
        {if $node|has_attribute('has_role')}
            {attribute_view_gui attribute=$node|attribute('has_role')}
        {/if}
    </div>
</div>
{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}