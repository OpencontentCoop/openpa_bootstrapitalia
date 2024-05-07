<div class="collapse-header" id="heading-{$node.node_id}">
    <button data-toggle="collapse" data-bs-toggle="collapse" data-target="#collapse-{$node.node_id}" data-bs-target="#collapse-{$node.node_id}" aria-expanded="false" aria-controls="collapse-{$node.node_id}">
        {$node.name|wash()}
    </button>
</div>
<div id="collapse-{$node.node_id}" class="collapse" aria-labelledby="heading-{$node.node_id}">
    <div class="collapse-body">
        {node_view_gui content_node=$node view=accordion_content}
    </div>
</div>