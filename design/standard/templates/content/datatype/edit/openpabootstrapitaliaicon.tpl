{default attribute_base=ContentObjectAttribute html_class='full'}
<div class="row icon-select-preview ">
    <div class="col-sm-11">
        <select id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
                class="icon-select {$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                name="{$attribute_base}_openpabootstrapitaliaicon_data_text_{$attribute.id}">
            {if $attribute.is_required|not()}
                <option></option>
            {/if}
            {foreach $attribute.contentclass_attribute.content as $icon}
                <option value="{$icon.value}" {if $attribute.data_text|eq( $icon.value )}selected="selected"{/if}>
                    {$icon.name|wash( xhtml )}
                </option>
            {/foreach}
        </select>
    </div>
    <div class="col-sm-1 text-center">
        <svg class="icon"></svg>
    </div>
</div>
{run-once}
    <script>{literal}
        $(document).ready(function () {
            var container = $('.icon-select-preview');
            var select = container.find('.icon-select');
            var preview = container.find('svg.icon');
            function displayIconSelect() {
                if (select.val() !== '')
                    preview.html('<use xlink:href={/literal}{sprite_svg_href()}{literal}#'+select.val()+'"></use>')
                else
                    preview.html('');
            }
            select.on('change', displayIconSelect);
            displayIconSelect();
        });
        {/literal}</script>
{/run-once}
{/default}