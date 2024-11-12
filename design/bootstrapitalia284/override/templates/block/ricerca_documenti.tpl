{ezscript_require(array(
    'jsrender.js',
    'handlebars.min.js',
    'bootstrap-datetimepicker.min.js',
	'daterangepicker.js'
))}
{ezcss_require(array(
    'bootstrap-datetimepicker.min.css',
	'daterangepicker-bs3.css'
))}
{def $locale = fetch(content, locale)}
{def $filters = array()}
{def $filterMap = hash(
	'hide_search_text', 'search_text',
	'hide_search_number', 'number',
	'hide_search_year', 'year',
	'hide_search_daterange', 'daterange',
	'hide_search_office', 'has_organization',
	'hide_search_area', 'has_organization',
	'hide_search_topics', 'topics'
)}
{foreach $filterMap as $setting_field => $flag_identifier}
	{if or(is_set($block.custom_attributes[$setting_field])|not(), $block.custom_attributes[$setting_field]|eq(0))}
		{set $filters = $filters|append($flag_identifier)}
	{/if}
{/foreach}

{def $root_tags = $block.custom_attributes.root_tag|explode(',')}
{def $hide_tag_select = cond(and(is_set($block.custom_attributes.hide_tag_select), $block.custom_attributes.hide_tag_select|eq('1')), true(), false())}
{def $topics_filter = cond(and(is_set($block.custom_attributes.topic_node_id), $block.custom_attributes.topic_node_id|ne('')), $block.custom_attributes.topic_node_id|wash(), false())}
{def $topics = fetch(content, object, hash(remote_id, 'topics'))
	 $topic_list = tree_menu( hash( 'root_node_id', $topics.main_node_id, 'user_hash', false(), 'scope', 'side_menu'))
	 $topic_list_children = $topic_list.children}
{def $office_count = fetch(content, tree_count, hash(parent_node_id, ezini('NodeSettings', 'RootNode', 'content.ini'), class_filter_type, 'include', class_filter_array, array('organization')))}

{def $start_date = cond(and(is_set($block.custom_attributes.start_date), $block.custom_attributes.start_date|ne(''), array('start_time','publication_start_time','data_di_firma','data_protocollazione')|contains($block.custom_attributes.start_date)), $block.custom_attributes.start_date, 'publication_start_time')}
{def $end_date = cond(and(is_set($block.custom_attributes.end_date), $block.custom_attributes.end_date|ne(''), array('end_time','publication_end_time','expiration_time','data_di_scadenza_delle_iscrizioni','data_di_conclusione')|contains($block.custom_attributes.end_date)), $block.custom_attributes.end_date, 'publication_end_time')}
{def $number = cond(and(is_set($block.custom_attributes.number), $block.custom_attributes.number|ne(''), array('has_code','protocollo')|contains($block.custom_attributes.number)), $block.custom_attributes.number, 'has_code')}

{def $root_tag_id_list = array()}
{def $root_tag_list = array()}
{foreach $root_tags as $root_index => $root_tag}
	{def $tag_tree = api_tagtree($root_tag)}
	{set $root_tag_id_list = $root_tag_id_list|append($tag_tree.id)}
	{set $root_tag_list = $root_tag_list|append($tag_tree)}
	{undef $tag_tree}
{/foreach}

{def $show_filters = cond(or(count($filters)|gt(1), and($root_tag_id_list|count()|gt(0), $hide_tag_select|not())), true(), false())}

{include uri='design:parts/block_name.tpl'}

<div data-block_document_subtree="{cond(is_set($block.custom_attributes.node_id), $block.custom_attributes.node_id, 1)}"
	 data-hide_publication_end_time="{cond(and(is_set($block.custom_attributes.hide_publication_end_time), $block.custom_attributes.hide_publication_end_time|eq('1')), 'true','false')}"
	 data-show_only_publication="{cond(and(is_set($block.custom_attributes.show_only_publication), $block.custom_attributes.show_only_publication|eq('1')), 'true','false')}"
	 data-limit="10"
	 data-hide_empty_facets="{cond($block.custom_attributes.hide_empty_facets, 'true', 'false')}"
	 data-topics="{$topics_filter}"
	 data-hide_first_level="{cond($block.custom_attributes.hide_first_level, 'true', 'false')}"
	 data-start_identifier="{$start_date|wash()}"
	 data-end_identifier="{$end_date|wash()}"
	 data-number_identifier="{$number|wash()}">

	<form class="row">
	    <section class="{if $show_filters}col-12 col-lg-8 {else}col-12{/if} pt-lg-2 pb-lg-2">
			{if $filters|contains('search_text')}
			<div class="cmp-input-search">
				<div class="form-group autocomplete-wrapper mb-2 mb-lg-4">
					<div class="input-group">
						<label for="search-{$block.id}" class="visually-hidden">{'Search text'|i18n('bootstrapitalia/documents')}</label>
						<input type="text" data-search="q" class="autocomplete form-control" placeholder="{'Search text'|i18n('bootstrapitalia/documents')}" id="search-{$block.id}">
						<div class="input-group-append">
							<button type="reset" class="btn btn-link bg-white border-0 border-bottom border-primary hide"><i class="fa fa-close"></i></button>
							<button class="btn btn-primary" type="submit"  data-focus-mouse="false">{'Search'|i18n('design/plain/layout')}</button>
						</div>
						<span class="autocomplete-icon" aria-hidden="true">{display_icon('it-search', 'svg', 'icon icon-sm icon-primary')}</span>
					</div>
				</div>
			</div>
			{/if}
			<div class="results" data-root_tags="{$root_tag_id_list|implode(',')}"></div>
	    </section>

		{if $show_filters}
			<div class="col-12 col-lg-4 ps-lg-5 order-first order-md-last">

				<div class="cmp-accordion accordion">
					{if $hide_tag_select|not()}
					<div class="accordion-item bg-none{if $hide_tag_select} d-none{/if}">
						  <span class="accordion-header" id="collapseTagList-{$block.id}-title">
							<button class="accordion-button collapsed pb-10 px-3 text-uppercase text-decoration-none" type="button"
									data-bs-toggle="collapse" href="#collapseTagList-{$block.id}" role="button" aria-expanded="false" aria-controls="collapseTagList-{$block.id}"
									data-focus-mouse="false">
								{'Document type'|i18n('bootstrapitalia/documents')}
							</button>
						  </span>
						<div id="collapseTagList-{$block.id}" class="accordion-collapse collapse" role="region" aria-labelledby="collapseTagList-{$block.id}-title">
							<div class="accordion-body">
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
						  <span class="accordion-header" id="collapseNumber-{$block.id}-title">
							<button class="accordion-button collapsed pb-10 px-3 text-uppercase text-decoration-none" type="button"
									data-bs-toggle="collapse" href="#collapseNumber-{$block.id}" role="button" aria-expanded="false" aria-controls="collapseNumber-{$block.id}"
									data-focus-mouse="false">
								{'Document number'|i18n('bootstrapitalia/documents')}
							</button>
						  </span>
						<div id="collapseNumber-{$block.id}" class="accordion-collapse collapse" role="region" aria-labelledby="collapseNumber-{$block.id}-title">
							<div class="accordion-body">
								<label for="searchFormNumber-{$block.id}" class="visually-hidden">{'Document number'|i18n('bootstrapitalia/documents')}</label>
								<input type="text" autocomplete="off" class="form-control form-control-sm" id="searchFormNumber-{$block.id}" data-search="has_code" placeholder="{'Document number'|i18n('bootstrapitalia/documents')}">
							</div>
						</div>
					</div>
					{/if}

					{if $filters|contains('year')}
						<div class="accordion-item bg-none">
						  <span class="accordion-header" id="collapseYear-{$block.id}-title">
							<button class="accordion-button collapsed pb-10 px-3 text-uppercase text-decoration-none" type="button"
									data-bs-toggle="collapse" href="#collapseYear-{$block.id}" role="button" aria-expanded="false" aria-controls="collapseYear-{$block.id}"
									data-focus-mouse="false">
								{'Year'|i18n('openpa/search')}
							</button>
						  </span>
							<div id="collapseYear-{$block.id}" class="accordion-collapse collapse" role="region" aria-labelledby="collapseYear-{$block.id}-title">
								<div class="accordion-body">
									<label for="searchFormYear-{$block.id}" class="visually-hidden">{'Year'|i18n('openpa/search')}</label>
									<input type="text" size="4" autocomplete="off" class="form-control form-control-sm" id="searchFormYear-{$block.id}" data-search="year" placeholder="{'Year'|i18n('openpa/search')}">
								</div>
							</div>
						</div>
					{/if}

					{if $filters|contains('daterange')}
						<div class="accordion-item bg-none">
						  <span class="accordion-header" id="collapseDate-{$block.id}-title">
							<button class="accordion-button collapsed pb-10 px-3 text-uppercase text-decoration-none" type="button"
									data-bs-toggle="collapse" href="#collapseDate-{$block.id}" role="button" aria-expanded="false" aria-controls="collapseDate-{$block.id}"
									data-focus-mouse="false">
								{'Date'|i18n('bootstrapitalia/documents')}
							</button>
						  </span>
							<div id="collapseDate-{$block.id}" class="accordion-collapse collapse" role="region" aria-labelledby="collapseDate-{$block.id}-title">
								<div class="accordion-body">
									<label for="searchFormDate-{$block.id}" class="visually-hidden"><small>{'Date'|i18n('bootstrapitalia/documents')}</small></label>
									<input type="text" class="form-control form-control-sm" id="searchFormDate-{$block.id}" data-search="daterange" placeholder="{'Date'|i18n('bootstrapitalia/documents')}">
								</div>
							</div>
						</div>
					{/if}

					{if and($filters|contains('has_organization'), $office_count|gt(0))}
						<div class="accordion-item bg-none">
						  <span class="accordion-header" id="collapseOffice-{$block.id}-title">
							<button class="accordion-button collapsed pb-10 px-3 text-uppercase text-decoration-none" type="button"
									data-bs-toggle="collapse" href="#collapseOffice-{$block.id}" role="button" aria-expanded="false" aria-controls="collapseOffice-{$block.id}"
									data-focus-mouse="false">
								{'Office'|i18n('bootstrapitalia/documents')}
							</button>
						  </span>
							<div id="collapseOffice-{$block.id}" class="accordion-collapse collapse" role="region" aria-labelledby="collapseOffice-{$block.id}-title">
								<div class="accordion-body">
									<label for="searchFormOffice-{$block.id}" class="visually-hidden"><small>{'Office'|i18n('bootstrapitalia/documents')}</small></label>
									<select class="form-control border-bottom" id="searchFormOffice-{$block.id}" data-search="has_organization">
										<option value=""></option>
										{foreach fetch(content, tree, hash( parent_node_id, ezini('NodeSettings', 'RootNode', 'content.ini'),
																			class_filter_type, 'include', class_filter_array, array('organization'),
																			main_node_only, true(),
																			load_data_map, false(),
																			sort_by, array('name', true()))) as $office}
											<option value="{$office.contentobject_id}">{$office.name|wash()}</option>
										{/foreach}
									</select>
								</div>
							</div>
						</div>
					{/if}

					{if and($filters|contains('topics'), $topics_filter|not())}
						<div class="accordion-item bg-none">
						  <span class="accordion-header" id="collapseTopic-{$block.id}-title">
							<button class="accordion-button collapsed pb-10 px-3 text-uppercase text-decoration-none" type="button"
									data-bs-toggle="collapse" href="#collapseTopic-{$block.id}" role="button" aria-expanded="false" aria-controls="collapseTopic-{$block.id}"
									data-focus-mouse="false">
								{'Topics'|i18n('bootstrapitalia')}
							</button>
						  </span>
							<div id="collapseTopic-{$block.id}" class="accordion-collapse collapse" role="region" aria-labelledby="collapseTopic-{$block.id}-title">
								<div class="accordion-body">
									<label for="searchFormTopic-{$block.id}" class="visually-hidden"><small>{'Topics'|i18n('bootstrapitalia')}</small></label>
									<select class="form-control border-bottom" id="searchFormTopic-{$block.id}" data-search="topic">
										<option value=""></option>
										{foreach $topic_list_children as $topic}
											<option value="{$topic.item.node_id}">{$topic.item.name|wash()}</option>
											{if $topic.has_children}
												{foreach $topic.children as $child}
													<option value="{$child.item.node_id}">&nbsp;&nbsp;{$child.item.name|wash()}</option>
												{/foreach}
											{/if}
										{/foreach}
									</select>
								</div>
							</div>
						</div>
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
			<div class="col"><em>{/literal}{'No documents were found'|i18n('bootstrapitalia/documents')}{literal}</em></div>
		</div>
	{{else}}
		{{if currentPage == 0}}
			<p class="mb-4 results-count">{{:documentsFound}}</p>
		{{/if}}
		{{for searchHits}}
		<div class="cmp-card-latest-messages mb-3 mb-30">
			<div class="card shadow-sm px-4 pt-4 pb-4 rounded">
				<span class="visually-hidden">{/literal}{'Date'|i18n('bootstrapitalia/documents')}{literal}:</span>
				<div class="card-header border-0 p-0">
					<span class="text-decoration-none title-xsmall-bold mb-2 category text-uppercase">
						{{if ~i18n(data,startIdentifier) && ~i18n(data,endIdentifier) && !hideEndTime}}
							{/literal}{'From'|i18n('bootstrapitalia/documents')}{literal} {{:~formatDate(~i18n(data,startIdentifier), dateFormat)}}
							{/literal}{'to'|i18n('bootstrapitalia/documents')}{literal} {{:~formatDate(~i18n(data,endIdentifier), dateFormat)}}
						{{else}}
							{{:~formatDate(~i18n(data,startIdentifier), dateFormat)}}
						{{/if}}
					</span>
				</div>
				<div class="card-body p-0 my-2">
					<h3 class="green-title-big mb-8">
						<a class="text-decoration-none" href="{{if ~i18n(extradata,'urlAlias')}}{{:~i18n(extradata,'urlAlias')}}{{else}}{{:baseUrl}}openpa/object/{{:metadata.id}}{{/if}}">{{:~i18n(metadata.name)}}</a>
					</h3>
					{{if ~i18n(data, 'description')}}<p class="text-paragraph">{{:~stripTag(~i18n(data, 'description'))}}</p>{{/if}}
					<ul class="list-inline m-0"><li class="list-inline-item"><strong>{{:~i18n(data, 'document_type')}}</strong>{{if ~i18n(data, numberIdentifier)}} ({{:~i18n(data, numberIdentifier)}}){{/if}}</li></ul>
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
			<p class="text-paragraph-regular-medium mt-4 mb-0">{/literal}{'Nessun altro risultato'|i18n('bootstrapitalia')}{literal}</p>
		{{/if}}
	{{/if}}
</script>

<script>
$(document).ready(function () {
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
        var documentsFound = '{/literal}{'%count documents found'|i18n('bootstrapitalia/documents')}{/literal}';
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
		var topics = container.data('topics').toString();
		var currentPage = 0;
		var queryPerPage = [];
		var template = $.templates('#tpl-document-results');
		var spinner = $($.templates("#tpl-document-spinner").render({}));
		var isLoadedFacetsCount = false;
		var startIdentifier = container.data('start_identifier');
		var endIdentifier = container.data('end_identifier');
		var numberIdentifier = container.data('number_identifier');

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

		var dateRange = container.find('[data-search="daterange"]');
		if (dateRange.length > 0){
			dateRange.daterangepicker({
				autoUpdateInput: false,
				"opens": "left",
				locale: {
					format: MomentDateFormat,
					"applyLabel": "{/literal}{'Apply'|i18n('design/standard/ezoe')}{literal}",
					"cancelLabel": "{/literal}{'Cancel'|i18n('design/standard/ezoe')}{literal}",
					"fromLabel": "{/literal}{'From'|i18n('bootstrapitalia/documents')}{literal}",
					"toLabel": "{/literal}{'to'|i18n('bootstrapitalia/documents')}{literal}",
					"daysOfWeek": [
						"{/literal}{$locale.weekday_short_name_list[0]}{literal}",
						"{/literal}{$locale.weekday_short_name_list[1]}{literal}",
						"{/literal}{$locale.weekday_short_name_list[2]}{literal}",
						"{/literal}{$locale.weekday_short_name_list[3]}{literal}",
						"{/literal}{$locale.weekday_short_name_list[4]}{literal}",
						"{/literal}{$locale.weekday_short_name_list[5]}{literal}",
						"{/literal}{$locale.weekday_short_name_list[6]}{literal}"
					],
					"monthNames": ["{/literal}{$locale.month_name_list|implode('","')}{literal}"]
				}
			});
			dateRange.on('apply.daterangepicker', function(ev, picker) {
				$(this).val(picker.startDate.format(MomentDateFormat) + ' - ' + picker.endDate.format(MomentDateFormat));
				container.find('button[type="submit"]').trigger('click');
			}).on('cancel.daterangepicker', function(ev, picker) {
				$(this).val('');
				container.find('button[type="submit"]').trigger('click');
			});
		}

	    var buildQuery = function(){
			var query = 'classes [document] subtree [' + subtree + '] facets [raw[subattr_document_type___tag_ids____si],raw[subattr_'+startIdentifier+'___year____dt]]';
			if (showOnlyPublication){
				query += ' and (calendar['+startIdentifier+','+endIdentifier+'] = [yesterday,now] or ('+startIdentifier+' range [*,now] and '+endIdentifier+' !range [*,*]))';
			}
			if (rootTagIdList !== ''){
				query += " and raw[subattr_document_type___tag_ids____si] in [" + rootTagIdList + "]";
			}
			if (container.find('[data-search="q"]').length > 0) {
				var searchText = container.find('[data-search="q"]').val().replace(/"/g, '').replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
				if (searchText.length > 0) {
					query += " and q = '\"" + searchText + "\"'";
				}
			}
			var tagFilters = [];
			container.find('a[data-tag_id].active').each(function(){
				tagFilters.push($(this).data('tag_id'));
			});
			if (tagFilters.length > 0){
				query += " and raw[subattr_document_type___tag_ids____si] in [" + tagFilters.join(',') + "]";
			}
			if (container.find('[data-search="has_organization"]').length > 0) {
				var officeFilter = container.find('[data-search="has_organization"]').val();
				if (officeFilter && officeFilter.length > 0) {
					query += " and has_organization.id in [" + officeFilter + "]";
				}
			}
			if (container.find('[data-search="area"]').length > 0) {
				var areaFilter = container.find('[data-search="area"]').val();
				if (areaFilter && areaFilter.length > 0) {
					query += " and area.id in [" + areaFilter + "]";
				}
			}
			if (container.find('[data-search="has_code"]').length > 0) {
				var hasCodeFilter = container.find('[data-search="has_code"]').val().replace(/"/g, '').replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
				if (hasCodeFilter.length > 0) {
					query += ' and raw[attr_'+numberIdentifier+'_t] = \'"' + hasCodeFilter + '"\'';
				}
			}
			if (container.find('[data-search="year"]').length > 0) {
				var yearFilter = container.find('[data-search="year"]').val();
				if (yearFilter.length > 0) {
					var dateFilter = moment(yearFilter, "YYYY");
					query += ' and calendar['+startIdentifier+','+endIdentifier+'] = [' + dateFilter.dayOfYear(1).set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm') + ','
							+ dateFilter.dayOfYear(365).set('hour', 23).set('minute', 59).format('YYYY-MM-DD HH:mm') + ']';
				}
			}
			if (dateRange.length > 0 && dateRange.val().length > 0){
				var picker = dateRange.data('daterangepicker');
				query += ' and calendar['+startIdentifier+','+endIdentifier+'] = [' + picker.startDate.format('YYYY-MM-DD') + ' 00:00,'
						+ picker.endDate.format('YYYY-MM-DD') + ' 23:59]';
			}
			if (topics.length > 0){
				query += ' and raw[submeta_topics___main_node_id____si] in ['+topics+']';
			}else{
				var topicsFilter = container.find('[data-search="topic"]').val();
				if (topicsFilter && topicsFilter.length > 0){
					query += ' and raw[submeta_topics___main_node_id____si] in ['+topicsFilter+']';
				}
			}
			var sort = ' sort ['+startIdentifier+'=>desc';
			if (numberIdentifier === 'has_code'){
				sort += ',raw[extra_has_code_sl]=>desc';
			}else {
				sort += ',' + numberIdentifier + '=>desc';
			}
			sort += ']';
			query += sort;
			
			return query;
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
					}else if (this.name === 'raw[subattr_'+startIdentifier+'___year____dt]'){
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

		var loadContents = function(){						
			var baseQuery = buildQuery();
			var paginatedQuery = baseQuery + ' and limit ' + limitPagination + ' offset ' + currentPage*limitPagination;
			resultsContainer.find('.nextPage').replaceWith(spinner);
			$.opendataTools.find(paginatedQuery, function (response) {				
				loadFacetsCount(response.facets);
				queryPerPage[currentPage] = paginatedQuery;				
				response.documentsFound = documentsFound.replace('%count', '<strong>'+response.totalCount+'</strong>');
				response.currentPage = currentPage;
				response.prevPage = currentPage - 1;
				response.nextPage = currentPage + 1;
	            var pagination = response.totalCount > 0 ? Math.ceil(response.totalCount/limitPagination) : 0;
            	var pages = [];
            	var i;
				for (i = 0; i < pagination; i++) {			  		
			  		queryPerPage[i] = baseQuery + ' and limit ' + limitPagination + ' offset ' + (limitPagination*i);			  		
			  		pages.push({'query': i, 'page': (i+1)});
				} 
	            response.pages = pages;
	            response.pageCount = pagination;
	            response.prevPageQuery = jQuery.type(queryPerPage[response.prevPage]) === "undefined" ? null : queryPerPage[response.prevPage];

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
				}else {
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
		loadContents();

		container.find('a[data-tag_id]').on('click', function(e){
			e.preventDefault();
			var listItem = $(this);
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
			currentPage = 0;
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
