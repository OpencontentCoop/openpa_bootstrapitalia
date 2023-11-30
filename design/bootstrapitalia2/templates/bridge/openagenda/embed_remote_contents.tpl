{if $openpa.content_tag_menu.current_view_tag|not()}
    {def $openagenda_next_events = openagenda_next_events($node.object)}
    {if $openagenda_next_events.is_enabled}
        {def $next_event_block = page_block(
            $openagenda_next_events.view.block_name,
            $openagenda_next_events.view.block_type,
            $openagenda_next_events.view.block_view,
            $openagenda_next_events.view.parameters
        )}
        {include uri='design:zone/default.tpl' zones=array(hash('blocks', array($next_event_block)))}
        {undef $next_event_block}
    {/if}
    {undef $openagenda_next_events}
{/if}