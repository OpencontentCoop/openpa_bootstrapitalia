{if $has_media}
    <div class="img-responsive-wrapper">
        <div class="img-responsive{if $view_variation|eq('big')} img-responsive-panoramic{/if}">
            <div class="img-wrapper">
                {if and(is_set($oembed), is_array($oembed))}
                    {if class_extra_parameters($node.object.class_identifier, 'line_view').show|contains('disable_video_player')|not()}
                        {$oembed.html}
                    {else}
                        <a class="img-fluid" style="border: 0px;" href="{$openpa.content_link.full_link}"><img src="{$oembed.thumbnail_url}" alt="{$oembed.title|wash()}" /></a>
                    {/if}
                {elseif $node|has_attribute('image')}
                    {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class link_class='w-100' href=$openpa.content_link.full_link alt_text=$node.name}
                {/if}
            </div>
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
        </div>        
    </div>
{/if}
