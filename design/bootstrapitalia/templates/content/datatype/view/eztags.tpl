{default show_link=true() tag_view=''}
{if $attribute.content.tag_ids|count} 
{foreach $attribute.content.tags as $tag}
{if $show_link}<a class="text-decoration-none text-sans-serif mr-1" href={concat( '/tags/view/', $tag.url )|explode('tags/view/tags/view')|implode('tags/view')|ezurl}><div class="chip {$tag_view} chip-simple chip-primary"><span class="chip-label">{$tag.keyword|wash}</span></div></a>
{else}
<div class="text-sans-serif chip {$tag_view} chip-simple chip-secondary"><span class="chip-label">{$tag.keyword|wash}</span></div>{/if}
{/foreach}
{/if}
{/default}