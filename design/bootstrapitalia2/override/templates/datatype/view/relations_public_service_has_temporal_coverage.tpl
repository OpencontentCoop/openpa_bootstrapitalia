{def $node_list = array()}
{if $attribute.has_content}
    {foreach $attribute.content.relation_list as $relation_item}
        {if $relation_item.in_trash|not()}
            {def $content_object = fetch( content, object, hash( object_id, $relation_item.contentobject_id ) )}
            {if $content_object.can_read}
                {set $node_list = $node_list|append($content_object.main_node)}
            {/if}
            {undef $content_object}
        {/if}
    {/foreach}
{/if}

{if count($node_list)|gt(0)}
<div class="calendar-vertical mb-3 font-sans-serif">
    {foreach $node_list as $child }
    {def $valid_date_attribute = cond($child|has_attribute('valid_through'), $child|attribute('valid_through'), $child|attribute('valid_from'))}
    <div class="calendar-date">
        <div class="calendar-date-day">
            <small class="calendar-date-day__year">{$valid_date_attribute.content.timestamp|datetime( 'custom', '%Y' )}</small>
            <span class="title-xxlarge-regular d-flex justify-content-center">{$valid_date_attribute.content.timestamp|datetime( 'custom', '%d' )}</span>
            <small class="calendar-date-day__month text-lowercase">{$valid_date_attribute.content.timestamp|datetime( 'custom', '%M' )}</small>
        </div>
        <div class="calendar-date-description rounded bg-white">
            <div class="calendar-date-description-content">
                {def $has_attribute_opening_hours = cond(and($child|has_attribute('opening_hours'), $child|attribute('opening_hours')|is_empty_matrix|not), true(), false())}
                {def $has_attribute_closure = cond(and($child|has_attribute('closure'), $child|attribute('closure')|is_empty_matrix|not), true(), false())}

                <h3 class="title-medium-2 mb-0">
                    {if or($has_attribute_opening_hours, $has_attribute_closure, $child|has_attribute('note'))}
                    <a class="float-right" style="margin-top: -3px;" data-toggle="collapse" data-bs-toggle="collapse" href="#collapse-{$child.contentobject_id}" role="button" aria-expanded="false" aria-controls="collapse-{$child.contentobject_id}">
                        {display_icon('it-info-circle', 'svg', 'icon icon-sm card-icon-color-primary')}
                    </a>
                    {/if}
                    {attribute_view_gui attribute=$child|attribute('name')}
                    {if $child|has_attribute('valid_through')}
                        <small class="d-block">
                            {$child|attribute('valid_from').content.timestamp|l10n('shortdate')}
                            <i class="fa fa-arrow-right" aria-hidden="true"></i>
                            {$child|attribute('valid_through').content.timestamp|l10n('shortdate')}
                        </small>
                    {/if}
                </h3>
                {if or($has_attribute_opening_hours, $has_attribute_closure, $child|has_attribute('note'))}
                    <div class="collapse pt-2" id="collapse-{$child.contentobject_id}">
                        {if $has_attribute_opening_hours}
                            <strong class="m-0">{$child|attribute('opening_hours').contentclass_attribute_name|wash()}</strong>
                            {attribute_view_gui attribute=$child|attribute('opening_hours')}
                        {/if}
                        {if $has_attribute_closure}
                            <strong class="m-0">{$child|attribute('closure').contentclass_attribute_name|wash()}</strong>
                            {attribute_view_gui attribute=$child|attribute('closure')}
                        {/if}
                        {if $child|has_attribute('note')}
                            <strong class="m-0">{$child|attribute('note').contentclass_attribute_name|wash()}</strong>
                            {attribute_view_gui attribute=$child|attribute('note')}
                        {/if}
                    </div>
                {/if}
                {undef $has_attribute_opening_hours $has_attribute_closure}
            </div>
        </div>
    </div>
    {undef $valid_date_attribute}
    {/foreach}
</div>

{/if}

{undef $node_list}
