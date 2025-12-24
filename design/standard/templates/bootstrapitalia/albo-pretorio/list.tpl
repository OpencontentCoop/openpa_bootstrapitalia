{def $publication_range = cond($archive, '', "and calendar[publication_start_time,publication_end_time] = [today,now]")}
{def $official_noticeboard_title = cond($setup_object.data_map.title.content|ne(''), $setup_object.data_map.title.content|wash(), 'Official noticeboard'|i18n('bootstrapitalia'))}
{include uri='design:bootstrapitalia/albo-pretorio/breadcrumb.tpl' archive=$archive official_noticeboard_title=$official_noticeboard_title}
{def $block_id = 'albo'}

<div class="container mb-5">
  <div class="row justify-content-center">
    <div class="col-12 col-lg-10">
      <div class="cmp-hero">
        <section class="it-hero-wrapper bg-white d-block">
          <div class="it-hero-text-wrapper pt-0 ps-0 pb-4 ">
            <h1 class="text-black hero-title" data-element="page-name">{if $archive}{'Official noticeboard archive'|i18n('bootstrapitalia')}{else}{$official_noticeboard_title}{/if}</h1>
          </div>
          {if $setup_object|has_attribute('intro')}
              {attribute_view_gui attribute=$setup_object|attribute('intro')}
          {/if}
          {if $archive}
          {else}
            <p>{'Official noticeboard text to archive'|i18n('bootstrapitalia')} <a href="{'/albo_pretorio/archivio'|ezurl(no)}">{'Official noticeboard archive'|i18n('bootstrapitalia')}</a>.</p>
          {/if}
        </section>
      </div>
    </div>
  </div>
</div>

{ezscript_require(array(
    'jsrender.js',
    'handlebars.min.js'
))}
{def $locale = fetch(content, locale)}
{def $filters = array('search_text','number','year','daterange','has_organization')}

{def $root_tags = array($main_tag_id)}
{def $hide_tag_select = false()}
{def $office_count = fetch(content, tree_count, hash(parent_node_id, ezini('NodeSettings', 'RootNode', 'content.ini'), class_filter_type, 'include', class_filter_array, array('organization')))}

{def $start_date = 'publication_start_time'}
{def $end_date = 'publication_end_time'}
{def $number = 'id_albo_pretorio'}

{def $root_tag_id_list = array()}
{def $root_tag_list = array()}
{foreach $root_tags as $root_index => $root_tag}
	{def $tag_tree = api_tagtree($root_tag)}
	{set $root_tag_id_list = $root_tag_id_list|append($tag_tree.id)}
	{set $root_tag_list = $root_tag_list|append($tag_tree)}
	{undef $tag_tree}
{/foreach}

{def $show_filters = cond(or(count($filters)|gt(1), and($root_tag_id_list|count()|gt(0), $hide_tag_select|not())), true(), false())}

{def $document_class = fetch(class, list, hash(class_filter, array('document')))[0]}

<div data-block_document_subtree="1"
	 data-hide_publication_end_time="false"
	 data-show_only_publication="{cond($archive, 'false','true')}"
	 data-limit="50"
	 data-hide_empty_facets="true"
	 data-hide_first_level="false"
	 data-start_identifier="{$start_date|wash()}"
	 data-end_identifier="{$end_date|wash()}"
	 data-number_identifier="{$number|wash()}">

	<form class="row">
	  <section class="{if $show_filters}col-12 col-lg-8 {else}col-12{/if} pt-lg-2 pb-lg-2">
			{if $filters|contains('search_text')}
			<div class="cmp-input-search">
				<div class="form-group autocomplete-wrapper mb-2 mb-lg-4">
					<div class="input-group">
						<label for="search-{$block_id}" class="visually-hidden">{'Search text'|i18n('bootstrapitalia/documents')}</label>
						<input type="search" data-search="q" class="autocomplete form-control ps-2 ps-md-5" placeholder="{'Search text'|i18n('bootstrapitalia/documents')}" id="search-{$block_id}">
						<div class="input-group-append">
							<button class="btn btn-primary btn-xs" type="submit" data-focus-mouse="false" aria-label={'Search'|i18n('design/plain/layout')}>
                <span class="d-none d-md-inline" aria-hidden="true">{'Search'|i18n('design/plain/layout')}</span>
                <span class="d-md-none">{display_icon('it-search', 'svg', 'icon icon-sm icon-white')}</span>
              </button>
              <button type="reset" class="btn btn-secondary btn-xs hide" style="margin-left: -6px; z-index: 1" aria-label={'Remove filters'|i18n('bootstrapitalia/documents')}>
                <span class="d-none d-md-inline" aria-hidden="true">{'Remove filters'|i18n('bootstrapitalia/documents')}</span>
                <span class="d-md-none">{display_icon('it-close', 'svg', 'icon icon-sm icon-white')}</span>
              </button>
						</div>
						<span class="autocomplete-icon d-none d-md-block">{display_icon('it-search', 'svg', 'icon icon-sm icon-primary')}</span>
					</div>
				</div>
			</div>
			{/if}
			<div class="results mb-5" data-root_tags="{$root_tag_id_list|implode(',')}"></div>
	  </section>

		{if $show_filters}
			<div class="col-12 col-lg-4 ps-lg-5 order-first order-md-last">
				<div class="accordion cmp-accordion">
					{if $hide_tag_select|not()}
					<div class="accordion-item bg-none{if $hide_tag_select} d-none{/if}">
						<h2 class="accordion-header" id="collapseTagList-{$block_id}-title">
							<button class="accordion-button collapsed px-2 text-uppercase" type="button"
									data-bs-toggle="collapse" href="#collapseTagList-{$block_id}" role="button" aria-expanded="false" aria-controls="collapseTagList-{$block_id}"
									data-focus-mouse="false">
								{'Document type'|i18n('bootstrapitalia/documents')}
							</button>
						</h2>
						<div id="collapseTagList-{$block_id}" class="accordion-collapse collapse" role="region" aria-labelledby="collapseTagList-{$block_id}-title">
							<div class="accordion-body pb-4">
								<ul class="link-list">
									{foreach $root_tag_list as $root_index => $tag_tree}
										{if is_set($tag_tree.children)}
											{foreach $tag_tree.children as $index => $tag}
												{if and($root_index|gt(0), $index|eq(0))}<li class="border-top my-2"></li>{/if}
												<li data-level="1">
													<a class="list-item pb-2" style="display: block" data-tag_id="{$tag.id|wash()}" href="#"><span>{$tag.keyword|wash()} <small></small></span></a>
													{if $tag.hasChildren}
														<ul class="ps-3">
															{foreach $tag.children as $childTag}
																<li data-level="2">
																	<a class="list-item pb-2" style="display: block" data-tag_id="{$childTag.id|wash()}" href="#"><span>{$childTag.keyword|wash()} <small></small></span></a>
																	{if $childTag.hasChildren}
																		<ul class="ps-3">
																			{foreach $childTag.children as $subChildTag}
																				<li data-level="3">
																					<a class="list-item pb-2" style="display: block" data-tag_id="{$subChildTag.id|wash()}" href="#"><span>{$subChildTag.keyword|wash()} <small></small></span></a>
																				</li>
																			{/foreach}
																		</ul>
																	{/if}
																</li>
															{/foreach}
														</ul>
													{/if}
												</li>
											{/foreach}
										{/if}
									{/foreach}
								</ul>
							</div>
						</div>
					</div>
					{/if}

					{if $filters|contains('number')}
					<div class="accordion-item bg-none">
						<h2 class="accordion-header" id="collapseNumber-{$block_id}-title">
							<button class="accordion-button collapsed px-2 text-uppercase" type="button"
									data-bs-toggle="collapse" href="#collapseNumber-{$block_id}" role="button" aria-expanded="false" aria-controls="collapseNumber-{$block_id}"
									data-focus-mouse="false">
								{'Official noticeboard document identifier'|i18n('bootstrapitalia')}
							</button>
						</h2>
						<div id="collapseNumber-{$block_id}" class="accordion-collapse collapse" role="region" aria-labelledby="collapseNumber-{$block_id}-title">
							<div class="accordion-body pb-4">
                <div class="form-group mb-0">
                  <label for="searchFormNumber-{$block_id}" class="visually-hidden">{'Official noticeboard document identifier'|i18n('bootstrapitalia')}</label>
                  <input type="text" autocomplete="off" class="form-control form-control-sm" id="searchFormNumber-{$block_id}" data-search="has_code" placeholder="es: 2025/1">
                </div>
							</div>
						</div>
					</div>
					{/if}

					{if $filters|contains('year')}
						<div class="accordion-item bg-none">
						  <h2 class="accordion-header" id="collapseYear-{$block_id}-title">
							<button class="accordion-button collapsed px-2 text-uppercase" type="button"
									data-bs-toggle="collapse" href="#collapseYear-{$block_id}" role="button" aria-expanded="false" aria-controls="collapseYear-{$block_id}"
									data-focus-mouse="false">
								{'Year'|i18n('openpa/search')}
							</button>
						  </h2>
							<div id="collapseYear-{$block_id}" class="accordion-collapse collapse" role="region" aria-labelledby="collapseYear-{$block_id}-title">
								<div class="accordion-body pb-4">
                  <div class="form-group mb-0">
                    <label for="searchFormYear-{$block_id}" class="visually-hidden">{'Year'|i18n('openpa/search')}</label>
                    <input type="text" size="4" autocomplete="off" class="form-control form-control-sm" id="searchFormYear-{$block_id}" data-search="year" placeholder="{'Year'|i18n('openpa/search')}">
                  </div>
								</div>
							</div>
						</div>
					{/if}

					{if $filters|contains('daterange')}
						<div class="accordion-item bg-none">
						  <h2 class="accordion-header" id="collapseDate-{$block_id}-title">
							<button class="accordion-button collapsed px-2 text-uppercase" type="button"
									data-bs-toggle="collapse" href="#collapseDate-{$block_id}" role="button" aria-expanded="false" aria-controls="collapseDate-{$block_id}"
									data-focus-mouse="false">
								{'Date'|i18n('bootstrapitalia/documents')}
							</button>
						  </h2>
							<div id="collapseDate-{$block_id}" class="accordion-collapse collapse" role="region" aria-labelledby="collapseDate-{$block_id}-title">
								<div class="accordion-body pb-4">
                  <div class="row form-group mb-0">
                    <div class="col-sm-6 col-lg-12 col-xl-6 mb-2 px-lg-1">
                      <label class="active" for="{$block_id}-date_start">{'Date start'|i18n('bootstrapitalia/booking')}</label>
                      <input class="form-control form-control-sm" type="date" data-search="date-start" id="{$block_id}-date_start" name="{$block_id}-date_start">
                    </div>
                    <div class="col-sm-6 col-lg-12 col-xl-6 mb-2 px-lg-1">
                      <label class="active" for="{$block_id}-date_end">{'Date end'|i18n('bootstrapitalia/booking')}</label>
                      <input class="form-control form-control-sm" type="date" data-search="date-end" id="{$block_id}-date_end" name="{$block_id}-date_end">
                    </div>
                  </div>
                </div>
							</div>
						</div>
					{/if}

          {if and($filters|contains('has_organization'), $office_count|gt(0))}
						{def $has_org_id_list = api_search(
							concat("classes [document] and subtree [1] limit 1 facets [has_organization.id|alpha|1000]")
						).facets[0].data|array_keys}
						{if $has_org_id_list|count()}
              <div class="accordion-item bg-none">
                <h2 class="accordion-header" id="collapseOffice-{$block_id}-title">
                <button class="accordion-button collapsed px-2 text-uppercase" type="button"
                    data-bs-toggle="collapse" href="#collapseOffice-{$block_id}" role="button" aria-expanded="false" aria-controls="collapseOffice-{$block_id}"
                    data-focus-mouse="false">
									{$document_class.data_map.has_organization.name|wash()}
                </button>
                </h2>
								<div id="collapseOffice-{$block_id}" class="accordion-collapse collapse" role="region" aria-labelledby="collapseOffice-{$block_id}-title">
									<div class="accordion-body pb-4">
										<div class="select-wrapper">
											<label for="searchFormOffice-{$block_id}" class="visually-hidden">{'Office'|i18n('bootstrapitalia/documents')}</label>
											<select class="form-control form-control-sm" id="searchFormOffice-{$block_id}" data-search="has_organization" placeholder="{'Select'|i18n('design/admin/content/browse')}">
												<option value=""></option>
												{foreach $has_org_id_list as $has_org_id}
													{def $org = fetch(content, object, hash(object_id, $has_org_id))}
													{if $org}
													<option value="{$org.id}">{$org.name|wash()}</option>
													{/if}
													{undef $org}
												{/foreach}
											</select>
										</div>
									</div>
								</div>
							</div>
						{/if}
						{undef $has_org_id_list}
					{/if}
				</div>
			</div>
		{/if}
	</form>
</div>


{run-once}
{literal}
<script id="tpl-document-spinner" type="text/x-jsrender">
<div class="spinner text-center pt-3">
    <i aria-hidden="true" class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
    <span class="sr-only">{/literal}{'Loading...'|i18n('bootstrapitalia/documents')}{literal}</span>
</div>
</script>
<script id="tpl-document-results" type="text/x-jsrender">    		
	{{if totalCount == 0}}
		<div class="row mb-2">
			<div class="col" role="status">{/literal}{'No results were found'|i18n('bootstrapitalia/documents')}{literal}</div>
		</div>
	{{else}}
		{{if currentPage == 0}}
			<div class="mb-4 results-count" role="status">{{:resultsFound}}</div>
		{{/if}}
		{{for searchHits}}		
		<div class="cmp-card-latest-messages mb-3 mb-30">
			<div class="card shadow-sm px-4 pt-4 pb-4 rounded">
				<span class="visually-hidden">{/literal}{'Date'|i18n('bootstrapitalia/documents')}{literal}:</span>
				<div class="card-body border-0 p-0">
					<span class="text-decoration-none mb-2 category-top text-uppercase">
            {{:~i18n(data, numberIdentifier)}}
            <span class="data">
              {{if ~i18n(data,startIdentifier) && ~i18n(data,endIdentifier) && !hideEndTime}}
                {/literal}{'From'|i18n('bootstrapitalia/documents')}{literal} {{:~formatDate(~i18n(data,startIdentifier), dateFormat)}}
                {/literal}{'to'|i18n('bootstrapitalia/documents')}{literal} {{:~formatDate(~i18n(data,endIdentifier), dateFormat)}}
              {{else}}
                {{if ~i18n(data,startIdentifier)}}
                  {{:~formatDate(~i18n(data,startIdentifier), dateFormat)}}
                {{else}}
                  {{if ~i18n(data, 'issued')}}
                    {{:~formatDate(~i18n(data, 'issued'), dateFormat)}}
                  {{else}}
                    {{if ~i18n(data, 'published')}}
                      {{:~formatDate(~i18n(data, 'published'), dateFormat)}}
                    {{/if}}
                  {{/if}}
                {{/if}}
              {{/if}}
            </span>
					</span>
				</div>
				<div class="card-body p-0 my-2">
					<h3 class="green-title-big mb-8">
					  {{if metadata.userAccess.canRead}}
						  <a class="text-decoration-none" href="{{if ~i18n(extradata,'urlAlias')}}{{:~i18n(extradata,'urlAlias')}}{{else}}{{:baseUrl}}openpa/object/{{:metadata.id}}{{/if}}">{{:~i18n(metadata.name)}}</a>
						{{else}}
						  {{:~i18n(metadata.name)}}
						{{/if}}
					</h3>
					{{if ~i18n(data, 'alternative_name')}}<p class="text-paragraph">{{:~stripTag(~i18n(data, 'alternative_name'))}}</p>{{/if}}
          {{if ~i18n(data, 'abstract')}}<div class="mb-2"><p class="text-paragraph">{{:~stripTag(~i18n(data, 'abstract'))}}</p></div> {{/if}}
          {{if ~i18n(data, 'document_type')}}<ul class="list-inline m-0"><li class="list-inline-item"><strong>{{:~i18n(data, 'document_type')}}</strong></li></ul>{{/if}}
					{{if ~i18n(data, 'area') || ~i18n(data, 'has_organization')}}<ul class="list-inline m-0"><li class="list-inline-item"><strong>{/literal}{'Administrative area'|i18n('bootstrapitalia/documents')}/{'Office'|i18n('bootstrapitalia/documents')}{literal}:</strong></li>{{if ~i18n(data, 'area')}}{{for ~i18n(data,'area')}}<li class="list-inline-item">{{:~i18n(name)}}</li>{{/for}}{{/if}}{{if ~i18n(data, 'has_organization')}}{{for ~i18n(data,'has_organization')}}<li class="list-inline-item">{{:~i18n(name)}}</li>{{/for}}{{/if}}</ul>{{/if}}
					{{if ~i18n(data, 'interroganti')}}<ul class="list-inline m-0"><li class="list-inline-item"><strong>{/literal}{'Questioners'|i18n('bootstrapitalia/documents')}{literal}:</strong></li>{{for ~i18n(data,'interroganti')}}<li class="list-inline-item">{{:~i18n(name)}}</li>{{/for}}{{/if}}
        </div>
			</div>
		</div>
		{{/for}}
		{{if nextPageQuery}}
			<button type="button" data-page="{{>nextPage}}" class="nextPage btn btn-outline-primary pt-15 pb-15 pl-90 pr-90 mb-30 mt-3 mb-lg-50 full-mb text-button">
			   <span class="">{/literal}{'Load more results'|i18n('bootstrapitalia')}{literal}</span>
			</button>
		{{else}}
			<p class="text-paragraph-regular-medium mt-4 mb-0">{/literal}{'No other results'|i18n('bootstrapitalia')}{literal}</p>
		{{/if}}
	{{/if}}
</script>

<script>
$(document).ready(function() {
	$.opendataTools.settings('language', "{/literal}{ezini('RegionalSettings','Locale')}{literal}");
	$.opendataTools.settings('languages', ['{/literal}{ezini('RegionalSettings','SiteLanguageList')|implode("','")}{literal}']);
	$.views.helpers($.extend({}, $.opendataTools.helpers, {
		'stripTag': function (value) {
			var element = $('<div>'+value+'</div>');
			element.find('*').each(function() {
				var content = $(this).contents();
				$(this).replaceWith(content);
			});

			return element.html()
		}
	}));
	$('[data-block_document_subtree]').each(function(){
    var resultsFound = '';
		var baseUrl = '/';
        if (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/'){
            baseUrl = UriPrefix + '/';
        }
	  var container = $(this);
		var resultsContainer = container.find('.results');
		var rootTagIdList = resultsContainer.data('root_tags');
		var limitPagination = container.data('limit');
		var subtree = container.data('block_document_subtree');		
		var hideEmptyFacets = container.data('hide_empty_facets');
		var hideFirstLevel = container.data('hide_first_level');
		var hideEndTime = container.data('hide_publication_end_time');
		var showOnlyPublication = container.data('show_only_publication');
		var currentPage = 0;
		var queryPerPage = [];
		var template = $.templates('#tpl-document-results');
		var spinner = $($.templates("#tpl-document-spinner").render({}));
		var isLoadedFacetsCount = false;
		var startIdentifier = container.data('start_identifier');
		var endIdentifier = container.data('end_identifier');
		var numberIdentifier = container.data('number_identifier');
    var startDateField = container.find('[data-search="date-start"]');
    var endDateField = container.find('[data-search="date-end"]');
    var dateFields = [];
    var startDate = '';
    var endDate = '';
    var urlParams = new URLSearchParams(window.location.search);
    var tagParam = urlParams.get('tag_id');

		var officeSelect = container.find('[data-search="has_organization"]')
		if (officeSelect.length > 0){
			var opts_list = officeSelect.find('option');
			opts_list.sort(function(a, b) { return $(a).text() > $(b).text() ? 1 : -1; });
			officeSelect.html('').append(opts_list);
			// officeSelect.chosen({allow_single_deselect:true})
		}

    if (startDateField.length > 0) dateFields.push(startDateField);
    if (endDateField.length > 0) dateFields.push(endDateField);

		if (hideFirstLevel){
			container.find('[data-level="1"]').each(function(){
				var self = $(this);
				var children = self.find('[data-level="2"]');
				if (children.length > 0){
					children.each(function(){
						$(this).insertBefore(self);
					});
					self.remove();
				}
			});
		}

    if (startDateField.length > 0) {
      startDateField.on('change', function(){
        startDate = $(this).val();
        endDateField.attr('min', $(this).val());
      })
    }

    if (endDateField.length > 0) {
      endDateField.on('change', function(){
        endDate = $(this).val();
        startDateField.attr('max', $(this).val());
      })
    }

    if (dateFields.length > 1) {
      $.each(dateFields, function(){
        var self = $(this);
        self.on('change', function(){
          if (startDate && endDate) {
            container.find('button[type="submit"]').trigger('click');
          }
        });
      });
    }

	  var buildQueryFilters = function(){
      var filters = [];
			if (showOnlyPublication){
        filters.push({name: 'publication', value: 'current' });
			}
			if (container.find('[data-search="q"]').length > 0) {
				var searchText = container.find('[data-search="q"]').val().replace(/"/g, '').replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
				if (searchText.length > 0) {
          filters.push({name: 'q', value: searchText});
				}
			}
			var tagFilters = [];
			container.find('a[data-tag_id].active').each(function(){
				tagFilters.push($(this).data('tag_id'));
			});
			if (tagFilters.length > 0){
        filters.push({name: 'tag_id', value: tagFilters.join(',')});
			}
			if (container.find('[data-search="has_organization"]').length > 0) {
				var officeFilter = container.find('[data-search="has_organization"]').val();
				if (officeFilter && officeFilter.length > 0) {
          filters.push({name: 'has_organization', value: officeFilter});
				}
			}
			if (container.find('[data-search="has_code"]').length > 0) {
				var hasCodeFilter = container.find('[data-search="has_code"]').val().replace(/"/g, '').replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
				if (hasCodeFilter.length > 0) {
          filters.push({name: 'has_code', value: hasCodeFilter});
				}
			}
			if (container.find('[data-search="year"]').length > 0) {
				var yearFilter = container.find('[data-search="year"]').val();
				if (yearFilter.length > 0) {
          filters.push({name: 'year', value: yearFilter});
				}
			}
			if (startDate && endDate){
        var formattedStartDate = moment(startDate).format('YYYY-MM-DD');
        var formattedEndDate = moment(endDate).format('YYYY-MM-DD');
        filters.push({name: 'date_range', value: [formattedStartDate, formattedEndDate].join(',')});
			}

      return filters;
		};

		var loadFacetsCount = function(data){
			if(isLoadedFacetsCount === false){
				var yearList = [];
				if (hideEmptyFacets){
					container.find('[data-tag_id]').hide();
				}
				container.find('[data-tag_id] small').html('');
				$.each(data, function(){
					if (this.name === 'raw[subattr_document_type___tag_ids____si]') {
						$.each(this.data, function (tagId, tagCount) {
							container.find('[data-tag_id="' + tagId + '"]').show().find('small').html('(' + tagCount + ')');
						});
					} else if (this.name === 'raw[subattr_'+startIdentifier+'___year____dt]'){
						$.each(this.data, function (year, yearCount) {
							yearList.push(moment(year).get('year'))
						});
					}
				});
				isLoadedFacetsCount = true;
				if (yearList.length > 0){
					yearList.sort();
					var dataListContent = $('<datalist id="years"></datalist>');
					$.each(yearList, function (){
						dataListContent.append('<option value="'+this+'">');
					});
					container.find('[data-search="year"]').attr('list', 'years').after(dataListContent);
				}
			}
		};

    function formatSearchResults(counts) {
      const singleResultsLabels = {
        document: '{/literal}{'Document result'|i18n('bootstrapitalia/documents')}{/literal}',
        public_project: "{/literal}{'Project result'|i18n('bootstrapitalia/documents')}{/literal}",
        suffix: "{/literal}{'Result found'|i18n('bootstrapitalia/documents')}{/literal}"
      };
      const multipleResultsLabels = {
        document: '{/literal}{'Documents results'|i18n('bootstrapitalia/documents')}{/literal}',
        public_project: "{/literal}{'Projects results'|i18n('bootstrapitalia/documents')}{/literal}",
        suffix: "{/literal}{'Results found'|i18n('bootstrapitalia/documents')}{/literal}"
      };
      const results = Object.entries(counts)
        .filter(([_, count]) => count > 0)
        .map(([key, count]) => {
            const labels = count === 1 ? singleResultsLabels : multipleResultsLabels;
            return `<strong>${count}</strong> ${labels[key]}`;
        });

      const totalResults = Object.values(counts).reduce((sum, count) => sum + count, 0);
      const suffix = totalResults === 1 ? singleResultsLabels.suffix : multipleResultsLabels.suffix;

      return results.join(", ") + ` ${suffix}`;
    }

    var detectError = function(response,jqXHR){
      if(response.error_message || response.error_code){
        return true;
      }
      return false;
    };

    var find = function (filters, cb, context) {
      $.ajax({
        type: "GET",
        url: "{/literal}{'/openpa/data/albo_pretorio'|ezurl(no)}{literal}",
        data: filters,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data,textStatus,jqXHR) {
          if (!detectError(data,jqXHR)){
            cb.call(context, data);
          }
        },
        error: function (jqXHR) {
          var error = {
            error_code: jqXHR.status,
            error_message: jqXHR.statusText
          };
          detectError(error,jqXHR);
        }
      });
    };

		var loadContents = function(){
			var filters = buildQueryFilters();
      filters.push({name: 'limit', value: limitPagination});
      filters.push({name: 'offset', value: currentPage*limitPagination});
			console.log(filters);
			resultsContainer.find('.nextPage').replaceWith(spinner);
			find(filters, function (response) {
				loadFacetsCount(response.facets);
        const counts = response.facets[2].data;
				response.resultsFound = formatSearchResults(counts);
				response.currentPage = currentPage;
				response.prevPage = currentPage - 1;
				response.nextPage = currentPage + 1;
        var pagination = response.totalCount > 0 ? Math.ceil(response.totalCount/limitPagination) : 0;
        var pages = [];
        var i;
				for (i = 0; i < pagination; i++) {			  		
			  		pages.push({'query': i, 'page': (i+1)});
				} 
        response.pages = pages;
        response.pageCount = pagination;

        $.each(response.searchHits, function(){
            this.baseUrl = baseUrl;
            this.hideEndTime = hideEndTime;
            this.dateFormat = MomentDateFormat;
            this.dateTimeFormat = MomentDateTimeFormat;
            this.startIdentifier = startIdentifier;
            this.endIdentifier = endIdentifier;
            this.numberIdentifier = numberIdentifier;
        });

        var renderData = $(template.render(response));
				if (currentPage > 0){
					resultsContainer.find('.spinner').replaceWith(renderData);
				} else {
					resultsContainer.html(renderData);
				}
        resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
            currentPage = $(this).data('page');
            if (currentPage >= 0) loadContents();
            e.preventDefault();
        });
			});
		};

		container.find('form')[0].reset();

    if (tagParam) {
      const tagIds = tagParam.split(',');

      tagIds.forEach(function(tagId) {
        const listItem = container.find('a[data-tag_id="' + tagId + '"]');
        if (listItem.length) {
          listItem.addClass('active');
          listItem.css('font-weight', 'bold');
        }
      });
      container.find('button[type="reset"]').removeClass('hide');
    }

    currentPage = 0;
    loadContents();

		container.find('a[data-tag_id]').on('click', function(e){
			e.preventDefault();
			var listItem = $(this);
      
      // Aggiunta/rimozione classe e stile
			if (listItem.hasClass('active')){
				listItem.removeClass('active');
				listItem.css('font-weight', 'normal');
			}else{
				listItem.addClass('active');
				listItem.css('font-weight', 'bold');
			}

			var idList = [];
			container.find('a[data-tag_id].active').each(function(){
				idList.push($(this).data('tag_id'));
			});

      if (idList.length > 0) {
        container.find('button[type="reset"]').removeClass('hide');
      } else {
        container.find('button[type="reset"]').addClass('hide');
      }

      const newUrl = new URL(window.location.href);
      if (idList.length > 0) {
        newUrl.searchParams.set('tag_id', idList.join(','));
      } else {
        newUrl.searchParams.delete('tag_id');
      }
      history.replaceState({}, '', newUrl.toString());

			// location.hash = idList.join(',');
			currentPage = 0;
	    loadContents();
		});

		container.find('select[data-search]').on('change', function (){
			container.find('button[type="submit"]').trigger('click');
		})

		container.find('button[type="submit"]').on('click', function(e){
			container.find('button[type="reset"]').removeClass('hide');
			currentPage = 0;
	    loadContents();
			e.preventDefault();
		});
		container.find('button[type="reset"]').on('click', function(e){			
      container.find('form')[0].reset();
      container.find('button[type="reset"]').addClass('hide');

      const url = new URL(window.location.href);
      url.searchParams.delete('tag_id');
      history.replaceState({}, '', url.toString());

      container.find('a[data-tag_id]').removeClass('active').css('font-weight', 'normal');

      isLoadedFacetsCount = false;
      currentPage = 0;
      startDate = '';
      endDate = '';

      loadContents();

      e.preventDefault();
		});
		// $.each(location.hash.split(','), function () {
		// 	container.find('a[data-tag_id="'+this+'"]').trigger('click');
		// })
	});
}); 
</script>
{/literal}
{/run-once}


{undef $root_tags}

{undef $blocks $official_noticeboard_title $publication_range}
