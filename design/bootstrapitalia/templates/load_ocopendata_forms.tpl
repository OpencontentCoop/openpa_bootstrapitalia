{run-once}
{ezscript_require(array(
    'handlebars.min.js',
    'bootstrap-datetimepicker.min.js',
    'jquery.fileupload.js',
    'jquery.fileupload-ui.js',
    'jquery.fileupload-process.js',
    'jquery.caret.min.js',
    'jquery.tag-editor.js',
    'alpaca.js',
    'jquery.price_format.min.js',
    'jquery.opendatabrowse.js',
    'jstree.min.js',
    'fields/OpenStreetMap.js',
    'fields/RelationBrowse.js',
    'fields/LocationBrowse.js',
    'fields/Tags.js',
    'fields/Ezxml.js',
    'fields/Tree.js',
    ezini('JavascriptSettings', 'IncludeScriptList', 'ocopendata_connectors.ini'),
    'jquery.opendataform.js'
))}
{def $plugin_list = ezini('EditorSettings', 'Plugins', 'ezoe.ini',,true() )
     $ez_locale = ezini( 'RegionalSettings', 'Locale', 'site.ini')
     $language = '-'|concat( $ez_locale )
     $dependency_js_list = array( 'ezoe::i18n::'|concat( $language ) )}
{foreach $plugin_list as $plugin}
    {set $dependency_js_list = $dependency_js_list|append( concat( 'plugins/', $plugin|trim, '/editor_plugin.js' ))}
{/foreach}
<script id="tinymce_script_loader" type="text/javascript" src={"javascript/tiny_mce_jquery.js"|ezdesign} charset="utf-8"></script>
{ezscript( $dependency_js_list )}

{ezcss_require(array(
    'alpaca.min.css',
    'bootstrap-datetimepicker.min.css',
    'jquery.fileupload.css',
    'jquery.tag-editor.css',
    'alpaca-custom.css',
    'jstree.min.css'
))}
<script>{literal}
$(document).ready(function(){
    $.opendataFormSetup({
        i18n: {{/literal}
            'store': "{'Store'|i18n('opendata_forms')}",
            'cancel': "{'Cancel'|i18n('opendata_forms')}",
            'storeLoading': "{'Loading...'|i18n('opendata_forms')}",
            'cancelDelete': "{'Cancel deletion'|i18n('opendata_forms')}",
            'confirmDelete': "{'Confirm deletion'|i18n('opendata_forms')}"
        {literal}}
    });

    $(document).on('click', "[data-edit]", function(e){
        var object = $(this).data('edit');
        var attribute = $(this).data('attribute');
        var priority = $(this).data('priority');
        var container = $(this).parents('tr');
        $('#relation-form').opendataFormEdit(
            {
                'object': object
            },
            {
                onBeforeCreate: function () {$('#relation-modal').modal('show');},
                onSuccess: function () {
                    $('#relation-modal').modal('hide');
                    $.ez('ezjsctemplate::relation_list_row::'+object+'::'+attribute+'::'+priority+'::?ContentType=json', false, function(response){
                        container.replaceWith(response.content);
                    });
                }
            }            
        );
        e.preventDefault();
    });
    $(document).on('click', "[data-remove]", function(e){
        var object = $(this).data('remove');
        var attribute = $(this).data('attribute');
        var priority = $(this).data('priority');
        var container = $(this).parents('tr');
        $('#relation-form').opendataFormDelete(object,
            {
                onBeforeCreate: function () {$('#relation-modal').modal('show');},
                onSuccess: function () {
                    $('#relation-modal').modal('hide');
                    container.remove();
                }
            }            
        );
        e.preventDefault();
    });   
});
{/literal}</script>
<div id="relation-modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
                </div>
                <div id="relation-form" class="clearfix p-4"></div>
            </div>
        </div>
    </div>
</div>
{/run-once}