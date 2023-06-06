{def $valid_date_attribute = cond($node|has_attribute('valid_through'), $node|attribute('valid_through'), $node|attribute('valid_from'))}
<div class="point-list">
    <div class="point-list-aside point-list-warning">
        <div class="point-date text-monospace" style="max-height: 53px;">{$valid_date_attribute.content.timestamp|datetime( 'custom', '%d' )}</div>
        <div class="point-month text-monospace" style="max-height: 20px;">{$valid_date_attribute.content.timestamp|datetime( 'custom', '%M' )}</div>
    </div>
    <div class="point-list-content">
        <div class="card card-teaser shadow p-4 rounded border">
            <div class="card-body">

                {def $has_attribute_opening_hours = cond(and($node|has_attribute('opening_hours'), $node|attribute('opening_hours')|is_empty_matrix|not), true(), false())}
                {def $has_attribute_closure = cond(and($node|has_attribute('closure'), $node|attribute('closure')|is_empty_matrix|not), true(), false())}

                <h5 class="card-title">
                    {if or($has_attribute_opening_hours, $has_attribute_closure, $node|has_attribute('note'))}
                        <a class="float-right" style="margin-top: -3px;" data-toggle="collapse" data-bs-toggle="collapse" href="#collapse-{$node.contentobject_id}" role="button" aria-expanded="false" aria-controls="collapse-{$node.contentobject_id}">
                            {display_icon('it-info-circle', 'svg', 'icon icon-sm card-icon-color-primary')}
                        </a>
                    {/if}
                    {attribute_view_gui attribute=$node|attribute('name')}
                    {if $node|has_attribute('valid_through')}
                        <small class="d-block">
                            {$node|attribute('valid_from').content.timestamp|l10n('shortdate')}
                            <i class="fa fa-arrow-right" aria-hidden="true"></i>
                            {$node|attribute('valid_through').content.timestamp|l10n('shortdate')}
                        </small>
                    {/if}
                </h5>
                {if or($has_attribute_opening_hours, $has_attribute_closure, $node|has_attribute('note'))}
                    <div class="collapse pt-2" id="collapse-{$node.contentobject_id}">
                        {if $has_attribute_opening_hours}
                            <h6 class="m-0">{$node|attribute('opening_hours').contentclass_attribute_name|wash()}</h6>
                            {attribute_view_gui attribute=$node|attribute('opening_hours')}
                        {/if}
                        {if $has_attribute_closure}
                            <h6 class="m-0">{$node|attribute('closure').contentclass_attribute_name|wash()}</h6>
                            {attribute_view_gui attribute=$node|attribute('closure')}
                        {/if}
                        {if $node|has_attribute('note')}
                            <h6 class="m-0">{$node|attribute('note').contentclass_attribute_name|wash()}</h6>
                            {attribute_view_gui attribute=$node|attribute('note')}
                        {/if}
                    </div>
                {/if}
                {undef $has_attribute_opening_hours $has_attribute_closure}
            </div>
        </div>
    </div>
</div>
{undef $valid_date_attribute}