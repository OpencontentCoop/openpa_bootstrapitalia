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
<section class="{$container_class}">
    {if $current_topics|count()}
        {if $show_title}
            <div class="row">
                <h2 class="mb-2 h6 fw-normal">{'Topics'|i18n('bootstrapitalia')}</h2>
            </div>
        {/if}
        <ul class="d-flex flex-wrap gap-1 mb-2">
        {foreach $current_topics as $index => $object max 6}
            <li>
                <a class="chip chip-simple chip-primary {if $object.section_id|ne(1)}no-sezioni_per_tutti{/if}"
                   {if $node.class_identifier|eq('public_service')}data-element="service-topic"{/if}
                   href="{$object.main_node.url_alias|ezurl(no)}">
                    <span class="chip-label">{$object.name|wash()}</span>
                </a>
            </li>
        {/foreach}
        </ul>
        {if $current_topics|count()|gt(6) }
          <div>
            <button 
              class="btn-link"
              type="button"
              data-bs-toggle="collapse"
              data-bs-target="#collapse-{$node.node_id}-topics"
              aria-expanded="false"
              aria-controls='collapse-{$node.node_id}-topics'>
              <small>{'Show more elements'|i18n('bootstrapitalia')}</small>
            </button>
            <div class="collapse mt-2" id='collapse-{$node.node_id}-topics'>
              <ul class="d-flex flex-wrap gap-1 mb-2">
                {foreach $current_topics as $index => $object offest 6}
                  <li>
                    <a class="chip chip-simple chip-primary {if $object.section_id|ne(1)}no-sezioni_per_tutti{/if}"
                      {if $node.class_identifier|eq('public_service')}data-element="service-topic"{/if}
                      href="{$object.main_node.url_alias|ezurl(no)}">
                        <span class="chip-label">{$object.name|wash()}</span>
                    </a>
                  <li>
                {/foreach}
              </ul>
            </div>
          </div>
        {/if}
    {/if}
    {if $show_title}
    {* eventi *}
    {foreach array('has_public_event_typology', 'content_type', 'document_type', 'announcement_type') as $identifier}
    {if $node|has_attribute($identifier)}
        {if $show_title}
            <div class="row">
                <h2 class="mb-2 h6 fw-normal">{$node|attribute($identifier).contentclass_attribute_name}</h2>
            </div>
        {/if}
        {if $node|attribute($identifier).data_type_string|eq('eztags')}
            <ul class="d-flex flex-wrap gap-1 mb-2">
            {foreach $node|attribute($identifier).content.tags as $tag max 6}
                <li class="chip chip-simple chip-primary"><span class="chip-label">{$tag.keyword|wash}</span></li>
            {/foreach}
            </ul>
            {if $node|attribute($identifier).content.tags|count()|gt(6) }
              <div>
                <button 
                  class="btn-link"
                  type="button"
                  data-bs-toggle="collapse"
                  data-bs-target="#collapse-{$node.node_id}-{$identifier}"
                  aria-expanded="false"
                  aria-controls='collapse-{$node.node_id}-{$identifier}'>
                  <small>{'Show more elements'|i18n('bootstrapitalia')}</small>
                </button>
                <div class="collapse mt-2" id='collapse-{$node.node_id}-{$identifier}'>
                  <ul class="d-flex flex-wrap gap-1 mb-2">
                    {foreach $node|attribute($identifier).content.tags as $tag offest 6}
                      <li class="chip chip-simple chip-primary"><span class="chip-label">{$tag.keyword|wash}</span></li>
                    {/foreach}
                  </ul>
                </div>
              </div>
            {/if}
        {else}
            {attribute_view_gui attribute=$node|attribute($identifier)}
        {/if}
    {/if}
    {/foreach}
    {/if}
</section>
{/if}

{* servizi *}
{if and($show_title, $node|has_attribute('type'), $node|attribute('type').data_type_string|eq('eztags'), is_set($parent_openpa), $parent_openpa.content_tag_menu.has_tag_menu)}
<section class="{$container_class}">
    {if $show_title}
        <div class="row">
            <h2 class="mb-2 h6 fw-normal">{$node|attribute('type').contentclass_attribute_name|wash()}</h2>
        </div>
    {/if}
    <ul class="d-flex flex-wrap gap-1">
    {foreach $node|attribute('type').content.tags as $tag max 6}
      <li>
          <a class="chip chip-simple chip-primary"
              href="{if $parent_openpa.content_tag_menu.has_tag_menu}{concat( $parent_openpa.content_tag_menu.tag_menu_root_node.url_alias, '/(view)/', $tag.keyword )|ezurl(no)}{else}#{/if}">
              <span class="chip-label">{$tag.keyword|wash}</span>
          </a>
      </li>
    {/foreach}
    </ul>
    {if $node|attribute('type').content.tags|count()|gt(6) }
      <div>
        <button 
          class="btn-link"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#collapse-{$node.node_id}-type"
          aria-expanded="false"
          aria-controls='collapse-{$node.node_id}-type'>
          <small>{'Show more elements'|i18n('bootstrapitalia')}</small>
        </button>
        <div class="collapse mt-2" id='collapse-{$node.node_id}-type'>
          <ul class="d-flex flex-wrap gap-1 mb-2">
            {foreach $node|attribute('type').content.tags as $tag offest 6}
              <li>
                  <a class="chip chip-simple chip-primary"
                      href="{if $parent_openpa.content_tag_menu.has_tag_menu}{concat( $parent_openpa.content_tag_menu.tag_menu_root_node.url_alias, '/(view)/', $tag.keyword )|ezurl(no)}{else}#{/if}">
                      <span class="chip-label">{$tag.keyword|wash}</span>
                  </a>
              </li>
            {/foreach}
          </ul>
        </div>
      </div>
    {/if}
</section>
{/if}

{unset_defaults(array(
    'show_title',
    'container_class'
))}
