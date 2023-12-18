{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'view_variation', false()
))}
{def $openpa = object_handler($node)}
{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}

<div data-object_id="{$node.contentobject_id}" class="card h-100 card-teaser {$node|access_style} p-3 position-relative overflow-hidden rounded border {$view_variation}">
    <div class="card-body{if $node|has_attribute('image')} pr-3 pe-3{/if}">
        {if $show_icon}
            {if $openpa.content_icon.context_icon}
                <div class="etichetta mb-2">
                    {display_icon($openpa.content_icon.context_icon.icon_text, 'svg', 'icon')}
                    {include uri='design:openpa/card/parts/icon_label.tpl' fallback=$openpa.content_icon.context_icon.full_label}
                </div>
            {/if}
        {/if}
        <p class="mb-3 h6 font-weight-normal">
            <a href="{$openpa.content_link.full_link}" title="{'Go to content'|i18n('bootstrapitalia')} {$node.name|wash()}">{$node.name|wash()}</a>
        </p>
        <div class="card-text">
            {include uri='design:openpa/card_teaser/parts/attributes.tpl'}
        </div>
    </div>
    {if and($attributes.show|contains('image'), $node|has_attribute('image'))}
        <div class="avatar size-xl">
            {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
        </div>
    {/if}
</div>

{undef $openpa $attributes}
{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}
