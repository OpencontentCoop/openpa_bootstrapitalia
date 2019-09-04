{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'large',
    'view_variation', ''
))}
<a data-object_id="{$node.contentobject_id}" href="{$openpa.content_link.full_link}" class="banner {$view_variation} {$node|access_style}">
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
        <h4>{$node.name|wash()}</h4>
        {if $node|has_abstract()}
            <p>{$node|abstract()|oc_shorten(60)}</p>
        {/if}
    </div>
</a>
{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}