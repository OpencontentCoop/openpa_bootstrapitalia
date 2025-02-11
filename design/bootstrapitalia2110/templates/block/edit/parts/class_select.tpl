<div class="row my-3">
    <label for="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}"
           class="col-12 col-form-label font-weight-bold">{$attribute.label|wash()}:</label>
    <div class="col-12 d-flex">
        {def $class_list = fetch( class, list, hash( sort_by, array( 'name', true() ) ) )}
        <select id="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}" class="form-control select_to_string" onchange="select_to_string(this)">
            <option></option>
            {foreach $class_list as $class}
                <option value="{$class.identifier}">{$class.name|wash()}</option>
            {/foreach}
        </select>
        {undef $class_list}
        <input id="block-custom_attribute-{$attribute.block_id}-{$attribute.loop_count}" class="form-control" type="text"
               name="ContentObjectAttribute_ezpage_block_custom_attribute_{$attribute.attribute.id}[{$attribute.zone_id}][{$attribute.block_id}][{$attribute.identifier}]"
               value="{if is_set($attribute.block.custom_attributes[$attribute.identifier])}{$attribute.block.custom_attributes[$attribute.identifier]|wash()}{/if}" />
    </div>
    {if $attribute.help_text}<div class="form-text">{$attribute.help_text|wash()}</div>{/if}
</div>