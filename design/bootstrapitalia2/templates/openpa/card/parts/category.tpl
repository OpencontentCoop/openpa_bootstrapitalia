{def $show_date = cond(and(class_extra_parameters($node.object.class_identifier, 'table_view').show|contains('content_show_published'), $node.object.published|gt(0)), true(), false())}
{if $show_icon}
    {if $openpa.content_icon.context_icon}
        <div class="category-top cmp-list-card-img__body">
            <a class="text-decoration-none fw-bold cmp-list-card-img__body-heading-title" href="{$openpa.content_icon.context_icon.node.url_alias|ezurl(no)}">
                {display_icon($openpa.content_icon.context_icon.icon_text, 'svg', 'icon icon-sm', $openpa.content_icon.context_icon.node.name)}
                {include uri='design:openpa/card/parts/icon_label.tpl' fallback=$openpa.content_icon.context_icon.node.name|wash()}
            </a>
            {if $show_date}
                <span class="data fw-normal">{$node.object.published|l10n( 'shortdate' )}</span>
            {/if}
        </div>
    {elseif $openpa.content_icon.class_icon}
        <div class="category-top cmp-list-card-img__body">
            <a class="text-decoration-none fw-bold cmp-list-card-img__body-heading-title" href="{concat('content/search?Class[]=', $node.object.contentclass_id)|ezurl(no)}">
                {display_icon($openpa.content_icon.class_icon.icon_text, 'svg', 'icon icon-sm', $node.class_name|wash())}
                {include uri='design:openpa/card/parts/icon_label.tpl' fallback=$node.class_name}
            </a>
        </div>
    {/if}
{elseif $show_date}
    <div class="category-top cmp-list-card-img__body">
        <span class="data">
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
{/if}
{undef $show_date}