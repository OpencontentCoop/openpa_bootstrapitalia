{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'view_variation', '',
    'limit', 4,
    'class_filter_type', 'exclude',
    'class_filter_array', openpaini( 'ExcludedClassesAsChild', 'FromFolder', array( 'image', 'infobox', 'global_layout' ) )
))}

{def $fetch_params = hash('parent_node_id', $node.main_node_id,
                          'class_filter_type', $class_filter_type,
                          'class_filter_array', $class_filter_array,
                          'sort_by', array('modified', false()),
                          'limit', $limit)}

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

        <a class="read-more" href="{$openpa.content_link.full_link}">
            <span class="text">Leggi di più</span>
            {display_icon('it-arrow-right', 'svg', 'icon')}
        </a>

    </div>

{include uri='design:openpa/card/parts/card_wrapper_close.tpl'}

{unset_defaults(array('show_icon', 'image_class', 'limit', 'class_filter_type', 'class_filter_array', 'view_variation'))}