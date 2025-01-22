{set_defaults(hash('hide_title', false()))}
{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}
{def $has_image = cond(and($attributes.show|contains('image'), $node|has_attribute('image')), true(), false())}
{set_defaults(hash(
    'attribute_index', 0,
    'view_variation', '',
    'data_element', $openpa.data_element.value
))}
<div data-object_id="{$node.contentobject_id}" class="font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 {if $view_variation|eq('auto_width')|not()}card-teaser-info-width {/if}mt-0 mb-3 {$view_variation}" style="z-index: {100|sub($attribute_index)}">
    <div class="card-body {if $has_image}pe-3{/if}">
        <div class="card-text u-main-black">
            {include uri='design:atoms/image.tpl' node=$node is_main_image=true()}
        </div>
    </div>
    {if $has_image}
    <div class="avatar size-xl">
        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class context='card_teaser'}
    </div>
    {/if}
</div>
{unset_defaults(array('attribute_index', 'data_element', 'view_variation'))}
{undef $attributes $has_image}
{unset_defaults(array('hide_title'))}