{default attribute_base='ContentObjectAttribute'}
{let data_int=cond( is_set( $#collection_attributes[$attribute.id]), $#collection_attributes[$attribute.id].data_int, $attribute.data_int )}
  <div class="form-group form-check m-0">
    <input id="{$attribute_base}_data_boolean_{$attribute.id}"
           class="form-check-input"
           type="checkbox"
           name="{$attribute_base}_data_boolean_{$attribute.id}" {$attribute.data_int|choose( '', 'checked="checked"' )}
           value="" />
    <label class="form-check-label text-sans-serif" for="ezcoa-{$attribute_base}_data_boolean_{$attribute.id}">
      {$attribute.contentclass_attribute.name}
    </label>
  </div>
{/let}
{/default}

