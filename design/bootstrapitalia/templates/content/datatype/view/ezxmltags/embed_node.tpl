<div class="embed {if $object_parameters.align}object-{$object_parameters.align}{/if}{if ne($classification|trim,'')} {$classification|wash}{/if}"{if is_set($object_parameters.id)} id="{$object_parameters.id}"{/if}>
{node_view_gui view=$view link_parameters=$link_parameters object_parameters=$object_parameters content_node=$node object=$object classification=$classification}
</div>