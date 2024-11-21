{set_defaults(hash('no_after', true()))}
<div data-object_id="{$node.contentobject_id}"
     class="card-wrapper border border-light rounded shadow-sm h-100 {$node|access_style}">
    <div class="card{if $no_after} no-after{/if} rounded">
{unset_defaults(array('no_after'))}