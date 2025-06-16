{set_defaults(hash('image_class', 'imagelargeoverlay', 'view_variation', ''))}
<div class="it-grid-item-wrapper it-grid-item-overlay {$node|access_style}">
    <a data-element="{$openpa.data_element.value|wash()}" class="" title="{$node.name|wash()}" {if $view_variation|eq('gallery')}data-gallery href={$openpa.event_link.image.url}{else}href="{$openpa.content_link.full_link}"{/if}>
        <div class="img-responsive-wrapper bg-dark">
            <div class="img-responsive">
                <div class="img-wrapper">
                    {if $node|has_attribute('time_interval')}
                        {def $attribute_content = $node|attribute('time_interval').content}
                        {def $events = $attribute_content.events}
                        {def $is_recurrence = cond(count($events)|gt(1), true(), false())}
                        {if recurrences_strtotime($attribute_content.input.startDateTime)|datetime( 'custom', '%j%m%Y' )|ne(recurrences_strtotime($attribute_content.input.endDateTime)|datetime( 'custom', '%j%m%Y' ))}
                            {set $is_recurrence = true()}
                        {/if}
                        {if count($events)|gt(0)}
                            <div class="card no-after position-absolute h-100" style="background: none !important">
                                <div class="card-calendar d-flex flex-column justify-content-center">
                                    <span class="card-date">{if $is_recurrence}<small>{'from'|i18n('openpa/search')}</small> {/if}{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j' )}</span>
                                    <span class="card-day">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%F' )}</span>
                                    {if openpaini('ViewSettings', 'ShowYearInEventCard')|eq('enabled')}
                                        <span class="card-year">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%Y' )}</span>
                                    {/if}
                                </div>
                            </div>
                        {/if}
                        {undef $events $is_recurrence $attribute_content}
                    {/if}

                    {if $openpa.event_link.image}
                        <img class="img-fluid" src="{$openpa.event_link.image.url}" alt="{$node.name|wash()}" loading="lazy" />
                    {elseif $node|has_attribute('image')}
                        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
                    {else}
                        <div class="bg-dark" style="width:{rand(300,400)}px;height:{rand(300,400)}px"></div>
                    {/if}
                </div>
            </div>
        </div>
        <span class="it-griditem-text-wrapper">
            <h3 class="oc-card-title-clamp">{$node.name|wash()}</h3>
      </span>
    </a>
    {if and($view_variation|eq('gallery'), $node.can_edit)}
        <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$node.url_alias|ezurl(no)}">
            <span class="fa-stack">
              <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
              <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
            </span>
        </a>
    {elseif and($openpa.content_link.is_node_link|not(), $node.can_edit)}
        <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$node.url_alias|ezurl(no)}">
            <span class="fa-stack">
              <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
              <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
            </span>
        </a>
    {/if}
</div>
{unset_defaults(array('image_class', 'view_variation'))}
