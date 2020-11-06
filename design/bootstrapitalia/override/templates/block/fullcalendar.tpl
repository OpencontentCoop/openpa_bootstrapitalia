{def $openpa = object_handler($block)}

{ezscript_require(array('fullcalendar/core/main.js','fullcalendar/core/locales/it.js','fullcalendar/daygrid/main.js', 'fullcalendar/list/main.js'))}
{ezcss_require(array('fullcalendar/core/main.css','fullcalendar/daygrid/main.css', 'fullcalendar/list/main.css'))}

{def $query = 'facets [class]'
$classes = array()}
{if and(is_set($block.custom_attributes.includi_classi), $block.custom_attributes.includi_classi|ne(''))}
    {set $query = concat('classes [', $block.custom_attributes.includi_classi, ']')}
    {set $classes = fetch(class, list, hash(class_filter, $block.custom_attributes.includi_classi|explode(',')))}
{/if}

{def $calendar_view = 'day_grid_4'}
{if and(is_set($block.custom_attributes.calendar_view), $block.custom_attributes.calendar_view|ne(''))}
    {set $calendar_view = $block.custom_attributes.calendar_view}
{/if}
{def $show_facets = false()}
{if and($classes|count()|gt(1), is_set($block.custom_attributes.show_facets), $block.custom_attributes.show_facets|eq(1))}
    {set $show_facets = true()}
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
{if and(is_set($block.custom_attributes.max_events), $block.custom_attributes.max_events|int()|gt(0))}
    {set $max_events = $block.custom_attributes.max_events}
{/if}

{include uri='design:parts/block_name.tpl'}
<div class="block-calendar-{$block.view} shadow block-calendar block-calendar-{$size}" {if $show_facets|not()}data-query="{$query}"{/if}>
    {if $show_facets}
        <div class="block-calendar-facets d-none d-md-block" style="position: absolute;right: 0;top: -57px;">
            <button type="button" class="btn btn-secondary btn-sm filter-select" data-block_calendar_class="{foreach $classes as $class}{$class.identifier|wash()}{delimiter},{/delimiter}{/foreach}">Tutto</button>
            {foreach $classes as $class}
            {*def $icon = class_extra_parameters($class.identifier, 'bootstrapitalia_icon').icon*}
            <button type="button" class="btn btn-outline-secondary btn-sm filter-select" data-block_calendar_class="{$class.identifier|wash()}">
                {*if $icon}{display_icon($icon, 'svg', 'icon icon-sm')}{/if*}
                {$class.name|wash()}                
            </button>
            {*undef $icon*}
            {/foreach}
        </div>
    {/if}
    <div id='calendar-{$block.id}' class="bg-white"></div>
</div>

{undef $openpa}

{run-once}
<script>
    var baseUrl = '/';
    if (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/'){ldelim}
        baseUrl = UriPrefix + '/';
    {rdelim}
    var BlockCalendarEndpoint = '{'/opendata/api/calendar/search/'|ezurl(no)}/';
    {literal}
    var BlockCalendarBaseOptions = {
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
            window.location.href = baseUrl + "openpa/object/"+info.event.id;
        },
        displayEventTime: false        
    };
    var BlockCalendarBuildQuery = function(calendarId){
        var container = $('#'+calendarId).parent();
        if (typeof container.data('query') !== 'undefined'){
            return container.data('query');
        }

        var classList = [];
        container.find('.btn-secondary[data-block_calendar_class]').each(function(){
            classList.push($(this).data('block_calendar_class'));
        });

        return 'classes [' + classList.join(',') + ']';
    };
    $('[data-block_calendar_class]').on('click', function(e){
        var self = $(this);
        var container = self.parents('.block-calendar');
        if(self.hasClass('btn-secondary')){
            self.removeClass('btn-secondary').addClass('btn-outline-secondary');    
        }else{
            container.find('.filter-select').removeClass('btn-secondary').addClass('btn-outline-secondary');
            self.addClass('btn-secondary').removeClass('btn-outline-secondary');            
        }        
        container.find('.fc').data('fullcalendar').refetchEvents();
        e.preventDefault();
    });
    {/literal}
</script>
{/run-once}
<script>
    document.addEventListener('DOMContentLoaded', function() {ldelim}
        $('#calendar-{$block.id}').data('fullcalendar', new FullCalendar.Calendar(
            document.getElementById('calendar-{$block.id}'), $.extend({ldelim}{rdelim}, BlockCalendarBaseOptions,{ldelim}
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
                {if $classes|count()|gt(1)}
                    eventRender: function(info) {ldelim}
                        $(info.el)
                            .find('.fc-content, .fc-list-item-title')
                            .html(info.event.extendedProps.type + ' - <strong>' + info.event.title + '</strong>')
                            .css('cursor', 'pointer');
                    {rdelim},
                {else}
                    eventRender: function(info) {ldelim}
                        $(info.el)
                            .find('.fc-content, .fc-list-item-title')
                            .html('<strong>' + info.event.title + '</strong>')
                            .css('cursor', 'pointer');
                    {rdelim},
                {/if}
                events: {ldelim}
                    url: BlockCalendarEndpoint,
                    extraParams: function () {ldelim}
                        return {ldelim}q: BlockCalendarBuildQuery('calendar-{$block.id}'){rdelim};
                        {rdelim}
                    {rdelim}
                {rdelim}))
        ).data('fullcalendar').render();
        window.dispatchEvent(new Event('resize'));
        {rdelim});
</script>