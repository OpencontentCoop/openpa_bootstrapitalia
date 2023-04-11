{def $openpa= object_handler($block)}
{set_defaults(hash('show_title', true(), 'items_per_row', 1))}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        {include uri='design:parts/block_name.tpl'}
    {/if}
    <div class="openpa-widget-content">
        {include name="carousel"
                 uri='design:atoms/carousel.tpl'
                 items=$openpa.content
                 css_id=$block.id
                 root_node=$openpa.root_node
                 pagination=false()
                 top_pagination_position=true()
                 navigation= and( $show_title, $block.name|ne(''), $items_per_row|gt(1) )
                 items_per_row=1
                 i_view=carousel
                 show_items_preview=true()
				 image_class='agid_wide_carousel'
                 wide_items_preview=true()}
    </div>
    {include uri='design:parts/block_show_all.tpl'}
</div>

{unset_defaults(array('show_title','items_per_row'))}
