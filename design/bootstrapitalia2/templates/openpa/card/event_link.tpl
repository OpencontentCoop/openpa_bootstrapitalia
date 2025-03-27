{set_defaults(hash('show_icon', false(), 'image_class', 'imagelargeoverlay', 'view_variation', ''))}

{if class_extra_parameters($node.object.class_identifier, 'line_view').show|contains('show_icon')}
    {set $show_icon = true()}
{/if}

{def $has_image = false()}
{if $openpa.event_link.image}
    {set $has_image = true()}
{/if}
{def $has_video = false()}

{def $has_media = false()}
{if or($has_image, $has_video)}
    {set $has_media = true()}
{/if}

{include uri='design:openpa/card/parts/card_wrapper_open.tpl'}

    {if $has_media}
      <div class="img-responsive-wrapper">
        <div class="img-responsive img-responsive-panoramic">
          <figure class="img-wrapper">
            <img class="img-fluid" src="{$openpa.event_link.image.url}" alt="{$node.name|wash()}" />
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
                <span class="card-date">{if $is_recurrence}<small>{'from'|i18n('openpa/search')}</small> {/if}{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j' )}</span>
                <span class="card-day">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%F' )}</span>
                {if openpaini('ViewSettings', 'ShowYearInEventCard')|eq('enabled')}
                  <span class="card-year">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%Y' )}</span>
                {/if}
              </div>
            {/if}
            {undef $events $is_recurrence $attribute_content}
          {/if}
        </div>
      </div>
    {/if}

    <div class="">
      <div class="card-body pb-5">
        {include uri='design:openpa/card/parts/category.tpl'}
        {include uri='design:openpa/card/parts/card_title.tpl'}
        {include uri='design:openpa/card/parts/abstract.tpl'}
      </div>
    </div>

{include uri='design:openpa/card/parts/card_wrapper_close.tpl'}

{undef $has_image $has_video}

{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}
