{def $__VIEW_IMAGE = 'original'}

{def $__IMAGE = fetch('content','node',hash('node_id',$block.last_valid_item.node_id))}

<div class="thumbnail">
    <img src={$__IMAGE|attribute('image').content[$__VIEW_IMAGE].url|ezroot()} alt="{$__IMAGE|attribute('image').content.alternative_text|wash()}" />
</div>

