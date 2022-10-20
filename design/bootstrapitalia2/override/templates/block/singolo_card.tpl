{def $valid_node = $block.valid_nodes[0]}

{include uri='design:parts/block_name.tpl'}
{node_view_gui content_node=$valid_node view=card image_class=imagelargeoverlay show_icon=true() view_variation='big'}

{undef $valid_node}