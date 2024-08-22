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
	'hide_search_office', 'office',
	'hide_search_area', 'area',
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
{def $area_count = fetch(content, tree_count, hash(parent_node_id, ezini('NodeSettings', 'RootNode', 'content.ini'), class_filter_type, 'include', class_filter_array, array('administrative_area')))}
{def $office_count = fetch(content, tree_count, hash(parent_node_id, ezini('NodeSettings', 'RootNode', 'content.ini'), class_filter_type, 'include', class_filter_array, array('office')))}

{def $start_date = cond(and(is_set($block.custom_attributes.start_date), $block.custom_attributes.start_date|ne(''), array('start_time','publication_start_time','data_di_firma','data_protocollazione')|contains($block.custom_attributes.start_date)), $block.custom_attributes.start_date, 'publication_start_time')}
{def $end_date = cond(and(is_set($block.custom_attributes.end_date), $block.custom_attributes.end_date|ne(''), array('end_time','publication_end_time','expiration_time','data_di_scadenza_delle_iscrizioni','data_di_conclusione')|contains($block.custom_attributes.end_date)), $block.custom_attributes.end_date, 'publication_end_time')}
{def $number = cond(and(is_set($block.custom_attributes.number), $block.custom_attributes.number|ne(''), array('has_code','protocollo')|contains($block.custom_attributes.number)), $block.custom_attributes.number, 'has_code')}
{* controllo sulla tipologia del numero selezionato *}
{def $number_is_string = true()}
{def $document_class = fetch(content, class, hash(class_id, 'document'))}
{if and(is_set($document_class.data_map[$number]), $document_class.data_map[$number].data_type_string|eq('ezinteger'))}
	{set $number_is_string = false()}
{/if}

<div data-block_document_subtree="{cond(is_set($block.custom_attributes.node_id), $block.custom_attributes.node_id, 1)}"
	 data-hide_publication_end_time="{cond(and(is_set($block.custom_attributes.hide_publication_end_time), $block.custom_attributes.hide_publication_end_time|eq('1')), 'true','false')}"
	 data-show_only_publication="{cond(and(is_set($block.custom_attributes.show_only_publication), $block.custom_attributes.show_only_publication|eq('1')), 'true','false')}"
	 data-limit="20"
	 data-hide_empty_facets="{cond($block.custom_attributes.hide_empty_facets, 'true', 'false')}"
	 data-topics="{$topics_filter}"
	 data-hide_first_level="{cond($block.custom_attributes.hide_first_level, 'true', 'false')}"
	 data-start_identifier="{$start_date|wash()}"
	 data-end_identifier="{$end_date|wash()}"
	 data-number_as_string="{cond($number_is_string, 'enabled', 'disabled')}"
	 data-number_identifier="{$number|wash()}">
	{if $filters|count()}
	<div class="d-block d-lg-none d-xl-none text-center mb-2">
		<a href="#filters" role="button" class="btn btn-primary btn-md text-uppercase collapsed" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="filters">{'Filters'|i18n('bootstrapitalia')}</a>
	</div>
	<div class="d-lg-block d-xl-block collapse" id="filters">
		<form class="form">
			<div class="form-row flex-nowrap">
				{if $filters|contains('search_text')}
				<div class="col-md-4 col-lg-2 my-2">
					<label for="search-{$block.id}" class="m-0 d-none"><small>{'Search text'|i18n('bootstrapitalia/documents')}</small></label>
					<input type="text" autocomplete="off" class="form-control chosen-border" id="search-{$block.id}" data-search="q" placeholder="{'Search text'|i18n('bootstrapitalia/documents')}">
				</div>
				{/if}
				{if $filters|contains('number')}
				<div class="col-md-2 col-lg-1 my-2">
					<label for="searchFormNumber-{$block.id}" class="m-0 d-none"><small>{'Document number'|i18n('bootstrapitalia/documents')}</small></label>
					<input type="text" autocomplete="off" class="form-control chosen-border" id="searchFormNumber-{$block.id}" data-search="has_code" placeholder="{'Document number'|i18n('bootstrapitalia/documents')}">
				</div>
				{/if}
				{if $filters|contains('year')}
				<div class="col-md-2 col-lg-1 my-2">
					<label for="searchFormYear-{$block.id}" class="m-0 d-none"><small>{'Year'|i18n('openpa/search')}</small></label>
					<input size="4" autocomplete="off" class="form-control chosen-border" id="searchFormYear-{$block.id}" data-search="year" placeholder="{'Year'|i18n('openpa/search')}">
				</div>
				{/if}
				{if $filters|contains('daterange')}
					<div class="col-md-4 col-lg-2 my-2">
						<label for="searchFormDate-{$block.id}" class="m-0 d-none"><small>{'Date'|i18n('bootstrapitalia/documents')}</small></label>
						<input type="text" class="form-control chosen-border" id="searchFormDate-{$block.id}" data-search="daterange" placeholder="{'Date'|i18n('bootstrapitalia/documents')}">
					</div>
				{/if}
				{if and($filters|contains('office'), $office_count|gt(-1))}
				<div class="col-md-4 col-lg-2 my-2">
					<label for="searchFormOffice-{$block.id}" class="m-0 d-none"><small>{'Office'|i18n('bootstrapitalia/documents')}</small></label>
					<select class="form-control custom-select chosen-border" id="searchFormOffice-{$block.id}" data-search="has_organization">
						<option value="">{'Office'|i18n('bootstrapitalia/documents')}</option>
						{foreach fetch(content, tree, hash(parent_node_id, ezini('NodeSettings', 'RootNode', 'content.ini'), class_filter_type, 'include', class_filter_array, array('office'), load_data_map, false(), sort_by, array('name', true()))) as $office}
							<option value="{$office.contentobject_id}">{$office.name|wash()}</option>
						{/foreach}
					</select>
				</div>
				{/if}
				{if and($filters|contains('area'), $area_count|gt(-1))}
				<div class="col-md-4 col-lg-2 my-2">
					<label for="searchFormArea-{$block.id}" class="m-0 d-none"><small>{'Administrative area'|i18n('bootstrapitalia/documents')}</small></label>
					<select class="form-control custom-select chosen-border" id="searchFormArea-{$block.id}" data-search="area">
						<option value="">{'Administrative area'|i18n('bootstrapitalia/documents')}</option>
						{foreach fetch(content, tree, hash(parent_node_id, ezini('NodeSettings', 'RootNode', 'content.ini'), class_filter_type, 'include', class_filter_array, array('administrative_area'), load_data_map, false(), sort_by, array('name', true()))) as $area}
							<option value="{$area.contentobject_id}">{$area.name|wash()}</option>
						{/foreach}
					</select>
				</div>
				{/if}
				{if and($filters|contains('topics'), $topics_filter|not())}
					<div class="col-md-4 col-lg-2 my-2">
						<label for="searchFormTopic-{$block.id}" class="m-0 d-none"><small>{'Topics'|i18n('bootstrapitalia')}</small></label>
						<select class="form-control custom-select chosen-border" id="searchFormTopic-{$block.id}" data-search="topic">
							<option value="">{'Topics'|i18n('bootstrapitalia')}</option>
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
				{/if}
				<div class="col-md-12 col-lg-1 my-2 text-center">
					<div class="row">
						<div class="col">
							<button type="submit" class="btn btn-link pt-2 px-lg-0 text-decoration-none">
								<i aria-hidden="true" class="fa fa-search text-black" style="font-size: 1.4em"></i> <span class="d-md-inline d-lg-none text-uppercase h5 text-black">{'Search'|i18n('design/plain/layout')}</span>
							</button>
						</div>
						<div class="col">
							<button type="reset" class="btn btn-link pt-2 px-lg-0 text-decoration-none hide">
								<i aria-hidden="true" class="fa fa-close resetSearch text-danger" style="font-size: 1.4em"></i> <span class="d-md-inline d-lg-none text-uppercase h5 text-danger">{'Reset'|i18n('bootstrapitalia/documents')}</span>
							</button>
						</div>
					</div>
				</div>
			</div>
		</form>
	</div>
	{/if}
	<div class="row border-top row-column-border row-column-menu-left attribute-list mt-0">
	    {if and($root_tags|count(), $root_tags[0]|ne(''))}
		    <aside class="col-lg-4{if $hide_tag_select} d-none{/if}">
				<div class="d-block d-lg-none d-xl-none text-center mb-2">
					<a href="#types" role="button" class="btn btn-primary btn-md text-uppercase collapsed" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="types">{'Document type'|i18n('bootstrapitalia/documents')}</a>
				</div>
				<div class="link-list-wrapper menu-link-list d-lg-block d-xl-block collapse" id="types">
					<ul class="link-list">
						<li>
							<h3 class="d-none d-lg-block">{'Document type'|i18n('bootstrapitalia/documents')}</h3>
						</li>
						{def $root_tag_id_list = array()}
						{foreach $root_tags as $root_index => $root_tag}
							{def $tag_tree = api_tagtree($root_tag)}
							{set $root_tag_id_list = $root_tag_id_list|append($tag_tree.id)}
							{if is_set($tag_tree.children)}
								{foreach $tag_tree.children as $index => $tag}
									{if and($root_index|gt(0), $index|eq(0))}<li class="border-top my-2"></li>{/if}
									<li data-level="1">
										<a class="list-item pr-0 pe-0" data-tag_id="{$tag.id|wash()}" href="#"><span>{$tag.keyword|wash()} <small></small></span></a>

										{if $tag.hasChildren}
											<ul class="link-sublist">
											{foreach $tag.children as $childTag}
												<li data-level="2">
													<a class="list-item pr-0 pe-0" data-tag_id="{$childTag.id|wash()}" href="#"><span>{$childTag.keyword|wash()} <small></small></span></a>
													{if $childTag.hasChildren}
														<ul class="link-sublist">
														{foreach $childTag.children as $subChildTag}
															<li data-level="3">
																<a class="list-item pr-0 pe-0" data-tag_id="{$subChildTag.id|wash()}" href="#"><span>{$subChildTag.keyword|wash()} <small></small></span></a>
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
							{undef $tag_tree}
						{/foreach}
					</ul>
				</div>
		    </aside>
	    {/if}

	    <section class="{if and($root_tag_id_list|count()|gt(0), $hide_tag_select|not())}col-lg-8{else}col{/if} p-0">
			<div class="results p-3" data-root_tags="{$root_tag_id_list|implode(',')}"></div>
	    </section>
	</div>
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
	{{if totalCount > 0}}	
	<div class="row mb-3 d-none d-md-flex">		
		<div class="col-md-3"><strong>{/literal}{'Date'|i18n('bootstrapitalia/documents')}{literal}</strong></div>
		<div class="col-md-9"><strong>{/literal}{'Subject'|i18n('bootstrapitalia/documents')}{literal}</strong></div>
	</div>
	{{else}}
		<div class="row mb-2">
			<div class="col"><em>{/literal}{'No documents were found'|i18n('bootstrapitalia/documents')}{literal}</em></div>
		</div>
	{{/if}}
	{{for searchHits}}		
		<div class="row mb-3 pt-3 border-top">				
			<div class="col-md-3"><strong class="d-inline d-sm-none">{/literal}{'Date'|i18n('bootstrapitalia/documents')}{literal}</strong>
				{{if ~i18n(data,startIdentifier) && ~i18n(data,endIdentifier) && !hideEndTime}}
					<small>{/literal}{'From'|i18n('bootstrapitalia/documents')}{literal} {{:~formatDate(~i18n(data,startIdentifier), dateFormat)}}
					<br />{/literal}{'to'|i18n('bootstrapitalia/documents')}{literal} {{:~formatDate(~i18n(data,endIdentifier), dateFormat)}}</small>
				{{else}}
					{{:~formatDate(~i18n(data,startIdentifier), dateFormat)}}
				{{/if}}
			</div>			
			<div class="col-md-9">
				<strong class="d-block d-sm-none">{/literal}{'Subject'|i18n('bootstrapitalia/documents')}{literal}</strong>
				<a href="{{:baseUrl}}content/view/full/{{:metadata.mainNodeId}}">{{:~i18n(metadata.name)}}</a>
				{{if ~i18n(data, 'description')}}<p class="m-0" style="line-height:1.2"><small>{{:~stripTag(~i18n(data, 'description'))}}</small></p>{{/if}}
				<ul class="list-inline m-0"><li class="list-inline-item"><strong>{{:~i18n(data, 'document_type')}}</strong>{{if ~i18n(data, numberIdentifier)}} ({{:~i18n(data, numberIdentifier)}}){{/if}}</li></ul>
				{{if ~i18n(data, 'area') || ~i18n(data, 'has_organization')}}<ul class="list-inline m-0"><li class="list-inline-item"><strong>{/literal}{'Administrative area'|i18n('bootstrapitalia/documents')}/{'Office'|i18n('bootstrapitalia/documents')}{literal}:</strong></li>{{if ~i18n(data, 'area')}}{{for ~i18n(data,'area')}}<li class="list-inline-item">{{:~i18n(name)}}</li>{{/for}}{{/if}}{{if ~i18n(data, 'has_organization')}}{{for ~i18n(data,'has_organization')}}<li class="list-inline-item">{{:~i18n(name)}}</li>{{/for}}{{/if}}</ul>{{/if}}
				{{if ~i18n(data, 'interroganti')}}<ul class="list-inline m-0"><li class="list-inline-item"><strong>{/literal}{'Questioners'|i18n('bootstrapitalia/documents')}{literal}:</strong></li>{{for ~i18n(data,'interroganti')}}<li class="list-inline-item">{{:~i18n(name)}}</li>{{/for}}{{/if}}
			</div>		
		</div>
	{{/for}}	

	{{if pageCount > 1}}
	<div class="row mt-lg-4">
	    <div class="col">
	        <nav class="pagination-wrapper justify-content-center" aria-label="{/literal}{'Navigation'|i18n('design/ocbootstrap/menu')}{literal}">
	            <ul class="pagination">
	                
	                <li class="page-item {{if !prevPageQuery}}disabled{{/if}}">
	                    <a class="page-link prevPage" {{if prevPageQuery}}data-page="{{>prevPage}}"{{/if}} href="#">
	                        <svg class="icon icon-primary">
	                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-left"></use>
	                        </svg>
	                        <span class="sr-only">{/literal}{"Previous"|i18n("design/admin/navigator")}{literal}</span>
	                    </a>
	                </li>
	                               
	                {{for pages ~current=currentPage}}	                
						<li class="page-item"><a href="#" class="page-link page" data-page_number="{{:page}}" data-page="{{:query}}"{{if ~current == query}} data-current aria-current="page"{{/if}}>{{:page}}</a></li>						
					{{/for}}	

	                <li class="page-item {{if !nextPageQuery}}disabled{{/if}}">
	                    <a class="page-link nextPage" {{if nextPageQuery}}data-page="{{>nextPage}}"{{/if}} href="#">
	                        <span class="sr-only">{/literal}{"Next"|i18n("design/admin/navigator")}{literal}</span>
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

<script>
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
$(document).ready(function () {
	$('[data-block_document_subtree]').each(function(){
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
		var numberAsString = container.data('number_as_string') === 'enabled';

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
			}).on('cancel.daterangepicker', function(ev, picker) {
				$(this).val('');
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
					if (numberAsString) {
						query += ' and raw[attr_' + numberIdentifier + '_t] = \'"' + hasCodeFilter + '"\'';
					}else{
						query += ' and ' + numberIdentifier + ' = \'' + hasCodeFilter + '\'';
					}
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
			resultsContainer.html(spinner);
			$.opendataTools.find(paginatedQuery, function (response) {				
				loadFacetsCount(response.facets);
				queryPerPage[currentPage] = paginatedQuery;				
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
				resultsContainer.html(renderData);

	            resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
	                currentPage = $(this).data('page');
	                if (currentPage >= 0) loadContents();
	                e.preventDefault();
	            });
	            var more = $('<li class="page-item"><span class="page-link">...</span></li');
	            var displayPages = resultsContainer.find('.page[data-page_number]');
	            
	            var currentPageNumber = resultsContainer.find('.page[data-current]').data('page_number');
	            var length = 7;
	            if (displayPages.length > (length+2)){
	            	if (currentPageNumber <= (length-1)){
	            		resultsContainer.find('.page[data-page_number="'+length+'"]').parent().after(more.clone());
	            		for (i = length; i < pagination; i++) {	            			
	            			resultsContainer.find('.page[data-page_number="'+i+'"]').parent().hide();
	            		}
	            	}else if (currentPageNumber >= length ){	            		
	            		resultsContainer.find('.page[data-page_number="1"]').parent().after(more.clone());
	            		var itemToRemove = (currentPageNumber+1-length);
	            		for (i = 2; i < pagination; i++) {
	            			if (itemToRemove > 0){
	            				resultsContainer.find('.page[data-page_number="'+i+'"]').parent().hide();
	            				itemToRemove--;
	            			}
	            		}
	            		if (currentPageNumber < (pagination-1)){
	            			resultsContainer.find('.page[data-current]').parent().after(more.clone());
	            		}
	            		for (i = (currentPageNumber+1); i < pagination; i++) {
	            			resultsContainer.find('.page[data-page_number="'+i+'"]').parent().hide();
	            		}
	            	}
	            }
			});
		};

		container.find('form')[0].reset();
		loadContents();

		container.find('a[data-tag_id]').on('click', function(e){
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
			location.hash = idList.join(',');
			currentPage = 0;
	        loadContents();
			e.preventDefault();
		});

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
		$.each(location.hash.split(','), function () {
			container.find('a[data-tag_id="'+this+'"]').trigger('click');
		})
	});
}); 
</script>
{/literal}
{/run-once}


{undef $root_tags}
