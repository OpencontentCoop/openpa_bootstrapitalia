{default attribute_base=ContentObjectAttribute}
{let matrix=$attribute.content}

    {* Matrix. *}
{section show=$matrix.rows.sequential}
    <table class="table" cellspacing="0">
        <tr>
            <th class="tight">&nbsp;</th>
            {section var=ColumnNames loop=$matrix.columns.sequential}
                <th>{$ColumnNames.item.name}</th>
            {/section}
        </tr>
        {section var=Rows loop=$matrix.rows.sequential sequence=array( bglight, bgdark )}
            <tr class="{$Rows.sequence}">
                {* Remove. *}
                <td>
                    <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_remove_{$Rows.index}"
                           class="ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                           type="checkbox" name="{$attribute_base}_data_matrix_remove_{$attribute.id}[]"
                           value="{$Rows.index}"
                           title="{'Select row for removal.'|i18n( 'design/standard/content/datatype' )}"/></td>
                {* Custom columns. *}
                {section var=Columns loop=$Rows.item.columns}
                    <td>
                        <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_matrix_cell_{$Rows.index}_{$Columns.index}"
                               class="form-control ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                               type="text"
                               data-contact-identifier="{$matrix.columns.sequential[$Columns.index].identifier|wash()}"
                               name="{$attribute_base}_ezmatrix_cell_{$attribute.id}[]"
                               value="{$Columns.item|wash( xhtml )}"/>
                    </td>
                {/section}
            </tr>
        {/section}
    </table>
{/section}
<div class="clearfix">
{* Buttons. *}
{if $matrix.rows.sequential}
    <div class="float-left">
    <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_remove_selected"
           class="btn btn-sm btn-danger ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
           type="submit" name="CustomActionButton[{$attribute.id}_remove_selected]"
           value="{'Remove selected'|i18n( 'design/standard/content/datatype' )}"
           title="{'Remove selected rows from the matrix.'|i18n( 'design/standard/content/datatype' )}"/>
    </div>
{/if}
    &nbsp;&nbsp;
{let row_count=sub( 40, count( $matrix.rows.sequential ) ) index_var=0}
{if $row_count|lt( 1 )}
    {set row_count=0}
{/if}
<div class="{if $matrix.rows.sequential}float-right{else}float-left{/if}">
    <div class="input-group">
        <select id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_add_count"
                class="custom-select form-control-sm matrix_cell ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                name="{$attribute_base}_data_matrix_add_count_{$attribute.id}"
                title="{'Number of rows to add.'|i18n( 'design/standard/content/datatype' )}">
            <option value="1">1</option>
            {section loop=$row_count}
                {set index_var=$index_var|inc}
                {delimiter modulo=5}
                    <option value="{$index_var}">{$index_var}</option>
                {/delimiter}
            {/section}
        </select>
        <div class="input-group-append">
        <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_new_row"
               class="btn btn-sm btn-success ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
               type="submit" name="CustomActionButton[{$attribute.id}_new_row]"
               value="{'Add rows'|i18n('design/standard/content/datatype')}"
               title="{'Add new rows to the matrix.'|i18n( 'design/standard/content/datatype' )}"/>
        </div>
    </div>
</div>
{/let}
</div>

{/let}
{/default}
{def $tipologia_punti_contatto = array()
     $tag_root = api_tagtree('/Organizzazione/Tipologia di punti di contatto')}
{foreach $tag_root.children as $tag}
    {set $tipologia_punti_contatto = $tipologia_punti_contatto|append($tag.keyword)}
{/foreach}
<script>
{literal}
$(document).ready(function () {
    var facetsQuery = "facets [raw[subattr_contact___type____s]|alpha,raw[subattr_contact___contact____s]|alpha] limit 1";
    $.opendataTools.find(facetsQuery, function (response){
        if (response.facets){
            $.each(response.facets, function (){
                var name = this.name;
                var values = Object.keys(this.data);
                if (name === 'raw[subattr_contact___type____s]'){
                    values = $.unique($.merge(values, ['Telefono', 'E-mail', 'Fax', 'Cellulare', 'Sito web', 'PEC']));
                    var dataTypeList = $('<datalist id="contact_type"></datalist>');
                    $.each(values, function (){
                        dataTypeList.append('<option value="'+this+'">');
                    });
                    $('body').append(dataTypeList);
                    $('[data-contact-identifier="type"]').attr('list', 'contact_type')
                }
                if (name === 'raw[subattr_contact___contact____s]'){
                    values = $.unique($.merge(values, JSON.parse('{/literal}{$tipologia_punti_contatto|json_encode()}{literal}')));
                    var dataContactList = $('<datalist id="contact_contact"></datalist>');
                    $.each(values, function (){
                        dataContactList.append('<option value="'+this+'">');
                    });
                    $('body').append(dataContactList);
                    $('[data-contact-identifier="contact"]').attr('list', 'contact_contact');
                }
            })
        }
    })
})
{/literal}
</script>
{undef $tipologia_punti_contatto $tag_root}