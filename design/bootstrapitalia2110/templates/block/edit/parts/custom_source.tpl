<label class="font-weight-bold w-100">{if $attribute.label}{$attribute.label}:{else}{'Current source:'|i18n( 'design/standard/block/edit' )}{/if}</label>
<input id="block-choose-source-{$attribute.block_id}" class="btn-secondary btn py-1 px-2 btn-xs block-control"
       data-browsersubtree="{if and($attribute.label, $attribute.label|contains('Immagine'))}51{else}2{/if}"
       data-browserselectiontype="single"
       name="CustomActionButton[{$attribute.attribute.id}_custom_attribute_browse-{$attribute.zone_id}-{$attribute.block_id}-{$attribute.identifier}]" type="submit" value="{'Choose source'|i18n( 'design/standard/block/edit' )}" />
<div class="source d-inline-block w-auto float-none font-weight-normal">
    {if is_set( $attribute.block.custom_attributes[$attribute.identifier] )}
        {def $source_node = fetch( 'content', 'node', hash( 'node_id', $attribute.block.custom_attributes[$attribute.identifier] ) )}
        {if $source_node}
            <a href={$source_node.url_alias|ezurl()}>{$source_node.name|wash()}</a>
        {/if}
        {undef $source_node}
    {/if}
</div>