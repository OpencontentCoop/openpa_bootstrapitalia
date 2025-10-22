<div class="form-check">
    <input id="topic-filter-{$topic.item.node_id}"
           type="checkbox"
           class="form-check-input"
           name="Topic[]"
           value="{$topic.item.node_id}"
           data-topic="{$topic.item.node_id}">
    <label for="topic-filter-{$topic.item.node_id}" class="form-check-label"{if $topic.has_children} style="max-width: 80%"{/if}>
        {$topic.item.name|wash()}
    </label>
    {if $topic.has_children}
        <a href="#search-more-topic-{$topic.item.node_id}" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="search-more-topic-{$topic.item.node_id}" aria-label="{'Expand section'|i18n('bootstrapitalia')}" role="button">
            {display_icon('it-more-items', 'svg', 'icon icon-primary right icon-sm')}
        </a>
    {/if}
</div>
{if $topic.has_children}
    <div class="pl-4 ps-4 collapse" id="search-more-topic-{$topic.item.node_id}">
        {foreach $topic.children as $child}
            {include uri='design:parts/search/topic_top_search_input.tpl' topic=$child}
        {/foreach}
    </div>
{/if}
