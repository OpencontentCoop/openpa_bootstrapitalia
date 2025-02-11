<div class="row">
    <div class="col">
        <input id="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}-a" type="hidden"
               name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.attribute.id}[{$attribute.zone_id}][{$attribute.block_id}][{$attribute.identifier}]"
               value="0"/>
        <div class="form-check">
            <input id="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}-b"
                   class="form-check-input"
                   type="checkbox"
                   name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.attribute.id}[{$attribute.zone_id}][{$attribute.block_id}][{$attribute.identifier}]"
                    {if and(is_set($attribute.block.custom_attributes[$attribute.identifier]), eq( $attribute.block.custom_attributes[$attribute.identifier], '1'))} checked="checked"{/if}
                   value="1">
            <label class="form-check-label" for="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}-b" style="font-size:1em">
                {$attribute.label|wash()}
            </label>
        </div>
        {if $attribute.help_text}<div class="form-text">{$attribute.help_text|wash()}</div>{/if}
    </div>
</div>