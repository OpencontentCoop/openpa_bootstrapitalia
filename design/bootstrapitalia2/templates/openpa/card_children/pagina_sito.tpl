{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'large',
    'view_variation', '',
    'limit', 4,
    'class_filter_type', 'exclude',
    'class_filter_array', openpaini( 'ExcludedClassesAsChild', 'FromFolder', array( 'image', 'infobox', 'global_layout' )|merge($exclude_classes) )
))}

{def $fetch_params = hash('parent_node_id', $node.node_id,
                          'class_filter_type', $class_filter_type,
                          'class_filter_array', $class_filter_array,
                          'sort_by', array('modified', false()),
                          'limit', $limit)}

{def $has_media = false()}
{if $node|has_attribute('image')}
    {set $has_media = true()}
{/if}

{include uri='design:openpa/card/parts/card_wrapper_open.tpl'}

    {include uri='design:openpa/card/parts/image.tpl'}

    {include uri='design:openpa/card/parts/icon.tpl'}

    <div class="card-body">

        {include uri='design:openpa/card/parts/card_title.tpl'}

        {if fetch(content, list_count, $fetch_params)}
            {include uri='design:atoms/list_with_icon.tpl' items=fetch(content, list, $fetch_params)}
        {else}
            {include uri='design:openpa/card/parts/abstract.tpl'}
        {/if}

        <a class="read-more" href="{$openpa.content_link.full_link}#page-content">
            <span class="text">{if $node|has_attribute('menu_name')}{$node|attribute('menu_name').content|wash()}{else}{'Go to page'|i18n('bootstrapitalia')}{/if}</span>
            {display_icon('it-arrow-right', 'svg', 'icon', 'Read more'|i18n('bootstrapitalia'))}
        </a>

    </div>

{include uri='design:openpa/card/parts/card_wrapper_close.tpl'}

{unset_defaults(array('show_icon', 'image_class', 'limit', 'class_filter_type', 'class_filter_array', 'view_variation'))}