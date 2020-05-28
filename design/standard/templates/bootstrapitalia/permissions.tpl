{ezpagedata_set('show_path', false())}
{def $parent_node_id = ezini("UserSettings", "DefaultUserPlacement")}
{def $editor_object = fetch(content, object, hash('remote_id', 'editors_base'))}
{if $editor_object}
    {def $editor_node_id = fetch(content, object, hash('remote_id', 'editors_base')).main_node_id}
    {def $available_groups = fetch(content, list, hash('parent_node_id', $editor_node_id, 'class_filter_type', 'include', 'class_filter_array', array('user_group'), 'sort_by', array('name', 'asc')))}

    <div class="row">
        <div class="col-12">
            <h3>Gestione accessi redazione</h3>
        </div>
        <div class="col-11">
            <div class="input-group">
                <input type="text" class="form-control" id="name">
                <div class="input-group-append">
                    <button class="btn btn-info rounded-0" type="button" id="FindContents">Cerca</button>
                    <button class="btn btn-danger rounded-0" type="button" style="display: none;" id="ResetContents">Annulla ricerca</button>
                </div>
            </div>
        </div>
        <div class="col-1">
            <button type="submit" class="btn btn-success rounded-0" id="AddContent" title="Crea nuovo utente">
                <i class="fa fa-plus"></i>
            </button>
        </div>
        <div class="col-12">
            <p class="font-weight-bold m-0">Filtra per tipologia di utenza:</p>
            <div class="form-check form-check-inline">
                <input class="filter" id="user" data-filterclass="user" type="checkbox">
                <label for="user">Utente</label>
            </div>
            <div class="form-check form-check-inline">
                <input class="filter" id="employee" data-filterclass="employee" type="checkbox">
                <label for="employee">Dipendente</label>
            </div>
            <div class="form-check form-check-inline">
                <input class="filter" id="politico" data-filterclass="politico" type="checkbox">
                <label for="politico">Politico</label>
            </div>
        </div>
        <div class="col-12">
            <p class="font-weight-bold m-0">Filtra per assegnazione del ruolo:</p>
            {foreach $available_groups as $group}
            <div class="form-check form-check-inline">
                <input class="filter" id="path-{$group.node_id}" data-filterpath="{$group.node_id}" type="checkbox">
                <label for="path-{$group.node_id}">{$group.name|wash()}</label>
            </div>
            {/foreach}
        </div>
        <div class="col-12">
            <table class="table table-striped mt-2" id="data">
                <thead>
                <tr style="font-size: .7em">
                    <th>Utente</th>
                    {foreach $available_groups as $group}
                        <th style="text-align: center" data-node="{$group.node_id}">{$group.name|wash()}</th>
                    {/foreach}
                </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>

    <div id="data-modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-body">
                    <div class="clearfix">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    </div>
                    <div id="data-form" class="clearfix p-4"></div>
                </div>
            </div>
        </div>
    </div>


    {ezscript_require(array(
        'jsrender.js',
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

    {literal}
    <script id="tpl-results" type="text/x-jsrender">
    {{for searchHits}}
    <tr>
        <td>
            {{if metadata.classIdentifier == 'user'}}
                <a href="#" class="edit-object" data-object="{{:metadata.id}}">{{:~i18n(metadata.name)}}</a> <br /><small>{{:~i18n(metadata.classDefinition.name)}}</small>
            {{else}}
                {{:~i18n(metadata.name)}} <br /><small>{{:~i18n(metadata.classDefinition.name)}}</small>
            {{/if}}
        </td>

        {{for groups ~current=metadata}}
            <td>
                <div class="toggles">
                    <label for="user-permission-{{:~current.mainNodeId}}-{{:node}}" style="line-height: 1px;text-align:center">
                        <input type="checkbox" data-user="{{:~current.mainNodeId}}" data-group="{{:node}}" id="user-permission-{{:~current.mainNodeId}}-{{:node}}" name="UserPermission" {{if active}}checked = "checked"{{/if}} />
                        <span class="lever" style="margin-top: 0;display: inline-block;float:none"></span>
                    </label>
                </div>
            </td>
        {{/for}}
    </tr>
    {{/for}}
    {{if prevPageQuery || nextPageQuery }}
    <tr>
        <td colspan="{{:colSpan}}">
            {{if prevPageQuery}}
                <div class="pull-left"><a href="#" id="prevPage" data-query="{{>prevPageQuery}}">Pagina precedente</a></div>
            {{/if}}
            {{if nextPageQuery }}
                <div class="pull-right"><a href="#" id="nextPage" data-query="{{>nextPageQuery}}">Pagina successiva</a></div>
            {{/if}}
        </td>
    </tr>
    {{/if}}
    </script>
    {/literal}

    <script type="text/javascript" language="javascript">
        var Groups = [{foreach $available_groups as $group}{ldelim}name: '{$group.name|wash()}',node: {$group.node_id}, object: {$group.contentobject_id}, active: false{rdelim}{delimiter},{/delimiter}{/foreach}];
        var ParentNodeId = {$parent_node_id};
        var ContainerSelector = "#data";
        var FormSelector = "#data-form";
        var ModalSelector = "#data-modal";
        {literal}

        $(document).ready(function () {

            var baseUrl = '/';
            if (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/'){
                baseUrl = UriPrefix + '/';
            }

            var tools = $.opendataTools;
            $.views.helpers(tools.helpers);

            var pageLimit = 50;
            var template = $.templates('#tpl-results');
            var $container = $(ContainerSelector).find('tbody');
            var resetButton = $('#ResetContents');

            var currentPage = 0;
            var queryPerPage = [];

            var buildQuery = function(){
                var mainQuery = "((raw[meta_class_identifier_ms] = 'user' and raw[meta_path_si] = ["+ParentNodeId+"]) or (raw[meta_class_identifier_ms] in [politico,employee])) sort [name=>asc] limit " + pageLimit;
                var filters = '';
                var showReset = false;

                var filterClasses = [];
                var checkedClassFilters = $('[data-filterclass]:checked');
                checkedClassFilters.each(function () {
                    filterClasses.push($(this).data('filterclass'));
                });
                if (filterClasses.length > 0){
                    filters += 'classes [' + filterClasses.join(',') + '] and ';
                    showReset = true;
                }

                var filterPath = [];
                var checkedPathFilters = $('[data-filterpath]:checked');
                checkedPathFilters.each(function () {
                    filterPath.push($(this).data('filterpath'));
                });
                if (filterPath.length > 0){
                    filters += 'raw[meta_path_si] in [' + filterPath.join(',') + '] and ';
                    showReset = true;
                }

                var name = $('#name').val();
                if (name.length > 0) {
                    filters += 'q = "' + name + '" and ';
                    showReset = true;
                }

                if (showReset){
                    resetButton.show();
                }else{
                    resetButton.hide();
                }

                return filters + mainQuery;
            };

            var runQuery = function (query) {
                tools.find(query, function (response) {
                    queryPerPage[currentPage] = query;
                    response.currentPage = currentPage;
                    response.prevPageQuery = jQuery.type(queryPerPage[currentPage - 1]) === "undefined" ? null : queryPerPage[currentPage - 1];
                    response.colSpan = Groups.length + 1;

                    $.each(response.searchHits, function(){
                        var currentParentNodes = this.metadata.parentNodes;
                        this.baseUrl = baseUrl;
                        var groups = [];
                        $.each(Groups, function () {
                            var group = $.extend({}, this);
                            if ($.inArray(group.node, currentParentNodes) > -1){
                                group.active = true;
                            }
                            groups.push(group);
                        });
                        this.groups = groups;
                    });
                    var renderData = $(template.render(response));

                    renderData.find('[name="UserPermission"]').on('change', function (e) {
                        var self = $(this);
                        var user = self.data('user');
                        var group = self.data('group');
                        var action = self.is(':checked') ? 'add' : 'remove';
                        $.ajax({
                            url: '/bootstrapitalia/permissions/'+action+'/'+user+'/'+group,
                            type: 'get',
                            dataType: 'json',
                            success: function (response) {
                                if (response.code !== 'success'){
                                    self.prop('checked', action !== 'add');
                                }
                            },
                            error: function () {
                                self.prop('checked', action !== 'add');
                            }
                        });
                    });

                    renderData.find('.edit-object').on('click', function (e) {
                        var object = $(this).data('object');
                        $(FormSelector).opendataFormEdit({'object': object},{
                            onBeforeCreate: function () {$(ModalSelector).modal('show');},
                            onSuccess: function () {$(ModalSelector).modal('hide');runQuery(query);}
                        });
                        e.preventDefault();
                    });

                    $container.html(renderData);

                    $container.find('#nextPage').on('click', function (e) {
                        currentPage++;
                        runQuery($(this).data('query'));
                        e.preventDefault();
                    });

                    $container.find('#prevPage').on('click', function (e) {
                        currentPage--;
                        runQuery($(this).data('query'));
                        e.preventDefault();
                    });
                });
            };

            var loadContents = function () {
                runQuery(buildQuery());
            };

            $('input.filter').on('change', function (e) {
                currentPage = 0;
                loadContents();
            });

            $('#FindContents').on('click', function (e) {
                currentPage = 0;
                loadContents();
                e.preventDefault();
            });

            resetButton.on('click', function (e) {
                $('#name').val('');
                $('input.filter').prop('checked', false);
                resetButton.hide();
                currentPage = 0;
                loadContents();
                e.preventDefault();
            });

            $('#AddContent').on('click', function (e) {
                $(FormSelector).opendataFormCreate({
                        class: 'user',
                        parent: ParentNodeId
                    },{
                        onBeforeCreate: function () {$(ModalSelector).modal('show');},
                        onSuccess: function () {
                            $(ModalSelector).modal('hide');
                            $('#ResetContents').trigger('click');
                        }
                    }
                );
                e.preventDefault();
            });

            loadContents();
        });
    {/literal}
    </script>
{else}
    <div class="message-error">Errore di configurazione. Si prega di contattare il supporto.</div>
{/if}