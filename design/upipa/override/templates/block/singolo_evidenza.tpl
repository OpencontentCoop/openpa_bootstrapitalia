{if count($block.valid_nodes)|gt(0)}
    {def $valid_node = $block.valid_nodes[0]}
    {def $openpa = object_handler($valid_node)}

    {def $has_image = false()}
    {foreach class_extra_parameters($valid_node.object.class_identifier, 'table_view').main_image as $identifier}
        {if $valid_node|has_attribute($identifier)}
            {set $has_image = true()}
            {break}
        {/if}
    {/foreach}

    <div class="block-evidence">
        <div class="container position-relative overflow-hidden">
            {if $has_image}
                <div class="d-none d-lg-block position-absolute h-100 w-50"
                     style="right: 0;background-image:url('{include uri='design:atoms/image_url.tpl' node=$valid_node}'); background-position: center center;background-repeat: no-repeat;background-size: cover;min-height:200px">
                </div>
            {/if}
            <div class="row">
                <div class="col">
                    <div class="py-4 px-2">
                        <h4 class="mt-0 mb-2">
                            <a href="{$openpa.content_link.full_link}" title="Link a {$valid_node.name|wash()}" class="text-white text-decoration-none font-weight-bold">
                                {$valid_node.name|wash()}
                            </a>
                        </h4>
                        <div class="text-white lead evidence-text">
                            {include uri='design:openpa/full/parts/main_attributes.tpl' node=$valid_node}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {undef $valid_node $openpa $has_image}
{/if}