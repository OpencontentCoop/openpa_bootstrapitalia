{ezpagedata_set( 'has_container', true() )}
{def $remoteUrl = $node.object.data_map.remote_endpoint.content}
{def $query = cond($node.object.data_map.query.has_content, $node.object.data_map.query.content, 'sort [published=>desc]')}
{def $destination = $node.object.data_map.parent.content}
<section class="container">
    <div class="row">
        <div class="col">
            <h1>{$node.name|wash()}</h1>
            <h6><code>{$remoteUrl} - {$query}</code></h6>

            <div id="remote-gui">
                <div class="input-group mb-3 search-form">
                    <input type="text" class="form-control" placeholder="Cerca" />
                    <div class="input-group-append">
                        <button class="btn btn-link text-black" type="button"><i aria-hidden="true" class="fa fa-search" aria-hidden="true"></i></button>
                    </div>
                </div>
                <a class="active view-selector hide" href="#remote-gui-list">{'List'|i18n('editorialstuff/dashboard')}</a>
                <div class="items">
                    <section id="remote-gui-list"></section>
                </div>
            </div>

        </div>
    </div>
</section>
{include uri='design:load_ocopendata_forms.tpl'}
{ezscript_require(array(
    'jsrender.js',
    'jquery.opendata_remote_gui.js'
))}

<script>
    $(document).ready(function () {ldelim}
        moment.locale($.opendataTools.settings('locale'));
        $.views.helpers($.extend({ldelim}{rdelim}, $.opendataTools.helpers, {ldelim}
            'remoteUrl': function (remoteUrl, id) {ldelim}
                return remoteUrl+'/openpa/object/' + id;
                {rdelim},
            'mainImage': function (remoteUrl, id, css) {ldelim}
                return '<img alt="" src="'+remoteUrl+'/image/view/'+id+'" class="'+css+'" />';
                {rdelim},
            {rdelim}));

        $("#remote-gui").remoteContentsGui({ldelim}
            'remoteUrl': "{$remoteUrl}",
            'spinnerTpl': '#tpl-remote-gui-spinner',
            'listTpl': '#tpl-remote-gui-list',
            'popupTpl': '#tpl-remote-gui-item',
            'limitPagination': 10,
            'query': "{$query|wash(javascript)}",
            {literal}
            'responseCallback': function (response, resultsContainer) {
                // controlla i contenuti già importati
                $.each(response.searchHits, function(){
                    var remoteId = this.metadata.remoteId;
                    $.ajax({
                        type: "GET",
                        url: '/opendata/api/content/read/' + remoteId,
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        cache: true,
                        success: function (data,textStatus,jqXHR) {
                            if(typeof data.error_message === 'string'){
                                resultsContainer.find('span.load[data-remote="'+remoteId+'"]').hide()
                                resultsContainer.find('a.import[data-remote="'+remoteId+'"]').removeClass('hide')
                            }else{
                                resultsContainer.find('span.load[data-remote="'+remoteId+'"]').hide()
                                resultsContainer.find('a.link[data-remote="'+remoteId+'"]').removeClass('hide')
                            }
                        },
                        error: function (jqXHR) {

                        }
                    });
                });

                var form = $('#form');
                var modal = $('#dashboard-modal');
                // espone il form di selezione target
                var showClassMapForm = function(remoteId, missingRelatedRemoteContents){
                    form.alpaca('destroy').opendataForm({
                        rc: '{/literal}{$remoteUrl}{literal}/api/opendata/v2/content/read/' + remoteId,
                        d: '{/literal}{$node.contentobject_id}{literal}'
                    },{
                        connector:'remote_dashboard_select_target',
                        i18n: {
                            'store': 'Prosegui',
                            'storeLoading': 'Attendere...'
                        },
                        onSuccess: function (classMap) {
                            showAttributeMapForm(remoteId, classMap, missingRelatedRemoteContents);
                        }
                    });
                };

                // espone il form di mapping degli attributi
                var showAttributeMapForm = function(remoteId, classMap, missingRelatedRemoteContents){
                    form.alpaca('destroy').opendataForm({
                        tc: classMap.t,
                        rc: '{/literal}{$remoteUrl}{literal}/api/opendata/v2/content/read/' + remoteId,
                        d: '{/literal}{$node.contentobject_id}{literal}'
                    },{
                        connector:'remote_dashboard_map_target',
                        i18n: {
                            'store': 'Prosegui',
                            'storeLoading': 'Attendere...'
                        },
                        onSuccess: function (attributeMap) {
                            missingRelatedRemoteContents = filterMissingRelated(missingRelatedRemoteContents, attributeMap);
                            showImportForm(remoteId, classMap, attributeMap, missingRelatedRemoteContents);
                        }
                    });
                }

                // espone il form di import
                var showImportForm = function(remoteId, classMap, attributeMap, missingRelatedRemoteContents, mapRelatedRemoteContents){
                    if (missingRelatedRemoteContents.length > 0){
                        form.alpaca('destroy').opendataForm({
                            cm: classMap,
                            am: attributeMap,
                            rc: '{/literal}{$remoteUrl}{literal}/api/opendata/v2/content/read/' + remoteId,
                            d: '{/literal}{$node.contentobject_id}{literal}',
                            xr: missingRelatedRemoteContents || [],
                            mr: mapRelatedRemoteContents || []
                        },{
                            connector:'remote_dashboard_manage_relations',
                            i18n: {
                                'store': 'Prosegui',
                                'storeLoading': 'Attendere...'
                            },
                            onSuccess: function (response) {
                                showImportForm(remoteId, classMap, attributeMap, response.missing, response.mapped);
                            }
                        });
                    }else{
                        form.alpaca('destroy').opendataForm({
                            cm: classMap,
                            am: attributeMap,
                            p: {/literal}{if $destination}{$destination.main_node_id}{else}null{/if}{literal},
                            rc: '{/literal}{$remoteUrl}{literal}/api/opendata/v2/content/read/' + remoteId,
                            d: '{/literal}{$node.contentobject_id}{literal}',
                            mr: mapRelatedRemoteContents || []
                        },{
                            connector:'remote_dashboard_import',
                            onSuccess: function (importResult) {
                                modal.modal('hide');
                                resultsContainer.find('a.import[data-remote="'+importResult.content.metadata.remoteId+'"]').addClass('hide');
                                resultsContainer.find('a.link[data-remote="'+importResult.content.metadata.remoteId+'"]').removeClass('hide');
                            }
                        });
                    }
                }

                var filterMissingRelated = function(missingRelatedRemoteContents, attributeMap){
                    var filteredMissingRelatedRemoteContents = [];
                    $.each(attributeMap, function () {
                        if ($.inArray(this.s, missingRelatedRemoteContents) > -1){
                            filteredMissingRelatedRemoteContents.push(this.s);
                        }
                    })

                    return filteredMissingRelatedRemoteContents;
                }

                resultsContainer.find('a.import').on('click', function (e) {
                    e.preventDefault();
                    var remoteId = $(this).data('remote');

                    $.ajax({
                        type: "GET",
                        url: '{/literal}{$remoteUrl}{literal}/api/opendata/v2/content/read/' + remoteId,
                        contentType: "application/json; charset=utf-8",
                        dataType: "jsonp",
                        cache: true,
                        success: function (remoteContent,textStatus,jqXHR) {
                            var sourceClass = remoteContent.metadata.classIdentifier;
                            var missingRelatedRemoteContents = [];
                            $.each(remoteContent.metadata.classDefinition.fields, function () {
                                if (this.dataType === 'ezobjectrelationlist' /*|| this.dataType === 'ezobjectrelation'*/) {
                                    var fieldData = remoteContent.data[$.opendataTools.settings('language')][this.identifier];
                                    if (fieldData.length > 0) {
                                        missingRelatedRemoteContents.push(this.identifier);
                                    }
                                }
                            })
                            $.opendataTools.find('id = {/literal}{$node.contentobject_id}{literal}', function (response) {
                                var dashboard = response.searchHits[0];
                                var mapFound = false;
                                $.each(dashboard.data[$.opendataTools.settings('language')].map, function () {
                                    var map = this;
                                    if (this.s === sourceClass){
                                        mapFound = true;
                                        var classMap = {
                                            's': sourceClass,
                                            't': map.t,
                                        }
                                        var attributeMap = JSON.parse(map.m);
                                        modal.modal('show');
                                        showImportForm(remoteId, classMap, attributeMap, missingRelatedRemoteContents);
                                    }
                                });
                                if (!mapFound){
                                    modal.modal('show');
                                    showClassMapForm(remoteId, missingRelatedRemoteContents);
                                }
                            })
                        }
                    });
                })
            }
            {/literal}
        {rdelim});
    {rdelim});
</script>

{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}
<script>
    $.opendataTools.settings('language', "{$current_language}");
    $.opendataTools.settings('locale', "{$moment_language}");
</script>
{literal}
<script id="tpl-remote-gui-spinner" type="text/x-jsrender">
<div class="row">
    <div class="col spinner text-center py-5">
        <i aria-hidden="true" class="fa fa-circle-o-notch fa-spin fa-3x fa-fw py-5"></i>
        <span class="sr-only">{'Loading...'|i18n('editorialstuff/dashboard')}</span>
    </div>
</div>
</script>
<script id="tpl-remote-gui-list" type="text/x-jsrender">
	{{if pageCount > 1}}
	<div class="row mt-lg-4">
	    <div class="col">
	        <nav class="pagination-wrapper justify-content-center" aria-label="Pagination">
	            <ul class="pagination">
	                <li class="page-item {{if !prevPageQuery}}disabled{{/if}}">
	                    <a class="page-link prevPage" {{if prevPageQuery}}data-page="{{>prevPage}}"{{/if}} href="#">
	                        <svg class="icon icon-primary">
	                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-left"></use>
	                        </svg>
	                        <span class="sr-only">Pagina precedente</span>
	                    </a>
	                </li>
	                {{for pages ~current=currentPage}}
						<li class="page-item"><a href="#" class="page-link page" data-page_number="{{:page}}" data-page="{{:query}}"{{if ~current == query}} data-current aria-current="page"{{/if}}>{{:page}}</a></li>
					{{/for}}
	                <li class="page-item {{if !nextPageQuery}}disabled{{/if}}">
	                    <a class="page-link nextPage" {{if nextPageQuery}}data-page="{{>nextPage}}"{{/if}} href="#">
	                        <span class="sr-only">Pagina successiva</span>
	                        <svg class="icon icon-primary">
	                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-right"></use>
	                        </svg>
	                    </a>
	                </li>
	            </ul>
	        </nav>
	    </div>
	</div>
	{{/if}}
	{{if totalCount == 0}}
	    <div class="row">
            <div class="col text-center py-4">
                <i aria-hidden="true" class="fa fa-times"></i> {/literal}{'No contents'|i18n('opendata_forms')}{literal}
            </div>
        </div>
	{{else}}
        <table class="table table-hover">
        <tr>
            <th>Titolo</th>
            <th>Tipo</th>
            <th>Data</th>
            <th></th>
        </tr>
        {{for searchHits}}
        <tr>
            <td>
                <a target="_blank" href="{{:~remoteUrl(remoteUrl, metadata.id)}}">{{:~i18n(metadata.name)}}</a>
            </td>
            <td style="white-space:nowrap">{{:~i18n(metadata.classDefinition.name)}}</td>
            <td style="white-space:nowrap">{{:~formatDate(metadata.published,'DD/MM/YYYY HH:mm')}}</td>
            <td style="white-space:nowrap;text-align:right">
                <span class="load" href="#" data-remote="{{:metadata.remoteId}}"><i aria-hidden="true" class="fa fa-circle-o-notch fa-spin"></i></span>
                <a class="hide import btn btn-xs btn-warning text-nowrap" href="#" data-remote="{{:metadata.remoteId}}"><i aria-hidden="true" class="fa fa-arrow-up"></i> Importa</a>
                <a class="hide link btn btn-xs btn-success text-nowrap" target="_blank" href="/openpa/object/{{:metadata.remoteId}}" data-remote="{{:metadata.remoteId}}"><i aria-hidden="true" class="fa fa-link"></i> Vedi</a>
            </td>
        </tr>
        {{/for}}
        </table>
	{{/if}}
	{{if pageCount > 1}}
	<div class="row mt-lg-4">
	    <div class="col">
	        <nav class="pagination-wrapper justify-content-center" aria-label="Pagination">
	            <ul class="pagination">
	                <li class="page-item {{if !prevPageQuery}}disabled{{/if}}">
	                    <a class="page-link prevPage" {{if prevPageQuery}}data-page="{{>prevPage}}"{{/if}} href="#">
	                        <svg class="icon icon-primary">
	                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-left"></use>
	                        </svg>
	                        <span class="sr-only">Pagina precedente</span>
	                    </a>
	                </li>
	                {{for pages ~current=currentPage}}
						<li class="page-item"><a href="#" class="page-link page" data-page_number="{{:page}}" data-page="{{:query}}"{{if ~current == query}} data-current aria-current="page"{{/if}}>{{:page}}</a></li>
					{{/for}}
	                <li class="page-item {{if !nextPageQuery}}disabled{{/if}}">
	                    <a class="page-link nextPage" {{if nextPageQuery}}data-page="{{>nextPage}}"{{/if}} href="#">
	                        <span class="sr-only">Pagina successiva</span>
	                        <svg class="icon icon-primary">
	                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-right"></use>
	                        </svg>
	                    </a>
	                </li>
	            </ul>
	        </nav>
	    </div>
	</div>
	{{/if}}
</script>
<script id="tpl-remote-gui-item" type="text/x-jsrender">
<div class="d-flex w-100">
    <div class="card-body p-0">
        <h5 class="card-title">
            {{:~i18n(metadata.name)}}
        </h5>
        <div style="padding-bottom: 34px;">
            {{for fields ~current=data}}
                {{if ~i18n(~current, #data)}}<div class="card-text">{{:~i18n(~current, #data)}}</div>{{/if}}
            {{/for}}
        </div>
        <a class="read-more" href="{{:~remoteUrl(remoteUrl, metadata.id)}}">
            <span class="text">{/literal}{'Read more'|i18n('bootstrapitalia')}{literal}</span>
            <svg class="icon"><use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-arrow-right"></use></svg>
        </a>
    </div>
</div>
</script>
{/literal}

<div id="dashboard-modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
            </div>
            <div class="modal-body pb-5" id="form">
            </div>
        </div>
    </div>
</div>