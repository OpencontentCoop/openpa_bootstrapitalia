{def $openpa = object_handler($block)}
{set_defaults(hash('show_title', true(), 'items_per_row', 2))}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        <h3 class="openpa-widget-title">{if $openpa.root_node}<a href={$openpa.root_node.url_alias|ezurl()}>{else}<span>{/if}{$block.name|wash()}{if $openpa.root_node}</a>{else}</span>{/if}</h3>
    {/if}
    <div class="openpa-widget-content">
        {include uri='design:atoms/carousel.tpl'
                 css_id=$block.id
                 items=$openpa.content
                 root_node=$openpa.root_node
                 i_view=panel
                 autoplay=10000
                 pagination=true()
                 navigation=false()
                 image_class=squaremedium
                 items_per_row=$items_per_row}
    </div>
    {unset_defaults(array('show_title','items_per_row'))}
</div>
