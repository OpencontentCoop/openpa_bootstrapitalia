{ezscript_require(array(    
    'jsrender.js',
    'handlebars.min.js',
    'bootstrap-datetimepicker.min.js'
))}
{ezcss_require(array(
    'bootstrap-datetimepicker.min.css'    
))}

{def $root_tags = $block.custom_attributes.root_tag|explode(',')}

<div data-block_document_subtree="{$block.custom_attributes.node_id}" data-limit="20" data-hide_empty_facets="{$block.custom_attributes.hide_empty_facets}" data-hide_first_level="{$block.custom_attributes.hide_first_level}">
	<form class="row form p-3 analogue-1-bg-a1 border-top">
    	<div class="form-row">
	      	<div class="col-md-2">
		      	<label for="search-{$block.id}" class="m-0"><small>Ricerca libera</small></label>
		      	<input type="text" class="form-control" id="search-{$block.id}" data-search="q">
	      	</div>
	      	<div class="col-md-2">
		      	<label for="searchFormNumber-{$block.id}" class="m-0"><small>Numero</small></label>
		      	<input type="text" class="form-control" id="searchFormNumber-{$block.id}" data-search="has_code">
	      	</div>
	      	<div class="col-md-2">
		      	<label for="searchFormDate-{$block.id}" class="m-0"><small>Data</small></label>
		      	<input type="text" class="form-control" id="searchFormDate-{$block.id}" data-search="calendar">
	      	</div>
	      	<div class="col-md-2">
		      	<label for="searchFormOffice-{$block.id}" class="m-0"><small>Ufficio</small></label>
		      	<select class="form-control custom-select" id="searchFormOffice-{$block.id}" data-search="has_organization">
					<option></option>
					{foreach fetch(content, tree, hash(parent_node_id, ezini('NodeSettings', 'RootNode', 'content.ini'), class_filter_type, 'include', class_filter_array, array('office'), load_data_map, false(), sort_by, array('name', true()))) as $office}
						<option value="{$office.contentobject_id}">{$office.name|wash()}</option>
					{/foreach}
				</select>
			</div>
			<div class="col-md-2">
		      	<label for="searchFormArea-{$block.id}" class="m-0"><small>Area</small></label>
		      	<select class="form-control custom-select" id="searchFormArea-{$block.id}" data-search="area">
					<option></option>
					{foreach fetch(content, tree, hash(parent_node_id, ezini('NodeSettings', 'RootNode', 'content.ini'), class_filter_type, 'include', class_filter_array, array('administrative_area'), load_data_map, false(), sort_by, array('name', true()))) as $area}
						<option value="{$area.contentobject_id}">{$area.name|wash()}</option>
					{/foreach}
				</select>
			</div>
			<div class="col-md-2 text-center">
				<button type="submit" class="btn btn-link mt-4">
					{display_icon('it-search', 'svg', 'icon startSearch')}							
				</button>
				<button type="reset" class="btn btn-link mt-4 hide">
					{display_icon('it-close-big', 'svg', 'icon resetSearch')}
				</button>						
			</div>					
      	</div>
	</form>
	<div class="row border-top row-column-border row-column-menu-left attribute-list mt-0">
	    {if and($root_tags|count(), $root_tags[0]|ne(''))}
		    <aside class="col-lg-4">
		    <div class="link-list-wrapper menu-link-list">
		        <ul class="link-list">
		        	<li>
		                <h3>Tipo di documento</h3>
		            </li> 
				    {foreach $root_tags as $root_index => $root_tag}				    
					    {def $tag_tree = api_tagtree($root_tag)}
					    {if is_set($tag_tree.children)}			    
					    	{foreach $tag_tree.children as $index => $tag}
					    		{if and($root_index|gt(0), $index|eq(0))}<li class="border-top my-2"></li>{/if}					    		
					    		<li data-level="1">
					    			<a class="list-item pr-0" data-tag_id="{$tag.id|wash()}" href="#"><span>{$tag.keyword|wash()} <small></small></span></a>
					    		
					    			{if $tag.hasChildren}
					    				<ul class="link-sublist">
					    				{foreach $tag.children as $childTag}
					    					<li data-level="2">
					    						<a class="list-item pr-0" data-tag_id="{$childTag.id|wash()}" href="#"><span>{$childTag.keyword|wash()} <small></small></span></a>
					    						{if $childTag.hasChildren}
					    							<ul class="link-sublist">
								    				{foreach $childTag.children as $subChildTag}
								    					<li data-level="3">
								    						<a class="list-item pr-0" data-tag_id="{$subChildTag.id|wash()}" href="#"><span>{$subChildTag.keyword|wash()} <small></small></span></a>				    						
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

	    <section class="{if $root_tags|count()}col-lg-8 {else}col{/if} p-0">		    
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
	<div class="row mb-3 d-none d-md-flex">		
		<div class="col-md-2"><strong>Data</strong></div>		
		<div class="col-md-8"><strong>Oggetto</strong></div>
	</div>
	{{else}}
		<div class="row mb-2">
			<div class="col"><em>Nessun documento trovato</em></div>
		</div>
	{{/if}}
	{{for searchHits}}		
		<div class="row mb-3 pt-3 border-top">				
			<div class="col-md-2"><strong class="d-inline d-sm-none">Data</strong> 
				{{if ~i18n(data,'publication_start_time') && ~i18n(data,'publication_end_time')}}
					<small>Dal {{:~formatDate(~i18n(data,'publication_start_time'), 'D/MM/YYYY')}}<br />al {{:~formatDate(~i18n(data,'publication_end_time'), 'D/MM/YYYY')}}</small>
				{{else}}
					{{:~formatDate(~i18n(data,'publication_start_time'), 'D/MM/YYYY')}} 
				{{/if}}
			</div>			
			<div class="col-md-8">
				<strong class="d-block d-sm-none">Oggetto</strong>				
				<a href="{{:baseUrl}}content/view/full/{{:metadata.mainNodeId}}">{{:~i18n(metadata.name)}}</a>
				<ul class="list-inline m-0"><li class="list-inline-item"><strong>{{:~i18n(data, 'document_type')}}</strong>{{if ~i18n(data, 'has_code')}} ({{:~i18n(data, 'has_code')}}){{/if}}</li></ul>
				{{if ~i18n(data, 'area') || ~i18n(data, 'has_organization')}}<ul class="list-inline m-0"><li class="list-inline-item"><strong>Area/Ufficio:</strong></li>{{if ~i18n(data, 'area')}}{{for ~i18n(data,'area')}}<li class="list-inline-item">{{:~i18n(name)}}</li>{{/for}}{{/if}}{{if ~i18n(data, 'has_organization')}}{{for ~i18n(data,'has_organization')}}<li class="list-inline-item">{{:~i18n(name)}}</li>{{/for}}{{/if}}</ul>{{/if}}
			</div>		
		</div>
	{{/for}}	

	{{if pageCount > 1}}
	<div class="row mt-lg-4">
	    <div class="col">
	        <nav class="pagination-wrapper justify-content-center" aria-label="Esempio di navigazione della pagina">
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

<script>
$.views.helpers($.opendataTools.helpers);
$(document).ready(function () {
	$('[data-block_document_subtree]').each(function(){
        var baseUrl = '/';
        if (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/'){
            baseUrl = UriPrefix + '/';
        }
	    var container = $(this);
		var resultsContainer = container.find('.results');		
		var limitPagination = container.data('limit');
		var subtree = container.data('block_document_subtree');		
		var hideEmptyFacets = container.data('hide_empty_facets') == 1;
		var hideFirstLevel = container.data('hide_first_level') == 1;
		var currentPage = 0;
		var queryPerPage = [];
		var template = $.templates('#tpl-document-results');
		var spinner = $($.templates("#tpl-document-spinner").render({}));
		var isLoadedFacetsCount = false;

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

		container.find('[data-search="calendar"]').datetimepicker({
			locale: 'it',
			format: "DD/MM/YYYY"
		});
		
	    var buildQuery = function(){
			var query = 'classes [document] subtree [' + subtree + '] facets [raw[subattr_document_type___tag_ids____si]]';
			var searchText = container.find('[data-search="q"]').val().replace(/"/g, '').replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
			if (searchText.length > 0){
				query += " and q = '\"" + searchText + "\"'";
			}
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
				query += ' and calendar[publication_start_time,publication_end_time] = [' + dateFilter.set('hour', 0).set('minute', 0).format('YYYY-MM-DD HH:mm') + ',' + dateFilter.set('hour', 23).set('minute', 59).format('YYYY-MM-DD HH:mm') + ']';				
			}

			query += ' sort [publication_start_time=>desc,start_time=>desc,raw[extra_has_code_sl]=>desc]'
			
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

                $.each(response.searchHits, function(){
                    this.baseUrl = baseUrl;
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


{undef $root_tags}