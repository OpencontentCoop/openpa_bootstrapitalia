{def $openpa = object_handler($node)}
{ezpagedata_set('is_homepage', false())}

{if fetch(user, current_user).is_logged_in}

    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="cmp-hero">
                    <section class="it-hero-wrapper bg-white d-block">
                        <div class="it-hero-text-wrapper pt-0 ps-0 pb-4">
                            <h1 class="text-black hero-title" data-element="page-name">
                                {$node.name|wash()}
                            </h1>
                        </div>
                    </section>
                </div>

                {def $children_count = fetch( content, list_count, hash( 'parent_node_id', $node.node_id, 'sort_by', $node.sort_array, 'class_filter_type', 'include', 'class_filter_array', array('pagina_sito')))}
                {if $children_count}
                {def $children = fetch( content, list, hash( 'parent_node_id', $node.node_id, 'sort_by', $node.sort_array, 'class_filter_type', 'include', 'class_filter_array', array('pagina_sito')))}
                <div class="row mt-4 mb-5">
                    <div class="col-2">
                        <ul class="nav nav-tabs nav-tabs-vertical" role="tablist" aria-orientation="vertical">
                            {foreach $children as $index => $child}
                                <li class="nav-item">
                                    <a class="nav-link ps-0{if $index|eq(0)} active{/if} mw-100"
                                       data-toggle="tab"
                                       data-bs-toggle="tab" href="#classification-{$child.contentobject_id}"
                                       data-focus-mouse="false">
                                        {$child.name|wash()}
                                    </a>
                                </li>
                            {/foreach}
                        </ul>
                    </div>
                    <div class="col-10 tab-content">
                        {foreach $children as $index => $child}
                            <div class="position-relative clearfix tab-pane p-2 mt-2{if $index|eq(0)} active{/if}"
                                 data-parent="{$child.node_id}"
                                 data-object="{$child.contentobject_id}"
                                 data-classes=""
                                 id="classification-{$child.contentobject_id}">

                                <h2 class="mb-4">{$child.name|wash()}</h2>
                                <div class="content-data"></div>

                            </div>
                        {/foreach}
                    </div>
                </div>
                {else}
                    <div class="position-relative clearfix tab-pane active"
                         data-parent="{$node.node_id}"
                         data-object="{$node.contentobject_id}"
                         data-classes=""
                         id="classification-{$node.contentobject_id}">
                        <div class="content-data"></div>
                    </div>
                {/if}
                {undef $children}
            </div>
        </div>
    </div>

    <div id="modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-body">
                    <div class="clearfix">
                        <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
                    </div>
                    <div id="item" class="clearfix"></div>
                </div>
            </div>
        </div>
    </div>

    {def $current_language = ezini('RegionalSettings', 'Locale')}
    {def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
    {def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}

    <script>
    {literal}
      $(document).ready(function () {
        let datatables = {};
        let initTable = function (container) {
          let id = container.attr('id');
          if (!datatables.hasOwnProperty(id)) {
            let mainQuery = 'subtree ['+ container.data('parent') + '] and id != ' + container.data('object');
            datatables[id] = container.find('.content-data').opendataDataTable({
              builder: {
                query: mainQuery
              },
              table: {
                template: '<table class="table table-hover"></table>'
              },
              datatable: {
                ajax: {
                  url: '{/literal}{'opendata/api/datatable/search'|ezurl(no,full)}{literal}/'
                },
                language: {
                  url: "{/literal}{concat('javascript/datatable/',$current_language,'.json')|ezdesign(no)}{literal}"
                },
                lengthMenu: [20, 40, 60],
                columns: [
                  {
                    data: "metadata.name." + $.opendataTools.settings('language'),
                    name: 'name',
                    title: '{/literal}{'Name'|i18n( 'design/admin/node/view/full' )}{literal}',
                    className: 'align-middle'
                  },
                  {
                    data: "metadata.published",
                    name: 'published',
                    title: '{/literal}{'Published'|i18n( 'design/admin/node/view/full' )}{literal}',
                    className: 'align-middle'
                  },
                  {
                    data: "metadata.modified",
                    name: 'modified',
                    title: '{/literal}{'Modified'|i18n( 'design/admin/node/view/full' )|explode(' ')|implode('&middot;')}{literal}',
                    className: 'align-middle'
                  },
                  {
                    data: "metadata.id",
                    name: 'id',
                    title: '',
                    searchable: false,
                    orderable: false,
                    width: '1',
                    className: 'align-middle'
                  },
                  {
                    data: "metadata.remoteId",
                    name: 'remote_id',
                    title: '',
                    searchable: false,
                    orderable: false,
                    width: '1',
                    className: 'align-middle'
                  }
                ],
                columnDefs: [
                  {
                    render: function (data, type, row) {
                      return $.opendataTools.helpers.i18n(row.metadata.name);
                    },
                    targets: [0]
                  },
                  {
                    render: function (data, type, row) {
                      var date = moment(data, moment.ISO_8601);
                      return date.format('DD/MM/YYYY');

                    },
                    targets: [1, 2]
                  },
                  {
                    render: function (data, type, row) {
                      let output = '<span style="white-space:nowrap">';
                      var currentTranslations = row.metadata.languages;
                      var translations = [];
                      $.each(currentTranslations, function () {
                        output += '<img style="max-width:none;margin-right: 3px" src="/share/icons/flags/' + this + '.gif" />';
                      });
                      output += '</span>';
                      return output;
                    },
                    targets: [3]
                  },
                  {
                    render: function (data, type, row) {
                      let output = '<div style="white-space:nowrap">';
                      output += '<a class="py-2 px-3" target="_blank" href="/openpa/object/' + row.metadata.id + '"><i class="fa fa-external-link"></i></a>';
                      output += '<a class="py-2 px-3" href="#" data-view="' + row.metadata.id + '"><i class="fa fa-eye"></i></a>';
                      output += '<a class="py-2 px-3" href="#" data-edit="' + row.metadata.id + '"><i class="fa fa-pencil"></i></a>';
                      output += '<a class="py-2 px-3" href="#" data-remove="' + row.metadata.id + '"><i class="fa fa-trash"></i></a>';
                      output += '</div>';
                      return output;
                    },
                    targets: [4]
                  },
                ]
              }
            }).on('draw.dt', function (e, settings) {
              let renderData = $(e.currentTarget);
              renderData.find('[data-view]').on('click', function (e) {
                $('#item').opendataFormView({
                  object: $(this).data('view')
                }, {
                  onBeforeCreate: function () {
                    $('#modal').modal('show');
                  },
                  onSuccess: function () {
                    $('#modal').modal('hide');
                  }
                });
                e.preventDefault();
              });
              renderData.find('[data-edit]').on('click', function (e) {
                $('#item').opendataFormEdit({
                  object: $(this).data('edit')
                }, {
                  onBeforeCreate: function () {
                    $('#modal').modal('show');
                  },
                  onSuccess: function () {
                    $('#modal').modal('hide');
                    datatables[id].datatable.ajax.reload(null,false);
                  }
                });
                e.preventDefault();
              });
              renderData.find('[data-remove]').on('click', function (e) {
                $('#item').opendataFormDelete({
                  object: $(this).data('remove')
                }, {
                  onBeforeCreate: function () {
                    $('#modal').modal('show');
                  },
                  onSuccess: function () {
                    $('#modal').modal('hide');
                    datatables[id].datatable.ajax.reload(null,false);
                  }
                });
                e.preventDefault();
              });
            }).data('opendataDataTable');
            datatables[id].loadDataTable();
          }
        };
        $('body').on('shown.bs.tab', function (e) {
          initTable($($(e.target).attr('href')))
        });
        initTable($('.tab-pane.active'))
      });
        {/literal}
    </script>

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
    <script id="tinymce_script_loader" type="text/javascript" charset="utf-8" src={"javascript/tiny_mce_jquery.js"|ezdesign}></script>
    {ezscript( $dependency_js_list )}
    {ezcss_require(array(
        'alpaca.min.css',
        'bootstrap-datetimepicker.min.css',
        'jquery.fileupload.css',
        'jquery.tag-editor.css',
        'alpaca-custom.css',
        'jstree.min.css'
    ))}

{else}
    {include uri=$openpa.control_template.full}
{/if}


{if and($openpa.content_tools.editor_tools, module_params().function_name|ne('versionview'))}
    {include uri=$openpa.content_tools.template}
{/if}
{undef $openpa}