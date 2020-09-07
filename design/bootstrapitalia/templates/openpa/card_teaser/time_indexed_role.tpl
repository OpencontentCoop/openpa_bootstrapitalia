{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'view_variation', false(),
    'hide_title', false()
))}

{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}

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

<div data-object_id="{$node.contentobject_id}" class="card card-teaser shadow {$node|access_style} p-4 rounded border {$view_variation}">
    {if and($show_icon, $openpa.content_icon.icon)}
        {display_icon($openpa.content_icon.icon.icon_text, 'svg', 'icon')}
    {/if}
    <div class="card-body{if $node|has_attribute('image')} pr-3{/if}">
        {if and($person, $hide_title|not())}
        <h5 class="card-title mb-1">            
            {$person.name|wash()}
        </h5>
        {/if}
        <div class="card-text">        
            {if $role}{$role}{/if} {if $for_entity}{$for_entity.name|wash()}{/if}
            
            {include uri='design:openpa/card_teaser/parts/attributes.tpl'}
            
            {if and($person, $attributes.show|contains('content_show_read_more'))}
            <p class="mt-3"><a href="{$person.url_alias|ezurl(no)}" title="{'Go to content'|i18n('bootstrapitalia')} {$person.name|wash()}">{'Further details'|i18n('bootstrapitalia')}</a></p>
            {/if}
        </div>
    </div>
    {if $person|has_attribute('image')}
        <div class="avatar size-xl">
            {attribute_view_gui attribute=$person|attribute('image') image_class=$image_class}
        </div>
    {/if}
</div>

{undef $attributes $person $role $for_entity}
{unset_defaults(array('show_icon', 'image_class', 'view_variation', 'hide_title'))}