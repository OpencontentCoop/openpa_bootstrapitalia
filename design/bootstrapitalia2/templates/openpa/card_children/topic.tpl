{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'large',
    'view_variation', '',
    'limit', 7
))}

{def $esclude_query = array("class != 'homepage'")}
{foreach $exclude_classes as $exclude_class}
    {set $esclude_query = $esclude_query|append(concat("class != '",$exclude_class|trim(),"'"))}
{/foreach}

{def $related_items_query = concat($esclude_query|implode(' and '), " and topics.id in [", $node.contentobject_id, '] sort [modified=>desc] limit ', $limit)}
{debug-log var=$related_items_query msg='Topic related query'}
{def $related_items = api_search($related_items_query)}
{def $language = ezini('RegionalSettings', 'Locale')}

<div data-object_id="{$node.contentobject_id}" class="card card-teaser no-after rounded shadow-sm border border-light">
    <div class="card-body pb-5" style="min-height: 180px;">
        <h3 class="{*card-title *}text-secondary">{$node.name|wash()}</h3>
        {include uri='design:openpa/card/parts/abstract.tpl' wrapper_class='card-text'}
        {if $related_items.totalCount|gt(0)}
            <div class="link-list-wrapper mt-4">
                <ul class="link-list" role="list">
                    {foreach $related_items.searchHits as $item}
                        <li>
                            <a class="list-item active icon-left mb-2"
                               {if $item.metadata.classIdentifier|begins_with('public_service')}data-element="service-link"{/if}
                               href="{concat('openpa/object/', $item.metadata.id)|ezurl(no)}">
                                <span class="list-item-title-icon-wrapper">
                                    <span class="text-success">
                                      {if is_set($item.metadata.name[$language])}
                                          {$item.metadata.name[$language]|wash()}
                                      {else}
                                          {foreach $item.metadata.name as $locale => $name}{$name|wash()}{break}{/foreach}
                                      {/if}
                                    </span>
                                </span>
                            </a>
                        </li>
                    {/foreach}
                </ul>
            </div>
        {/if}
    </div>
    <a class="read-more pt-0" href="{$openpa.content_link.full_link}">
        <span class="list-item-title-icon-wrapper">
            <span class="text">{'Explore topic'|i18n('bootstrapitalia')}</span>
            {display_icon('it-arrow-right', 'svg', 'icon', 'Read more'|i18n('bootstrapitalia'))}
        </span>
    </a>
</div>
{unset_defaults(array('show_icon', 'image_class', 'limit', 'view_variation'))}
{undef $related_items $language $related_items_query}