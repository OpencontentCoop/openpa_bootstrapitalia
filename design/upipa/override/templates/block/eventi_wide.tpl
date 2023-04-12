{set_defaults(hash('show_title', true(), 'link_top_title', true()))}

{def $valid_node = cond( is_set( $block.valid_nodes[0] ), $block.valid_nodes[0], false() )
     $show_link = true()}

{if and( $valid_node|not(), is_set( $block.custom_attributes.source ) )}
    {set $valid_node = fetch( content, node, hash( node_id, $block.custom_attributes.source ) )}
{/if}

{if $valid_node|not()}
    {set $valid_node = fetch( content, node, hash( node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ) )
    $show_link = false()}
{/if}

{def $calendarDataDay = fetch( openpa, calendario_eventi, hash( 'calendar', $valid_node, 'params', hash( 'interval', 'PT1439M' ) ) )}
{if and(is_set($block.custom_attributes.tab_title),$block.custom_attributes.tab_title|ne(''))}
    {def $calendarDataOther = fetch( openpa, calendario_eventi, hash( 'calendar', $valid_node, 'params', $block.custom_attributes ) )}
{else}
    {def $calendarDataOther = false()}
{/if}
{*debug-log var=$calendarDataDay.fetch_parameters msg='Blocco eventi fetch oggi'*}

{def $day_events = $calendarDataDay.events
     $day_events_count = $calendarDataDay.search_count
     $prossimi = array()
     $prossimi_count = 0}

{if $calendarDataOther}
    {*debug-log var=$calendarDataOther.fetch_parameters msg='Blocco eventi fetch secondo tab'*}
    {set $prossimi = $calendarDataOther.events
         $prossimi_count = $calendarDataOther.search_count}
{/if}

{if and( $prossimi_count|eq(0), $day_events_count|eq(0) )}

    {if fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'editor_tools' ) )}
        {editor_warning( "Nessun evento in programma" )}
    {/if}

{else}

    <div id="{$block.id}" class="openpa-widget {$block.view} color">

      <div class="events_wide_wrapper">
          <div class="row">

              <div class="col col-md-6">
              {include uri='design:parts/block_name.tpl'}
              </div>

              <div class="col col-md-6">
                  {if and( $day_events_count|gt(0), $prossimi_count|gt(0) )}
                      <ul role="tablist" class="nav nav-tabs float-right border-0">
                          {if $day_events_count|ne(0)}
                              <li class="nav-item eventi-oggi">
                                  <a class="nav-link" href="#oggi" data-toggle="tab">
                                      <i class="fa fa-clock-o mr-2"></i> Oggi
                                  </a>
                              </li>
                          {/if}
                          {if $prossimi_count|gt(0)}
                              <li class="nav-item eventi-futuri eventi-{$block.custom_attributes.tab_title|slugize}">
                                  <a class="nav-link"  href="#{$block.custom_attributes.tab_title|slugize}" data-toggle="tab">
                                      <i class="fa fa-calendar-o  mr-2"></i> {$block.custom_attributes.tab_title}
                                  </a>
                              </li>
                          {/if}

                          {if $show_link}
                              <li class="nav-item  jump-to-calendar">
                                  <a class="nav-link"  href="{$valid_node.url_alias|ezurl(no)}" title="{'Go to calendar'|i18n('openpa_designitalia')}">
                                      <i class="fa fa-calendar"></i> Tutti
                                  </a>
                              </li>
                          {/if}
                      </ul>
                  {/if}
              </div>
          </div>
      </div>

      <div class="events_wide_tabs_wrapper mt-3">
        {if $day_events_count|ne(0)}
            <div class="openpa-widget-content u-layout-centerContent u-cf" id="oggi">
                <section class="row">
                    {foreach $day_events as $i => $child max 10}
                    <div class="col col-md-4">
                        {node_view_gui content_node=$child.node view=card image_class=agid_panel view_variation=big show_image=false() event=$child}
                    </div>
                    {/foreach}
                </section>
            </div>
        {/if}

        {if $prossimi_count|gt(0)}
            <div id="{$block.custom_attributes.tab_title|slugize}" class="lista_masonry openpa-widget-content u-layout-centerContent u-cf">
                <section class="row">
                    {foreach $prossimi as $i => $child max 10}
                    <div class="col col-md-4">
                        {node_view_gui content_node=$child.node view=card view_variation=big image_class=agid_panel show_image=false() event=$child}
                    </div>
                    {/foreach}
                </section>
            </div>
        {/if}
      </div>
    </div>

    <script>
        {literal}
        $(document).ready(function() {
            $("#{/literal}{$block.id}{literal}").tabs({
                collapsible: true,
                beforeActivate: function( event, ui ) {
                    if (ui.newTab.hasClass('jump-to-calendar')){
                        window.location.href = ui.newTab.find('a').attr('href');
                        return false;
                    }
                }
            });
        });
        {/literal}
    </script>



{/if}

