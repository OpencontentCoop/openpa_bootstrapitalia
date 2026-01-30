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

    {if openpaini('ViewSettings', 'ShowTitleInSingleBlock')|eq('enabled')}
        <div class="container">{include uri='design:parts/block_name.tpl'}</div>
    {elseif $block.name|ne('')}
      <h2 class="visually-hidden">{$block.name|wash()}</h2>
    {else}
      <h2 class="visually-hidden">{$valid_node.name|wash()}</h2>
    {/if}

    <div class="block-evidence">
        <div class="container position-relative overflow-hidden">
            <div class="row position-relative">
                <div class="col-12 col-lg-6">
                    <div class="py-4 px-2">
                        <h3 class="h4 mt-0 mb-2">
                            <a href="{$openpa.content_link.full_link}" class="text-decoration-none font-weight-bold">
                                {$valid_node.name|wash()}
                            </a>
                        </h3>
                        <div class="lead evidence-text bg-grey-card rounded w-100">
                            {include uri='design:openpa/full/parts/main_attributes.tpl' node=$valid_node}
                        </div>
                    </div>
                </div>
                {if $has_image}
                    <div class="col col-lg-6">
                        {include name="bg" uri='design:atoms/background-image.tpl' node=$valid_node}
                    </div>
                {/if}
            </div>
        </div>
    </div>

    {undef $valid_node $openpa $has_image}
{/if}