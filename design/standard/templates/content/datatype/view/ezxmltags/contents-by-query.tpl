{def $block = page_block(
    "",
    "OpendataRemoteContents",
    "default",
    hash(
        "remote_url", "",
        "query", $query,
        "show_grid", "1",
        "show_map", "0",
        "show_search", "0",
        "limit", $limit,
        "items_per_row", "2",
        "facets", "",
        "view_api", $view,
        "color_style", "",
        "fields", "",
        "template", "",
        "simple_geo_api", "0",
        "input_search_placeholder", "",
        "hide_if_empty", "0"
    )
)}
<div class="font-sans-serif my-3">
    {if and(is_set( $title ), $title)}<p class="h2">{$title|wash}</p>{/if}
{block_view_gui
    block_index=0
    items_per_row=2
    container_styles=''
    is_homepage=false()
    wrapper_class="position-relative"
    block=$block}

<script>
    $.opendataTools.settings('language', "{ezini('RegionalSettings', 'Locale')}");
    $.opendataTools.settings('locale', "{fetch( 'content', 'locale' , hash( 'locale_code', ezini('RegionalSettings', 'Locale') )).http_locale_code|explode('-')[0]|downcase()|extract_left( 2 )}");
</script>
{literal}
<script id="tpl-remote-gui-spinner" type="text/x-jsrender">
<div class="col-xs-12 spinner{{if paginationStyle == 'reload'}} text-center py-5{{/if}}">
    <i aria-hidden="true" class="fa fa-circle-o-notch fa-spin fa-fw {{if paginationStyle == 'reload'}}fa-3x py-5{{else}}fa-2x{{/if}}"></i>
    <span class="sr-only">{'Loading...'|i18n('editorialstuff/dashboard')}</span>
</div>
</script>
<script id="tpl-remote-gui-list" type="text/x-jsrender">
	{{if totalCount == 0}}
	    <div class="row">
            <div class="col text-center py-4">
                <i aria-hidden="true" class="fa fa-times"></i> {/literal}{'No contents'|i18n('opendata_forms')}{literal}
            </div>
        </div>
	{{else paginationStyle === 'append' || view === 'latest_messages_item'}}
	    {{if currentPage == 0}}
			<p class="mb-4 results-count"><strong>{{:totalCount}}</strong> {{if totalCount > 1}}{/literal}{'contents found'|i18n('bootstrapitalia')}{literal}{{else}}{/literal}{'contenuto trovato'|i18n('bootstrapitalia')}{literal}{{/if}}</p>
		{{/if}}
		{{for searchHits}}
          {{:~i18n(extradata, 'view')}}
		{{/for}}
		{{if nextPageQuery}}
			<button type="button" data-page="{{>nextPage}}" class="nextPage btn btn-outline-primary pt-15 pb-15 pl-90 pr-90 mb-30 mt-3 mb-lg-50 full-mb text-button" data-element="load-other-cards">
			   <span class="">{/literal}{'Load more results'|i18n('bootstrapitalia')}{literal}</span>
			</button>
		{{else}}
			<p class="text-paragraph-regular-medium mt-4 mb-0">{/literal}{'No other results'|i18n('bootstrapitalia')}{literal}</p>
		{{/if}}
	{{else}}
	    <div class="row mx-lg-n3{{if !autoColumn && itemsPerRow != 'auto'}} row-cols-1 row-cols-md-2 row-cols-lg-{{:itemsPerRow}}{{/if}}"{{if itemsPerRow == 'auto'}} data-bs-toggle="masonry"{{/if}}>
            {{if autoColumn}}<div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-{{:itemsPerRow}}">{{/if}}
            {{for searchHits ~contentIcon=icon ~itemsPerRow=itemsPerRow ~autoColumn=autoColumn}}
            {{if !~autoColumn}}<div class="{{if ~itemsPerRow == 'auto'}}col-sm-6 col-lg-4 mb-4 card-wrapper card-teaser-wrapper card-teaser-masonry-wrapper{{else}}px-3 pb-3{{/if}}">{{/if}}
            {{if ~i18n(extradata, 'view') && !useCustomTpl}}
                {{:~i18n(extradata, 'view')}}
            {{else}}
                <div class="card card-teaser rounded shadow" style="text-decoration:none !important">
                    {{include tmpl="#tpl-remote-gui-item"/}}
                </div>
            {{/if}}
            {{if !~autoColumn}}</div>{{/if}}
            {{/for}}
            {{if autoColumn}}</div>{{/if}}
        </div>
        {{if pageCount > 1}}
        <div class="row mt-lg-4">
            <div class="col">
                <nav class="pagination-wrapper justify-content-center" aria-label="{/literal}{'Navigation'|i18n('design/ocbootstrap/menu')}{literal}">
                    <ul class="pagination" style="list-style-type:none !important">
                        <li class="page-item {{if !prevPageQuery}}disabled{{/if}}" style="margin-left:0">
                            <a class="page-link prevPage" {{if prevPageQuery}}data-page="{{>prevPage}}"{{/if}} href="#">
                                <svg class="icon icon-primary" aria-label="{/literal}{"Previous"|i18n("design/admin/navigator")}{literal}">
                                    <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-left"></use>
                                </svg>
                                <span class="sr-only">{/literal}{"Previous"|i18n("design/admin/navigator")}{literal}</span>
                            </a>
                        </li>
                        {{for pages ~current=currentPage}}
                            <li class="page-item" style="margin-left:0"><a href="#" class="page-link page" data-page_number="{{:page}}" data-page="{{:query}}"{{if ~current == query}} data-current aria-current="page"{{/if}}>{{:page}}</a></li>
                        {{/for}}
                        <li class="page-item {{if !nextPageQuery}}disabled{{/if}}" style="margin-left:0">
                            <a class="page-link nextPage" {{if nextPageQuery}}data-page="{{>nextPage}}"{{/if}} href="#">
                                <span class="sr-only">{/literal}{"Next"|i18n("design/admin/navigator")}{literal}</span>
                                <svg class="icon icon-primary" aria-label="{/literal}{"Next"|i18n("design/admin/navigator")}{literal}">
                                    <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-right"></use>
                                </svg>
                            </a>
                        </li>
                    </ul>
                </nav>
            </div>
        </div>
        {{/if}}
	{{/if}}
</script>
{/literal}
</div>
{undef $block}

