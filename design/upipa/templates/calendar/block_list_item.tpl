{if is_set( $item.from )}
    {def $month = $item.from|datetime( 'custom', '%M' )
         $day = $item.from|datetime( 'custom', '%j' )
         $sameDay = cond($item.to|sub($item.from)|le(86400), true(), false())
         $__node = $item.node}
{else}
    {def $month = $item.data_map.from_time.content.timestamp|datetime( 'custom', '%M' )
         $day = $item.data_map.from_time.content.timestamp|datetime( 'custom', '%j' )
         $sameDay = cond($item.data_map.to_time.content.timestamp|sub($item.data_map.from_time.content.timestamp)|le(86400), true(), false())
         $__node = $item}
{/if}

<div class="row event-item">
    <div class="col-xs-4 col-md-1 calendar-date">
        <span class="month">{$month}</span>
        <span class="day">{if $sameDay|not()}<small>dal </small>{/if}{$day}</span>
    </div>
    <div class="col-xs-8 col-md-11">
        {node_view_gui content_node=$__node view=text_linked shorten=80}
    </div>
</div>

{undef $month $day $__node $sameDay}
