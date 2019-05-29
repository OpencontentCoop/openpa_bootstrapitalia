{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'view_variation', 'banner-round banner-shadow'
))}
<a href="{$openpa.content_link.full_link}" class="banner {$view_variation} {$node|access_style}">
    {if and($show_icon, or($openpa.content_icon.object_icon, $openpa.content_icon.context_icon))}
    <div class="banner-icon">
        <svg class="icon">
            {if $openpa.content_icon.object_icon}
            <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#{$openpa.content_icon.object_icon.icon_text}"></use></svg>
            {else}
            <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#{$openpa.content_icon.context_icon.icon_text}"></use></svg>
            {/if}
        </svg>
        <span>Aenean ipsum ante</span>
    </div>
    {elseif $node|has_attribute('image')}
    <div class="banner-image">
        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
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