{set_defaults(hash(
    'show_icon', false(),
    'show_category', false(),
    'image_class', 'medium',
    'view_variation', 'border-light',
    'custom_css_class', '',
    'hide_title', false()
))}
{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}
{def $has_image = cond($person|has_attribute('image'), true(), false())}

{def $person = false()
     $role = false()
     $for_entity = false()}
{if $node|has_attribute('person')}
    {foreach $node|attribute('person').content.relation_list as $item}
        {set $person = fetch(content, node, hash(node_id, $item.node_id))}  
        {break}      
    {/foreach}
{/if}
{if $node|has_attribute('role')}
    {set $role = $node|attribute('role').content.keyword_string}
{/if}
{if $node|has_attribute('for_entity')}
    {foreach $node|attribute('for_entity').content.relation_list as $item}
        {set $for_entity = fetch(content, node, hash(node_id, $item.node_id))}  
        {break}      
    {/foreach}
{/if}

<div data-object_id="{$node.contentobject_id}"
     class="font-sans-serif card card-teaser{if $has_image} card-teaser-image card-flex{/if} no-after rounded shadow-sm mb-0 border border-light {$node|access_style} {$custom_css_class}">
    {if $has_image}
    <div class="card-image-wrapper{if $attributes.show|contains('content_show_read_more')} with-read-more{/if}">
    {/if}
        <div class="card-body {if $has_image}p-3 {/if}pb-5">
        {if and($show_category, $openpa.content_icon.context_icon.node)}
        <div class="category-top">
            {if $show_icon}{display_icon($openpa.content_icon.icon.icon_text, 'svg', 'icon icon-sm')}{/if}
            <span class="title-xsmall-semi-bold fw-semibold">{$openpa.content_icon.context_icon.node.name|wash()}</span>
        </div>
        {/if}
        {if and($person, $hide_title|not())}
        <h3 class="card-title text-paragraph-medium u-grey-light">
            {$person.name|wash()}
        </h3>
        {/if}
        <div class="text-paragraph-card u-grey-light m-0">
            {if $role}{$role}{/if} {if $for_entity}{$for_entity.name|wash()}{/if}
            {include uri='design:openpa/card_teaser/parts/attributes.tpl'}
            {if and($person, $attributes.show|contains('content_show_read_more'))}
                <p class="mt-3"><a href="{$person.url_alias|ezurl(no)}" title="{'Go to content'|i18n('bootstrapitalia')} {$person.name|wash()}">{'Further details'|i18n('bootstrapitalia')}</a></p>
            {/if}
        </div>
    </div>
    {if $person|has_attribute('image')}
        <div class="card-image card-image-rounded pb-5">
            {attribute_view_gui attribute=$person|attribute('image') image_class=$image_class}
        </div>
    </div>
    {/if}
    {if $attributes.show|contains('content_show_read_more')}
        <a class="read-more{if $has_image} ps-3 position-absolute bottom-0 mb-3{/if}" href="{$openpa.content_link.full_link}" title="{'Go to content'|i18n('bootstrapitalia')} {$node.name|wash()}">
            <span class="text">{'Further details'|i18n('bootstrapitalia')}</span>
            {display_icon('it-arrow-right', 'svg', 'icon ms-0')}
        </a>
    {/if}
</div>
{undef $attributes $has_image}
{unset_defaults(array('show_icon', 'image_class', 'view_variation', 'hide_title'))}