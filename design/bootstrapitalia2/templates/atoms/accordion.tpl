<div class="accordion">
    {foreach $items as $item}
    <div class="accordion-item">
        <h2 class="accordion-header" id="heading-{$item.node_id}">
            <button class="accordion-button collapsed" type="button"
                    data-bs-toggle="collapse" data-bs-target="#collapse-{$item.node_id}" aria-expanded="false" aria-controls="collapse-{$item.node_id}">
                {$item.name|wash()}
            </button>
        </h2>
        <div id="collapse-{$item.node_id}" class="accordion-collapse collapse" role="region" aria-labelledby="heading-{$item.node_id}">
            <div class="accordion-body">
                {node_view_gui content_node=$item view=accordion_content}
            </div>
        </div>
    </div>
    {/foreach}
</div>