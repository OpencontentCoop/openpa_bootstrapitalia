{* DO NOT EDIT THIS FILE! Use an override template instead. *}
{default attribute_base=ContentObjectAttribute html_class='form-control'}
{let data_int=cond( is_set( $#collection_attributes[$attribute.id] ), $#collection_attributes[$attribute.id].data_int, $attribute.content )}
<input class="{$html_class}" type="number" name="{$attribute_base}_data_integer_{$attribute.id}" size="10" value="{$data_int}" />
{/let}
{/default}
