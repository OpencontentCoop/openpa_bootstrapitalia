{def $valid_node = cond( is_set( $block.valid_nodes[0] ), $block.valid_nodes[0], false() )
     $show_link = true()}

{if and( $valid_node|not(), is_set( $block.custom_attributes.source ) )}
    {set $valid_node = fetch( content, node, hash( node_id, $block.custom_attributes.source ) )}
{/if}

{if $valid_node|not()}
    {set $valid_node = fetch( content, node, hash( node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ) )
         $show_link = false()}
{/if}

{if is_set($link_top_title)|not()}
    {def $link_top_title = $show_link}
{/if}

{def $calendarData = fetch( openpa, calendario_eventi, hash( 'calendar', $valid_node, 'params', hash( 'interval', 'P30D' ) ) )}

{set_defaults(hash('show_title', true(), 'items_per_row', 1))}
{if count($calendarData.events)|gt(0)}
<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_link, $show_title, $block.name|ne('') )}
        {include uri='design:parts/block_name.tpl'}
    {/if}
    <div class="openpa-widget-content">
        {if count($calendarData.events)|gt(0)}
        <div class="carousel-top-control openpa-panels-container {$block.view}">
            {include uri='design:calendar/carousel.tpl'
                    css_id=$block.id
                    items=$calendarData.events
                    root_node=$valid_node
                    i_view=card
                    view_variation='big'
                    autoplay=0
                    image_class=squaremedium
                    auto_height=true()
					top_pagination_position=true()
                    items_per_row=$items_per_row}
        </div>
      {else}
        <div class="Alert Alert--info Alert--withIcon u-padding-r-bottom u-padding-r-right u-margin-r-bottom" role="alert">
          <h4 class="u-text-h4">
            Non ci sono eventi in programma.
          </h4>
        </div>
      {/if}
    </div>
    {if and( $link_top_title|not(), $calendarData.events|gt(0) )}
        <div class="row mt-2">
            <div class="col text-center">
                <a class="btn btn-primary" href="{$valid_node.url_alias|ezurl(no)}">
                    {'Go to calendar'|i18n('openpa_designitalia')}
                </a>
            </div>
        </div>
    {/if}
</div>
{else}
    {editor_warning("Nessuno evento trovato per il prossimo mese")}
{/if}
{unset_defaults(array('show_title','items_per_row'))}
