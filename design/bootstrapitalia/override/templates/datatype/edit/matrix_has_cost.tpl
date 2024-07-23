{* DO NOT EDIT THIS FILE! Use an override template instead. *}

{def $currency_tag = fetch('tags', 'tags_by_keyword', hash('keyword', 'Valute'))}
{default attribute_base=ContentObjectAttribute}
{let matrix=$attribute.content}

<div class="oc-cost-matrix">
    <div class="oc-cost-matrix-table">
        {section show=$matrix.rows.sequential}
            <table class="table table-sm">
                <tr>
                    <th class="tight" width="1">&nbsp;</th>
                    {section var=ColumnNames loop=$matrix.columns.sequential}
                        <th class="size-sm">{$ColumnNames.item.name}</th>
                    {/section}
                </tr>
                {section var=Rows loop=$matrix.rows.sequential sequence=array( bglight, bgdark )}
                    <tr class="{$Rows.sequence}">
                        {* Remove. *}
                        <td>
                            <label style="margin: 0;padding: 10px;" for="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_remove_{$Rows.index}">
                                <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_remove_{$Rows.index}"
                                       class="ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                                       type="checkbox" name="{$attribute_base}_data_matrix_remove_{$attribute.id}[]"
                                       value="{$Rows.index}"
                                       data-select
                                       title="{'Select row for removal.'|i18n( 'design/standard/content/datatype' )}"/>
                            </label>
                        </td>
                        {* Custom columns. *}
                        {section var=Columns loop=$Rows.item.columns}
                            <td>
                                <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_matrix_cell_{$Rows.index}_{$Columns.index}"
                                       class="form-control ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                                       type="text"
                                       data-cell
                                       name="{$attribute_base}_ezmatrix_cell_{$attribute.id}[]"
                                       list="{$matrix.columns.sequential[$Columns.index].identifier}-choose-{$attribute.id}"
                                       value="{$Columns.item|wash( xhtml )}"/>
                            </td>
                        {/section}
                    </tr>
                {/section}
            </table>
        {/section}
    </div>


    {if is_set($currency_tag[0])}
    <datalist id="currency-choose-{$attribute.id}">
        {foreach $currency_tag[0].children as $currency}
            <option value="{$currency.keyword|wash}"></option>
        {/foreach}
    </datalist>
    {/if}

    <div class="row">
        <div class="col-9">
            <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_remove_selected"
                   class="oc-cost-matrix-remove-rows btn btn-sm btn-danger px-2 py-1 ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                   type="submit" name="CustomActionButton[{$attribute.id}_remove_selected]"
                   data-id="{$attribute.id}"
                   data-version="{$attribute.version}"
                   data-language="{$attribute.language_code}"
                   value="{'Remove selected'|i18n( 'design/standard/content/datatype' )}"
                   {if $matrix.rows.sequential|not()}style="display:none"{/if}
                   title="{'Remove selected rows from the matrix.'|i18n( 'design/standard/content/datatype' )}"/>
        </div>
        {let row_count=sub( 40, count( $matrix.rows.sequential ) ) index_var=0}
        {if $row_count|lt( 1 )}
            {set row_count=0}
        {/if}
            <div class="col-3">
                <div class="input-group" style="width: auto;float:right">
                    <select id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_add_count"
                            class="custom-select form-control border form-control-sm matrix_cell ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                            name="{$attribute_base}_data_matrix_add_count_{$attribute.id}"
                            style="max-width:50px"
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
                               class="oc-cost-matrix-add-rows btn btn-sm btn-success ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                               type="submit" name="CustomActionButton[{$attribute.id}_new_row]"
                               data-id="{$attribute.id}"
                               data-version="{$attribute.version}"
                               data-language="{$attribute.language_code}"
                               value="{'Add rows'|i18n('design/standard/content/datatype')}"
                               title="{'Add new rows to the matrix.'|i18n( 'design/standard/content/datatype' )}"/>
                    </div>
                </div>
            </div>
        {/let}
    </div>

</div>
{/let}
{/default}
{undef $currency_tag}
<script>{literal}
  $(document).ready(function () {
    var tokenNode = document.getElementById('ezxform_token_js');
    $('.oc-cost-matrix-add-rows').on('click', function (e) {
      var self = $(this)
      var id = $(this).data('id');
      var version = $(this).data('version');
      var language = $(this).data('language');
      var num = $(this).parents('.input-group').find('select').val();
      var table = $(this).parents('.oc-cost-matrix').find('table');
      if (table.length === 0){
        table = $('<table class="table table-sm"></table>')
          .appendTo($(this).parents('.oc-cost-matrix').find('.oc-cost-matrix-table'))
      }
      var data = [];
      table.find('[data-cell]').each(function (){
        data.push($(this).val())
      });
      console.log(table)
      //self.attr('disabled', 'disabled');
      table.load(
        $.ez.url + 'call/ezjscmatrix::addRows::' + id + '::' + version + '::' + language + '::' + num, {
          data: data,
          ezxform_token: tokenNode ? tokenNode.getAttribute('title') : ''
        }, function (response){
          self.parents('.oc-cost-matrix').find('.oc-cost-matrix-remove-rows').show()
          self.removeAttr('disabled');
        })
      e.preventDefault();
    });
    $('.oc-cost-matrix-remove-rows').on('click', function (e) {
      var self = $(this)
      var id = $(this).data('id');
      var version = $(this).data('version');
      var language = $(this).data('language');
      var table = $(this).parents('.oc-cost-matrix').find('table');
      var data = [];
      table.find('[data-cell]').each(function (){
        data.push($(this).val())
      });
      var removeList = [];
      table.find('[data-select]').each(function (){
        if ($(this).is(':checked')) {
          removeList.push($(this).val())
        }
      });
      self.attr('disabled', 'disabled');
      table.load(
        $.ez.url + 'call/ezjscmatrix::removeRows::' + id + '::' + version + '::' + language, {
          data: data,
          remove: removeList,
          ezxform_token: tokenNode ? tokenNode.getAttribute('title') : ''
        }, function (response){
          self.removeAttr('disabled');
          if ($(response).find('td').length === 0) {
            self.hide()
          }
        })
      e.preventDefault();
    });
  })
    {/literal}</script>