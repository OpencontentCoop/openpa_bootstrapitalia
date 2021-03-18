{if $has_media}
    <div class="img-responsive-wrapper">
        <div class="img-responsive{if $view_variation|eq('big')} img-responsive-panoramic{/if}">
            <div class="img-wrapper">
                {if and(is_set($oembed), is_array($oembed))}
                    {$oembed.html}
                {elseif $node|has_attribute('image')}
                    {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class href=$openpa.content_link.full_link alt_text=$node.name}
                {/if}
            </div>
            {if $node|has_attribute('time_interval')}
                {def $events = $node|attribute('time_interval').content.events}
                {def $is_recurrence = cond(count($events)|gt(1), true(), false())}
                {if count($events)|gt(0)}
                <div class="card-calendar d-flex flex-column justify-content-center">
                    <span class="card-date">{if $is_recurrence}<small>dal</small> {/if}{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j' )}</span>
                    <span class="card-day">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%F' )}</span>
                </div>
                {/if}
                {undef $events $is_recurrence}
            {/if}
        </div>        
    </div>
{/if}