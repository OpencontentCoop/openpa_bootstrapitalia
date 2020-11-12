{run-once}
{def $current_language = ezini('RegionalSettings', 'Locale')}
{def $current_locale = fetch( 'content', 'locale' , hash( 'locale_code', $current_language ))}
{def $moment_language = $current_locale.http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}
<script>
    $.opendataTools.settings('language', "{$current_language}");
    $.opendataTools.settings('locale', "{$moment_language}");
</script>
{literal}
<script id="tpl-remote-gui-spinner" type="text/x-jsrender">
<div class="col-xs-12 spinner text-center py-5">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw py-5"></i>
    <span class="sr-only">{'Loading...'|i18n('editorialstuff/dashboard')}</span>
</div>
</script>
<script id="tpl-remote-gui-list" type="text/x-jsrender">
	{{if totalCount == 0}}
	    <div class="row">
            <div class="col text-center py-4">
                <i class="fa fa-times"></i> {/literal}{'No contents'|i18n('opendata_forms')}{literal}
            </div>
        </div>
	{{else}}
        <div class="{{if itemsPerRow == 'auto'}}card-columns{{else}}row card-h-100 mx-lg-n3 row-cols-1 row-cols-md-2 row-cols-lg-{{:itemsPerRow}}{{/if}}">
        {{for searchHits ~itemsPerRow=itemsPerRow}}
        {{if ~itemsPerRow !== 'auto'}}<div class="px-3 pb-3">{{/if}}
        {{if ~i18n(extradata, 'view') && !useCustomTpl}}
			{{:~i18n(extradata, 'view')}}
		{{else}}
            <div class="card card-teaser rounded shadow" style="text-decoration:none !important">
                {{include tmpl="#tpl-remote-gui-item"/}}
            </div>
        {{/if}}
        {{if ~itemsPerRow !== 'auto'}}</div>{{/if}}
        {{/for}}
        </div>
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
{/literal}
{/run-once}
{literal}
<script id="tpl-remote-gui-item" type="text/x-jsrender">
    {{if ~i18n(extradata, 'view') && !useCustomTpl}}
        {{:~i18n(extradata, 'view')}}
    {{else}}
        {{include tmpl=customTpl /}}
    {{/if}}
</script>
{/literal}