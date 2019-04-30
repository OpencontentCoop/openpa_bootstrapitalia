{ezscript_require(array(    
    'jsrender.js',
    'handlebars.min.js',
    'bootstrap-datetimepicker.min.js'
))}
{ezcss_require(array(
    'bootstrap-datetimepicker.min.css'    
))}

{def $tag_tree = cond($block.custom_attributes.root_tag, api_tagtree($block.custom_attributes.root_tag), false())}

<div data-block_document_subtree="{$block.custom_attributes.node_id}" data-limit="20" data-hide_empty_facets="{$block.custom_attributes.hide_empty_facets}">
	<div class="row border-top row-column-border row-column-menu-left attribute-list">
	    {if $tag_tree}
		    <aside class="col-lg-4 col-md-4">
		    {if is_set($tag_tree.children)}
		    <div class="link-list-wrapper menu-link-list">
		        <ul class="link-list">
		        	<li>
		                <h3>Tipo di documento</h3>
		            </li> 
			    	{foreach $tag_tree.children as $tag}
			    		{if $block.custom_attributes.hide_first_level|not}<li><a class="list-item pr-0" data-tag_id="{$tag.id|wash()}" href="#"><span>{$tag.keyword|wash()} <small></small></span></a>{/if}
			    			{if $tag.hasChildren}
			    				{if $block.custom_attributes.hide_first_level|not}<ul class="link-sublist">{/if}
			    				{foreach $tag.children as $childTag}
			    					<li>
			    						<a class="list-item pr-0" data-tag_id="{$childTag.id|wash()}" href="#"><span>{$childTag.keyword|wash()} <small></small></span></a>
			    						{if $childTag.hasChildren}
			    							<ul class="link-sublist">
						    				{foreach $childTag.children as $subChildTag}
						    					<li>
						    						<a class="list-item pr-0" data-tag_id="{$subChildTag.id|wash()}" href="#"><span>{$subChildTag.keyword|wash()} <small></small></span></a>				    						
					    						</li>
						    				{/foreach}
						    				</ul>
			    						{/if}
		    						</li>
			    				{/foreach}
			    				{if $block.custom_attributes.hide_first_level|not}</ul>{/if}
			    			{/if}
		    			{if $block.custom_attributes.hide_first_level|not}</li>{/if}
			    	{/foreach}
		    	</ul>
			</div>
		    {/if}
		    </aside>
	    {/if}

	    <section class="{if $tag_tree}col-lg-8 col-md-8{else}col{/if} p-0">
		    <form class="form p-3 bg-light border-bottom">
		    	<div class="form-row">
			      	<div class="col-md-2">
				      	<label for="searchFormNumber-{$block.id}" class="m-0"><small>Numero</small></label>
				      	<input type="text" class="form-control" id="searchFormNumber-{$block.id}" data-search="has_code">
			      	</div>
			      	<div class="col-md-2">
				      	<label for="searchFormDate-{$block.id}" class="m-0"><small>Data</small></label>
				      	<input type="text" class="form-control" id="searchFormDate-{$block.id}" data-search="calendar">
			      	</div>
			      	<div class="col-md-3">
				      	<label for="searchFormOffice-{$block.id}" class="m-0"><small>Ufficio</small></label>
				      	<select class="form-control custom-select" id="searchFormOffice-{$block.id}" data-search="has_organization">
							<option></option>
							{foreach fetch(content, tree, hash(parent_node_id, ezini('NodeSettings', 'RootNode', 'content.ini'), class_filter_type, 'include', class_filter_array, array('office'), load_data_map, false(), sort_by, array('name', true()))) as $office}
								<option value="{$office.contentobject_id}">{$office.name|wash()}</option>
							{/foreach}
						</select>
					</div>
					<div class="col-md-3">
				      	<label for="searchFormArea-{$block.id}" class="m-0"><small>Area</small></label>
				      	<select class="form-control custom-select" id="searchFormArea-{$block.id}" data-search="area">
							<option></option>
							{foreach fetch(content, tree, hash(parent_node_id, ezini('NodeSettings', 'RootNode', 'content.ini'), class_filter_type, 'include', class_filter_array, array('administrative_area'), load_data_map, false(), sort_by, array('name', true()))) as $area}
								<option value="{$area.contentobject_id}">{$area.name|wash()}</option>
							{/foreach}
						</select>
					</div>
					<div class="col-md-2">
						<button type="submit" class="btn btn-link mt-4 px-0">
							{display_icon('it-search', 'svg', 'icon startSearch')}							
						</button>
						<button type="reset" class="btn btn-link mt-4 px-0 hide">
							{display_icon('it-close-big', 'svg', 'icon resetSearch')}
						</button>						
					</div>					
		      	</div>
			</form>
			<div class="results p-3"></div>
	    </section>
	</div>
</div>


{run-once}
{literal}
<script id="tpl-document-spinner" type="text/x-jsrender">
<div class="spinner text-center pt-3">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
    <span class="sr-only">Attendere il caricamento dei dati...</span>
</div>
</script>
<script id="tpl-document-results" type="text/x-jsrender">    		
	{{if totalCount > 0}}	
	<div class="row mb-2 d-none d-md-flex">
		<div class="col-md-2"><strong>Numero</strong></div>
		<div class="col-md-3"><strong>Data di inizio e fine</strong></div>
		<div class="col-md-3"><strong>Area/Ufficio</strong></div>
		<div class="col-md-4"><strong>Oggetto</strong></div>
	</div>
	{{else}}
		<div class="row mb-2">
			<div class="col"><em>Nessun documento trovato</em></div>
		</div>
	{{/if}}
	{{for searchHits}}		
		<div class="row mb-3 pt-3 border-top">	
			<div class="col-md-2"><strong class="d-block d-sm-none">Numero</strong> {{if ~i18n(data, 'has_code')}}{{:~i18n(data, 'has_code')}}{{/if}}</div>
			<div class="col-md-3"><strong class="d-block d-sm-none">Data di inizio e fine</strong> 
				{{if ~i18n(data,'start_time') && ~i18n(data,'end_time')}}
					Da {{:~formatDate(~i18n(data,'start_time'), 'D/MM/YYYY')}} a {{:~formatDate(~i18n(data,'end_time'), 'D/MM/YYYY')}}
				{{else}}
					{{:~formatDate(~i18n(data,'start_time'), 'D/MM/YYYY')}} 
				{{/if}}
			</div>
			<div class="col-md-3"><strong class="d-block d-sm-none">Area/Ufficio</strong> <ul class="list-unstyled m-0">{{if ~i18n(data, 'area')}}{{for ~i18n(data,'area')}}<li>{{:~i18n(name)}}</li>{{/for}}{{/if}}{{if ~i18n(data, 'has_organization')}}{{for ~i18n(data,'has_organization')}}<li>{{:~i18n(name)}}</li>{{/for}}{{/if}}</ul></div>
			<div class="col-md-4">
				<strong class="d-block d-sm-none">Oggetto</strong>
				{{if ~i18n(data, 'document_type')}}<small class="d-block text-truncate">{{:~i18n(data, 'document_type')}}</small>{{/if}}
				<a href="/content/view/full/{{:metadata.mainNodeId}}">{{:~i18n(metadata.name)}}</a>
			</div>		
		</div>
	{{/for}}	

	{{if pageCount > 1}}
	<div class="row mt-lg-4">
	    <div class="col">
	        <nav class="pagination-wrapper justify-content-center" aria-label="Esempio di navigazione della pagina">
	            <ul class="pagination">
	                {{if prevPageQuery}}
	                <li class="page-item">
	                    <a class="page-link prevPage" data-page="{{>prevPage}}" href="#">
	                        <svg class="icon icon-primary">
	                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-left"></use>
	                        </svg>
	                        <span class="sr-only">Pagina precedente</span>
	                    </a>
	                </li>
	                {{/if}}	                
	                {{for pages ~current=currentPage}}	                
						<li class="page-item"><a href="#" class="page-link page" data-page="{{:query}}"{{if ~current == query}} aria-current="page"{{/if}}>{{:page}}</a></li>						
					{{/for}}	
					{{if nextPageQuery }}	 
	                <li class="page-item">
	                    <a class="page-link nextPage" data-page="{{>nextPage}}" href="#">
	                        <span class="sr-only">Pagina successiva</span>
	                        <svg class="icon icon-primary">
	                            <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#it-chevron-right"></use>
	                        </svg>
	                    </a>
	                </li>
	                {{/if}}
	            </ul>
	        </nav>
	    </div>
	</div>
	{{/if}}
</script>

<script>
$.views.helpers($.opendataTools.helpers);
$(document).ready(function () {
	$('[data-block_document_subtree]').each(function(){
		var container = $(this);
		var resultsContainer = container.find('.results');		
		var limitPagination = container.data('limit');
		var subtree = container.data('block_document_subtree');		
		var hideEmptyFacets = container.data('hide_empty_facets') == 1;
		var currentPage = 0;
		var queryPerPage = [];
		var template = $.templates('#tpl-document-results');
		var spinner = $($.templates("#tpl-document-spinner").render({}));
		var isLoadedFacetsCount = false;

		container.find('[data-search="calendar"]').datetimepicker({
			locale: 'it',
			format: "DD/MM/YYYY"
		});
		
	    var buildQuery = function(){
			var query = 'classes [document] subtree [' + subtree + '] facets [raw[subattr_document_type___tag_ids____si]]';
			var tagFilters = [];
			container.find('a[data-tag_id].active').each(function(){
				tagFilters.push($(this).data('tag_id'));
			});
			if (tagFilters.length > 0){
				query += " and raw[subattr_document_type___tag_ids____si] in [" + tagFilters.join(',') + "]";
			}
			var officeFilter = container.find('[data-search="has_organization"]').val();			
			if (officeFilter.length > 0){
				query += " and has_organization.id in [" + officeFilter + "]";
			}
			var areaFilter = container.find('[data-search="area"]').val();
			if (areaFilter.length > 0){
				query += " and area.id in [" + areaFilter + "]";
			}
			var hasCodeFilter = container.find('[data-search="has_code"]').val().replace(/"/g, '').replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
			if (hasCodeFilter.length > 0){
				query += " and raw[attr_has_code_t] = '" + hasCodeFilter + "'";
			}
			var calendarFilter = container.find('[data-search="calendar"]').val();
			if (calendarFilter.length > 0){
				var dateFilter = moment(calendarFilter, "DD/MM/YYYY");
				query += ' and calendar[start_time,end_time] = [' + dateFilter.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm') + ',' + dateFilter.set('hour', 23).set('minute', 59).format('YYYY-MM-DD HH:mm') + ']';				
			}

			query += ' sort [publication_start_time=>desc,has_code=>desc]'
			
			return query;
		};

		var loadFacetsCount = function(data){
			if(isLoadedFacetsCount === false){
				if (hideEmptyFacets){
					container.find('[data-tag_id]').hide();
				}
				container.find('[data-tag_id] small').html('');
				$.each(data, function(){
					$.each(this.data, function(tagId, tagCount){
						container.find('[data-tag_id="'+tagId+'"]').show().find('small').html('('+tagCount+')');
					});
				});
				isLoadedFacetsCount = true;
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
	            
				var renderData = $(template.render(response));
				resultsContainer.html(renderData);

	            resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
	                currentPage = $(this).data('page');
	                loadContents();
	                e.preventDefault();
	            });	            
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
	});
}); 
</script>
{/literal}
{/run-once}


{undef $tag_tree}