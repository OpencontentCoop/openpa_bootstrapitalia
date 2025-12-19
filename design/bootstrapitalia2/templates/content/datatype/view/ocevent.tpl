{set-block scope=root variable=cache_ttl}86400{/set-block}


{def $events = $attribute.content.events}

{if count($events)|gt(10)}
    <p class="text-serif">{"Event daytime text"|i18n('bootstrapitalia')} {recurrences_strtotime($events[0].start)|datetime( 'custom', '%j %F %Y' )|downcase}, {$attribute.content.text|wash()} </p>
    {set $events = recurrences_next_events($events, 5)}
    {if count($events)|gt(0)}
        <p class="text-serif">{"Next appointments"|i18n('bootstrapitalia')}</p>
    {/if}
{/if}

<div class="calendar-vertical font-sans-serif mb-4">

    {foreach $events as $event}

        {if recurrences_strtotime($event.start)|datetime( 'custom', '%j%m%Y' )|ne(recurrences_strtotime($event.end)|datetime( 'custom', '%j%m%Y' ))}

            <div class="calendar-date">
                <div class="calendar-date-day">
                    <small class="calendar-date-day__year">{recurrences_strtotime($event.start)|datetime( 'custom', '%Y' )}</small>
                    <span class="title-xxlarge-regular d-flex justify-content-center lh-1">{recurrences_strtotime($event.start)|datetime( 'custom', '%d' )}</span>
                    <small class="calendar-date-day__month text-lowercase">{recurrences_strtotime($event.start)|datetime( 'custom', '%M' )}</small>
                </div>
                <div class="calendar-date-description rounded bg-white">
                    <div class="calendar-date-description-content">
                        <h3 class="title-medium-2 mb-0">
                            {"Event start"|i18n('bootstrapitalia')} {recurrences_strtotime($event.start)|datetime( 'custom', '%H:%i' )}
                        </h3>
                    </div>
                </div>
            </div>

            <div class="calendar-date">
                <div class="calendar-date-day">
                    <small class="calendar-date-day__year">{recurrences_strtotime($event.end)|datetime( 'custom', '%Y' )}</small>
                    <span class="title-xxlarge-regular d-flex justify-content-center lh-1">{recurrences_strtotime($event.end)|datetime( 'custom', '%d' )}</span>
                    <small class="calendar-date-day__month text-lowercase">{recurrences_strtotime($event.end)|datetime( 'custom', '%M' )}</small>
                </div>
                <div class="calendar-date-description rounded bg-white">
                    <div class="calendar-date-description-content">
                        <h3 class="title-medium-2 mb-0">
                            {"Event end"|i18n('bootstrapitalia')} {recurrences_strtotime($event.end)|datetime( 'custom', '%H:%i' )}
                        </h3>
                    </div>
                </div>
            </div>

        {else}

            <div class="calendar-date">
                <div class="calendar-date-day">
                    <small class="calendar-date-day__year">{recurrences_strtotime($event.start)|datetime( 'custom', '%Y' )}</small>
                    <span class="title-xxlarge-regular d-flex justify-content-center lh-1">{recurrences_strtotime($event.start)|datetime( 'custom', '%d' )}</span>
                    <small class="calendar-date-day__month text-lowercase">{recurrences_strtotime($event.start)|datetime( 'custom', '%M' )}</small>
                </div>
                <div class="calendar-date-description rounded bg-white">
                    <div class="calendar-date-description-content">
                        <h3 class="title-medium-2 mb-0">
                            {"Event start"|i18n('bootstrapitalia')} {recurrences_strtotime($event.start)|datetime( 'custom', '%H:%i' )}
                            {if recurrences_strtotime($event.start)|datetime( 'custom', '%H:%i' )|ne(recurrences_strtotime($event.end)|datetime( 'custom', '%H:%i' ))}
                                - {"Event end"|i18n('bootstrapitalia')} {recurrences_strtotime($event.end)|datetime( 'custom', '%H:%i' )}
                            {/if}
                        </h3>
                    </div>
                </div>
            </div>

        {/if}
    {/foreach}
    {undef $events}
</div>