{def $block_handler = object_handler($block)}
{if and(is_set($block.custom_attributes.show_all_link), $block.custom_attributes.show_all_link|eq(1), is_set($block_handler.root_node), $block_handler.root_node, $block_handler.root_node.node_id|ne(ezini('NodeSettings', 'RootNode', 'content.ini')) )}
<div class="row mt-2">
    <div class="col text-center">
        <a class="btn btn-primary" href="{$block_handler.root_node.url_alias|ezurl(no)}">
            {if and(is_set($block.custom_attributes.show_all_text), $block.custom_attributes.show_all_text|ne(''))}
                {$block.custom_attributes.show_all_text|wash()}
            {else}
                Vedi tutti
            {/if}
        </a>
    </div>
</div>
{/if}
{undef $block_handler}