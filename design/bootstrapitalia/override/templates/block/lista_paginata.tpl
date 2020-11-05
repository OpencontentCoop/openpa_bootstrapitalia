{ezscript_require(array(    
    'jsrender.js',
    'handlebars.min.js'
))}

{def $view='card_teaser'}
{switch match=$block.view}
	{case match='lista_paginata_card'}
		{set $view='card'}
	{/case}
	{case match='lista_paginata_banner'}
		{set $view='banner'}
	{/case}
	{case}
		{set $view='card_teaser'}
	{/case}
{/switch}
{def $openpa = object_handler($block)}
{if $openpa.has_content}
	<div class="hide"
		 data-view="{$view}"
		 data-block_subtree_query="{$openpa.query}"
		 data-subtree_filter="{$openpa.subtree_facet_filter}"
		 data-limit="{$openpa.limit}"
		 data-items_per_row="{cond(is_set($block.custom_attributes.elementi_per_riga), $block.custom_attributes.elementi_per_riga, 3)}"
		 {if and($openpa.root_node, $openpa.root_node|has_attribute('icon'))}data-icon="{$openpa.root_node|attribute('icon').content}"{/if}>
		<div class="row row-title">
			{if $block.name|ne('')}
				<div class="col">
					<h3 class="m-0">{$block.name|wash()}</h3>
				</div>
			{/if}
			{if and($openpa.root_node, object_handler($openpa.root_node).content_tag_menu.has_tag_menu|not())}
				{def $tree_menu = tree_menu( hash( 'root_node_id', $openpa.root_node.node_id, 'scope', 'side_menu'))}
				<div class="col text-right mb-2 mb-md-0 filters-wrapper hide">
					<button type="button" class="btn btn-secondary btn-sm mb-1" data-block_subtree_filter>Tutto</button>
					{foreach $tree_menu.children as $child}
						{if $openpa.tree_facets.subtree|contains($child.item.node_id)}
							<button type="button" data-block_subtree_filter="{$child.item.node_id}" class="btn btn-outline-secondary btn-sm mb-1">{$child.item.name|wash()}</button>
						{/if}
					{/foreach}
				</div>
			{/if}
		</div>
		<div class="{if $block.name|ne('')}py-4{else}pb-4{/if} results"></div>
		{include uri='design:parts/block_show_all.tpl'}
	</div>
{/if}

{run-once}
{literal}
<script id="tpl-results" type="text/x-jsrender">    	
	<div class="{{if itemsPerRow == 'auto'}}card-columns{{else}}row card-h-100 mx-lg-n3 row-cols-1 row-cols-md-2 row-cols-lg-{{:itemsPerRow}}{{/if}}">
	{{for searchHits ~contentIcon=icon ~itemsPerRow=itemsPerRow}}
		{{if ~itemsPerRow !== 'auto'}}<div class="px-3 pb-3">{{/if}}
		{{if ~i18n(extradata, 'view')}}
			{{:~i18n(extradata, 'view')}}
		{{else}}
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
				</div>
			</a>
		{{/if}}
		{{if ~itemsPerRow !== 'auto'}}</div>{{/if}}
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
						<li class="page-item"><a href="#" class="page-link page" data-page_number="{{:page}}" data-page="{{:query}}"{{if ~current == query}} data-current aria-current="page"{{/if}}>{{:page}}</a></li>
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
<style>
.card-h-100 .card-wrapper {height: 100%;}
</style>
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
		var itemsPerRow = container.data('items_per_row');
		var view = container.data('view');
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

		var detectError = function(response,jqXHR){
			if(response.error_message || response.error_code){
				if ($.isFunction(settings.onError)) {
					settings.onError(response.error_code, response.error_message,jqXHR);
				}
				return true;
			}
			return false;
		};

		var find = function (query, cb, context) {
			$.ajax({
				type: "GET",
				url: $.opendataTools.settings('endpoint').search,
				data: {q: query, view: view},
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
			var baseQuery = buildQuery();
			var paginatedQuery = baseQuery + ' and limit ' + limitPagination + ' offset ' + currentPage*limitPagination;
			
			find(paginatedQuery, function (response) {
				queryPerPage[currentPage] = paginatedQuery;
				response.view = view;
				response.itemsPerRow = itemsPerRow;
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
	            	this.baseUrl = baseUrl;
	            });
				var renderData = $(template.render(response));
				resultsContainer.html(renderData);

	            resultsContainer.find('.page, .nextPage, .prevPage').on('click', function (e) {
	                currentPage = $(this).data('page');
	                loadContents();
	                e.preventDefault();
	            });
				let more = $('<li class="page-item"><span class="page-link">...</span></li');
				let displayPages = resultsContainer.find('.page[data-page_number]');

				let currentPageNumber = resultsContainer.find('.page[data-current]').data('page_number');
				let length = 3;
				if (displayPages.length > (length + 2)) {
					if (currentPageNumber <= (length - 1)) {
						resultsContainer.find('.page[data-page_number="' + length + '"]').parent().after(more.clone());
						for (i = length; i < pagination; i++) {
							resultsContainer.find('.page[data-page_number="' + i + '"]').parent().hide();
						}
					} else if (currentPageNumber >= length) {
						resultsContainer.find('.page[data-page_number="1"]').parent().after(more.clone());
						let itemToRemove = (currentPageNumber + 1 - length);
						for (i = 2; i < pagination; i++) {
							if (itemToRemove > 0) {
								resultsContainer.find('.page[data-page_number="' + i + '"]').parent().hide();
								itemToRemove--;
							}
						}
						if (currentPageNumber < (pagination - 1)) {
							resultsContainer.find('.page[data-current]').parent().after(more.clone());
						}
						for (i = (currentPageNumber + 1); i < pagination; i++) {
							resultsContainer.find('.page[data-page_number="' + i + '"]').parent().hide();
						}
					}
				}
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