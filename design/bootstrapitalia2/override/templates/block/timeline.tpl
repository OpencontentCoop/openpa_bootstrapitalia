{def $openpa = object_handler($block)}

{if $openpa.has_content}
  {include uri='design:parts/block_name.tpl'}
  {include uri='design:atoms/timeline.tpl' items=$block.valid_nodes}
{/if}

{undef $openpa}