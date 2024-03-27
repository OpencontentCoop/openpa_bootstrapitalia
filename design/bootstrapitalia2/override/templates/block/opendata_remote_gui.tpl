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
	 $remoteUrl = cond(is_set($block.custom_attributes.remote_url), $block.custom_attributes.remote_url|trim('/'), false())}

{def $background_image = false()}
{if and(is_set($block.custom_attributes.image), $block.custom_attributes.image|ne(''))}
    {def $image = fetch(content, node, hash(node_id, $block.custom_attributes.image))}
    {if and($image, $image.class_identifier|eq('image'), $image|has_attribute('image'))}
        {set $background_image = $image|attribute('image').content.original.full_path|ezroot(no)}
    {/if}
    {undef $image}
{/if}

{if or($showGrid, $showMap)}
<div class="py-5 position-relative remote-gui-wrapper"{cond(and(is_set($block.custom_attributes.hide_if_empty), $block.custom_attributes.hide_if_empty|ne('')), ' style="display:none"', '  ')}>
    <div class="block-topics-bg" {if $background_image}{include name="bg" uri='design:atoms/background-image.tpl' url=$background_image}{/if}></div>
    <div class="container">

        {include uri='design:parts/block_name.tpl' css_class=cond($background_image, 'text-white bg-dark d-inline-block px-2 rounded', '')}

        <div class="row" id="remote-gui-{$block.id}">

            <section class="{if $facets|count()}col-12 col-lg-8 {else}col-12{/if} pt-lg-2 pb-lg-2">
                {if and($showSearch, count($facets)|eq(0))}<div class="row g-0">{/if}
                {if $showSearch}
                    <div class="cmp-input-search">
                        <div class="form-group autocomplete-wrapper mb-2 mb-lg-4 search-form">
                            <div class="input-group">
                                <label for="{$block.id}-search-input" class="visually-hidden">{$searchPlaceholder|wash()}</label>
                                <input type="search" data-search="q" class="autocomplete form-control" placeholder="{$searchPlaceholder|wash()}" id="{$block.id}-search-input">
                                <div class="input-group-append">
                                    <button class="btn btn-primary" type="submit"  data-focus-mouse="false">{'Submit'|i18n('bootstrapitalia/documents')}</button>
                                </div>
                                <span class="autocomplete-icon" aria-hidden="true" aria-labelledby="{$block.id}">{display_icon('it-search', 'svg', 'icon icon-sm icon-primary')}</span>
                            </div>
                        </div>
                    </div>
                {/if}
                {if count($facets)|eq(0)}
                    <div class="col">
                        <ul class="nav d-block nav-pills text-right{if or($showGrid|not(), $showMap|not())} hide{/if}">
                            {if $showGrid}
                                <li class="nav-item pr-1 pe-1 text-center d-inline-block">
                                    <a data-toggle="tab" data-bs-toggle="tab"
                                       class="nav-link active rounded view-selector"
                                       href="#remote-gui-{$block.id}-list">
                                        <i aria-hidden="true" class="fa fa-list"></i> <span class="sr-only"> {'List'|i18n('editorialstuff/dashboard')}</span>
                                    </a>
                                </li>
                            {/if}
                            {if $showMap}
                                <li class="nav-item text-center d-inline-block">
                                    <a data-toggle="tab" data-bs-toggle="tab"
                                       class="nav-link{if $showGrid|not} active{/if} rounded view-selector"
                                       href="#remote-gui-{$block.id}-geo">
                                        <i aria-hidden="true" class="fa fa-map"></i> <span class="sr-only">{'Map'|i18n('bootstrapitalia')}</span>
                                    </a>
                                </li>
                            {/if}
                        </ul>
                    </div>
                {/if}
                {if and($showSearch, count($facets)|eq(0))}</div>{/if}
                <div class="items tab-content">
                    {if $showGrid}
                        <section id="remote-gui-{$block.id}-list" class="tab-pane active pt-0 pl-0 ps-0"></section>
                    {/if}
                    {if $showMap}
                        <section id="remote-gui-{$block.id}-geo" class="tab-pane{if $showGrid|not} active{/if} p-0">
                            <div id="remote-gui-{$block.id}-map" style="width: 100%; height: 700px"></div>
                        </section>
                    {/if}
                </div>
            </section>

            {if $facets|count()}
                <div class="col-12 col-lg-4 ps-lg-5 order-first order-sm-last">
                    <ul class="nav d-block nav-pills text-right{if or($showGrid|not(), $showMap|not())} hide{/if}">
                        {if $showGrid}
                            <li class="nav-item pr-1 pe-1 text-center d-inline-block">
                                <a data-toggle="tab" data-bs-toggle="tab"
                                   class="nav-link active rounded view-selector text-uppercase"
                                   href="#remote-gui-{$block.id}-list">
                                    <i aria-hidden="true" class="fa fa-list"></i> {'List'|i18n('editorialstuff/dashboard')}
                                </a>
                            </li>
                        {/if}
                        {if $showMap}
                            <li class="nav-item text-center d-inline-block">
                                <a data-toggle="tab" data-bs-toggle="tab"
                                   class="nav-link{if $showGrid|not} active{/if} rounded view-selector text-uppercase"
                                   href="#remote-gui-{$block.id}-geo">
                                    <i aria-hidden="true" class="fa fa-map"></i> {'Map'|i18n('bootstrapitalia')}
                                </a>
                            </li>
                        {/if}
                    </ul>

                    {if $facets|count()}
                        <div class="search-form">
                            <div class="accordion">
                                {foreach $facets as $index => $facet}
                                    {def $facets_parts = $facet|explode(':')}
                                    {if is_set($facets_parts[1])}
                                        <div class="accordion-item bg-none">
                                          <span class="accordion-header" id="collapse-{$block.id}-{$index}-title">
                                            <button class="accordion-button pb-10 px-0 text-uppercase text-decoration-none border-0" type="button"
                                                    data-bs-toggle="collapse" href="#collapse-{$block.id}-{$index}" role="button" aria-expanded="true" aria-controls="collapse-{$block.id}-{$index}"
                                                    data-focus-mouse="false">
                                                {$facets_parts[0]|wash()}
                                            </button>
                                          </span>
                                            <div id="collapse-{$block.id}-{$index}" class="accordion-collapse collapse show" role="region" aria-labelledby="collapse-{$block.id}-{$index}-title">
                                                <div class="accordion-body px-0 pb-1">
                                                    <label for={$block.id}-facet-{$index}" class="visually-hidden">{$facets_parts[0]|wash()}</label>
                                                    <select data-placeholder="..." data-facets_select="facet-{$index}" id="{$block.id}-facet-{$index}" class="form-control" style="height: 0" multiple></select>
                                                </div>
                                            </div>
                                        </div>
                                        {set $facetsFields = $facetsFields|append($facets_parts[1])}
                                    {/if}
                                    {undef $facets_parts}
                                {/foreach}
                            </div>
                        </div>
                    {/if}

                </div>
            {/if}
        </div>

        {if and(is_set($block.custom_attributes.show_all_link), $block.custom_attributes.show_all_link|eq(1))}
            <div class="row mt-lg-2">
                <div class="col-12 col-lg-3 offset-lg-9">
                    <a class="btn btn-primary text-button w-100" href="{$remoteUrl}">
                        {if and(is_set($block.custom_attributes.show_all_text), $block.custom_attributes.show_all_text|ne(''))}
                            {$block.custom_attributes.show_all_text|wash()}
                        {else}
                            {'View all'|i18n('bootstrapitalia')}
                        {/if}
                    </a>
                </div>
            </div>
        {/if}

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
        {rdelim},
        'mainImage': function (remoteUrl, id, css) {ldelim}
            return '<img alt="" src="'+remoteUrl+'/image/view/'+id+'" class="'+css+'" />';
        {rdelim},
    {rdelim}));
    $("#remote-gui-{$block.id}").remoteContentsGui({ldelim}
        'queryBuilder': "{cond($block.type|eq('OpendataQueriedContents'), 'server', 'browser')}",
        'remoteUrl': "{$remoteUrl}",
        'localAccessPrefix': {'/'|ezurl()},
        {if and(is_set($block.custom_attributes.simple_geo_api), $block.custom_attributes.simple_geo_api)}
        'geoSearchApi': '/api/opendata/v2/geo/search/',
        {/if}
        'spinnerTpl': '#tpl-remote-gui-spinner',
        'listTpl': '#tpl-remote-gui-list',
        'popupTpl': '#tpl-remote-gui-item',
        'itemsPerRow': '{cond(and($facets|count(), $itemsPerRow|eq('3')), '2', $itemsPerRow)}',
        'limitPagination': {$limit},
        'query': "{$query|wash(javascript)}",
        'hideIfEmpty': {cond(and(is_set($block.custom_attributes.hide_if_empty), $block.custom_attributes.hide_if_empty|ne('')), 'true', 'false')},
        'customTpl': "{concat('#tpl-remote-gui-item-inner-', $block.id)}",
        'useCustomTpl': {cond(and(is_set($block.custom_attributes.template), $block.custom_attributes.template|ne('')), 'true', 'false')},
        'view': '{cond(and(is_set($block.custom_attributes.view_api), $block.custom_attributes.view_api|ne('')), $block.custom_attributes.view_api, 'card_teaser')}'
        {if $facetsFields|count()},'facets':['{$facetsFields|implode("','")}']{/if}
        {if $fields|ne('')},'fields':['{$fields|explode(',')|implode("','")}']{/if}
    {rdelim});
{rdelim});
</script>
{undef $showGrid $showMap $showSearch $searchPlaceholder $query $limit $itemsPerRow $fields $remoteUrl}
{/if}

{include uri='design:parts/opendata_remote_gui_templates.tpl' block=$block}

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
                <span class="text">{/literal}{'Read more'|i18n('bootstrapitalia')}{literal}</span>
                <svg class="icon"><use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-arrow-right" aria-label="{/literal}{'Read more'|i18n('bootstrapitalia')}{literal}"></use></svg>
            </a>
        </div>
    </div>
    {/literal}
{/if}
</script>
