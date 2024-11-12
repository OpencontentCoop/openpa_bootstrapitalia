{if $has_media}
    <div class="img-responsive-wrapper">
        <div class="img-responsive img-responsive-panoramic">
            <figure class="img-wrapper">
                {if and(is_set($oembed), is_array($oembed))}
                    <img class="rounded-top img-fluid img-responsive" src="{$oembed.thumbnail_url}"
                         alt="{$oembed.title|wash()}"/>
                {elseif $node|has_attribute('image')}
                    {def $image = $node|attribute('image')}
                    {attribute_view_gui image_css_class=image_class_and_style($image.content.original.width, $image.content.original.height, 'card').css_class
                                        inline_style= image_class_and_style($image.content.original.width, $image.content.original.height, 'card').inline_style
                                        attribute=$image
                                        image_class=$image_class
                                        context='card'
                                        alt_text=$node.name}
                    {undef $image}
                {/if}
            </figure>
            {if $node|has_attribute('time_interval')}
                {def $attribute_content = $node|attribute('time_interval').content}
                {def $events = $attribute_content.events}
                {def $is_recurrence = cond(count($events)|gt(1), true(), false())}
                {if recurrences_strtotime($attribute_content.input.startDateTime)|datetime( 'custom', '%j%m%Y' )|ne(recurrences_strtotime($attribute_content.input.endDateTime)|datetime( 'custom', '%j%m%Y' ))}
                    {set $is_recurrence = true()}
                {/if}
                {if count($events)|gt(0)}
                    <div class="card-calendar d-flex flex-column justify-content-center">
                        <span class="card-date">{if $is_recurrence}
                                <small>{'from'|i18n('openpa/search')}</small> {/if}{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j' )}</span>
                        <span class="card-day">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%F' )}</span>
                    </div>
                {/if}
                {undef $events $is_recurrence $attribute_content}
            {/if}
        </div>
    </div>
{/if}
