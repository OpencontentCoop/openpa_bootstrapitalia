{def $valid_node = $block.valid_nodes[0]
     $link = '#'}

{if object_handler($valid_node).content_link.full_link|ne('')}
    {set $link = object_handler($valid_node).content_link.full_link}
{/if}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    <div class="openpa-widget-content">
        {if $valid_node|has_attribute('image')}
            <div class="owl-item">
                <div class="item">
                    {include uri='design:atoms/image.tpl' item=$valid_node image_class=agid_carousel css_classes="" image_css_class="media-object tr_all_long_hover" alignment=center href=$link}
                </div>
            </div>
        {else}
            <div class="Grid-cell u-padding-bottom-s">
                <a class="u-sizeFull u-textClean u-text-m u-background-grey-20 u-floatLeft" href="{$valid_node.url_alias|ezurl(no)}" style="height: 120px; overflow: hidden">
                    <span class="u-block u-padding-all-l">{$valid_node.name|oc_shorten(120)}</span>
                </a>
            </div>
        {/if}
    </div>
</div>