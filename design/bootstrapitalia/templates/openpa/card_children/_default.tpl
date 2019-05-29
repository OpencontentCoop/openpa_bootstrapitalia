{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'limit', 4,
    'class_filter_type', 'exclude',
    'class_filter_array', openpaini( 'ExcludedClassesAsChild', 'FromFolder', array( 'image', 'infobox', 'global_layout' ) )
))}

{def $fetch_params = hash('parent_node_id', $node.node_id,
                          'class_filter_type', $class_filter_type,
                          'class_filter_array', $class_filter_array,
                          'sort_by', $node.sort_array,
                          'limit', $limit)}

<div class="card-wrapper card-space {$node|access_style}">
    <div class="card card-bg{if $node|has_attribute('image')} card-img{/if}">

        {if and($node|has_attribute('image'), fetch(openpa, list_count, $fetch_params)eq(0))}
            <div class="img-responsive-wrapper">
                <div class="img-responsive">
                    <div class="img-wrapper">
                        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
                    </div>
                </div>
            </div>
        {/if}

        <div class="card-body card-body-alt">

            {if $show_icon}
                {if $openpa.content_icon.object_icon}
                    <div class="card-icon">
                        {display_icon($openpa.content_icon.object_icon.icon_text, 'svg', 'icon')}
                    </div>
                {elseif $openpa.content_icon.context_icon}
                    <div class="card-icon-sm">
                        <a href="{$openpa.content_icon.context_icon.node.url_alias|ezurl(no)}" title="Vai alla pagina: {$openpa.content_icon.context_icon.node.name|wash()}" >
                            {display_icon($openpa.content_icon.context_icon.icon_text, 'svg', 'icon')}
                            <span>{$openpa.content_icon.context_icon.node.name|wash()}</span>
                        </a>
                    </div>
                {/if}
            {/if}

            <h5 class="card-title{if or($openpa.content_icon.context_icon|not(), $openpa.content_icon.object_icon, $show_icon|not())} big-heading{/if}">
                <a href="{$openpa.content_link.full_link}" class="color-primary">
                    {$node.name|wash()}
                </a>
            </h5>

            {include uri='design:atoms/list_with_icon.tpl'
                     items=fetch(openpa, list, $fetch_params)}

            {if $node|has_attribute('menu_name')}
            <a class="read-more read-more-color-500" href="{$openpa.content_link.full_link}">
                <span class="text">{$node|attribute('menu_name').content|wash()}</span>
                {display_icon('it-arrow-right', 'svg', 'icon')}
            </a>
            {/if}

        </div>
    </div>
</div>
{undef $fetch_params}
{unset_defaults(array('show_icon', 'image_class', 'limit', 'class_filter_type', 'class_filter_array'))}