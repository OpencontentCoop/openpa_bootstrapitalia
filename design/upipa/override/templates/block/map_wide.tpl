{set_defaults( hash('show_title', true()) )}

{if and( is_set( $block.custom_attributes.height ), ne( $block.custom_attributes.height, '' ) )}
    {def $height = $block.custom_attributes.height}
{else}
    {def $height = '600'}
{/if}

{def $root = ezini( 'NodeSettings', 'RootNode', 'content.ini' )}
{if is_set( $block.custom_attributes.parent_node_id )}
    {set $root = $block.custom_attributes.parent_node_id}
{/if}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>
    {/if}
    <div class="openpa-widget-content">
        {include uri='design:parts/children/map.tpl' map_type="osm" view='line' node=hash( node_id, $root) class_identifiers=$block.custom_attributes.class|explode(',') show_list=false()}
    </div>
</div>
