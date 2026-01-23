{set_defaults(hash(
    'show_icon', false(),
    'show_category', true(),
    'image_class', 'medium',
    'custom_css_class', '',
    'view_variation', '',
    'hide_title', false()
))}

{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}
{def $has_image = false()}
{if or($openpa.event_link.image, $node|has_attribute('image'))}
    {set $has_image = true()}
{/if}
<div data-object_id="{$node.contentobject_id}"
     class="font-sans-serif card card-teaser{if $has_image} card-teaser-image card-flex{/if} no-after rounded shadow-sm mb-0 border border-light {$node|access_style} {$custom_css_class}">
    {if $has_image}
    <div class="card-image-wrapper{if $attributes.show|contains('content_show_read_more')} with-read-more{/if}">
    {/if}
        <div class="card-body {if $has_image}p-3 {/if}pb-5 {$view_variation}">
        <div class="category-top">
            <span>
                {if $node|has_attribute('time_interval')}
                    {def $attribute_content = $node|attribute('time_interval').content}
                    {def $events = $attribute_content.events}
                    {if recurrences_strtotime($attribute_content.input.startDateTime)|datetime( 'custom', '%j%m%Y' )|ne(recurrences_strtotime($attribute_content.input.endDateTime)|datetime( 'custom', '%j%m%Y' ))}
                        {set $is_recurrence = true()}
                    {/if}
                    {def $is_recurrence = cond(count($events)|gt(1), true(), false())}
                    {if $is_recurrence}{'from'|i18n('openpa/search')} {/if}{recurrences_strtotime($events[0].start)|l10n( 'date' )}
                    {undef $events $is_recurrence $attribute_content}
                {else}
                    {$node.object.published|l10n( 'date' )}
                {/if}
            </span>
        </div>
        {if $hide_title|not()}
        <h3 class="card-title h4 u-grey-light">
            {include uri='design:openpa/card_teaser/parts/card_title.tpl'}
        </h3>
        {/if}

        <div class="text-paragraph-card u-grey-light m-0">
            {include uri='design:openpa/card_teaser/parts/attributes.tpl'}
        </div>
    </div>
    {if $has_image}
        <div class="card-image card-image-rounded pb-5">
            {if $openpa.event_link.image}
                <img class="img-fluid img-responsive" src="{$openpa.event_link.image.url}" alt="{$node.name|wash()}" />
            {else}
                {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class context='card_teaser'}
            {/if}
        </div>
    </div>
    {/if}
    {if or($attributes.show|contains('content_show_read_more'), $attributes.enabled|not())}
        <a data-element="{$openpa.data_element.value|wash()}" class="read-more{if $has_image} ps-3 position-absolute bottom-0 mb-3{/if}" href="{$openpa.content_link.full_link}" title="{'Go to content'|i18n('bootstrapitalia')} {$node.name|wash()}">
            <span class="text">{'Further details'|i18n('bootstrapitalia')}</span>
            {display_icon('it-arrow-right', 'svg', 'icon ms-0')}
        </a>
    {/if}
</div>
{undef $attributes $has_image}
{unset_defaults(array('show_icon', 'image_class', 'view_variation', 'hide_title'))}