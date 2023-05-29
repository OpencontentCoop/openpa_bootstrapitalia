{set_defaults( hash(
    'show_title', true(),
    'container_class', 'mt-4 mb-4'
))}

{def $current_topics = array()}
{if and(
    openpaini('ContentMain','ShowTopicsInOverview','enabled')|eq('enabled'),
    $node|has_attribute('topics'),
    $node|attribute('topics').data_type_string|eq('ezobjectrelationlist')
)}
    {foreach $node|attribute('topics').content.relation_list as $item}
        {def $object = fetch(content, object, hash(object_id, $item.contentobject_id))}
        {if and($object.can_read, $object.class_identifier|eq('topic'))}
            {set $current_topics = $current_topics|append($object)}
        {/if}
        {undef $object}
    {/foreach}
{/if}


{if or($current_topics|count(), $node|has_attribute('has_public_event_typology'))}
<div class="{$container_class}">
    {if $current_topics|count()}
        {if $show_title}
            <h6 class="mb-0"><small>{'Topics'|i18n('bootstrapitalia')}</small></h6>
        {/if}
        {foreach $current_topics as $object}
            <a class="text-decoration-none text-nowrap d-inline-block " href="{$object.main_node.url_alias|ezurl(no)}"><div class="chip chip-simple chip-{if $object.section_id|eq(1)}primary{else}danger{/if}"><span class="chip-label">{$object.name|wash()}</span></div></a>
        {/foreach}
    {/if}
    {if $node|has_attribute('has_public_event_typology')}
        {if $show_title}
            <h6 class="mb-0{if $current_topics|count()} mt-1{/if}"><small>{$node|attribute('has_public_event_typology').contentclass_attribute_name}</small></h6>
        {/if}
        {attribute_view_gui attribute=$node|attribute('has_public_event_typology')}
    {/if}
</div>
{/if}

{if and($node|has_attribute('type'), $node|attribute('type').data_type_string|eq('eztags'), $openpa.content_tag_menu.has_tag_menu)}
<div class="{$container_class}">
    {if $show_title}
        <h6 class="mb-0"><small>{$node|attribute('type').contentclass_attribute_name|wash()}</small></h6>
    {/if}

    {foreach $node|attribute('type').content.tags as $tag}
        <a class="text-decoration-none text-sans-serif mr-1 me-1 text-nowrap d-inline-block"
           href="{if $openpa.content_tag_menu.has_tag_menu}{concat( $openpa.control_menu.side_menu.root_node.url_alias, '/(view)/', $tag.keyword )|ezurl(no)}{else}#{/if}">
           <div class="chip chip-simple chip-primary"><span class="chip-label">{$tag.keyword|wash}</span></div>
       </a>
    {/foreach}
</div>
{/if}

{unset_defaults(array(
    'show_title',
    'container_class'
))}
