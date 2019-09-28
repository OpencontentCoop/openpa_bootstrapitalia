{*$class_content.class_constraint_list|contains( 'image', 'file', 'file_pdf' )		 *}
{if and( is_set( $class_content.class_constraint_list ),
		 $class_content.class_constraint_list|count|ne( 0 ),
     ezini( 'ObjectRelationsMultiupload', 'ClassAttributeIdentifiers', 'ocoperatorscollection.ini' )|contains( $attribute.contentclass_attribute_identifier )     
)}

<div id="{concat('multiupload-', $attribute.id, '-container')}" class="d-inline-block ml-1">
    <span class="btn btn-sm btn-info fileinput-button">
        <i class="spinner fa a fa-circle-o-notch fa-spin" style="display: none"></i>
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="17" viewBox="0 0 20 17"><path d="M10 0l-5.2 4.9h3.3v5.1h3.8v-5.1h3.3l-5.2-4.9zm9.3 11.5l-3.2-2.1h-2l3.4 2.6h-3.5c-.1 0-.2.1-.2.1l-.8 2.3h-6l-.8-2.2c-.1-.1-.1-.2-.2-.2h-3.6l3.4-2.6h-2l-3.2 2.1c-.4.3-.7 1-.6 1.5l.6 3.1c.1.5.7.9 1.2.9h16.3c.6 0 1.1-.4 1.3-.9l.6-3.1c.1-.5-.2-1.2-.7-1.5z"/></svg>
        <span>{'Upload file'|i18n('bootstrapitalia')}</span>
        <!-- The file input field used as target for the file upload widget -->
        <input id="{concat('multiupload-', $attribute.id)}" type="file" name="files[]" multiple>
    </span>
</div>

{def $start_node = cond( and( is_set( $class_content.default_placement.node_id ), $class_content.default_placement.node_id|ne( 0 ) ),
                                $class_content.default_placement.node_id,
								'auto' )}

<script type="text/javascript">
{literal}
$(function () {
    'use strict';
    $({/literal}'#{concat('multiupload-', $attribute.id)}'{literal}).fileupload({
        url: {/literal}{concat('ocbtools/upload/',$attribute.id, '/', $attribute.version, '/', $start_node)|ezurl()}{literal},
        acceptFileTypes: "{/literal}{$attribute|multiupload_file_types_string_from_attribute()}{literal}",
        dataType: 'json',
        autoUpload: true,
        submit: function (e, data) {
            $("{/literal}#{concat('multiupload-', $attribute.id, '-container')}{literal} .spinner").show();
            $("{/literal}#{concat('multiupload-', $attribute.id, '-container')}{literal} .add").hide();
        },
        done: function (e, data) {
            if ( data.result.errors.length > 0 ){
                alert('Error');
                $("{/literal}#{concat('multiupload-', $attribute.id, '-container')}{literal} .spinner").hide();
                $("{/literal}#{concat('multiupload-', $attribute.id, '-container')}{literal} .add").show();
            }else{
                var container = $("{/literal}#{concat('multiupload-', $attribute.id, '-container')}{literal} .spinner").hide();
                var id = data.result.contentobject_id;
                var priority = parseInt(container.parent().prev().find('input[name^="ContentObjectAttribute_priority"]:last-child').val()) || 0;
                priority++;
                $.ez('ezjsctemplate::relation_list_row::'+id+'::{/literal}{$attribute.id}{literal}::'+priority+'::?ContentType=json', false, function(content){
                    if (content.error_text.length) {
                        alert(content.error_text);
                    }else{
                        var table = container.parents( ".ezcca-edit-datatype-ezobjectrelationlist" ).find('table').show().removeClass('hide');
                        table.find('tr.hide').before(content.content);
                        table.find('.ezobject-relation-remove-button').removeClass('hide');
                    }
                    $("{/literal}#{concat('multiupload-', $attribute.id, '-container')}{literal} .spinner").hide();
                    $("{/literal}#{concat('multiupload-', $attribute.id, '-container')}{literal} .add").show();
                });
            }
        }
    }).prop('disabled', !$.support.fileInput)
            .parent().addClass($.support.fileInput ? undefined : 'disabled');
});
{/literal}
</script>

{/if}