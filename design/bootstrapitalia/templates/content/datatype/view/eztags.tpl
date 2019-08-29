{default show_link=true()}
{if $attribute.content.tag_ids|count} 
{foreach $attribute.content.tags as $tag}
{if $show_link}<a class="mr-1" href={concat( '/tags/view/', $tag.url )|explode('tags/view/tags/view')|implode('tags/view')|ezurl}><div class="chip chip-simple chip-primary"><span class="chip-label">{$tag.keyword|wash}</span></div></a>
{else}
<div class="chip chip-simple"><span class="chip-label">{$tag.keyword|wash}</span></div>{/if}
{/foreach}
{/if}
{/default}