{def $openpa = object_handler($block)}

{set_defaults(hash('show_title', true(), 'link_top_title', true(), 'items_per_row', 2, 'image_class', 'agid_carousel'))}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
  {if and( $show_title, $block.name|ne('') )}
    <h3 class="openpa-widget-title">{if and($openpa.root_node, $link_top_title)}<a href={$openpa.root_node.url_alias|ezurl()}>{else}<span style="text-decoration:none !important">{/if}{$block.name|wash()}{if $openpa.root_node}</a>{else}</span>{/if}</h3>
  {/if}
  <div class="openpa-widget-content">
    <div class="Grid Grid--withGutter u-flexWrap u-flex">
      {foreach $openpa.content as $item}
        <div class="Grid-cell u-flex u-md-size1of{$items_per_row} u-lg-size1of{$items_per_row} u-padding-bottom-s">
        {node_view_gui content_node=$item view='panel' image_class=$image_class items_per_row=$items_per_row}
        </div>
      {/foreach}
    </div>
  </div>

  {if and($openpa.root_node, $link_top_title|not(), $block.type|eq('Lista'))}
    <p class="goto">
      <a href="{$openpa.root_node.url_alias|ezurl(no)}">Vedi tutto <span></span></a>
    </p>
  {/if}
</div>

{unset_defaults(array('show_title', 'link_top_title', 'items_per_row', 'image_class'))}
