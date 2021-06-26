<div class="u-padding-all-s">

    <div class="row">
        <div class="col-9">
            <label class="d-none" for="{$attribute_base}_query_parameter_{$attribute.id}">
                {'Query Parameters'|i18n('occhart/attribute')}
            </label>
            <input class="form-control"
                   placeholder="{'Query Parameters'|i18n('occhart/attribute')}"
                   id="{$attribute_base}_query_parameter_{$attribute.id}"
                   name="{$attribute_base}_query_parameter_{$attribute.id}"
                   value="{if is_set($attribute_content.data_source_params.query_parameter)}{$attribute_content.data_source_params.query_parameter|wash()}{/if}"
                   type="text"/>
        </div>
        <div class="col-3">
            <button class="button" type="submit"
                    name="CustomActionButton[{$attribute.id}_ocql_query-save_query_parameter]">
                {'Save'|i18n( 'design/standard/content/datatype' )}
            </button>
        </div>
    </div>
</div>