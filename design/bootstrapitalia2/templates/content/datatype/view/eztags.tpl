{default show_link=true() tag_view=''}
{def $tags_count = $attribute.content.tag_ids|count}
  {if $tags_count}
    <div class="d-flex flex-wrap gap-2 mt-10 mb-30 font-sans-serif">
    {foreach $attribute.content.tags as $tag}
        <div class="cmp-tag">
            {if $show_link}
                <a
                  class="chip chip-simple chip-primary bg-tag"
                  href="{concat( '/tags/view/', $tag.url )|explode('tags/view/tags/view')|implode('tags/view')|ezurl(no)}"
                >
                  <span class="chip-label">{$tag.keyword|wash}</span>
                </a>
            {else}
              <div class="chip chip-simple chip-primary bg-tag">
                <span class="chip-label">{$tag.keyword|wash}</span>
              </div>
            {/if}
        </div>
    {/foreach}
    </div>
  {/if}
{undef $tags_count}
{/default}
