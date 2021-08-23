{default attribute_base=ContentObjectAttribute}

<input type="hidden" name="MAX_FILE_SIZE" value="{$attribute.contentclass_attribute.data_int1}000000"/>
<input id="{$attribute_base}_data_enhancedbinaryfilename_{$attribute.id}"
       name="{$attribute_base}_data_enhancedbinaryfilename_{$attribute.id}"
       type="file" class="position-relative" style="top:0;font-size: 1em;" />

{/default}