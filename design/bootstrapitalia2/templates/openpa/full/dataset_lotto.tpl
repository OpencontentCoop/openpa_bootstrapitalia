{ezpagedata_set( 'has_container', true() )}

{def $root_node = $openpa.control_menu.side_menu.root_node}
{if or($root_node|not(), $root_node.class_identifier|ne('trasparenza'))}
    {set $root_node = fetch('content', 'tree', hash(
        parent_node_id, 1,
        class_filter_type, 'include',
        class_filter_array, array('trasparenza'),
        limit, 1,
        load_data_map, false()
    ))[0]}
{/if}
{def $tree_menu = tree_menu( hash( 'root_node_id', $root_node.node_id, 'user_hash', $openpa.control_menu.side_menu.user_hash, 'scope', 'side_menu' ))
     $menu_type = openpaini('SideMenu', 'AmministrazioneTrasparenteTipoMenu', 'default')}
{if and($root_node|has_attribute('show_browsable_menu'), $root_node|attribute('show_browsable_menu').data_int|eq(1))}
    {set $menu_type = 'browsable'}
{/if}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            {include uri='design:openpa/full/parts/amministrazione_trasparente/intro.tpl' node=$root_node}
            {include uri='design:openpa/full/parts/info.tpl'}
        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>

<section class="container">
    <div class="row border-top row-column-border row-column-menu-left attribute-list">
        <aside class="col-lg-4">
            <div class="d-block d-lg-none d-xl-none text-center mb-2">
                <a href="#toogle-sidemenu" role="button" class="btn btn-primary btn-md collapsed" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="toogle-sidemenu"><i class="fa fa-bars" aria-hidden="true"></i> {$tree_menu.item.name|wash()}</a>
            </div>
            <div class="d-lg-block d-xl-block collapse" id="toogle-sidemenu">
                <div class="link-list-wrapper menu-link-list pt-2">
                    <ul class="link-list">
                        {foreach $tree_menu.children as $menu_item}
                            {include name=side_menu
                                    uri=cond($menu_type|eq('browsable'), 'design:openpa/full/parts/browsable_side_menu_item.tpl', 'design:openpa/full/parts/side_menu_item.tpl')
                                    menu_item=$menu_item
                                    current_node=$node
                                    max_recursion=3
                                    recursion=1}
                        {/foreach}
                    </ul>
                </div>
            </div>
        </aside>
        <section class="col-lg-8 p-4">
            <h2 class="mb-4">{$node.name|wash()}</h2>
            {include uri='design:openpa/full/parts/attributes_flat.tpl'
                     object=$node.object}

            {if $node.children_count}
                <a class="btn btn-success btn-sm my-2" href={concat("exportas/avpc/lotto/",$node.node_id)|ezurl()}>Esporta in formato <abbr title="Xtensible Markup Language">ANAC XML</abbr></a>
            {/if}
            {if $node.can_create}
                <a class="btn btn-info btn-sm my-2 mr-2 me-2" href='#' id="AddLotto"><i class="fa fa-plus"></i> {'Add item'|i18n( 'design/standard/block/edit' )}</a>
            {/if}

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
        </section>
    </div>
</section>

{undef $root_node $tree_menu}

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
                        <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
                    </div>
                    <div id="lotto-form" class="clearfix p-4"></div>
                </div>
            </div>
        </div>
    </div>
{/if}
