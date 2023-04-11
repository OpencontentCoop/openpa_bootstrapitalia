{if is_set($block.valid_nodes[0])}
{def $node = $block.valid_nodes[0]
     $openpa = object_handler($node)}
{include uri=$openpa.control_template.full_block}
{/if}