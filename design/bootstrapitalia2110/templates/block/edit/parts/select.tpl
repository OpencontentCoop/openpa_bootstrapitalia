<div class="row my-3">
    <label for="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}"
           class="col-12 col-form-label font-weight-bold">{$attribute.label|wash()}:</label>
    <div class="col-12">
        <select id="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}" class="form-control w-100"
                name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.attribute.id}[{$attribute.zone_id}][{$attribute.block_id}][{$attribute.identifier}]">
            {def $selection = ezini( $attribute.block.type, concat( 'CustomAttributeSelection_', $attribute.identifier ), 'block.ini' )}
            {foreach $selection as $selection_value => $selection_name}
                <option value="{$selection_value|wash()}"{if eq( $attribute.block.custom_attributes[$attribute.identifier], $selection_value )} selected="selected"{/if}>{$selection_name|wash()}</option>
            {/foreach}
            {undef $selection}
        </select>
        {if $attribute.help_text}<div class="form-text">{$attribute.help_text|wash()}</div>{/if}
    </div>
</div>