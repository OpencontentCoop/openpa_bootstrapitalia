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
            <div class="row">
                <span class="mb-2 small">{'Topics'|i18n('bootstrapitalia')}</span>
            </div>
        {/if}
        <ul class="d-flex flex-wrap gap-1 mb-2">
        {foreach $current_topics as $object}
            <li>
                <a class="chip chip-simple {if $object.section_id|ne(1)}bg-danger{else}chip-primary{/if}"
                   {if $node.class_identifier|eq('public_service')}data-element="service-topic"{/if}
                   href="{$object.main_node.url_alias|ezurl(no)}">
                    <span class="chip-label text-nowrap {if $object.section_id|ne(1)}text-white{/if}">{$object.name|wash()}</span>
                </a>
            </li>
        {/foreach}
        </ul>
    {/if}
    {if $show_title}
    {foreach array('has_public_event_typology', 'content_type', 'document_type', 'announcement_type') as $identifier}
    {if $node|has_attribute($identifier)}
        {if $show_title}
            <div class="row">
                <span class="mb-2 small">{$node|attribute($identifier).contentclass_attribute_name}</span>
            </div>
        {/if}
        {if $node|attribute($identifier).data_type_string|eq('eztags')}
            <ul class="d-flex flex-wrap gap-1 mb-2">
            {foreach $node|attribute($identifier).content.tags as $tag}
                <li class="chip chip-simple chip-primary"><span class="chip-label text-nowrap">{$tag.keyword|wash}</span></li>
            {/foreach}
            </ul>
        {else}
            {attribute_view_gui attribute=$node|attribute($identifier)}
        {/if}
    {/if}
    {/foreach}
    {/if}
</div>
{/if}

{if and($show_title, $node|has_attribute('type'), $node|attribute('type').data_type_string|eq('eztags'), is_set($parent_openpa), $parent_openpa.content_tag_menu.has_tag_menu)}
<div class="{$container_class}">
    {if $show_title}
        <div class="row">
            <span class="mb-2 small">{$node|attribute('type').contentclass_attribute_name|wash()}</span>
        </div>
    {/if}
    <ul class="d-flex flex-wrap gap-1">
    {foreach $node|attribute('type').content.tags as $tag}
        <li>
            <a class="chip chip-simple chip-primary"
               href="{if $parent_openpa.content_tag_menu.has_tag_menu}{concat( $parent_openpa.control_menu.side_menu.root_node.url_alias, '/(view)/', $tag.keyword )|ezurl(no)}{else}#{/if}">
               <span class="chip-label text-nowrap">{$tag.keyword|wash}</span>
           </a>
        </li>
    {/foreach}
    </ul>
</div>
{/if}

{unset_defaults(array(
    'show_title',
    'container_class'
))}
