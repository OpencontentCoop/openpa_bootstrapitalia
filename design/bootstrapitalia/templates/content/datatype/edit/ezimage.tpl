{default attribute_base='ContentObjectAttribute' html_class='full' placeholder=false() }
{let attribute_content=$attribute.content}
<div class="row">
    {if $attribute_content.original.is_valid}
    <div class="col-md-6">
        <div class="img-responsive-wrapper">
            <div class="img-responsive">
                <div class="img-wrapper bg-100">
                    {attribute_view_gui image_class=medium attribute=$attribute}
                </div>
            </div>
        </div>
        <p class="text-sans-serif text-center">{$attribute.content.original.original_filename|wash( xhtml )} <br /><small>{$attribute.content.original.mime_type|wash( xhtml )}{$attribute.content.original.filesize|si( byte )}</small></p>
        <div class="position-absolute" style="top:0">
            <button class="btn btn-sm btn-danger" type="submit" name="CustomActionButton[{$attribute.id}_delete_image]" title="{'Remove image'|i18n( 'design/standard/content/datatype' )}">
                <span class="fa fa-trash"></span>
            </button>
        </div>
    </div>
    {/if}
    <div class="col-md-6">
        <input type="hidden" name="MAX_FILE_SIZE" value="{$attribute.contentclass_attribute.data_int1|mul( 1024, 1024 )}" />
        <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_file"
               class="inputfile"
               name="{$attribute_base}_data_imagename_{$attribute.id}"
               type="file" />
        <label class="btn btn-sm btn-info"
               for="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_file">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="17" viewBox="0 0 20 17"><path d="M10 0l-5.2 4.9h3.3v5.1h3.8v-5.1h3.3l-5.2-4.9zm9.3 11.5l-3.2-2.1h-2l3.4 2.6h-3.5c-.1 0-.2.1-.2.1l-.8 2.3h-6l-.8-2.2c-.1-.1-.1-.2-.2-.2h-3.6l3.4-2.6h-2l-3.2 2.1c-.4.3-.7 1-.6 1.5l.6 3.1c.1.5.7.9 1.2.9h16.3c.6 0 1.1-.4 1.3-.9l.6-3.1c.1-.5-.2-1.2-.7-1.5z"/></svg>
            <span>{'New image file for upload'|i18n( 'design/standard/content/datatype' )}</span>
        </label>

        <div class="form-group">
            <input placeholder="{'Alternative image text'|i18n( 'design/standard/content/datatype' )}" id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_alttext" class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" name="{$attribute_base}_data_imagealttext_{$attribute.id}" type="text" value="{$attribute_content.alternative_text|wash(xhtml)}" />
        </div>
    </div>
</div>
{/let}
{/default}
{run-once}
{ezscript_require(array('jquery.custom-file-input.js'))}
{ezcss_require(array('custom-file-input.css'))}
{/run-once}