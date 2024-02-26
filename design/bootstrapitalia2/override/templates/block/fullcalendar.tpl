{def $openpa = object_handler($block)}
{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}

{def $query = 'facets [class]'
     $classes = array()}
{if and(is_set($block.custom_attributes.includi_classi), $block.custom_attributes.includi_classi|ne(''))}
    {set $query = concat('classes [', $block.custom_attributes.includi_classi, ']')}
    {set $classes = fetch(class, list, hash(class_filter, $block.custom_attributes.includi_classi|explode(',')))}
{/if}
{if and(is_set($block.custom_attributes.tag_id), $block.custom_attributes.tag_id|ne(''))}
    {set $query = concat($query, ' and raw[ezf_df_tag_ids] in [', $block.custom_attributes.tag_id, '] ')}
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
{def $topics_filter = cond(and(is_set($block.custom_attributes.topic_node_id), $block.custom_attributes.topic_node_id|ne('')), $block.custom_attributes.topic_node_id|wash(), false())}
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
{run-once}
{ezcss_require(array('fullcalendar/main.min.css'))}
{ezscript_require(array('fullcalendar/main.min.js','fullcalendar/locales-all.min.js', 'fullcalendar/init.js'))}
{run-once}
<script>
document.addEventListener('DOMContentLoaded', function () {ldelim}
    OpenCityFullCalendarInit(
        (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/') ? UriPrefix + '/' : '/',
        '{$moment_language}',
        '{'/opendata/api/calendar/search/'|ezurl(no)}/',
        'calendar-{$block.id}',
        '{$calendar_view}',
        {$max_events}
    ).render();
    window.dispatchEvent(new Event('resize'));
{rdelim});
</script>

{include uri='design:parts/block_name.tpl' no_margin=true()}
<div class="mt-2 position-relative block-calendar-{$block.view} block-calendar block-calendar-{$size}" {if $show_facets|not()}data-query="{$query}"{/if} data-topics="{$topics_filter}">
    {if $show_facets}
        <div class="block-calendar-facets d-none d-md-block" style="position: absolute;right: 0;top: -57px;">
            <button type="button"
                    title="{'All'|i18n('design/standard/ezoe')}"
                    class="btn btn-secondary btn-xs filter-select" data-block_calendar_class="{foreach $classes as $class}{$class.identifier|wash()}{delimiter},{/delimiter}{/foreach}">{'All'|i18n('design/standard/ezoe')}</button>
            {foreach $classes as $class}
            {*def $icon = class_extra_parameters($class.identifier, 'bootstrapitalia_icon').icon*}
            <button type="button" class="btn btn-outline-secondary btn-xs filter-select" data-block_calendar_class="{$class.identifier|wash()}">
                {*if $icon}{display_icon($icon, 'svg', 'icon icon-sm')}{/if*}
                {$class.name|wash()}
            </button>
            {*undef $icon*}
            {/foreach}
        </div>
    {/if}
    <div id='calendar-{$block.id}'></div>
</div>

{undef $openpa}
