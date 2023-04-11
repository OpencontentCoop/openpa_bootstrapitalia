{set_defaults( hash('show_title', true()) )}
{def $valid_node = $block.valid_nodes[0]}
{def $current_openpa = object_handler($valid_node)}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        <h3 class="openpa-widget-title"><a href={$valid_node.url_alias|ezurl()}>{$block.name|wash()}</a></h3>
    {/if}
    <div class="openpa-widget-content openpa-full">
        {include name=block_full uri=$current_openpa.content_main.template openpa=$current_openpa node=$valid_node}
    </div>
</div>
{undef $valid_node $current_openpa}
