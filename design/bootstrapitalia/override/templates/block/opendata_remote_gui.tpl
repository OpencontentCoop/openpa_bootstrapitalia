{def $openpa = object_handler($block)}

{def $showMap = $block.custom_attributes.show_map
	 $showSearch = $block.custom_attributes.show_search
	 $searchPlaceholder = $block.custom_attributes.input_search_placeholder
	 $query = $block.custom_attributes.query
	 $limit = $block.custom_attributes.limit
	 $itemsPerRow = $block.custom_attributes.items_per_row
	 $fields = $block.custom_attributes.fields
	 $remoteUrl = $block.custom_attributes.remote_url|trim('/')}

<div class="row" id="remote-gui-{$block.id}">
    <div class="col-12 col-md-9">
        {include uri='design:parts/block_name.tpl'}
    </div>
    <div class="col-12 col-md-3">
        <ul class="nav d-block nav-pills border-bottom border-primary text-right{if $showMap|not()} hide{/if}">
            <li class="nav-item pr-1 text-center d-inline-block">
                <a data-toggle="tab"
                   class="nav-link active rounded-0 view-selector"
                   href="#remote-gui-{$block.id}-list">
                    <i class="fa fa-list" aria-hidden="true"></i> <span class="sr-only"> {'List'|i18n('editorialstuff/dashboard')}</span>
                </a>
            </li>
            {if $showMap}
            <li class="nav-item text-center d-inline-block">
                <a data-toggle="tab"
                   class="nav-link rounded-0 view-selector"
                   href="#remote-gui-{$block.id}-geo">
                    <i class="fa fa-map" aria-hidden="true"></i> <span class="sr-only">{'Map'|i18n('extension/ezgmaplocation/datatype')}</span>
                </a>
            </li>
            {/if}
            {if $showSearch}
            <li class="nav-item text-center d-inline-block">
                <a class="nav-link rounded-0 search-form-toggle"
                   href="#">
                    <i class="fa fa-search" aria-hidden="true"></i>
                </a>
            </li>
            {/if}
        </ul>
        {if $showSearch}
            <div class="input-group mb-3 search-form{if $showMap} hide{/if}">
                <input type="text" class="form-control" placeholder="{$searchPlaceholder|wash()}" />
                <div class="input-group-append">
                    <button class="btn btn-outline-secondary" type="button"><i class="fa fa-search" aria-hidden="true"></i></button>
                </div>
            </div>
        {/if}
    </div>
    <div class="col-12">
        <div class="items tab-content">
            <section id="remote-gui-{$block.id}-list" class="tab-pane active pt-0 pl-0"></section>
            {if $showMap}
            <section id="remote-gui-{$block.id}-geo" class="tab-pane p-0">
                <div id="remote-gui-{$block.id}-map" style="width: 100%; height: 700px"></div>
            </section>
            {/if}
        </div>
    </div>
</div>

{ezscript_require(array(
    'leaflet.js',
    'leaflet.markercluster.js',
    'leaflet.makimarkers.js',
    'jsrender.js',
    'jquery.opendata_remote_gui.js'
))}

<script>
$(document).ready(function () {ldelim}
    moment.locale($.opendataTools.settings('locale'));
    $.views.helpers($.extend({ldelim}{rdelim}, $.opendataTools.helpers, {ldelim}
        'remoteUrl': function (remoteUrl, id) {ldelim}
            return remoteUrl+'/openpa/object/' + id;
        {rdelim}
    {rdelim}));
    $("#remote-gui-{$block.id}").remoteContentsGui({ldelim}
        'remoteUrl': "{$remoteUrl}",
        'spinnerTpl': '#tpl-remote-gui-spinner',
        'listTpl': '#tpl-remote-gui-list',
        'popupTpl': '#tpl-remote-gui-item',
        'itemsPerRow': {$itemsPerRow},
        'limitPagination': {$limit},
        'query': "{$query|wash(javascript)}"{if $fields|ne('')},
        'fields': ['{$fields|explode(',')|implode("','")}']{/if}
    {rdelim});
{rdelim});
</script>

{undef $showMap $showSearch $searchPlaceholder $query $limit $itemsPerRow $fields $remoteUrl}

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
        <div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-{{:itemsPerRow}}">
        {{for searchHits}}
            {{include tmpl="#tpl-remote-gui-item"/}}
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
<script id="tpl-remote-gui-item" type="text/x-jsrender">
<div class="card card-teaser rounded shadow" style="text-decoration:none !important">
    <div class="card-body">
        <h5 class="card-title">
            {{:~i18n(metadata.name)}}
        </h5>
        <div style="padding-bottom: 34px;">
            {{for fields ~current=data}}
                {{if ~i18n(~current, #data)}}<div class="card-text">{{:~i18n(~current, #data)}}</div>{{/if}}
            {{/for}}
        </div>
        <a class="read-more" href="{{:~remoteUrl(remoteUrl, metadata.id)}}">
            <span class="text">Leggi di più</span>
            <svg class="icon"><use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-arrow-right"></use></svg>
        </a>
    </div>
</div>
</script>
{/literal}
{/run-once}