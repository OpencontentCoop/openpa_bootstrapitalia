<div class="row my-3">
    <label for="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}" class="col-12 col-form-label font-weight-bold">{$attribute.label|wash()}:</label>
    <div class="col-12">
        <input id="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}" class="form-control w-100" type="text"
               name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.attribute.id}[{$attribute.zone_id}][{$attribute.block_id}][{$attribute.identifier}]"
               value="{$attribute.block.custom_attributes[$attribute.identifier]|wash()}" />
        {if $attribute.help_text}<div class="form-text">{$attribute.help_text|wash()}</div>{/if}
    </div>
</div>