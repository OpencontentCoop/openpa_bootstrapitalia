{def $openpa= object_handler($block)}
{set_defaults(
  hash(
    'show_title', true(),
    'items_per_row', 1,
    'image_class', 'agid_wide_carousel',
    'enable_pagination', true(),
    'enable_preview', false(),
    'control_buttons', true(),
    'autoplay', true(),
    'loop', true()))}

<div class="openpa-widget lista_carousel {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {include uri='design:parts/block_name.tpl'}
    <div class="openpa-widget-content openpa-carousel">
        {include name="carousel"
                 uri='design:atoms/carousel.tpl'
                 items=$openpa.content
                 css_id=$block.id
                 root_node=$openpa.root_node
                 pagination= or( $items_per_row|gt(1), $enable_pagination )
                 navigation= and( $show_title, $block.name|ne(''), $items_per_row|gt(1) )
                 control_buttons= $control_buttons
                 autoplay= $autoplay
                 loop= $loop
                 items_per_row=1
                 show_items_preview= and( $items_per_row|eq(1), $enable_preview)
                 image_class=$image_class}
    </div>
</div>

{unset_defaults(array('show_title'))}
