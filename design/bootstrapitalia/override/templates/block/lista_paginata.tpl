{ezscript_require(array(    
    'jsrender.js',
    'handlebars.min.js',
	'jquery.lista_paginata.js'
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
		{def $intro = cond(is_set($block.custom_attributes.intro_text), $block.custom_attributes.intro_text, '')}
		{if $intro|ne('')}
			<div class="row">
				<div class="col">
					<p class="lead">{$intro|simpletags|autolink}</p>
				</div>
			</div>
		{/if}
		{undef $intro}
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
{/literal}
{/run-once}


{undef $openpa}