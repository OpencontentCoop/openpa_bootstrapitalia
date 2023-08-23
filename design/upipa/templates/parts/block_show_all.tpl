{def $block_handler = object_handler($block)}
{*is_set($block.custom_attributes.show_all_link), $block.custom_attributes.show_all_link|eq(1), *}
{if and(
    array('lista_in_evidenza', 'lista_carousel')|contains($block.view)|not(),
    is_set($block_handler.fetch_parameters), count($block_handler.fetch_parameters)|gt(0),
    is_set($block_handler.root_node), $block_handler.root_node, $block_handler.root_node.node_id|ne(ezini('NodeSettings', 'RootNode', 'content.ini'))
)}
<div class="row mt-2">
    <div class="col text-center">
        <a class="btn btn-primary" href="{$block_handler.root_node.url_alias|ezurl(no)}">
            {if and(is_set($block.custom_attributes.show_all_text), $block.custom_attributes.show_all_text|ne(''))}
                {$block.custom_attributes.show_all_text|wash()}
            {else}
                {'View all'|i18n('bootstrapitalia')}
            {/if}
        </a>
    </div>
</div>
{elseif is_set($link)}
    <div class="row mt-2">
        <div class="col text-center">
            <a class="btn btn-primary" href="{$link}">
                {'View all'|i18n('bootstrapitalia')}
            </a>
        </div>
    </div>
{/if}
{undef $block_handler}