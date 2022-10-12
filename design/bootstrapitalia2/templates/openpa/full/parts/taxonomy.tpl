{set_defaults( hash(
    'show_title', true(),
    'container_class', 'mt-4 mb-4'
))}


{def $current_topics = array()}
{if and($node|has_attribute('topics'), $node|attribute('topics').data_type_string|eq('ezobjectrelationlist'))}
    {foreach $node|attribute('topics').content.relation_list as $item}
        {def $object = fetch(content, object, hash(object_id, $item.contentobject_id))}
        {if and($object.can_read, $object.class_identifier|eq('topic'))}
            {set $current_topics = $current_topics|append($object)}
        {/if}
        {undef $object}
    {/foreach}
{/if}

{if or($current_topics|count(), $node|has_attribute('has_public_event_typology'), $node|has_attribute('content_type'), $node|has_attribute('document_type'), $node|has_attribute('announcement_type'))}
<div class="{$container_class}">
    {if $current_topics|count()}
        {if $show_title}
            <p class="h6 mb-0"><small>{'Topics'|i18n('bootstrapitalia')}</small></p>
        {/if}
        {foreach $current_topics as $object}
            <a class="text-decoration-none text-nowrap d-inline-block "
               {if $node.class_identifier|eq('public_service')}data-element="service-topic"{/if}
               href="{$object.main_node.url_alias|ezurl(no)}">
                <div class="chip chip-simple chip-{if $object.section_id|eq(1)}primary{else}danger{/if}"><span class="chip-label">{$object.name|wash()}</span>
                </div>
            </a>
        {/foreach}
    {/if}
    {foreach array('has_public_event_typology', 'content_type', 'document_type', 'announcement_type') as $identifier}
    {if $node|has_attribute($identifier)}
        {if $show_title}
            <p class="h6 mb-0{if $current_topics|count()} mt-1{/if}"><small>{$node|attribute($identifier).contentclass_attribute_name}</small></p>
        {/if}
        {if $node|attribute($identifier).data_type_string|eq('eztags')}
            {foreach $node|attribute($identifier).content.tags as $tag}
                <div class="chip chip-simple chip-primary"><span class="chip-label">{$tag.keyword|wash}</span></div>
            {/foreach}
        {else}
            {attribute_view_gui attribute=$node|attribute($identifier)}
        {/if}
    {/if}
    {/foreach}
</div>
{/if}

{if and($node|has_attribute('type'), $node|attribute('type').data_type_string|eq('eztags'), is_set($parent_openpa), $parent_openpa.content_tag_menu.has_tag_menu)}
<div class="{$container_class}">
    {if $show_title}
        <p class="h6 mb-0"><small>{$node|attribute('type').contentclass_attribute_name|wash()}</small></p>
    {/if}

    {foreach $node|attribute('type').content.tags as $tag}
        <a class="text-decoration-none text-sans-serif mr-1 me-1 text-nowrap d-inline-block"
           href="{if $parent_openpa.content_tag_menu.has_tag_menu}{concat( $parent_openpa.control_menu.side_menu.root_node.url_alias, '/(view)/', $tag.keyword )|ezurl(no)}{else}#{/if}">
           <div class="chip chip-simple chip-primary"><span class="chip-label">{$tag.keyword|wash}</span></div>
       </a>
    {/foreach}
</div>
{/if}

{unset_defaults(array(
    'show_title',
    'container_class'
))}
