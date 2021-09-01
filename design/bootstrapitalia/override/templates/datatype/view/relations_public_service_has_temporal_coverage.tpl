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
<div class="point-list-wrapper my-4">
    {foreach $node_list as $child }
    {def $valid_date_attribute = cond($child|has_attribute('valid_through'), $child|attribute('valid_through'), $child|attribute('valid_from'))}
    <div class="point-list">
        <div class="point-list-aside point-list-warning">
            <div class="point-date text-monospace" style="max-height: 53px;">{$valid_date_attribute.content.timestamp|datetime( 'custom', '%d' )}</div>
            <div class="point-month text-monospace" style="max-height: 20px;">{$valid_date_attribute.content.timestamp|datetime( 'custom', '%M' )}</div>
        </div>
        <div class="point-list-content">
            <div class="card card-teaser shadow p-4 rounded border">
                <div class="card-body">

                    {def $has_attribute_opening_hours = cond(and($child|has_attribute('opening_hours'), $child|attribute('opening_hours')|is_empty_matrix|not), true(), false())}
                    {def $has_attribute_closure = cond(and($child|has_attribute('closure'), $child|attribute('closure')|is_empty_matrix|not), true(), false())}

                    <h5 class="card-title">
                        {if or($has_attribute_opening_hours, $has_attribute_closure, $child|has_attribute('note'))}
                        <a class="float-right" style="margin-top: -3px;" data-toggle="collapse" href="#collapse-{$child.contentobject_id}" role="button" aria-expanded="false" aria-controls="collapse-{$child.contentobject_id}">
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
                    </h5>
                    {if or($has_attribute_opening_hours, $has_attribute_closure, $child|has_attribute('note'))}
                        <div class="collapse pt-2" id="collapse-{$child.contentobject_id}">
                            {if $has_attribute_opening_hours}
                                <h6 class="m-0">{$child|attribute('opening_hours').contentclass_attribute_name|wash()}</h6>
                                {attribute_view_gui attribute=$child|attribute('opening_hours')}
                            {/if}
                            {if $has_attribute_closure}
                                <h6 class="m-0">{$child|attribute('closure').contentclass_attribute_name|wash()}</h6>
                                {attribute_view_gui attribute=$child|attribute('closure')}
                            {/if}
                            {if $child|has_attribute('note')}
                                <h6 class="m-0">{$child|attribute('note').contentclass_attribute_name|wash()}</h6>
                                {attribute_view_gui attribute=$child|attribute('note')}
                            {/if}
                        </div>
                    {/if}
                    {undef $has_attribute_opening_hours $has_attribute_closure}
                </div>
            </div>
        </div>
    </div>
    {undef $valid_date_attribute}
    {/foreach}
</div>

{/if}

{undef $node_list}
