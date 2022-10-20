{ezpagedata_set( 'has_container', true() )}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {if $node|has_attribute('short_title')}
                <h2 class="h4 py-2">{$node|attribute('short_title').content|wash()}</h2>
            {/if}

            {include uri='design:openpa/full/parts/main_attributes.tpl'}

            {include uri='design:openpa/full/parts/info.tpl'}

        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>


{include uri='design:openpa/full/parts/main_image.tpl'}

<section class="container">
    {include uri='design:openpa/full/parts/attributes.tpl' object=$node.object}
</section>

<div class="container">
    {if $node.children_count}
        <a class="btn btn-success btn-sm my-2" href={concat("exportas/avpc/lotto/",$node.node_id)|ezurl()}>Esporta in formato <abbr title="Xtensible Markup Language">ANAC XML</abbr></a>
    {/if}
    {if $node.can_create}
        <a class="btn btn-info btn-sm my-2 mr-2" href='#' id="AddLotto"><i class="fa fa-plus"></i> {'Add item'|i18n( 'design/standard/block/edit' )}</a>
    {/if}
</div>

{if $node.children_count}
    {include uri='design:zone/default.tpl' zones=array(hash('blocks', array(page_block(
        "",
        "OpendataRemoteContents",
        "datatable",
        hash(
            "remote_url", "",
            "query", concat("classes [lotto] and subtree [", $node.node_id, "]"),
            "show_grid", "0",
            "show_map", "0",
            "show_search", "0",
            "input_search_placeholder", "",
            "limit", "10",
            "items_per_row", "auto",
            "fields", "_link,data_inizio,data_ultimazione,cig,oggetto,sceltacontraente",
            "facets", "",
            "simple_geo_api", "0",
            "template", "",
            "color_style", "",
            "container_style", "",
            "show_all_link", "",
            "show_all_text", ""
        )
    ))))}
{/if}

{if $openpa['content_tree_related'].full.exclude|not()}
    {include uri='design:openpa/full/parts/related.tpl' object=$node.object}
{/if}

{if $node.can_create}
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
        var datatable = $('[data-fields]').find('.content-data');
        $('#AddLotto').on('click', function (e){
            $('#lotto-form').opendataFormCreate({
                'parent': {/literal}{$node.node_id}{literal},
                'class': 'lotto',
            }, {
                onBeforeCreate: function () {
                    $('#lotto-modal').modal('show');
                },
                onSuccess: function () {
                    $('#lotto-modal').modal('hide');
                    datatable.data('opendataDataTable').loadDataTable();
                }
            });
            e.preventDefault();
        })
    });
    {/literal}</script>
    <div id="lotto-modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-body">
                    <div class="clearfix">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
                    </div>
                    <div id="lotto-form" class="clearfix p-4"></div>
                </div>
            </div>
        </div>
    </div>
{/if}
