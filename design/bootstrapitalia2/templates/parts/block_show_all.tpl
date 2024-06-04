{def $block_handler = object_handler($block)}
{def $show_all_link = cond(is_set($block.custom_attributes.show_all_link), $block.custom_attributes.show_all_link|eq(1), true(), false())}
{def $show_all_has_node = cond(is_set($block_handler.root_node), $block_handler.root_node, $block_handler.root_node.node_id|ne(ezini('NodeSettings', 'RootNode', 'content.ini')), true(), false())}
{def $show_all_node = $block_handler.root_node}
{if and($show_all_link, $show_all_has_node)|not()}
    {if $block.id|eq('section-place')}
        {set $show_all_node = fetch(content, object, hash(remote_id, 'all-places')).main_node}
        {set $show_all_link = true()}
        {set $show_all_has_node = cond($show_all_node, true(), false())}
    {elseif $block.id|eq('9cd237a12fdb73a490fee0b01a3fab9d')}
        {set $show_all_node = fetch(content, object, hash(remote_id, 'all-events')).main_node}
        {set $show_all_link = true()}
        {set $show_all_has_node = cond($show_all_node, true(), false())}
    {/if}
{/if}
{if and($show_all_link, $show_all_has_node)}
    <div class="d-flex justify-content-end mt-4">
        <button type="button"
                href="{$show_all_node.url_alias|ezurl(no)}"
                onclick="location.href = '{$show_all_node.url_alias|ezurl(no)}';"
                {if $is_homepage|not()}data-element="{object_handler($show_all_node).data_element.value|wash()}"{/if}
                class="btn btn-primary px-5 py-3 full-mb text-button">
            <span>
                {if and(is_set($block.custom_attributes.show_all_text), $block.custom_attributes.show_all_text|ne(''))}
                    {$block.custom_attributes.show_all_text|wash()}
                {else}
                    {'View all'|i18n('bootstrapitalia')}
                {/if}
            </span>
        </button>
    </div>
{/if}
{undef $block_handler $show_all_link $show_all_has_node $show_all_node}