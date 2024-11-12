{def $block_handler = object_handler($block)}
{def $show_all_link = cond(is_set($block.custom_attributes.show_all_link), $block.custom_attributes.show_all_link|eq(1), true(), false())}
{def $show_all_has_node = cond(is_set($block_handler.root_node), $block_handler.root_node, $block_handler.root_node.node_id|ne(ezini('NodeSettings', 'RootNode', 'content.ini')), true(), false())}
{def $show_all_node = $block_handler.root_node}
{def $show_all_text = cond(and(is_set($block.custom_attributes.show_all_text), $block.custom_attributes.show_all_text|ne('')), $block.custom_attributes.show_all_text|wash(), 'View all'|i18n('bootstrapitalia'))}
{if and($show_all_link, $show_all_has_node)|not()}
    {if $block.id|eq('section-place')}
        {set $show_all_node = fetch(content, object, hash(remote_id, 'all-places')).main_node}
        {set $show_all_link = true()}
        {set $show_all_has_node = cond($show_all_node, true(), false())}
        {set $show_all_text = 'Explore the municipality'|i18n('bootstrapitalia')}
    {elseif $block.id|eq('9cd237a12fdb73a490fee0b01a3fab9d')}
        {set $show_all_node = fetch(content, object, hash(remote_id, 'all-events')).main_node}
        {set $show_all_link = true()}
        {set $show_all_has_node = cond($show_all_node, true(), false())}
        {set $show_all_text = 'Go to event calendar'|i18n('bootstrapitalia')}
    {elseif $block.id|eq('e60d1373e30187166ab36ff0f088d87f')}
        {set $show_all_node = fetch(content, object, hash(remote_id, 'news')).main_node}
        {set $show_all_link = true()}
        {set $show_all_has_node = cond($show_all_node, true(), false())}
        {set $show_all_text = 'All news'|i18n('bootstrapitalia')}
    {/if}
{/if}
{if and($show_all_link, $show_all_has_node)}
<div class="row mt-4">
    <div class="col-12 col-lg-3 offset-lg-9">
        <button type="button"
                href="{$show_all_node.url_alias|ezurl(no)}"
                onclick="location.href = '{$show_all_node.url_alias|ezurl(no)}';"
                {if $is_homepage|not()}data-element="{object_handler($show_all_node).data_element.value|wash()}"{/if}
                class="btn btn-primary text-button w-100">
            <span>
                {$show_all_text}
            </span>
        </button>
    </div>
</div>
{/if}
{undef $block_handler $show_all_link $show_all_has_node $show_all_node}