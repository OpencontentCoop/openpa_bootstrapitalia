{if $attribute.has_content}
  {def $items = array()}
  {foreach $attribute.content.relation_list as $item}
    {set $items = $items|append(fetch(content, node, hash(node_id, $item['node_id'])))}
  {/foreach}
  <div class="container my-4">
    <h2 class="mb-4 block-title title-xxlarge">Altri luoghi</h2>
    {include uri='design:atoms/dataset_map.tpl' items=$items block_id=$attribute.id name="dataset-map"}
  </div>
{/if}
{undef $items}