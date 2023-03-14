{ezscript_require(array(
    'jsrender.js',
    'handlebars.min.js',
	'jquery.lista_paginata.js'
))}

{def $view='card'}

{def $query = 'calendar[time_interval] = [*,now]'}
{if and(is_set($block.custom_attributes.includi_classi), $block.custom_attributes.includi_classi|ne(''))}
    {set $query = concat($query, ' and classes [', $block.custom_attributes.includi_classi, ']')}
{/if}

{def $openpa = object_handler($block)}
{if $openpa.has_content}
	<div class="hide"
		 data-view="{$view}"
		 data-block_subtree_query="{$query}"
		 data-limit="3"
		 data-items_per_row="3">
		<div class="row row-title">
			{if $block.name|ne('')}
				<div class="col">
					<h2 class="m-0 block-title">{$block.name|wash()}</h2>
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

		{def $calendar = fetch(content, object, hash('remote_id', 'all-events'))}
		{if $calendar}
		<div class="d-flex justify-content-end mt-4">
			<button type="button"
					href="{$calendar.main_node.url_alias|ezurl(no)}"
					onclick="location.href = '{$calendar.main_node.url_alias|ezurl(no)}';"
					data-element="{object_handler($calendar).data_element.value|wash()}"
					class="btn btn-primary px-5 py-3 full-mb">
            <span>{'Go to event calendar'|i18n('bootstrapitalia')}</span>
			</button>
		</div>
		{/if}
		{undef $calendar}
	</div>
{/if}

{run-once}
{literal}
<script id="tpl-results" type="text/x-jsrender">
	<div class="row mx-lg-n3{{if !autoColumn && itemsPerRow != 'auto'}} row-cols-1 row-cols-md-2 g-4 row-cols-lg-{{:itemsPerRow}}{{/if}}"{{if itemsPerRow == 'auto'}} data-bs-toggle="masonry"{{/if}}>
		{{if autoColumn}}<div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-{{:itemsPerRow}}">{{/if}}
		{{for searchHits ~contentIcon=icon ~itemsPerRow=itemsPerRow ~autoColumn=autoColumn}}
		{{if !~autoColumn}}<div class="{{if ~itemsPerRow == 'auto'}}col-sm-6 col-lg-4 mb-4 card-wrapper card-teaser-wrapper card-teaser-masonry-wrapper{{/if}}">{{/if}}
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
		{{if !~autoColumn}}</div>{{/if}}
		{{/for}}
		{{if autoColumn}}</div>{{/if}}
	</div>
	{{if pageCount > 1}}
	<div class="row mt-lg-4">
	    <div class="col">
	        <nav class="pagination-wrapper justify-content-center" aria-label="{/literal}{'Navigation'|i18n('design/ocbootstrap/menu')}{literal}">
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