{set_defaults(hash('show_icon', false(), 'image_class', 'large', 'view_variation', ''))}

{if class_extra_parameters($node.object.class_identifier, 'line_view').show|contains('show_icon')}
    {set $show_icon = true()}
{/if}

{def $has_image = false()}
{if $openpa.event_link.image}
    {set $has_image = true()}
    {break}
{/if}
{def $has_video = false()}

{def $has_media = false()}
{if or($has_image, $has_video)}
    {set $has_media = true()}
{/if}

{include uri='design:openpa/card/parts/card_wrapper_open.tpl'}

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
                    <span class="card-date">{if $is_recurrence}<small>{'from'|i18n('openpa/search')}</small> {/if}{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j' )}</span>
                    <span class="card-day">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%F' )}</span>
                </div>
            {/if}
            {undef $events $is_recurrence $attribute_content}
        {/if}
        <img class="img-fluid rounded-top img-fluid img-responsive" src="{$openpa.event_link.image.url}" alt="{$node.name|wash()}" />
    </div>

    <div class="col-{if $has_media}8{else}12{/if} order-1 order-md-2">
        <div class="card-body pb-5">

                {include uri='design:openpa/card/parts/category.tpl'}

                {include uri='design:openpa/card/parts/card_title.tpl'}

                {include uri='design:openpa/card/parts/abstract.tpl'}

                <a class="read-more" href="{$openpa.content_link.full_link}{if $openpa.content_link.is_internal}#page-content{/if}">
                    <span class="text">{'Read more'|i18n('bootstrapitalia')}</span>
                    {display_icon('it-arrow-right', 'svg', 'icon', 'Read more'|i18n('bootstrapitalia'))}
                </a>

        </div>
    </div>

{include uri='design:openpa/card/parts/card_wrapper_close.tpl'}

{undef $has_image $has_video}

{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}
