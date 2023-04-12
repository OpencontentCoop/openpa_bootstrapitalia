{if count($block.valid_nodes)}
{def $valid_node = $block.valid_nodes[0]}
  <div class="openpa-widget openpa-panels-container {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $block.name|ne(''), $valid_node|has_attribute( 'image' ) )}
      <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>
    {/if}
    <div class="openpa-widget-content">
        {node_view_gui content_node=$valid_node view=card view_variation=big image_class=large}
    </div>
  </div>

{undef $valid_node}
{/if}
