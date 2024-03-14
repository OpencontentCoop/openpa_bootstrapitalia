{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}
{def $has_image = cond($node|has_attribute('image'), true(), false())}
{set_defaults(hash('attribute_index', 0, 'data_element', $openpa.data_element.value))}
<div data-object_id="{$node.contentobject_id}" class="font-sans-serif card card-teaser border border-light rounded shadow-sm p-3">
    <div class="card-body {if $has_image}pe-3{/if}">
        <p class="card-title text-paragraph-regular-medium-semi mb-3">
            <a class="text-decoration-none" href="{$openpa.content_link.full_link}" data-element="{$data_element|wash()}" data-focus-mouse="false">
                {$node.data_map.given_name.content|wash()} {$node.data_map.family_name.content|wash()}{include uri='design:parts/card_title_suffix.tpl'}
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
        {attribute_view_gui attribute=$node|attribute('image') image_class=large}
    </div>
    {/if}
</div>
{unset_defaults(array('attribute_index', 'data_element'))}
{undef $attributes $has_image}