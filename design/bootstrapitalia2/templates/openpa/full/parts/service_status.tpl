{def $status_tags = array()}
{if $node|has_attribute('has_service_status')}
    {foreach $node|attribute('has_service_status').content.tags as $tag}
        {set $status_tags = $status_tags|append($tag.keyword)}
    {/foreach}
{/if}

<div class="d-flex flex-wrap cmp-heading__tag">
    <div class="cmp-tag">
        <span class="cmp-tag__tag title-xsmall" data-element="service-status">{$status_tags|implode(', ')|wash()}</span>
    </div>
</div>
{if $node|has_attribute('status_note')}
    <div class="alert alert-warning my-md-4 my-lg-4">
    {attribute_view_gui attribute=$node|attribute('status_note')}
    </div>
{/if}