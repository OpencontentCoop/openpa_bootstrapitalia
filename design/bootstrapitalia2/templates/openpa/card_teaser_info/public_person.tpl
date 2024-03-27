{set_defaults(hash('hide_title', false()))}
{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}
{def $has_image = cond(and($attributes.show|contains('image'), $node|has_attribute('image')), true(), false())}
{set_defaults(hash(
    'attribute_index', 0,
    'view_variation', '',
    'data_element', $openpa.data_element.value
))}
<div data-object_id="{$node.contentobject_id}" class="font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3 {$view_variation}" style="z-index: {100|sub($attribute_index)}">
    <div class="card-body {if $has_image}pe-3{/if}">
        {if $hide_title|not()}
        <p class="card-title text-paragraph-regular-medium-semi mb-3">
            {if $attributes.show|contains('content_show_read_more')}
                <a class="text-decoration-none" href="{$openpa.content_link.full_link}" data-element="{$data_element|wash()}" data-focus-mouse="false" style="hyphens: auto">
                    {$node.data_map.given_name.content|wash()} {$node.data_map.family_name.content|wash()}
                </a>
            {else}
                {$node.data_map.given_name.content|wash()} {$node.data_map.family_name.content|wash()}
            {/if}
        </p>
        {/if}
        <div class="card-text u-main-black">
            {include uri='design:openpa/card_teaser/parts/attributes.tpl'}
        </div>
        {if and($hide_title, $attributes.show|contains('content_show_read_more'), $node.object.state_identifier_array|contains('privacy/public'))}
            <a class="read-more mt-4 mb-3 position-relative" style="bottom: unset" href="{$openpa.content_link.full_link}" data-element="{$data_element|wash()}">
                <span class="text">{if $openpa.content_link.is_node_link}{'Further details'|i18n('bootstrapitalia')}{else}{'Visit'|i18n('bootstrapitalia')}{/if}</span>
                {display_icon('it-arrow-right', 'svg', 'icon', 'Read more'|i18n('bootstrapitalia'))}
            </a>
        {/if}
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