{default attribute_base=ContentObjectAttribute html_class='full'}
{def $all_list = fetch( 'bootstrapitalia', 'comuni_italiani')}
{def $selected_codes = array()}
{def $content = $attribute.content}
{foreach $content as $item}
    {set $selected_codes = $selected_codes|append($item.code)}
{/foreach}
<div class="row">
    <div class="col">
        <select id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
                class="select-comune {$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                {if $attribute.contentclass_attribute.content.multiple_choice}multiple="multiple"{/if}
                data-placeholder="{"Select"|i18n("design/ocbootstrap/ezodf/browse_place")}"
                name="{$attribute_base}_opcom_selection_{$attribute.id}[]">
            {if and($attribute.contentclass_attribute.content.multiple_choice|not(), $attribute.is_required|not())}
                <option></option>
            {/if}
            {foreach $all_list as $comune}
                <option value="{$comune.code|wash()}" {if $selected_codes|contains($comune.code)}selected="selected"{/if}>
                    {$comune.name|wash( xhtml )} ({$comune.sigla|wash( xhtml )})
                </option>
            {/foreach}
        </select>
    </div>
</div>
{undef $all_list $selected_codes $content}
{run-once}
{ezscript_require(array('ezjsc::jquery', 'plugins/chosen.jquery.js'))}
<script>{literal}
$(document).ready(function(){$(".select-comune").chosen({search_contains:true});});
{/literal}</script>
{/run-once}