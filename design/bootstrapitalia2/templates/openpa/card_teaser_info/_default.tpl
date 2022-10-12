{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}
{def $has_image = cond(and($attributes.show|contains('image'), $node|has_attribute('image')), true(), false())}
{set_defaults(hash(
    'attribute_index', 0,
    'view_variation', '',
    'data_element', $openpa.data_element.value
))}
<div data-object_id="{$node.contentobject_id}" class="font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 {$view_variation}" style="z-index: {100|sub($attribute_index)}">
    <div class="card-body {if $has_image}pe-3{/if}">
        <p class="card-title text-paragraph-regular-medium-semi mb-3">
            {if $attributes.show|contains('content_show_read_more')}
                <a class="text-decoration-none" href="{$openpa.content_link.full_link}" data-element="{$data_element|wash()}" data-focus-mouse="false" style="hyphens: auto">
                    {include uri='design:openpa/card_teaser/parts/card_title.tpl'}
                </a>
            {else}
                {include uri='design:openpa/card_teaser/parts/card_title.tpl'}
            {/if}
        </p>
        <div class="card-text u-main-black">
            {include uri='design:openpa/card_teaser/parts/attributes.tpl'}
        </div>
    </div>
    {if $has_image}
    <div class="avatar size-xl">
        {attribute_view_gui attribute=$node|attribute('image') image_class=medium}
    </div>
    {/if}
</div>
{unset_defaults(array('attribute_index', 'data_element', 'view_variation'))}
{undef $attributes $has_image}