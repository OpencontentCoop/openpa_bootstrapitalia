<div class="form-check custom-control custom-checkbox mb-3">
    <input name="Topic[]"
           id="topic-{$topic.item.node_id}"
           value={$topic.item.node_id}
           {if $checked}{if $selected|contains($topic.item.node_id)}checked="checked"{else}data-indeterminate="1"{/if}{/if}
           class="custom-control-input"
           type="checkbox">
    <label class="custom-control-label" for="topic-{$topic.item.node_id}"{if $topic.has_children} style="max-width: 80%"{/if}>
        {if $recursion|gt(0)}<small>{/if}
        {$topic.item.name|wash()} {if is_set($topic_facets[$topic.item.node_id])}<small>({$topic_facets[$topic.item.node_id]})</small>{/if}
        {if $recursion|gt(0)}</small>{/if}
    </label>
    {if $topic.has_children}
        <a class="float-right" aria-label="More items" href="#side-search-more-topic-{$topic.item.node_id}" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="{*if $checked}true{else*}false{*/if*}" aria-controls="side-search-more-topic-{$topic.item.node_id}">
            {display_icon('it-more-items', 'svg', 'icon icon-primary right icon-sm ml-2 ms-2')}
        </a>
    {/if}
</div>
{if $topic.has_children}
    <div class="pl-2 ps-2 collapse{*if $checked} show{/if*}" id="side-search-more-topic-{$topic.item.node_id}">
        {foreach $topic.children as $child}
            {set $recursion = $recursion|inc()}
            {include name="topic_search_input" uri='design:parts/search/topic_search_input.tpl' topic=$child topic_facets=$topic_facets checked=cond(menu_item_tree_contains($child,$selected), true(), false()) selected=$selected recursion=$recursion}
        {/foreach}
    </div>
{/if}
