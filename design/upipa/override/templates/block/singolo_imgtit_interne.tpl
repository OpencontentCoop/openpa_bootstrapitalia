{def $valid_node = $block.valid_nodes[0]}
<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
  <h3 class="openpa-widget-title">{node_view_gui content_node=$valid_node view=text_linked}</h3>
  <div class="openpa-widget-content">
      {include uri='design:atoms/image.tpl' item=$valid_node image_class=large alignment=center href=object_handler($valid_node).content_link.full_link}
  </div>
</div>