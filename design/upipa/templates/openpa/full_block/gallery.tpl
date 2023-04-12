{set_defaults(hash('show_title', true(), 'items_per_row', 1, 'image_class', 'agid_panel', 'enable_pagination', false()))}
<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        <h3 class="openpa-widget-title">{if $link_top_title}<a href={$openpa.root_node.url_alias|ezurl()}>{else}<span>{/if}{$block.name|wash()}{if $link_top_title}</a>{else}</span>{/if}</h3>
    {/if}
    <div class="openpa-widget-content openpa-full">
        {if fetch( 'content', 'list_count', hash( 'parent_node_id', $node.node_id,
                                                    'class_filter_type', 'include',
                                                    'class_filter_array', array( 'image', 'video' ) ) )}

            {def $children = fetch( 'content', 'list', hash( 'parent_node_id', $node.node_id,
                                                            'class_filter_type', 'include',
                                                            'class_filter_array', array( 'image', 'video' ),
                                                            'sort_by', $node.sort_array ) )}

            {include name="carousel"
                     uri='design:atoms/carousel.tpl'
                     items=$children
                     css_id=concat( 'gallery', $node.node_id)
                     root_node=$node
                     autoplay=0
                     i_view=image
                     pagination=$enable_pagination
                     navigation=and( $show_title, $block.name|ne(''), $items_per_row|gt(1) )
                     items_per_row=$items_per_row
                     top_pagination_position=true()
                     image_class=$image_class}
        {/if}
    </div>
    {if $link_top_title|not()}
        <p class="u-textCenter u-text-md-right u-text-lg-right u-margin-r-top">
            <a href="{$node.url_alias|ezurl(no)}" class="u-color-50 u-textClean u-text-h4">
                Vedi tutto <span class="Icon Icon-chevron-right"></span></a>
        </p>
    {/if}
</div>
