    <div class="accordion-item">
        <h2 class="accordion-header" id="heading-{$node.node_id}">
            <button class="accordion-button collapsed" type="button"
                    data-bs-toggle="collapse" data-bs-target="#collapse-{$node.node_id}" aria-expanded="false" aria-controls="collapse-{$node.node_id}">
                {$node.name|wash()}
            </button>
        </h2>
        <div id="collapse-{$node.node_id}" class="accordion-collapse collapse" role="region" aria-labelledby="heading-{$node.node_id}">
            <div class="accordion-body">
                {node_view_gui content_node=$node view=accordion_content}
            </div>
        </div>
    </div>