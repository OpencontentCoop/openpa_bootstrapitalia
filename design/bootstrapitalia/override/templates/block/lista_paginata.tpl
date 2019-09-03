{ezscript_require(array(    
    'jsrender.js',
    'handlebars.min.js'
))}

{def $openpa = object_handler($block)}
{if $openpa.has_content}
	<div class="hide" data-block_subtree_query="{$openpa.query}" data-subtree_filter="{$openpa.subtree_facet_filter}" data-limit="{$openpa.limit}"{if and($openpa.root_node, $openpa.root_node|has_attribute('icon'))} data-icon="{$openpa.root_node|attribute('icon').content}"{/if}>
		{if $block.name|ne('')}
		    <div class="row row-title">
		        <h3>{$block.name|wash()}</h3>
				{if $openpa.root_node}
					{def $tree_menu = tree_menu( hash( 'root_node_id', $openpa.root_node.node_id, 'scope', 'side_menu'))}
					<div class="mb-2 mb-md-0 filters-wrapper hide">
						<button type="button" class="btn btn-secondary btn-sm mb-1" data-block_subtree_filter>Tutto</button>
						{foreach $tree_menu.children as $child}
			                {if $openpa.tree_facets.subtree|contains($child.item.node_id)}
			                	<button type="button" data-block_subtree_filter="{$child.item.node_id}" class="btn btn-outline-secondary btn-sm mb-1">{$child.item.name|wash()}</button>
			                {/if}
			            {/foreach}
					</div>
				{/if}
		    </div>
		{/if}

		<div class="py-4 results">
			<div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-3">
		    </div>
		</div>
		{foreach $openpa.tree_facets.class_identifier as $class}
			{def $main_attributes = class_extra_parameters($class, 'table_view').in_overview}
			<div class="hide" data-class_identifier="{$class}" data-attributes="{$main_attributes|implode(',')}"></div>
			{undef $main_attributes}
		{/foreach}
	</div>
{/if}

{run-once}
{literal}
<script id="tpl-results" type="text/x-jsrender">    	
	<div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-3">	
	{{for searchHits ~contentIcon=icon}}		
		<a href="{{:baseUrl}}content/view/full/{{:metadata.mainNodeId}}" class="card card-teaser rounded shadow" style="text-decoration:none !important">
		    <div class="card-body">
		        {{if ~contentIcon && subtree}}
		        <div class="category-top">
		            <svg class="icon">
		                <use xlink:href="/extension/openpa_bootstrapitalia/design/standard/images/svg/sprite.svg#{{:~contentIcon}}"></use>
		            </svg>		            
		            <span class="category" href="{{:subtree.url}}">{{:subtree.text}}</span>
		        </div>
		        {{/if}}	
		        <h5 class="card-title">
		            {{:~i18n(metadata.name)}}
		        </h5>		        
		        <div class="card-text">		            
		            {{for mainAttributes ~content=#data}}			            	
		            	{{if ~i18n(~content.data, #data)}}{{:~i18n(~content.data, #data)}}{{/if}}	
		            {{/for}}
		        </div>		        		        
		    </div>
		</a>
	{{/for}}
	</div>

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
	$('[data-block_subtree_query]').each(function(){
        var baseUrl = '/';
	    if (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/'){
            baseUrl = UriPrefix + '/';
        }
	    var container = $(this);
		var resultsContainer = container.find('.results');
		var subTreeFilter = container.data('subtree_filter');
		var limitPagination = container.data('limit');
		var icon = container.data('icon');
		var currentPage = 0;
		var queryPerPage = [];
		var template = $.templates('#tpl-results');
		
		var filters = container.find('[data-block_subtree_filter]').on('click', function(e){
	        var self = $(this);	        
	        if(self.hasClass('btn-secondary')){
	            self.removeClass('btn-secondary').addClass('btn-outline-secondary');    
	        }else{
	            filters.removeClass('btn-secondary').addClass('btn-outline-secondary');
	            self.addClass('btn-secondary').removeClass('btn-outline-secondary');            
	        }
	        currentPage = 0;
	        loadContents();
	        e.preventDefault();
	    });
	    if (filters.length > 2){
	    	container.find('.filters-wrapper').removeClass('hide');
	    }

	    var buildQuery = function(){
			var subtreeList = [];
		    container.find('.btn-secondary[data-block_subtree_filter]').each(function(){
	            var subtree = $(this).data('block_subtree_filter');
	            if (subtree) subtreeList.push(subtree);
	        });
			var query = container.data('block_subtree_query');
			if (subtreeList.length > 0){
				query += ' and ' + subTreeFilter + ' in [' + subtreeList.join(',') + ']';
			}
			
			return query;
		};

		var findSubtree = function(content){
			var subtree;
			$.each(content.metadata.assignedNodes, function(){
				if (!subtree){
					var pathList = this.path_string.split('/');
					$.each(pathList, function(){						
						if (this !== '' && !subtree){
							var current = parseInt(this);							
							if(current > 0){
								var button = container.find('[data-block_subtree_filter="'+current+'"]');								
								if (button.length > 0){
									subtree = {text: button.text(), url: baseUrl + 'content/view/full/'+current};
								}
							}
						}
					});
				}
			});

			return subtree;
		};

		var findMainAttributes = function(content){
			var definition = container.find('[data-class_identifier="'+content.metadata.classIdentifier+'"]');
			if (definition.length && definition.data('attributes').length){
				return definition.data('attributes').split(',');
			}

			return [];
		};

		var loadContents = function(){						
			var baseQuery = buildQuery();
			var paginatedQuery = baseQuery + ' and limit ' + limitPagination + ' offset ' + currentPage*limitPagination;
			
			$.opendataTools.find(paginatedQuery, function (response) {				
				queryPerPage[currentPage] = paginatedQuery;
				response.icon = icon;
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
	            	this.subtree = findSubtree(this);
	            	this.mainAttributes = findMainAttributes(this);
	            	this.baseUrl = baseUrl;
	            });
				var renderData = $(template.render(response));
				resultsContainer.html(renderData);

	            resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
	                currentPage = $(this).data('page');
	                loadContents();
	                e.preventDefault();
	            });
	            container.removeClass('hide');
			});
		};

		loadContents();		
	});
}); 
</script>
{/literal}
{/run-once}


{undef $openpa}