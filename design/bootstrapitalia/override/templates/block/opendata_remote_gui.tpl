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

{def $background_image = false()}
{if and(is_set($block.custom_attributes.image), $block.custom_attributes.image|ne(''))}
    {def $image = fetch(content, node, hash(node_id, $block.custom_attributes.image))}
    {if and($image, $image.class_identifier|eq('image'), $image|has_attribute('image'))}
        {set $background_image = $image|attribute('image').content.original.full_path|ezroot(no)}
    {/if}
    {undef $image}
{/if}

{if or($showGrid, $showMap)}
<div class="py-5 position-relative">
    <div class="block-topics-bg" {if $background_image}style="background-image: url({$background_image});"{/if}></div>
    <div class="container">
        <div class="row" id="remote-gui-{$block.id}">
            <div class="col-12 col-md-9">
                {include uri='design:parts/block_name.tpl' css_class=cond($background_image, 'text-white bg-dark d-inline-block px-2 rounded', '') no_margin=cond(and($showGrid, $showMap, $showSearch), true(), false())}
            </div>
            <div class="col-12 col-md-3 pr-0">
                <ul class="nav d-block nav-pills border-bottom border-primary text-right{if or($showGrid|not(), $showMap|not())} hide{/if}">
                    {if $showGrid}
                    <li class="nav-item pr-1 text-center d-inline-block">
                        <a data-toggle="tab"
                           class="nav-link active rounded-0 view-selector"
                           href="#remote-gui-{$block.id}-list">
                            <i aria-hidden="true" class="fa fa-list" aria-hidden="true"></i> <span class="sr-only"> {'List'|i18n('editorialstuff/dashboard')}</span>
                        </a>
                    </li>
                    {/if}
                    {if $showMap}
                    <li class="nav-item text-center d-inline-block">
                        <a data-toggle="tab"
                           class="nav-link{if $showGrid|not} active{/if} rounded-0 view-selector"
                           href="#remote-gui-{$block.id}-geo">
                            <i aria-hidden="true" class="fa fa-map" aria-hidden="true"></i> <span class="sr-only">{'Map'|i18n('extension/ezgmaplocation/datatype')}</span>
                        </a>
                    </li>
                    {/if}
                    {if $showSearch}
                    <li class="nav-item text-center d-inline-block">
                        <a class="nav-link rounded-0 search-form-toggle"
                           href="#">
                            <i aria-hidden="true" class="fa fa-search" aria-hidden="true"></i>
                        </a>
                    </li>
                    {/if}
                </ul>
                {if and($showSearch, $facets|count()|eq(0))}
                <div class="input-group mb-3 search-form{if and($showGrid, $showMap)} hide{/if}">
                    <input type="text" autocomplete="off" class="form-control" placeholder="{$searchPlaceholder|wash()}" />
                    <div class="input-group-append">
                        <button class="btn btn-outline-secondary" type="button"><i aria-hidden="true" class="fa fa-search" aria-hidden="true"></i></button>
                    </div>
                </div>
                {/if}
            </div>
            {if and($showSearch, $facets|count())}
                <div class="search-form{if and($showGrid, $showMap)} hide{/if} col-12">
                    <div class="row pt-3">
                        <div class="col-sm mb-3">
                            <div class="input-group chosen-border">
                                <input type="text" autocomplete="off" class="form-control border-0" placeholder="{$searchPlaceholder|wash()}" />
                                <div class="input-group-append">
                                    <button class="btn btn-outline-secondary border-0" type="button"><i aria-hidden="true" class="fa fa-search" aria-hidden="true"></i></button>
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
        'localAccessPrefix': {'/'|ezurl()},
        {if and(is_set($block.custom_attributes.simple_geo_api), $block.custom_attributes.simple_geo_api)}
        'geoSearchApi': '/api/opendata/v2/geo/search/',
        {/if}
        'spinnerTpl': '#tpl-remote-gui-spinner',
        'listTpl': '#tpl-remote-gui-list',
        'popupTpl': '#tpl-remote-gui-item',
        'itemsPerRow': '{$itemsPerRow}',
        'limitPagination': {$limit},
        'query': "{$query|wash(javascript)}",
        'customTpl': "{concat('#tpl-remote-gui-item-inner-', $block.id)}",
        'useCustomTpl': {cond(and(is_set($block.custom_attributes.template), $block.custom_attributes.template|ne('')), 'true', 'false')}
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
                <span class="text">{'Read more'|i18n('bootstrapitalia')}</span>
                <svg class="icon"><use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-arrow-right"></use></svg>
            </a>
        </div>
    </div>
    {/literal}
{/if}
</script>