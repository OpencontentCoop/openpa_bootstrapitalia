{if $node.data_map.image.content[$image_class]}
<div class="openpa-image">
    {*<h2>{$node.name|wash()}</h2>*}
    {def $image = $node.data_map.image.content[$image_class]}
    <img src={$image.url|ezroot} width="{$image.width}" height="{$image.height}" alt="{$node.name|wash}" class="img-responsive center-block"/>    
    {undef $image}
    {include uri="design:parts/toolbar/node_edit.tpl" current_node=$node}
    {include uri="design:parts/toolbar/node_trash.tpl" current_node=$node}
</div>
{/if}
