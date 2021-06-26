{if is_set($attribute_content.data_source_params.original_filename)}
    {* Current file. *}
    <p>
        <button class="button" type="submit"
                name="CustomActionButton[{$attribute.id}_binary_file-delete_binary]"
                title="{'Remove the file from this draft.'|i18n( 'design/standard/content/datatype' )}">
            <i class="fa fa-trash"></i>
        </button>
        {$attribute_content.data_source_params.original_filename|wash( xhtml )}
    </p>
{else}
    <input type="hidden" name="MAX_FILE_SIZE" value="80000000"/>
    <div class="row">
        <div class="col">
            <input class="form-control"
                   name="{$attribute_base}_data_binaryfilename_{$attribute.id}" type="file"/>
        </div>
        <div class="col">
            <button class="button" type="submit"
                    name="CustomActionButton[{$attribute.id}_binary_file-upload_binary]">
                {'Upload'|i18n( 'design/standard/content/datatype' )}
            </button>
        </div>
    </div>
{/if}