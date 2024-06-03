{if count($block.valid_nodes)|gt(0)}
    {def $valid_node = $block.valid_nodes[0]}
    {def $openpa = object_handler($valid_node)}
    {def $has_image = cond($valid_node|has_attribute('image'), true(), false())}

    <div class="container {$valid_node|access_style}">
        <div class="row">
            <div class="col-12">
                {include uri='design:openpa/card/parts/card_title.tpl' node=$valid_node has_media=false() view_variation=false()}
            </div>
            <div class="col{if $has_image} col-md-8"{/if}>
                <div class="font-serif">
                    {include uri='design:openpa/card/parts/abstract.tpl' node=$valid_node has_media=false() view_variation=false()}
                </div>
                <a class="read-more pb-5 pt-4" href="{$openpa.content_link.full_link}#page-content">
                    <span class="text">
                        {if $openpa.content_link.is_node_link}{'Read more'|i18n('bootstrapitalia')}
                        {elseif and($openpa.content_link.is_internal|not(), $valid_node|has_attribute('location'), $valid_node|attribute('location').data_text|ne(''))}{$valid_node|attribute('location').data_text|wash()}
                        {else}{'Visit'|i18n('bootstrapitalia')}{/if}
                    </span>
                    {display_icon('it-arrow-right', 'svg', 'icon')}
                </a>
            </div>
            {if $has_image}
            <div class="col col-md-4">
                {attribute_view_gui attribute=$valid_node|attribute('image') image_class=large href=$openpa.content_link.full_link alt_text=$valid_node.name}
            </div>
            {/if}
        </div>
    </div>
    {undef $valid_node $openpa $has_image}
{/if}