{def $openpa = object_handler($block)}

{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}

{run-once}
{ezcss_require(array('fullcalendar/main.min.css'))}
{ezscript_require(array('fullcalendar/main.min.js','fullcalendar/locales-all.min.js', 'fullcalendar/init.js'))}
{run-once}

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

<script>
  document.addEventListener('DOMContentLoaded', function () {ldelim}
    OpenCityFullCalendarInit(
      (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/') ? UriPrefix + '/' : '/',
      '{$moment_language}',
      '{'/openpa/data/remote_calendar'|ezurl(no)}{concat('?url=',$block.custom_attributes.remote_url,'&remote=',$block.custom_attributes.api_url)}',
      'calendar-{$block.id}',
      '{$calendar_view}',
        {$max_events}
    ).render();
    window.dispatchEvent(new Event('resize'));
  {rdelim});
</script>

{include uri='design:parts/block_name.tpl' no_margin=true()}
<div class="mt-2 position-relative block-calendar-{$block.view} block-calendar block-calendar-{$size}" {if $show_facets|not()}data-query="{$query}"{/if} data-topics="{$topics_filter}">
    <div id='calendar-{$block.id}'></div>
</div>

{undef $openpa}