{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'view_variation', '',
    'limit', 4,
    'class_filter_type', 'exclude',
    'class_filter_array', openpaini( 'ExcludedClassesAsChild', 'FromFolder', array( 'image', 'infobox', 'global_layout' )|merge($exclude_classes) )
))}

{def $fetch_params = hash('parent_node_id', $node.main_node_id,
                          'class_filter_type', $class_filter_type,
                          'class_filter_array', $class_filter_array,
                          'sort_by', array('modified', false()),
                          'limit', $limit)}

{def $has_media = false()}
{if $node|has_attribute('image')}
    {set $has_media = true()}
{/if}

<div data-object_id="{$node.contentobject_id}" class="card card-teaser no-after rounded shadow-sm border border-light">
    <div class="card-body pb-5" style="min-height: 180px;">
        <h3 class="card-title title-xlarge-card">{$node.data_map.given_name.content|wash()} {$node.data_map.family_name.content|wash()}</h3>
        <div class="card-text pb-3">{include uri='design:openpa/card/parts/abstract.tpl'}</div>
        {if fetch(content, list_count, $fetch_params)}
            <div class="link-list-wrapper mt-4">
                <ul class="link-list" role="list">
                    {foreach fetch(content, list, $fetch_params) as $item}
                        <li>
                            <a class="list-item active icon-left mb-2" href="{$item.url_alias|ezurl(no)}">
                                <span class="list-item-title-icon-wrapper">
                                    <span class="text-success">
                                      {$item.name|wash()}
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
            <span class="text">{'Read more'|i18n('bootstrapitalia')}</span>
            {display_icon('it-arrow-right', 'svg', 'icon', 'Read more'|i18n('bootstrapitalia'))}
        </span>
    </a>
</div>

{unset_defaults(array('show_icon', 'image_class', 'limit', 'class_filter_type', 'class_filter_array', 'view_variation'))}