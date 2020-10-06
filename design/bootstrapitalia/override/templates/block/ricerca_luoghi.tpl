{ezscript_require(array(    
    'jsrender.js',
    'handlebars.min.js',
    'bootstrap-datetimepicker.min.js'
))}
{ezcss_require(array(
    'bootstrap-datetimepicker.min.css'    
))}

{def $tag_tree = cond($block.custom_attributes.root_tag, api_tagtree($block.custom_attributes.root_tag), false())}

<div data-block_place_subtree="{$block.custom_attributes.node_id}" data-limit="10" data-hide_empty_facets="{$block.custom_attributes.hide_empty_facets}">
	<form class="row form p-3 analogue-1-bg-a1 border-top">
		<div class="col-md-4">
	      	<label for="search-{$block.id}" class="m-0"><small>Ricerca libera</small></label>
	      	<input type="text" class="form-control" id="search-{$block.id}" data-search="q">
      	</div>
      	<div class="col-md-2">
			<button type="submit" class="btn btn-link mt-4">
				{display_icon('it-search', 'svg', 'icon startSearch')}							
			</button>
			<button type="reset" class="btn btn-link mt-4 hide">
				{display_icon('it-close-big', 'svg', 'icon resetSearch')}
			</button>						
		</div>	
		<div class="col-md-6 text-center">
			<a href="#" class="show-map btn btn-secondary mt-4">Visualizza come mappa</a>
			<a href="#" class="show-list btn btn-outline-secondary mt-4">Visualizza come lista</a>
		</div>
	</form>
	<div class="row border-top row-column-border row-column-menu-left attribute-list mt-0">
	    {if $tag_tree}
		    <aside class="col-lg-3 col-md-3">
		    {if is_set($tag_tree.children)}
		    <div class="link-list-wrapper menu-link-list">
		        <ul class="link-list">
		        	<li>
		                <h3>Tipo di luogo</h3>
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

	    <section class="{if $tag_tree}col-lg-9 col-md-9{else}col{/if} p-0">		    			
			<div class="results p-3"></div>
	    </section>
	</div>
</div>

{run-once}
{literal}
<script id="tpl-place-spinner" type="text/x-jsrender">
<div class="spinner text-center pt-3">
    <i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>
    <span class="sr-only">Attendere il caricamento dei dati...</span>
</div>
</script>
<script id="tpl-place-results" type="text/x-jsrender">    		
	{{if totalCount == 0}}		
		<div class="row mb-2">
			<div class="col"><em>Nessun luogo trovato</em></div>
		</div>
	{{/if}}
	{{for searchHits}}		
		<div class="row mb-3 pb-3 border-bottom">				
			<div class="col-md-12">				
				{{if ~i18n(data, 'type')}}<small class="d-block text-truncate">{{:~i18n(data, 'type')}}</small>{{/if}}
				<h5><a href="{{:baseUrl}}content/view/full/{{:metadata.mainNodeId}}">{{:~i18n(metadata.name)}}</a></h5>
				{{if ~i18n(data, 'abstract')}}{{:~i18n(data, 'abstract')}}{{/if}}
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
	$('[data-block_place_subtree]').each(function(){
        var baseUrl = '/';
        if (typeof(UriPrefix) !== 'undefined' && UriPrefix !== '/'){
            baseUrl = UriPrefix + '/';
        }
	    var container = $(this);
		var resultsContainer = container.find('.results');		
		var limitPagination = container.data('limit');
		var subtree = container.data('block_place_subtree');		
		var hideEmptyFacets = container.data('hide_empty_facets') === 1;
		var currentPage = 0;
		var queryPerPage = [];
		var template = $.templates('#tpl-place-results');
		var spinner = $($.templates("#tpl-place-spinner").render({}));
		var isLoadedFacetsCount = false;
		var showList = container.find('.show-list');
		var showMap = container.find('.show-map');
		
	    var buildQuery = function(){
			var query = 'classes [place] subtree [' + subtree + '] facets [raw[subattr_type___tag_ids____si]]';
			var searchText = container.find('[data-search="q"]').val().replace(/"/g, '').replace(/'/g, "").replace(/\(/g, "").replace(/\)/g, "").replace(/\[/g, "").replace(/\]/g, "");
			if (searchText.length > 0){
				query += " and q = '\"" + searchText + "\"'";
			}
			var tagFilters = [];
			container.find('a[data-tag_id].active').each(function(){
				tagFilters.push($(this).data('tag_id'));
			});
			if (tagFilters.length > 0){
				query += " and raw[subattr_type___tag_ids____si] in [" + tagFilters.join(',') + "]";
			}

			query += ' and state in ['+{/literal}{privacy_states()['privacy.public'].id}{literal}+'] sort [name=>asc]'
			
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
			if (!resultsContainer.hasClass('p-3')) resultsContainer.addClass('p-3');
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
	                loadContents();
	                e.preventDefault();
	            });	            
			});
		};

		var loadMap = function(){
			resultsContainer.removeClass('p-3');
			var baseQuery = buildQuery();
			var mapContainer = $('<div id="map" style="height:800px;" class="invisible"></div>');
			resultsContainer.html(mapContainer);
			var map = $.opendataTools.initMap(
                'map',
                function (response) {
                    return L.geoJson(response, {
                        pointToLayer: function (feature, latlng) {
                            var customIcon = L.MakiMarkers.icon({icon: "circle", size: "l"});
                            return L.marker(latlng, {icon: customIcon});
                        },
                        onEachFeature: function (feature, layer) {
                            var popupDefault = '<p class="text-center"><i class="fa fa-circle-o-notch fa-spin"></i></p><p><a href="' + baseUrl + 'content/view/full/' + feature.properties.mainNodeId + '" target="_blank">';
                            popupDefault += feature.properties.name;
                            popupDefault += '</a></p>';
                            var popup = new L.Popup({maxHeight: 450, maxWidth: 500, minWidth: 350});
                            popup.setContent(popupDefault);  
                            layer.on('click', function (e) {
                                $.getJSON("{/literal}{'/openpa/data/map_markers'|ezurl(no)}{literal}?contentType=marker&view=card_teaser&id="+e.target.feature.properties.id, function(data) {								  
								  var content = $(data.content).css({'max-width': '320px'}).removeClass('shadow p-4 rounded border');
								  popup.setContent(content.get(0).outerHTML);
								  popup.update();
								});
                            });                         
                            layer.bindPopup(popup);
                        }
                    });
                }
            );
            map.scrollWheelZoom.disable();
            $.opendataTools.loadMarkersInMap(baseQuery, function(){
            	mapContainer.removeClass('invisible');
            	map.fitBounds(map.getBounds().pad(0.5))
            });
		};

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
			if (showList.hasClass('btn-secondary'))
	        	loadContents();
        	else
        		loadMap();
			e.preventDefault();
		});
		
		showList.on('click', function(e){
			if (!showList.hasClass('btn-secondary')){				
				showList.addClass('btn-secondary');
				showList.removeClass('btn-outline-secondary');
				showMap.removeClass('btn-secondary');
				showMap.addClass('btn-outline-secondary');
				loadContents();
			}
			e.preventDefault();
		});
		showMap.on('click', function(e){
			if (!showMap.hasClass('btn-secondary')){				
				showMap.addClass('btn-secondary');
				showMap.removeClass('btn-outline-secondary');
				showList.removeClass('btn-secondary');
				showList.addClass('btn-outline-secondary');
				loadMap();
			}
			e.preventDefault();
		});
		container.find('button[type="submit"]').on('click', function(e){
			container.find('button[type="reset"]').removeClass('hide');
			currentPage = 0;
	        if (showList.hasClass('btn-secondary'))
	        	loadContents();
        	else
        		loadMap();
			e.preventDefault();
		});
		container.find('button[type="reset"]').on('click', function(e){			
			container.find('form')[0].reset();			
			container.find('button[type="reset"]').addClass('hide');
			currentPage = 0;
	        if (showList.hasClass('btn-secondary'))
	        	loadContents();
        	else
        		loadMap();
			e.preventDefault();
		});

		container.find('form')[0].reset();
		if (showList.hasClass('btn-secondary')){
			loadContents();
		}else{
			$.opendataTools.find(buildQuery() + ' and limit 1', function (response) {
				loadFacetsCount(response.facets);
				loadMap();
			});
		}
	});
}); 
</script>
{/literal}
{/run-once}


{undef $tag_tree}