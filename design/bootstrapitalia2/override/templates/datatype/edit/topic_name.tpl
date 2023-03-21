{default attribute_base='ContentObjectAttribute' html_class='full' placeholder=false()}
{if and( $attribute.has_content, $placeholder )}<label>{$placeholder}</label>{/if}
{if $attribute.object.state_identifier_array|contains('opencity_lock/locked')}
    <input type="hidden" name="{$attribute_base}_ezstring_data_text_{$attribute.id}" value="{$attribute.data_text|wash( xhtml )}" />
    <input type="text" disabled class="{$html_class}" value="{$attribute.data_text|wash( xhtml )}" />
{else}
    <input {if $placeholder}placeholder="{$placeholder}"{/if} id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
           class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="text" size="70" name="{$attribute_base}_ezstring_data_text_{$attribute.id}" value="{$attribute.data_text|wash( xhtml )}" />
{/if}
{/default}

