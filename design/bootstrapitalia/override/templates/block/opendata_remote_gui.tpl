{def $openpa = object_handler($block)}

{def $showGrid = cond(is_set($block.custom_attributes.show_grid), $block.custom_attributes.show_grid, true())
     $showMap = $block.custom_attributes.show_map
	 $showSearch = $block.custom_attributes.show_search
	 $searchPlaceholder = $block.custom_attributes.input_search_placeholder
	 $query = $block.custom_attributes.query
	 $limit = $block.custom_attributes.limit
	 $itemsPerRow = $block.custom_attributes.items_per_row
	 $fields = $block.custom_attributes.fields
     $facets = cond(and(is_set($block.custom_attributes.facets), $block.custom_attributes.facets|ne('')), $block.custom_attributes.facets|explode(','), array())
     $facetsFields = array()
	 $remoteUrl = $block.custom_attributes.remote_url|trim('/')}

{if or($showGrid, $showMap)}
<div class="row" id="remote-gui-{$block.id}">
    <div class="col-12 col-md-9">
        {include uri='design:parts/block_name.tpl' no_margin=cond(and($showGrid, $showMap, $showSearch), true(), false())}
    </div>
    <div class="col-12 col-md-3 pr-0">
        <ul class="nav d-block nav-pills border-bottom border-primary text-right{if or($showGrid|not(), $showMap|not())} hide{/if}">
            {if $showGrid}
            <li class="nav-item pr-1 text-center d-inline-block">
                <a data-toggle="tab"
                   class="nav-link active rounded-0 view-selector"
                   href="#remote-gui-{$block.id}-list">
                    <i class="fa fa-list" aria-hidden="true"></i> <span class="sr-only"> {'List'|i18n('editorialstuff/dashboard')}</span>
                </a>
            </li>
            {/if}
            {if $showMap}
            <li class="nav-item text-center d-inline-block">
                <a data-toggle="tab"
                   class="nav-link{if $showGrid|not} active{/if} rounded-0 view-selector"
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
        {if and($showSearch, $facets|count()|eq(0))}
        <div class="input-group mb-3 search-form{if and($showGrid, $showMap)} hide{/if}">
            <input type="text" class="form-control" placeholder="{$searchPlaceholder|wash()}" />
            <div class="input-group-append">
                <button class="btn btn-outline-secondary" type="button"><i class="fa fa-search" aria-hidden="true"></i></button>
            </div>
        </div>
        {/if}
    </div>
    {if and($showSearch, $facets|count())}
        <div class="search-form{if and($showGrid, $showMap)} hide{/if} col-12">
            <div class="row pt-3">
                <div class="col-sm mb-3">
                    <div class="input-group chosen-border">
                        <input type="text" class="form-control border-0" placeholder="{$searchPlaceholder|wash()}" />
                        <div class="input-group-append">
                            <button class="btn btn-outline-secondary border-0" type="button"><i class="fa fa-search" aria-hidden="true"></i></button>
                        </div>
                    </div>
                </div>
                {if count($facets)|gt(3)}<div class="w-100"></div>{/if}
                {foreach $facets as $index => $facet}
                    <div class="col-sm mb-3">
                        {def $facets_parts = $facet|explode(':')}
                        {if is_set($facets_parts[1])}
                            <label class="sr-only" for="{$block.id}-facet-{$index}">{$facets_parts[0]|wash()}</label>
                            <select data-placeholder="{$facets_parts[0]|wash()}" data-facets_select="facet-{$index}" id="{$block.id}-facet-{$index}" class="form-control" multiple>
                            </select>
                            {set $facetsFields = $facetsFields|append($facets_parts[1])}
                        {/if}
                        {undef $facets_parts}
                    </div>
                    {if or($index|eq(2), $index|eq(6))}<div class="w-100"></div>{/if}
                {/foreach}
            </div>
        </div>
    {/if}

    <div class="col-12">
        <div class="items tab-content">
            {if $showGrid}
            <section id="remote-gui-{$block.id}-list" class="tab-pane active pt-0 pl-0"></section>
            {/if}
            {if $showMap}
            <section id="remote-gui-{$block.id}-geo" class="tab-pane{if $showGrid|not} active{/if} p-0">
                <div id="remote-gui-{$block.id}-map" style="width: 100%; height: 700px"></div>
            </section>
            {/if}
        </div>
    </div>
</div>

{if and(is_set($block.custom_attributes.show_all_link), $block.custom_attributes.show_all_link|eq(1))}
    <div class="row mt-2">
        <div class="col text-center">
            <a class="btn btn-primary" href="{$remoteUrl}">
                {if and(is_set($block.custom_attributes.show_all_text), $block.custom_attributes.show_all_text|ne(''))}
                    {$block.custom_attributes.show_all_text|wash()}
                {else}
                    {'View all'|i18n('bootstrapitalia')}
                {/if}
            </a>
        </div>
    </div>
{/if}

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
        {rdelim},
        'mainImage': function (remoteUrl, id, css) {ldelim}
            return '<img alt="" src="'+remoteUrl+'/image/view/'+id+'" class="'+css+'" />';
        {rdelim},
    {rdelim}));
    $("#remote-gui-{$block.id}").remoteContentsGui({ldelim}
        'remoteUrl': "{$remoteUrl}",
        {if and(is_set($block.custom_attributes.simple_geo_api), $block.custom_attributes.simple_geo_api)}
        'geoSearchApi': '/api/opendata/v2/geo/search/',
        {/if}
        'spinnerTpl': '#tpl-remote-gui-spinner',
        'listTpl': '#tpl-remote-gui-list',
        'popupTpl': '#tpl-remote-gui-item',
        'itemsPerRow': {$itemsPerRow},
        'limitPagination': {$limit},
        'query': "{$query|wash(javascript)}"{if $fields|ne('')},
        'facets': {if $facetsFields|count()}['{$facetsFields|implode("','")}']{else}[]{/if},
        'fields': {if $fields|ne('')}['{$fields|explode(',')|implode("','")}']{else}[]{/if}
    {rdelim});
{rdelim});
</script>
{undef $showGrid $showMap $showSearch $searchPlaceholder $query $limit $itemsPerRow $fields $remoteUrl}
{/if}

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
        <div class="card card-teaser rounded shadow" style="text-decoration:none !important">
            {{include tmpl="#tpl-remote-gui-item"/}}
        </div>
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
{{include tmpl="#tpl-remote-gui-item-inner-{/literal}{$block.id}{literal}"/}}
</script>
{/literal}
{/run-once}

<script id="tpl-remote-gui-item-inner-{$block.id}" type="text/x-jsrender">
{if and(is_set($block.custom_attributes.template), $block.custom_attributes.template|ne(''))}
    {$block.custom_attributes.template}
{else}
    {literal}
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
                <span class="text">Leggi di più</span>
                <svg class="icon"><use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-arrow-right"></use></svg>
            </a>
        </div>
    </div>
    {/literal}
{/if}
</script>