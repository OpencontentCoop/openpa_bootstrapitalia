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
  {case match='lista_paginata_banner_color'}
    {set $view='banner_color'}
  {/case}
  {case match='lista_paginata_card_image'}
    {set $view='card_image'}
  {/case}
	{case}
		{set $view='card_teaser'}
	{/case}

{/switch}
{def $openpa = object_handler($block)}
{def $lista_paginata_items_per_row = cond(is_set($block.custom_attributes.elementi_per_riga), $block.custom_attributes.elementi_per_riga, 3)}
{def $has_loading_count = cond(is_set($block.custom_attributes.loading_count), $block.custom_attributes.loading_count, false())}
{if $openpa.has_content}
	<div{if $has_loading_count|not()} class="hide"{/if}
		 data-view="{$view}"
		 data-block_subtree_query="{$openpa.query}"
		 data-subtree_filter="{$openpa.subtree_facet_filter}"
		 data-limit="{$openpa.limit}"
		 data-items_per_row="{$lista_paginata_items_per_row}"
		 {if and($openpa.root_node, $openpa.root_node|has_attribute('icon'))}data-icon="{$openpa.root_node|attribute('icon').content}"{/if}>
		<div class="row row-title g-0">
			{if $block.name|ne('')}
				<div class="col ">
					<div class="d-md-flex justify-content-between{if $#node.class_identifier|eq('topic')} border-bottom{/if}">
						<h2 class="mb-3 block-title" style="border:none !important;padding-bottom: 0 !important;">{$block.name|wash()}</h2>
						{if and($openpa.root_node, object_handler($openpa.root_node).content_tag_menu.has_tag_menu|not())}
							{def $tree_menu = tree_menu( hash( 'root_node_id', $openpa.root_node.node_id, 'scope', 'side_menu'))}
							<div class="filters-wrapper mt-0 mb-3 ms-3 text-end hide">
								<button type="button" title="{'All'|i18n('design/standard/ezoe')}" class="btn btn-secondary btn-sm mb-1 me-1 py-1 px-2" data-block_subtree_filter>{'All'|i18n('design/standard/ezoe')}</button>
								{foreach $tree_menu.children as $index => $child}
									{if $openpa.tree_facets.subtree|contains($child.item.node_id)}
										<button type="button" title="{$child.item.name|wash()}" data-block_subtree_filter="{$child.item.node_id}" class="btn btn-outline-secondary btn-sm mb-1 me-1 py-1 px-2">{$child.item.name|wash()}</button>
									{/if}
								{/foreach}
							</div>
						{/if}
					</div>
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
		<div class="{if $block.name|ne('')}py-4{else}pb-4{/if} results">
			{if $has_loading_count}
			<div class="row mx-lg-n3">
				<div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-3">
				{for 1 to $has_loading_count as $counter}
					{if $counter|gt($openpa.limit)}{skip}{/if}
					<div class="font-sans-serif card card-teaser no-after rounded shadow-sm mb-0 border border-light">
						<div class="card-body pb-5 ">
							<div class="category-top">
								<span class="title-xsmall-semi-bold fw-semibold"><span class="category-placeholder"></span></span>
							</div>
							<h3 class="card-title text-paragraph-medium u-grey-light"><span class="title-placeholder"></span></h3>
							<div class="text-paragraph-card u-grey-light m-0">
								<div class="mt-1"><span class="text-placeholder"></span></div>
							</div>
						</div>
						<a class="read-more" href="#">
							<span class="text"><span class="link-placeholder"></span></span>
						</a>
					</div>
				{/for}
				</div>
			</div>
			{/if}
		</div>
		{include uri='design:parts/block_show_all.tpl'}
	</div>
{/if}

{run-once}
{literal}
<style>
	.category-placeholder{
		width:150px;
		height: 16px;
	}
	.title-placeholder{
		width:300px;
		height: 50px;
	}
	.text-placeholder{
		width:350px;
		height: 130px;
	}
	.link-placeholder{
		width:180px;
		height: 16px;
	}
	.category-placeholder, .title-placeholder, .text-placeholder, .link-placeholder {
		border-radius: 3px;
		display: inline-block;
		background: #ebeef0;
		animation: hintloading 1s ease-in-out 0s infinite reverse;
		-webkit-animation: hintloading 1s ease-in-out 0s infinite reverse;
	}
	@keyframes hintloading
	{
		0% {
			opacity: 0.5;
		}
		50%  {
			opacity: 1;
		}
		100% {
			opacity: 0.5;
		}
	}
	@-webkit-keyframes hintloading
	{
		0% {
			opacity: 0.5;
		}
		50%  {
			opacity: 1;
		}
		100% {
			opacity: 0.5;
		}
	}
</style>
<script id="tpl-results" type="text/x-jsrender">    	
	<div class="row mx-lg-n3{{if !autoColumn && itemsPerRow != 'auto'}} row-cols-1 row-cols-md-2 g-4 row-cols-lg-{{:itemsPerRow}}{{/if}}"{{if itemsPerRow == 'auto'}} data-bs-toggle="masonry"{{/if}}>
		{{if autoColumn}}<div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-{{:itemsPerRow}}">{{/if}}
		{{for searchHits ~contentIcon=icon ~itemsPerRow=itemsPerRow ~autoColumn=autoColumn}}
		{{if !~autoColumn}}<div class="{{if ~itemsPerRow == 'auto'}}col-sm-6 col-lg-4 mb-4 card-wrapper card-teaser-wrapper card-teaser-masonry-wrapper{{/if}}">{{/if}}
			{{if ~i18n(extradata, 'view')}}
				{{:~i18n(extradata, 'view')}}
			{{else}}
				<a href="{{if ~i18n(extradata,'urlAlias')}}{{:~i18n(extradata,'urlAlias')}}{{else}}{{:baseUrl}}openpa/object/{{:metadata.id}}{{/if}}" class="card card-teaser rounded shadow" style="text-decoration:none !important">
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
		{{if !~autoColumn}}</div>{{/if}}
		{{/for}}
		{{if autoColumn}}</div>{{/if}}
	</div>
	{{if pageCount > 1}}
	<div class="row mt-4">
	    <div class="col">
	        <nav class="pagination-wrapper justify-content-center" aria-label="{/literal}{'Navigation'|i18n('design/ocbootstrap/menu')}{literal}">
	            <ul class="pagination">
	                {{if prevPageQuery}}
	                <li class="page-item">
	                    <a class="page-link prevPage" data-page="{{>prevPage}}" href="#">
	                        <svg class="icon icon-primary" aria-hidden="true" focusable="false">
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
	                        <svg class="icon icon-primary" aria-hidden="true" focusable="false">
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


{undef $openpa $lista_paginata_items_per_row $has_loading_count}
