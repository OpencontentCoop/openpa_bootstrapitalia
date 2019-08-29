{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'view_variation', false()
))}

{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}

<div data-object_id="{$node.contentobject_id}" class="card card-teaser shadow {$node|access_style} p-4 rounded border {$view_variation}">
    {if and($show_icon, $openpa.content_icon.icon, $node|has_attribute('image')|not())}
        {display_icon($openpa.content_icon.icon.icon_text, 'svg', 'icon')}
    {/if}
    <div class="card-body{if $node|has_attribute('image')} pr-3{/if}">
        <h5 class="card-title mb-1">
            {$node.name|wash()}
        </h5>
        <div class="card-text">
            
            {include uri='design:openpa/card_teaser/parts/attributes.tpl'}

            {if $attributes.show|contains('content_show_read_more')}
            <p class="mt-3"><a href="{$openpa.content_link.full_link}" title="Vai al contenuto {$node.name|wash()}">Ulteriori dettagli</a></p>
            {/if}
        </div>
    </div>
    {if and($attributes.show|contains('image'), $node|has_attribute('image'))}
        <div class="avatar size-xl">
            {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
        </div>
    {/if}
</div>

{undef $attributes}
{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}