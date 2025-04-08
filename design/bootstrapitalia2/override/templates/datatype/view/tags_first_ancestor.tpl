{default show_link=true() tag_view=''}
{if $attribute.content.tag_ids|count}
    {def $subtree_limit = $attribute.content.permission_array.subtree_limit}
    {def $ancestors = $attribute.content.tags}
    {if $subtree_limit}
        {set $ancestors = array()}
        {foreach $attribute.content.tags as $tag}
            {foreach $tag.path as $index => $item}
                {if $item.id|eq($subtree_limit)}
                    {set $ancestors = $ancestors|append($tag.path[$index|inc()])}
                    {break}
                {/if}
            {/foreach}
        {/foreach}
    {/if}
    <div class="d-flex flex-wrap gap-2 mt-10 mb-30 font-sans-serif">
    {foreach $ancestors as $tag}
        <div class="cmp-tag">
            {if $show_link}
                <a class="chip chip-simple chip-primary bg-tag text-decoration-none" href="{concat( '/tags/view/', $tag.url )|explode('tags/view/tags/view')|implode('tags/view')|ezurl(no)}">
                    <span class="chip-label">{$tag.keyword|wash}</span>
                </a>
            {else}
            <div class="chip chip-simple chip-primary bg-tag text-decoration-none"><span class="chip-label">{$tag.keyword|wash}</span></div>
            {/if}
        </div>
    {/foreach}
    </div>
{/if}
{/default}
