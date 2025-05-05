{def $valid_node = $block.valid_nodes[0]}

{if openpaini('ViewSettings', 'ShowTitleInSingleBlock')|eq('enabled')}
    <div class="container">{include uri='design:parts/block_name.tpl'}</div>
{elseif $block.name|ne('')}
  <h2 class="visually-hidden">{$block.name|wash()}</h2>
{else}
  <h2 class="visually-hidden">{$valid_node.name|wash()}</h2>
{/if}

<div class="container p-0">
    {node_view_gui content_node=$valid_node view=card_image image_class=imagelargeoverlay show_icon=false() view_variation='big'}
</div>

{undef $valid_node}