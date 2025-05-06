{ezpagedata_set( 'has_container', true() )}
<section class="container">
    <div class="row my-5">
        <div class="col">
            <h1 class="h3">{$title|wash()} <span class="badge bg-primary">beta</span> <small class="d-block text-muted">{$tenant.name|wash()} - {$base_url|wash()}</small></h1>
            <p class="lead">
                Elenco dei servizi installati in <b>{$base_url|wash()}</b> con identificativo popolato.<br />
                {*(Se l'identificativo non è popolato, esso viene recuperato dal servizio con il medesimo slug in <em>{$prototype_operation_base_url}</em>, se presente)*}
                È possibile importare le schede dei servizi: i contenuti sono clonati dai prototipi delle schede presenti in <em>{$prototype_content_base_url}</em> in base all'identificativo
            </p>
            {if is_set($error)}
                <div class="alert alert-danger">
                    {$error|wash()}
                </div>
            {/if}
            <div id="remote-gui">
                {*<div class="input-group mb-3 search-form">
                    <input type="text" class="form-control" placeholder="{'Search'|i18n('openpa/search')}"/>
                    <div class="input-group-append">
                        <button class="btn btn-link text-black" type="button"><i aria-hidden="true" class="fa fa-search"
                                                                                 aria-hidden="true"></i></button>
                    </div>
                </div>
                <a class="active view-selector hide"
                   href="#remote-gui-list">{'List'|i18n('editorialstuff/dashboard')}</a>
                   *}
                <div class="items">
                    <table class="table table-hover">
                        <tr>
                            <th>Titolo</th>
                            <th>Identificativo</th>
                            <th></th>
                        </tr>
                    {foreach $services as $service}
                        <tr style="opacity:.5"{if $service.status|ne(1)} class="bg-light"{/if}>
                            <td><strong>{$service.name|wash()}</strong><code style="font-size: small" class="d-block">{$service.id|wash()}</code></td>
                            <td>
                                <code class="size-sm">{$service.identifier|wash()}</code>
                                {if is_set($service._is_prototype_identifier)}
                                    <small style="font-size: small" class="d-block">Identificativo dedotto dal <a href="{$prototype_operation_base_url}/it/admin/servizio/{$service._prototype_id}/edit" target="_blank" rel="noopener" title="{$prototype_operation_base_url}">prototipo</a> <small
                                {/if}
                            </td>
                            <td style="white-space:nowrap;text-align:right">
                                <span data-id="{$service.id|wash()}"
                                      class="load" href="#"
                                      data-remote_identifier="{$service._content_prototype_remote_id|wash()}"
                                      data-identifier="{$service.identifier|wash()}">
                                    <i aria-hidden="true" class="fa fa-circle-o-notch fa-spin"></i>
                                </span>
                                {if $service.identifier}
                                <form method="post" action="{'bootstrapitalia/service_tools'|ezurl(no)}" enctype="multipart/form-data" class="form">
                                    <input data-identifier="{$service.identifier|wash()}" type="hidden" name="identifier" value="{$service.identifier|wash()}" />
                                    <input data-identifier="{$service.identifier|wash()}" type="hidden" name="content_remote_id" value="" />
                                    <input data-identifier="{$service.identifier|wash()}" type="hidden" name="service_id" value="{$service.id|wash()}" />
                                    <button data-identifier="{$service.identifier|wash()}" type="submit" name="ImportService" data-id="{$service.id|wash()}" class="hide import btn btn-xs btn-warning text-nowrap"><i aria-hidden="true" class="fa fa-arrow-up"></i> Importa</button>
                                    <a data-identifier="{$service.identifier|wash()}" data-id="{$service.id|wash()}" class="hide link btn btn-xs btn-success text-nowrap" target="_blank" rel="noopener" href="#" data-remote="#"><i aria-hidden="true" class="fa fa-link"></i> Vedi</a>
                                    <button data-identifier="{$service.identifier|wash()}" type="submit" name="ReImportService" data-id="{$service.id|wash()}" class="hide update btn btn-xs btn-warning text-nowrap"><i aria-hidden="true" class="fa fa-refresh"></i> Reimporta</button>
                                </form>
                                {/if}
                            </td>
                        </tr>
                    {/foreach}
                    </table>
                </div>
                <small id="loading-helper" class="text-muted"></small>
            </div>
        </div>
    </div>
</section>

<script>
    var prototypeBaseUrl = '{$prototype_content_base_url}';
{literal}
    $(document).ready(function () {
      let stateMessage = $('#loading-helper');
      let resultsContainer = $('.items');
      var prefix = UriPrefix === '/' ? '' : UriPrefix;
      $('span.load').each(function () {
        var self = $(this);
        var serviceId = self.data('id');
        var identifier = self.data('identifier');
        if (identifier.length === 0) {
          self.parents('tr').remove();
          //self.css('font-size', 'small').text('Identificativo non trovato');
          return;
        }
        if (identifier.startsWith('http') === true) {
          self.css('font-size', 'small').text('Formato identificativo non valido');
          return;
        }
        stateMessage.text('Cerco i servizi nel sito prototipo ' + prototypeBaseUrl);

        var remoteIdentifier = self.data('remote_identifier')
        if (remoteIdentifier.length > 0){
          stateMessage.text('Cerco i servizi locali con identificatore ' + identifier);
          $.ajax({
            type: "GET",
            url: prefix+'/opendata/api/content/search/classes [public_service] and identifier = \'"' + identifier + '"\' limit 1',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            tryCount: 0,
            retryLimit: 3,
            success: function (localData, textStatus, jqXHR) {
              resultsContainer.find('span.load[data-identifier="' + identifier + '"]').hide();
              resultsContainer.find('input[name="content_remote_id"][data-identifier="' + identifier + '"]').val(remoteIdentifier);
              if (typeof localData.error_message === 'string' || localData.totalCount === 0) {
                resultsContainer.find('button.import[data-identifier="' + identifier + '"]').removeClass('hide');
              } else {
                resultsContainer.find('button.update[data-identifier="' + identifier + '"]').removeClass('hide');
                resultsContainer.find('a.link[data-identifier="' + identifier + '"]').removeClass('hide').attr('href', prefix+'/openpa/object/' + localData.searchHits[0].metadata.remoteId)
              }
              self.parents('tr').css('opacity', 1);
              stateMessage.text('');
            },
            error: function (jqXHR) {
              // this.tryCount++;
              // if (this.tryCount <= this.retryLimit) {
              //   console.log('try again');
              //   $.ajax(this);
              //   return;
              // }
              console.log(jqXHR);
              // self.parents('tr').remove();
              stateMessage.text('');
            }
          });
        }else{
          self.css('font-size', 'small').text('Identificativo non trovato nel prototipo delle schede');
        }
      });
      stateMessage.text('');
    });
{/literal}</script>
{*

{ezscript_require(array('jsrender.js','jquery.opendata_remote_gui.js'))}

<script>
  $(document).ready(function () {ldelim}
    moment.locale($.opendataTools.settings('locale'));
    $.views.helpers($.extend({ldelim}{rdelim}, $.opendataTools.helpers, {ldelim}
      'remoteUrl': function (remoteUrl, id) {ldelim}
        return remoteUrl + '/openpa/object/' + id;
      {rdelim},
      'mainImage': function (remoteUrl, id, css) {ldelim}
        return '<img alt="" src="' + remoteUrl + '/image/view/' + id + '" class="' + css + '" />';
          {rdelim},
      {rdelim}));

    $("#remote-gui").remoteContentsGui({ldelim}
      'remoteUrl': "{$remote_url}",
      'spinnerTpl': '#tpl-remote-gui-spinner',
      'listTpl': '#tpl-remote-gui-list',
      'popupTpl': '#tpl-remote-gui-item',
      'limitPagination': 10,
      'view': false,
      'query': "{$query|wash(javascript)}",
        {literal}
      'responseCallback': function (response, resultsContainer) {
        // controlla i contenuti già importati
        $.each(response.searchHits, function () {
          var remoteId = this.metadata.remoteId;
          var identifier = this.data['ita-IT'].identifier;
          $.ajax({
            type: "GET",
            url: '/opendata/api/content/search/classes [public_service] and identifier = \'"' + identifier + '"\'',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            cache: true,
            success: function (data, textStatus, jqXHR) {
              if (typeof data.error_message === 'string' || data.totalCount === 0) {
                resultsContainer.find('span.load[data-remote="' + remoteId + '"]').hide()
                resultsContainer.find('a.import[data-remote="' + remoteId + '"]').removeClass('hide')
              } else {
                resultsContainer.find('span.load[data-remote="' + remoteId + '"]').hide()
                resultsContainer.find('a.link[data-remote="' + remoteId + '"]').removeClass('hide')
              }
            },
            error: function (jqXHR) {

            }
          });
        });
        resultsContainer.find('a.import').on('click', function (e) {
          e.preventDefault();
          var remoteId = $(this).data('remote');
          console.log(remoteId);
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
	                {{for pages ~current = currentPage}}
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
            <th>Identificativo</th>
            <th>Data</th>
            <th></th>
        </tr>
        {{for searchHits}}
        <tr>
            <td>
                <a target="_blank" rel="noopener noreferrer" href="{{:~remoteUrl(remoteUrl, metadata.id)}}">{{:~i18n(metadata.name)}}</a>
            </td>
            <td style="white-space:nowrap">{{:~i18n(data, 'identifier')}}</td>
            <td style="white-space:nowrap">{{:~formatDate(metadata.published, 'DD/MM/YYYY HH:mm')}}</td>
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
	                {{for pages ~current = currentPage}}
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
            {{for fields ~current = data}}
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
                <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal"><span
                            aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
            </div>
            <div class="modal-body pb-5" id="form">
            </div>
        </div>
    </div>
</div>
*}