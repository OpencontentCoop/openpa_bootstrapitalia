{set_defaults( hash(
  'wrapper_class', 'py-5 position-relative',
  'container_class', 'container'
))}
{def $openpa = object_handler($block)}

{def $showGrid = cond(is_set($block.custom_attributes.show_grid), $block.custom_attributes.show_grid, true())
  $showMap = $block.custom_attributes.show_map
	$showSearch = $block.custom_attributes.show_search
    $showAgenda = cond(and(is_set($block.custom_attributes.facets), $block.custom_attributes.facets|contains('time_interval')), true(), false())
	$searchPlaceholder = $block.custom_attributes.input_search_placeholder
	$query = $block.custom_attributes.query
	$limit = $block.custom_attributes.limit
	$itemsPerRow = $block.custom_attributes.items_per_row
	$fields = $block.custom_attributes.fields
    $facets = cond(and(is_set($block.custom_attributes.facets), $block.custom_attributes.facets|ne('')), $block.custom_attributes.facets|explode(','), array())
    $facetsFields = array()
	$remoteUrl = cond(is_set($block.custom_attributes.remote_url), $block.custom_attributes.remote_url|trim('/'), false())
    $showArray = array($showMap, $showSearch, $showAgenda)
    $trueCount = 0
    $multipleViewsEnabled = false()}

{foreach $showArray as $showItem}
  {if $showItem}
      {set $trueCount = $trueCount|inc()}
  {/if}
{/foreach}
{if $trueCount|gt(1)}
  {set $multipleViewsEnabled = true()}
{/if}

{if or($showGrid, $showMap, $showAgenda)}
<div class="{$wrapper_class} remote-gui-wrapper"{cond(and(is_set($block.custom_attributes.hide_if_empty), $block.custom_attributes.hide_if_empty|ne('')), ' style="display:none"', '  ')}>
    <div class="{$container_class}">

        {include uri='design:parts/block_name.tpl'}

        <div class="row" id="remote-gui-{$block.id}">
            {if $facets|count()}
                <div class="col-12 col-lg-4 ps-lg-5">
                    <ul class="nav d-block nav-pills text-start {if $multipleViewsEnabled|not()} d-none {/if} d-flex {if $trueCount|gt(2)} flex-lg-column{/if} align-items-start flex-xxl-row">
                        {if $showGrid}
                            <li class="nav-item pr-1 pe-1 text-center mb-1">
                                <a data-toggle="tab" data-bs-toggle="tab"
                                    class="nav-link active rounded view-selector text-uppercase"
                                    href="#remote-gui-{$block.id}-list">
                                    <i aria-hidden="true" class="fa fa-list"></i> {'List'|i18n('editorialstuff/dashboard')}
                                </a>
                            </li>
                        {/if}
                        {if $showMap}
                            <li class="nav-item text-center mb-1">
                                <a data-toggle="tab" data-bs-toggle="tab"
                                    class="nav-link{if $showGrid|not} active{/if} rounded view-selector text-uppercase"
                                    href="#remote-gui-{$block.id}-geo">
                                    <i aria-hidden="true" class="fa fa-map"></i> {'Map'|i18n('bootstrapitalia')}
                                </a>
                            </li>
                        {/if}
                        {if $showAgenda}
                          <li class="nav-item text-center mb-1">
                            <a data-toggle="tab" data-bs-toggle="tab"
                                class="nav-link{if $showGrid|not} active{/if} rounded view-selector text-uppercase"
                                href="#remote-gui-{$block.id}-agenda">
                                <i aria-hidden="true" class="fa fa-calendar"></i> {'Calendar'|i18n('bootstrapitalia')}
                            </a>
                          </li>
                      {/if}
                    </ul>

            {if $facets|count()}
              {def $index = 0}
              {foreach $facets as $facet}
                {def $facets_parts = $facet|explode(':')}
                {if is_set($facets_parts[1])}
                  {if $facets_parts[1]|eq('time_interval')}
                    <div class="px-0 my-4 mb-5" data-datepicker>
                      <fieldset>
                        <legend class="h6 ms-0 ps-0">{$facets_parts[0]|wash()}</legend>
                        <div class="form-check">
                          <input name="time_interval" type="radio" id="today" value="today">
                          <label for="today">{'Today'|i18n('agenda')}</label>
                        </div>
                        <div class="form-check">
                          <input name="time_interval" type="radio" id="week" value="weekend">
                          <label for="week">{'This weekend'|i18n('agenda')}</label>
                        </div>
                        <div class="form-check">
                          <input name="time_interval" type="radio" id="next7days" value="next7days">
                          <label for="next7days">{'Next 7 days'|i18n('agenda')}</label>
                        </div>
                        <div class="form-check">
                          <input name="time_interval" type="radio" id="next30days" value="next30days">
                          <label for="next30days">{'Next 30 days'|i18n('agenda')}</label>
                        </div>
                        <div class="form-check">
                          <input name="time_interval" type="radio" id="all" value="all" checked>
                          <label for="all">{'Upcoming appointments'|i18n('bootstrapitalia')}</label>
                        </div>
                      </fieldset>
                    </div>
                  {else}
                    <div class="px-0 my-4 mb-5">
                      <label class="h6 ms-0 ps-0" for="facet-{$block.id}-{$index}">{$facets_parts[0]|wash()}</label>
                      <select id="facet-{$block.id}-{$index}" data-placeholder="{'Select'|i18n('design/admin/content/browse')}"
                        data-facets_select="facet-{$index}" class="d-none" multiple></select>
                    </div>
                    {set $index = $index|inc()}
                    {set $facetsFields = $facetsFields|append($facets_parts[1])}
                  {/if}
                {/if}
                {undef $facets_parts}
              {/foreach}
            {/if}

          </div>
        {/if}

        <section
          class="{if $facets|count()}order-lg-first col-12 col-lg-8 {else}col-12{/if} pt-lg-2 pb-lg-2 mb-5 mb-lg-0">
          {if and($showSearch, count($facets)|eq(0))}<div class="row g-0">{/if}
            {if $showSearch}
              {def $placeHolder = cond($searchPlaceholder|eq(''), 'Search by keyword'|i18n('bootstrapitalia'), $searchPlaceholder)}
              <div class="form-group mb-2 mb-lg-4 search-form{if and($showSearch, count($facets)|eq(0))} col-10{/if}">
                <div class="input-group">
                  <span class="input-group-text h-auto">{display_icon('it-search', 'svg', 'icon icon-sm')}</span>
                  <label for="search-input-{$block.id}" class="visually-hidden">{$placeHolder|wash()}</label>
                  <input type="text" class="form-control" id="search-input-{$block.id}" data-search="q"
                    placeholder="{$placeHolder|wash()}" name="search-input-{$block.id}">
                  <div class="input-group-append">
                    <button class="btn btn-primary" type="button"
                      id="button-3">{'Search'|i18n('design/plain/layout')}</button>
                  </div>
                </div>
              </div>
              {undef $placeHolder}
            {/if}
            {if count($facets)|eq(0)}
              <div class="col">
                <ul class="nav d-block nav-pills text-center {if $multipleViewsEnabled|not()} d-none {/if}">
                  {if $showGrid}
                    <li class="nav-item pr-1 pe-1 text-center d-inline-block">
                      <a data-toggle="tab" data-bs-toggle="tab" class="nav-link active rounded view-selector"
                        href="#remote-gui-{$block.id}-list">
                        <i aria-hidden="true" class="fa fa-list"></i>
                        <span class="sr-only"> {'List'|i18n('editorialstuff/dashboard')}</span>
                      </a>
                    </li>
                  {/if}
                  {if $showMap}
                    <li class="nav-item text-center d-inline-block">
                      <a data-toggle="tab" data-bs-toggle="tab"
                        class="nav-link{if $showGrid|not} active{/if} rounded view-selector"
                        href="#remote-gui-{$block.id}-geo">
                        <i aria-hidden="true" class="fa fa-map"></i>
                        <span class="sr-only">{'Map'|i18n('bootstrapitalia')}</span>
                      </a>
                    </li>
                  {/if}
                  {if $showAgenda}
                    <li class="nav-item text-center d-inline-block">
                      <a data-toggle="tab" data-bs-toggle="tab"
                        class="nav-link{if $showGrid|not} active{/if} rounded view-selector"
                        href="#remote-gui-{$block.id}-agenda">
                        <i aria-hidden="true" class="fa fa-calendar"></i>
                        <span class="sr-only">{'Calendar'|i18n('design/ocbootstrap/blog/calendar')}</span>
                      </a>
                    </li>
                  {/if}
                </ul>
              </div>
            {/if}
            {if and($showSearch, count($facets)|eq(0))}
          </div>{/if}
          <div class="items tab-content">
            {if $showGrid}
              <section id="remote-gui-{$block.id}-list" class="tab-pane active pt-0 pl-0 ps-0"></section>
            {/if}
            {if $showMap}
              <section id="remote-gui-{$block.id}-geo" class="tab-pane{if $showGrid|not} active{/if} p-0">
                <div id="remote-gui-{$block.id}-map" style="width: 100%; height: 700px"></div>
              </section>
            {/if}
            {if $showAgenda}
              <section id="remote-gui-{$block.id}-agenda" class="tab-pane{if $showGrid|not} active{/if} p-0">
                <div
                  id="remote-gui-{$block.id}-calendar"
                  style="overflow-x:auto;min-height: 300px;"
                  class="mt-5"
                ></div>
              </section>
            {/if}
        </div>
      </section>
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
    'accessible-autocomplete.min.js',
    'jquery.opendata_remote_gui.js'
))}
{ezcss_require(array('accessible-autocomplete.min.css'))}

{if $showAgenda}
  {ezscript_require(array('moment.js', 'event-calendar.min.js'))}
  {ezcss_require(array('event-calendar.min.css'))}
{/if}

{def $queryBuilder = 'browser'}
{if $block.type|eq('OpendataQueriedContents')}
  {set $queryBuilder = 'server'}
{/if}
{if and(is_set($block.custom_attributes.query_builder), $block.custom_attributes.query_builder|ne(''))}
  {set $queryBuilder = $block.custom_attributes.query_builder}
{/if}
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
  $("#remote-gui-{$block.id}").remoteContentsGui({ldelim}
  'queryBuilder': "{$queryBuilder}",
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
  'view': '{cond(and(is_set($block.custom_attributes.view_api), $block.custom_attributes.view_api|ne('')), $block.custom_attributes.view_api, 'card_teaser')}',
  'locale': '{fetch( 'content', 'locale' , hash( 'locale_code', ezini('RegionalSettings', 'Locale') )).http_locale_code}',
  'i18n': {ldelim}
    calendarToday: '{'Today'|i18n('agenda')}',
    calendarMoreEvents: '{'View all events'|i18n('bootstrapitalia')}',
    placeholder: '{'Select an item'|i18n('bootstrapitalia')}',
    noResults: '{'No results found'|i18n('bootstrapitalia')}',
    assistiveHint: '{'When autocomplete results are available use up and down arrows to review and enter to select. Touch device users, explore by touch or with swipe gestures.'|i18n('bootstrapitalia')}',
    selectedOptionDescription: '{'Press Enter or Space to remove selection'|i18n('bootstrapitalia')}',
  {rdelim}
  {if $facetsFields|count()},'facets':['{$facetsFields|implode("','")}']{/if}
  {if $fields|ne('')},'fields':['{$fields|explode(',')|implode("','")}']{/if}
  {rdelim});
  {rdelim});
</script>
{/if}

{include uri='design:parts/opendata_remote_gui_templates.tpl' block=$block show_search=$showSearch}

{undef $showGrid $showMap $showSearch $searchPlaceholder $query $limit $itemsPerRow $fields $remoteUrl}


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
{unset_defaults( array('wrapper_class','container_class'))}

{literal}
<style>
  .ec-event-title,
  .ec-event-time {
    font-size: 0.8rem;
    line-height: 1.3em;
    font-weight: 600 !important;
  }
  .ec-popup .ec-events {
    overflow: visible !important;
  }
  .ec-day-grid .ec-day-foot a {
    text-decoration: underline !important;
  }
  .ec-event {
    padding-left: 8px !important;
    padding-right: 8px !important;
  }
  .ec-popup {
    min-width: 300px !important;
    max-height: 500px !important;
    overflow: auto !important;
  }
</style>
{/literal}