{if and( is_set($block.custom_attributes.node_id), $block.custom_attributes.node_id|gt(0) )}
    {def $subtreearray = array( $block.custom_attributes.node_id )}
{else}
    {def $subtreearray = array( ezini( 'NodeSettings', 'RootNode', 'content.ini' ) )}
{/if}

{if $block.custom_attributes.class|ne('')}
    {def $class_filters = $block.custom_attributes.class|explode(',')}
{/if}

{def $class = fetch( 'content', 'class', hash( 'class_id', $class_filters[0] ) )}
{if $class}
    <div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
        {if $block.name|ne('')}
            <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>
        {/if}
        <div class="openpa-widget-content">
            <form class="Form Form--spaced" id="search-form-box" action="{'content/advancedsearch'|ezurl('no')}" method="get">
                {include name = searchform
                         uri = 'design:parts/class_search_form.tpl'
                         class = $class
                         subtree = $subtreearray
                         open_advanced = false()
                         exclude_attributes = openpaini( 'GestioneAttributi', 'attributi_da_escludere_dalla_ricerca', array() )}
            </form>
        </div>
    </div>
{/if}

