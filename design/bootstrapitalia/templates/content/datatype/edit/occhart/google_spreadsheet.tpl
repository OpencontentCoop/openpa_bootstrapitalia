<div class="u-padding-all-s">
{if is_set($attribute_content.data_source_params.spreadsheet_url)}
    <p>
        <button class="button" type="submit"
                name="CustomActionButton[{$attribute.id}_google_spreadsheet-delete_url]">
            <i class="fa fa-trash"></i>
        </button>
        Selected spreadsheet: <a class="text-decoration-none" href="{$attribute_content.data_source_params.spreadsheet_url|wash( xhtml )}">{$attribute_content.data_source_params.title|wash()}</a>
    </p>
    {if and( is_set($attribute_content.data_source_params.selected_sheet)|not(), $attribute_content.data_source_params.sheets|count()|gt(0))}
        <p>
            <div class="row">
                <div class="col-9">
                    <label class="d-none" for="{$attribute_base}_spreadsheet_sheet_{$attribute.id}">
                        {'Select sheet'|i18n('occhart/attribute')}
                    </label>
                    <select class="form-control"
                            id="{$attribute_base}_spreadsheet_sheet_{$attribute.id}"
                            name="{$attribute_base}_spreadsheet_sheet_{$attribute.id}">
                        <option>{'Select sheet'|i18n('occhart/attribute')}</option>
                        {foreach $attribute_content.data_source_params.sheets as $sheet}
                            <option value="{$sheet|wash()}">{$sheet|wash()}</option>
                        {/foreach}
                    </select>
                </div>
                <div class="col-3">
                    <input id="{$attribute_base}_google_spreadsheet_select_sheet_{$attribute.id}_select_button"
                           class="button"
                           type="submit"
                           name="CustomActionButton[{$attribute.id}_google_spreadsheet-select_sheet]"
                           value="{'Select'|i18n( 'design/standard/content/datatype' )}" />
                </div>
            </div>
        </p>
    {else}
        <p>
            <button class="button" type="submit"
                    name="CustomActionButton[{$attribute.id}_google_spreadsheet-delete_sheet]">
                <i class="fa fa-trash"></i>
            </button>
            {'Selected sheet'|i18n( 'design/standard/content/datatype' )}: {$attribute_content.data_source_params.selected_sheet}
        </p>
    {/if}
{else}
    <em class="attribute-description">
        {'Share your google spreadsheet as "Public" or "Anyone with link" using Share button and publish it to the web (via "File/Publish to the web..." menu)'|i18n( 'design/standard/content/datatype' )}
    </em>
    <div class="row">
        <div class="col-9">
            <label class="d-none form-control" for="select_google_sheet_url_{$attribute.id}">
                {'Select Url'|i18n('occhart/attribute')}
            </label>
            <input id="select_google_sheet_url_{$attribute.id}"
                   placeholder="{'Select Url'|i18n('occhart/attribute')}"
                   class="form-control"
                   name="{$attribute_base}_spreadsheet_url_{$attribute.id}" type="text"/>
        </div>
        <div class="col-3">
            <button class="button" type="submit"
                    name="CustomActionButton[{$attribute.id}_google_spreadsheet-select_url]">
                {'Select'|i18n( 'design/standard/content/datatype' )}
            </button>
        </div>
    </div>
{/if}
</div>