{if count($block.valid_nodes)|gt(0)}
    {def $valid_node = $block.valid_nodes[0]}
    {def $openpa = object_handler($valid_node)}
    {def $has_image = cond($valid_node|has_attribute('image'), true(), false())}

    <div class="container {$valid_node|access_style}">
        <div class="row">
            <div class="col-12">
                <h3 class="card-title big-heading">
                    {$valid_node.name|wash()}
                    {include uri='design:parts/card_title_suffix.tpl' node=$valid_node}
                    {if and($openpa.content_link.is_node_link|not(), $valid_node.can_edit)}
                        <a href="{$valid_node.url_alias|ezurl(no)}">
                            <span class="fa-stack">
                              <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
                              <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
                            </span>
                        </a>
                    {/if}
                </h3>
            </div>
            <div class="col{if $has_image} col-md-8"{/if}>
                <div class="font-serif">
                    {include uri='design:openpa/card/parts/abstract.tpl' node=$valid_node has_media=false() view_variation=false()}
                </div>
                <a class="read-more pb-5 pt-4" href="{$openpa.content_link.full_link}">
                    <span class="text">
                        {if $openpa.content_link.is_node_link}{'Read more'|i18n('bootstrapitalia')}
                        {elseif and($openpa.content_link.is_internal|not(), $valid_node|has_attribute('location'), $valid_node|attribute('location').data_text|ne(''))}{$valid_node|attribute('location').data_text|wash()}
                        {else}{'Visit'|i18n('bootstrapitalia')}{/if}
                    </span>
                    {if $openpa.content_link.is_node_link}
                        {display_icon('it-arrow-right', 'svg', 'icon')}
                    {else}
                        {display_icon('it-external-link', 'svg', 'icon')}
                    {/if}
                </a>
            </div>
            {if $has_image}
            <div class="col col-md-4">
                {attribute_view_gui attribute=$valid_node|attribute('image') image_class=large alt_text=$valid_node.name}
            </div>
            {/if}
        </div>
    </div>
    {undef $valid_node $openpa $has_image}
{/if}