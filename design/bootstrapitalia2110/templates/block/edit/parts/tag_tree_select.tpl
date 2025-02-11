<div class="row my-3">
    <label for="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}"
           class="col-12 col-form-label font-weight-bold">{$attribute.label|wash()}:</label>
    <div class="col-12">
        <a class="float-end mt-1" href="#" data-index="{$attribute.loop_count}" onclick="tag_tree_select(this);return false;"><i class="fa fa-plus-square-o"></i></a>
        <input id="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}" class="form-control" type="text" style="width:95%"
               name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.attribute.id}[{$attribute.zone_id}][{$attribute.block_id}][{$attribute.identifier}]"
               value="{if is_set($attribute.block.custom_attributes[$attribute.identifier])}{$attribute.block.custom_attributes[$attribute.identifier]|wash()}{/if}" />
    </div>
    {if $attribute.help_text}<div class="form-text">{$attribute.help_text|wash()}</div>{/if}
</div>