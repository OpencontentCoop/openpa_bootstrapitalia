{def $openpa = object_handler($node)}
<div class="search-item mb-4">
    <h5 class="mb-0"><a href="{$openpa.content_link.full_link}" title="Vai alla pagina: {$node.name|wash()}">{if $node.name|ne('')}{$node.name|wash()}{else}#{$node.node_id|wash()}{/if}</a></h5>
    <strong class="text-dark">{$node.path_with_names}</strong>
    <p>{$node|abstract()|oc_shorten(150,'...')}</p>
</div>