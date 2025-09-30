{if $has_media}
    <div class="col-4 order-2 order-md-1 position-relative">

        {if $node|has_attribute('time_interval')}
            {def $attribute_content = $node|attribute('time_interval').content}
            {def $events = $attribute_content.events}
            {def $is_recurrence = cond(count($events)|gt(1), true(), false())}
            {if recurrences_strtotime($attribute_content.input.startDateTime)|datetime( 'custom', '%j%m%Y' )|ne(recurrences_strtotime($attribute_content.input.endDateTime)|datetime( 'custom', '%j%m%Y' ))}
                {set $is_recurrence = true()}
            {/if}
            {if count($events)|gt(0)}
                <div class="card-calendar d-flex flex-column justify-content-center">
                    <span class="card-date">{if $is_recurrence}<small>{'from day'|i18n('bootstrapitalia')}</small> {/if}{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j' )}</span>
                    <span class="card-day">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%F' )}</span>
                    {if openpaini('ViewSettings', 'ShowYearInEventCard')|eq('enabled')}
                      <span class="card-year">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%Y' )}</span>
                    {/if}
                </div>
            {/if}
            {undef $events $is_recurrence $attribute_content}
        {/if}

        {if and(is_set($oembed), is_array($oembed))}
            {if class_extra_parameters($node.object.class_identifier, 'line_view').show|contains('disable_video_player')|not()}
                {$oembed.html}
            {else}
                <img class="rounded-top img-fluid img-responsive" src="{$oembed.thumbnail_url}" alt="{$oembed.title|wash()}" loading="lazy" />
            {/if}
        {elseif $node|has_attribute('image')}
            {def $image = $node|attribute('image')}
            {attribute_view_gui image_css_class=concat("rounded-top img-fluid img-responsive ", image_class_and_style($image.content.original.width, $image.content.original.height, 'card').css_class)
                                inline_style= image_class_and_style($image.content.original.width, $image.content.original.height, 'card').inline_style
                                attribute=$image
                                image_class=$image_class
                                context='card'
                                alt_text=$node.name}
            {undef $image}
        {/if}

    </div>
{/if}
