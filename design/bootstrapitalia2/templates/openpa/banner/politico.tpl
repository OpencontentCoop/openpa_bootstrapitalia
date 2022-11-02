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

{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}
{def $has_image = cond($node|has_attribute('image'), true(), false())}
{set_defaults(hash('attribute_index', 0, 'data_element', ''))}
<div data-object_id="{$node.contentobject_id}" class="font-sans-serif card card-teaser border border-light rounded shadow-sm p-3">
    <div class="card-body {if $has_image}pe-3{/if}">
        <p class="card-title text-paragraph-regular-medium-semi mb-3">
            <a class="text-decoration-none" href="{$openpa.content_link.full_link}" data-element="{$data_element}" data-focus-mouse="false">
                {include uri='design:openpa/card_teaser/parts/card_title.tpl'}
            </a>
        </p>
        {if $node|has_attribute('has_role')}
        <div class="card-text u-main-black">
            {attribute_view_gui attribute=$node|attribute('has_role')}
        </div>
        {/if}
    </div>
    {if $has_image}
    <div class="avatar size-xl">
        {attribute_view_gui attribute=$node|attribute('image') image_class=medium}
    </div>
    {/if}
</div>
{unset_defaults(array('attribute_index', 'data_element'))}
{undef $attributes $has_image}