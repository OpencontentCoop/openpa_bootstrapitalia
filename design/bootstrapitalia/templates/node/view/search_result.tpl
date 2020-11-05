{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'view_variation', false()
))}
{def $openpa = object_handler($node)}

{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}

<div data-object_id="{$node.contentobject_id}" class="card card-teaser shadow {$node|access_style} p-4 pt-5 position-relative overflow-hidden rounded border {$view_variation}">
    <div class="card-body{if $node|has_attribute('image')} pr-3{/if}">
        {if $show_icon}
            <div class="etichetta mb-2" style="position: absolute;top: 0;width: 100%;left: 0;background: #efefef;padding: 5px;">
            {if $openpa.content_icon.icon}
                {display_icon($openpa.content_icon.icon.icon_text, 'svg', 'icon')}
            {/if}
                {$node.class_name|wash()}
            </div>
        {/if}
        <h5 class="card-title mb-1">
            {$node.name|wash()}
        </h5>
        <div class="card-text">
            
            {include uri='design:openpa/card_teaser/parts/attributes.tpl'}
            
            <p class="mt-3"><a href="{$openpa.content_link.full_link}" title="{'Go to content'|i18n('bootstrapitalia')} {$node.name|wash()}">{'Go to content'|i18n('bootstrapitalia')}</a></p>

        </div>
    </div>
    {if and($attributes.show|contains('image'), $node|has_attribute('image'))}
        <div class="avatar size-xl">
            {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
        </div>
    {/if}
</div>

{undef $attributes}


{undef $openpa}
{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}