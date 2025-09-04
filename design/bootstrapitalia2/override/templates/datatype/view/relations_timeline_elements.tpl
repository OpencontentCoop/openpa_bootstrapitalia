{if $attribute.has_content}
  {include uri='design:atoms/timeline.tpl' items=$attribute.content.relation_list}
{/if}
