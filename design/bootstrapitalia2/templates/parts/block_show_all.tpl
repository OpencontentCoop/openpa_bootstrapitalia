{def $block_handler = object_handler($block)}
{if and(
    is_set($block.custom_attributes.show_all_link), $block.custom_attributes.show_all_link|eq(1),
    is_set($block_handler.root_node), $block_handler.root_node, $block_handler.root_node.node_id|ne(ezini('NodeSettings', 'RootNode', 'content.ini'))
)}
    <div class="d-flex justify-content-end mt-4">
        <button type="button"
                href="{$block_handler.root_node.url_alias|ezurl(no)}"
                onclick="location.href = '{$block_handler.root_node.url_alias|ezurl(no)}';"
                data-element="{object_handler($block_handler.root_node).data_element.value|wash()}"
                class="btn btn-primary px-5 py-3 full-mb">
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
{undef $block_handler}