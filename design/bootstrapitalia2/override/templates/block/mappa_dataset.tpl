{def $openpa = object_handler($block)}

{if $openpa.has_content}
  {include uri='design:parts/block_name.tpl'}
  {if count($block.valid_nodes)|gt(0)}
    {include uri='design:atoms/dataset_map.tpl' items=$block.valid_nodes block_id=$block.id}
  {/if}
{/if}
{undef $openpa }