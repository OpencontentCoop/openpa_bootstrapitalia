{def $openpa = object_handler($block)}

{ezscript_require(array('fullcalendar/core/main.js','fullcalendar/core/locales/it.js','fullcalendar/daygrid/main.js', 'fullcalendar/list/main.js'))}
{ezcss_require(array('fullcalendar/core/main.css','fullcalendar/daygrid/main.css', 'fullcalendar/list/main.css'))}

{def $calendar_view = 'day_grid_4'}
{if and(is_set($block.custom_attributes.calendar_view), $block.custom_attributes.calendar_view|ne(''))}
    {set $calendar_view = $block.custom_attributes.calendar_view}
{/if}

{def $size_list = array(
    'small',
    'medium',
    'big',
)}
{def $size = 'small'}
{if and(is_set($block.custom_attributes.size), $size_list|contains($block.custom_attributes.size))}
    {set $size = $block.custom_attributes.size}
{/if}

{def $max_events = 6}
{if and(is_set($block.custom_attributes.max_events), $block.custom_attributes.max_events|is_integer|gt(0))}
    {set $max_events = $block.custom_attributes.max_events}
{/if}

{include uri='design:parts/block_name.tpl'}
<div class="block-calendar-{$block.view} shadow block-calendar block-calendar-{$size}">    
    <div id='calendar-{$block.id}' class="bg-white"></div>
</div>

{undef $openpa}

{run-once}
<script>    
    {literal}
    var BlockRemoteCalendarBaseOptions = {
        plugins: [ 'dayGrid', 'list' ],
        header: {
            left: 'prev,next',
            center: 'title',
            right: 'today'
        },
        height: 'parent',
        locale: 'it',
        aspectRatio: 3,
        eventLimit: false,
        columnHeaderFormat: {
            weekday: 'short',
            day: 'numeric',
            omitCommas: true
        },
        eventClick: function(info) {
            window.location.href = info.event.url;
        },
        displayEventTime: false        
    };    
    {/literal}
</script>
{/run-once}
<script>
    document.addEventListener('DOMContentLoaded', function() {ldelim}
        $('#calendar-{$block.id}').data('fullcalendar', new FullCalendar.Calendar(
            document.getElementById('calendar-{$block.id}'), $.extend({ldelim}{rdelim}, BlockRemoteCalendarBaseOptions,{ldelim}
                    {switch match=$calendar_view}
                    {case match="month"}
                        defaultView: 'dayGridMonth',
                        views: {ldelim}
                            dayGridMonth: {ldelim}
                                eventLimit: {$max_events}
                                {rdelim}
                            {rdelim},
                        windowResize: function(view) {ldelim}
                            var windowWidth = $(window).width();
                            if (windowWidth < 800) {ldelim}
                                this.changeView('listWeek');
                            {rdelim}else{ldelim}
                                this.changeView('dayGridMonth');
                            {rdelim}
                        {rdelim},
                    {/case}
                    {case match="day_grid"}
                        defaultView: 'dayGridWeek',
                        views: {ldelim}
                            dayGridWeek: {ldelim}
                                eventLimit: {$max_events}
                                {rdelim}
                            {rdelim},
                        windowResize: function(view) {ldelim}
                            var windowWidth = $(window).width();
                            if (windowWidth < 800) {ldelim}
                                this.changeView('listWeek');
                            {rdelim}else{ldelim}
                                this.changeView('dayGridWeek');
                            {rdelim}
                        {rdelim},
                    {/case}
                    {case}                        
                        defaultView: 'dayGridWeek',
                        views: {ldelim}
                            dayGridWeek: {ldelim}
                                eventLimit: {$max_events},
                                duration: {ldelim} days: {4} {rdelim}
                                {rdelim}
                            {rdelim},
                        windowResize: function(view) {ldelim}
                            var windowWidth = $(window).width();
                            if (windowWidth < 800) {ldelim}
                                this.changeView('listWeek');
                            {rdelim}else{ldelim}
                                this.changeView('dayGridWeek');
                            {rdelim}
                        {rdelim},
                    {/case}
                    {/switch}                
                eventRender: function(info) {ldelim}
                    $(info.el)
                        .find('.fc-content, .fc-list-item-title')
                        .html('<strong>' + info.event.title + '</strong>')
                        .css('cursor', 'pointer');
                {rdelim},                
                events: '/openpa/data/remote_calendar?url={$block.custom_attributes.remote_url}&remote={$block.custom_attributes.api_url}'
                {rdelim}))
        ).data('fullcalendar').render();
        window.dispatchEvent(new Event('resize'));
        {rdelim});
</script>