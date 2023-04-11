{ezscript_require(array( 'ezjsc::jquery' ) )}
<script type="text/javascript">
{literal}
$(document).ready(function() {
    if (location.hash === '') {
        var today = $("#today");
        if (today.length > 0) $("html, body").animate({ scrollTop: today.offset().top });
    }
    $(".calendar_picker").datepicker({
      defaultDate: "+1w",
      changeMonth: true,
      changeYear: true,
      dateFormat: "dd-mm-yy",
      numberOfMonths: 1
    });
});
{/literal}
</script>

{def $currentInterval = 'P1M'
     $calendarData = fetch( openpa, calendario_eventi, hash( 'calendar', $node, 'params', $view_parameters|merge( hash( 'interval', 'P1M', 'view', 'calendar' ) ) ) )}

<form class="calendar-tools form-inline" method='GET' action={concat('openpa/calendar/', $node.node_id)|ezurl}>
    <input type='hidden' name="UrlAlias" value="{$node.url_alias}" />
    <input type='hidden' name="View" value="program" />
    <input type='hidden' name="CurrentInterval" value="{$calendarData.parameters.interval}" />
    <input type="hidden" name="SearchDate" value="{$calendarData.parameters.picker_date}" />

    <div class="navigation-calendar pull-right">
        <div class="btn-group">
            <input type="submit" name="PrevMonthCalendarButton" class="btn btn-default" value="&laquo;" />
            <input type="submit" name="ViewCalendarButton" class="btn btn-default" value="Calendario" />
            <input type="submit" name="ViewProgramButton" class="btn btn-primary" value="Lista" />
            <input type="submit" name="NextMonthCalendarButton" class="btn btn-default " value="&raquo;" />
        </div>
    </div>    
    
    <h1>{$calendarData.parameters.timestamp|datetime( custom, '%F' )|upfirst()}&nbsp;{$calendarData.parameters.timestamp|datetime( custom, '%Y' )}</h1>
    
    <div class="well well-sm calendar-tools">            
      <label class="hide" for="calendar_query">Cerca nel testo</label>
      <input id="calendar_query"  class="query form-control" placeholder="Cerca tra gli eventi" type="text" name="Query" value="{$calendarData.parameters.query|wash()}" />
      
      <label class="hide" for="calendar_picker">Seleziona data</label>
      <input id="calendar_picker" class="calendar_picker form-control" placeholder="gg-mm-yyyy" type="text" name="SearchDate" title="Seleziona data" value="{$calendarData.parameters.picker_date|wash()}" />
      
      {foreach $calendarData.search_facets as $facetFieldName => $facets}
          {if count($facets)|gt(0)}
          <label class="hide" for="calendar_facet">Cerca {$facetFieldName}</label>
          <select name="{$facetFieldName}" class="form-control" id="calendar_facet">
              <option value="">{$facetFieldName}</option>
              {foreach $facets as $styleAndName}                
                  <option value="{$styleAndName.value|wash()}"{if $calendarData.parameters[$facetFieldName]|eq($styleAndName.value)} selected="selected"{/if}>{if $styleAndName.indent}&nbsp;&nbsp;&nbsp;{/if}{$styleAndName.name|wash()}</option>
              {/foreach}            
          </select>
          {/if}
      {/foreach}
      
      {if and( count($calendarData.search_facets)|eq(0), is_set( $view_parameters.Manifestazione ) )}
          <label class="hide" for="calendar_facet">Cerca Manifestazione</label>
          <select name="Manifestazione" class="form-control" id="calendar_facet">
              <option value="">Manifestazione</option>
              <option value="{$view_parameters.Manifestazione|wash()}" selected="selected">{$view_parameters.Manifestazione|wash()}</option>              
          </select>
      {/if}
      
      <button class="defaultbutton" type="submit" name="SearchButton" title="Cerca"><i class="fa fa-search"></i></button>
      <button class="button" type="submit" name="TodayButton" title="Azzera la ricerca"><i class="fa fa-close"></i></button>
    </div>
    
    <hr />
    {def $col-width=6 $modulo=2}
    {foreach $calendarData.day_by_day as $calendarDay}
        {if $calendarDay.count|gt(0)}

          <div class="calendar-day-program float-break row events" id="day-{$calendarDay.identifier}">

            <div class="calendar-date col-xs-4 col-sm-3 col-md-2"{if $calendarDay.is_today} id="today"{/if}>
              <span class="month">{$calendarDay.start|datetime( 'custom', '%M' )}</span>
              <span class="day">{$calendarDay.start|datetime( 'custom', '%j' )}</span>
            </div>
            
                <!--<h3 class="widget_title">
                    {if $calendarDay.is_today}Oggi - {$calendarDay.start|l10n( 'date' )}
                    {elseif $calendarDay.is_tomorrow}Domani - {$calendarDay.start|l10n( 'date' )}
                    {elseif and( $calendarDay.is_in_week, $calendarDay.is_in_month )}{*$calendarDay.start|datetime( 'custom', '%l' )*}{$calendarDay.start|l10n( 'date' )}
                    {else}{$calendarDay.start|l10n( 'date' )}
                    {/if}
                </h3>-->
              
              <div class="calendar-date col-xs-8 col-sm-9 col-md-10">
                <div class="row panels-container">                  
                  {foreach $calendarDay.events as $event}
                    <div class="col-md-{$col-width}">
                      {node_view_gui view=panel content_node=$event.node image_class=small is_program=true()}
                    </div>
                    {delimiter modulo=$modulo}</div><div class="row panels-container">{/delimiter}
                  {/foreach}
                </div>
              </div>

            </div>
          <hr />
        {/if}        
    {/foreach}

    {*<div class="calendar-more">
        <input type="submit" name="AddIntervalButton" class="defaultbutton pull-right" value="Mostra altri eventi" />
    </div>*}

</form>