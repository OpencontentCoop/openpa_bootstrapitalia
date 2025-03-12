{def $status_tags = array()}
{if $node|has_attribute('has_service_status')}
    {foreach $node|attribute('has_service_status').content.tags as $tag}
        {set $status_tags = $status_tags|append($tag.keyword)}
    {/foreach}
{/if}

<ul class="d-flex flex-wrap gap-1 my-3">
    <li>
        <div class="chip chip-simple chip-primary text-button" href="#" data-element="service-status">
            <span class="chip-label">{$status_tags|implode(', ')|wash()}</span>
        </div>
    </li>
</ul>

{if is_active_public_service($node)|not()}
    {if $node|has_attribute('status_note')}
        <div class="alert alert-warning my-md-4 my-lg-4 pb-0">
        {attribute_view_gui attribute=$node|attribute('status_note')}
        </div>
    {else}
        <div class="alert alert-warning my-md-4 my-lg-4">
            {openpaini('AttributeHandlers', 'DefaultContent_status_note', 'Il servizio online al momento non è disponibile')}
        </div>
    {/if}
{else}
    <div class="alert alert-warning my-md-4 my-lg-4" style="display: none" id="status-note-placeholder">
        {openpaini('AttributeHandlers', 'DefaultContent_status_note', 'Il servizio online al momento non è disponibile')}
    </div>
{/if}