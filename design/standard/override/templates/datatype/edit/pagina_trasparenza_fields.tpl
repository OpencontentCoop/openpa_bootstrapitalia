{default attribute_base='ContentObjectAttribute' html_class='full' placeholder=false()}
{if and( $attribute.has_content, $placeholder )}<label>{$placeholder}</label>{/if}
{def $presets = openpaini('Trasparenza', 'FieldsPreset', array())}
  <textarea
          id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
          class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier} border"
          name="{$attribute_base}_ezstring_data_text_{$attribute.id}" cols="70"
          rows="5">{$attribute.data_text|wash()}</textarea>
{if count($presets)}
  <label class="form-label font-weight-bold mt-2" for="fields-presets">Utilizza una configurazione predefinita</label>
  <select class="form-control" onchange="document.getElementById('ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}').value = this.value">
      <option></option>
      {foreach $presets as $preset}
        <option value="preset:{$preset|wash()}">{openpaini(concat('TrasparenzaFieldsPreset_', $preset), 'Label', 'Missing label')}</option>
      {/foreach}
  </select>
{/if}
{/default}
