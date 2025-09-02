{if $attribute.has_content}
  {$pagedata.homepage.data_map|attribute(show, 1)}
  {include uri='design:atoms/timeline.tpl' items=$attribute.content.relation_list}
{/if}
