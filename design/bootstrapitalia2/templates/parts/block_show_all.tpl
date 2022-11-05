{def $block_handler = object_handler($block)}
{if and(is_set($block.custom_attributes.show_all_link), $block.custom_attributes.show_all_link|eq(1), is_set($block_handler.root_node), $block_handler.root_node, $block_handler.root_node.node_id|ne(ezini('NodeSettings', 'RootNode', 'content.ini')) )}
    <div class="row mt-lg-2">
        <div class="col-12 col-lg-3 offset-lg-9">
            <a class="btn btn-primary text-button w-100" href="{$block_handler.root_node.url_alias|ezurl(no)}">
                {if and(is_set($block.custom_attributes.show_all_text), $block.custom_attributes.show_all_text|ne(''))}
                    {$block.custom_attributes.show_all_text|wash()}
                {else}
                    {'View all'|i18n('bootstrapitalia')}
                {/if}
            </a>
        </div>
    </div>
{/if}
{undef $block_handler}