{literal}
<script id="tpl-dashboard-list" type="text/x-jsrender">
	<div class="row">
	{{if totalCount == 0}}
	    <div class="col text-center">
            <i class="fa fa-times"></i> {/literal}{'No contents'|i18n('opendata_forms')}{literal}
        </div>
	{{else}}
        <div class="col">
        <table class="table table-striped table-sm">
        {/literal}
            <thead>
                  <tr>
                      <th></th>
                      <th>{'Title'|i18n('editorialstuff/dashboard')}</th>
                      <th>{'Author'|i18n('editorialstuff/dashboard')}</th>
                      <th>{'Published'|i18n('editorialstuff/dashboard')}</th>
                      {if $enable_translations}
                      <th>{'Translations'|i18n('editorialstuff/dashboard')}</th>
                      {/if}
                  </tr>
            </thead>
        {literal}
            <tbody>
            {{for searchHits}}
                {{include tmpl="#tpl-dashboard-item"/}}
            {{/for}}
            </tbody>
        </table>
        </div>
	{{/if}}
	</div>

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

<script id="tpl-dashboard-item" type="text/x-jsrender">
<tr>
    <td>
        <a class="btn btn-link btn-xs label-{{:dashboardStateIdentifier}} text-white" href="{{:baseUrl}}/editorialstuff/edit/{{:factoryIdentifier}}/{{:metadata.id}}">
        {/literal}{'Detail'|i18n('editorialstuff/dashboard')}{literal}
        </a>
    </td>
    <td>{{:~i18n(metadata.name)}}</td>
    <td>{{:~i18n(metadata.ownerName)}}</td>
    <td>{{:~formatDate(metadata.published,'DD/MM/YYYY HH:mm')}}</td>
    {/literal}{if $enable_translations}{literal}
    <td class="text-nowrap">
        <ul class="list-inline">
        {{for translations ~baseUrl=baseUrl ~nodeId=metadata.mainNodeId ~objectId=metadata.id ~factoryIdentifier=factoryIdentifier}}
            {{if active}}
                <li class="list-inline-item align-middle">
                    <img style="display:flex;width: 30px;max-width:none" src="/share/icons/flags/{{:language}}.gif" />
                </li>
            {{else}}
                <li class="list-inline-item align-middle">
                    <form class="form-inline" method="post" action="{{:~baseUrl}}/content/action">
                        <input type="hidden" name="HasMainAssignment" value="1"/>
                        <input type="hidden" name="ContentObjectID" value="{{:~objectId}}"/>
                        <input type="hidden" name="NodeID" value="{{:~nodeId}}"/>
                        <input type="hidden" name="ContentNodeID" value="{{:~nodeId}}"/>
                        <input type="hidden" name="ContentObjectLanguageCode" value=""/>
                        <input type="hidden" name="RedirectIfDiscarded" value="/editorialstuff/dashboard/{{:~factoryIdentifier}}" />
                        <input type="hidden" name="RedirectURIAfterPublish" value="/editorialstuff/edit/{{:~factoryIdentifier}}/{{:~objectId}}" />
                        <input type="image" style="width: 30px;max-width:none;opacity:0.2" name="EditButton" src="/share/icons/flags/{{:language}}.gif" alt="Translate"/>
                    </form>
                </li>
            {{/if}}
        {{/for}}
    </td>
    {/literal}{/if}{literal}
</tr>
</script>

<script id="tpl-item" type="text/x-jsrender">
<div class="card-wrapper card-space">
    <div class="card card-big card-bg rounded shadow no-after">
        <div class="card-body">
            <div class="category-top">
                {{:~formatDate(metadata.published,'DD/MM/YYYY HH:mm')}}
            </div>
            <h5 class="card-title big-heading">
                <a class="stretched-link text-primary text-decoration-none" href="{{:~objectUrl(metadata.id)}}">{{:~i18n(metadata.name)}}</a>
            </h5>
            {{if ~i18n(data,'event_abstract')}}
              {{:~i18n(data,'event_abstract')}}
            {{/if}}
        </div>
    </div>
</div>
</script>
{/literal}
