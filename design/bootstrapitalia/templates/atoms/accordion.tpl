<div class="collapse-div collapse-left-icon">
    {foreach $items as $item}
    <div class="collapse-header" id="heading-{$item.node_id}">
        <button data-toggle="collapse" data-target="#collapse-{$item.node_id}" aria-expanded="false" aria-controls="collapse-{$item.node_id}">
            {$item.name|wash()}
        </button>
    </div>
    <div id="collapse-{$item.node_id}" class="collapse" aria-labelledby="heading-{$item.node_id}">
        <div class="collapse-body">
            {node_view_gui content_node=$item view=accordion_content}
        </div>
    </div>
    {/foreach}
</div>