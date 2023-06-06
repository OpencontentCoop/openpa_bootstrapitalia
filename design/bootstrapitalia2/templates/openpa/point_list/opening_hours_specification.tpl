{def $valid_date_attribute = cond($node|has_attribute('valid_through'), $node|attribute('valid_through'), $node|attribute('valid_from'))}
<div class="calendar-date">
    <div class="calendar-date-day">
        <small class="calendar-date-day__year">{$valid_date_attribute.content.timestamp|datetime( 'custom', '%Y' )}</small>
        <span class="title-xxlarge-regular d-flex justify-content-center">{$valid_date_attribute.content.timestamp|datetime( 'custom', '%d' )}</span>
        <small class="calendar-date-day__month text-lowercase">{$valid_date_attribute.content.timestamp|datetime( 'custom', '%M' )}</small>
    </div>
    <div class="calendar-date-description rounded bg-white">
        <div class="calendar-date-description-content">
            {def $has_attribute_opening_hours = cond(and($node|has_attribute('opening_hours'), $node|attribute('opening_hours')|is_empty_matrix|not), true(), false())}
            {def $has_attribute_closure = cond(and($node|has_attribute('closure'), $node|attribute('closure')|is_empty_matrix|not), true(), false())}

            <h3 class="title-medium-2 mb-0">
                {if or($has_attribute_opening_hours, $has_attribute_closure, $node|has_attribute('note'))}
                    <a class="float-right" style="margin-top: -3px;" data-toggle="collapse" data-bs-toggle="collapse" href="#collapse-{$node.contentobject_id}" role="button" aria-expanded="false" aria-controls="collapse-{$node.contentobject_id}">
                        {display_icon('it-info-circle', 'svg', 'icon icon-sm card-icon-color-primary')}
                    </a>
                {/if}
                {attribute_view_gui attribute=$node|attribute('name')}
                {if $node|has_attribute('valid_through')}
                    <small class="d-block">
                        {$node|attribute('valid_from').content.timestamp|l10n('shortdate')}
                        &#8674;
                        {$node|attribute('valid_through').content.timestamp|l10n('shortdate')}
                    </small>
                {/if}
            </h3>
            {if or($has_attribute_opening_hours, $has_attribute_closure, $node|has_attribute('note'))}
                <div class="collapse pt-2" id="collapse-{$node.contentobject_id}">
                    {if $has_attribute_opening_hours}
                        <strong class="m-0">{$node|attribute('opening_hours').contentclass_attribute_name|wash()}</strong>
                        {attribute_view_gui attribute=$node|attribute('opening_hours')}
                    {/if}
                    {if $has_attribute_closure}
                        <strong class="m-0">{$node|attribute('closure').contentclass_attribute_name|wash()}</strong>
                        {attribute_view_gui attribute=$node|attribute('closure')}
                    {/if}
                    {if $node|has_attribute('note')}
                        <strong class="m-0">{$node|attribute('note').contentclass_attribute_name|wash()}</strong>
                        {attribute_view_gui attribute=$node|attribute('note')}
                    {/if}
                </div>
            {/if}
            {undef $has_attribute_opening_hours $has_attribute_closure}
        </div>
    </div>
</div>
{undef $valid_date_attribute}