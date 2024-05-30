{ezscript_require(array(
    'jsrender.js',
    'handlebars.min.js',
	'jquery.lista_paginata.js'
))}

{def $view='card'}
{def $max_events = 3}
{if and(is_set($block.custom_attributes.max_events), $block.custom_attributes.max_events|int()|gt(0))}
	{set $max_events = $block.custom_attributes.max_events}
{/if}
{def $query = "classes [event] sort [time_interval=>asc]"}
{*if and(is_set($block.custom_attributes.includi_classi), $block.custom_attributes.includi_classi|ne(''))}
    {set $query = concat('classes [', $block.custom_attributes.includi_classi, '] limit 3')}
{/if*}
{if and(is_set($block.custom_attributes.topic_node_id), $block.custom_attributes.topic_node_id|int()|gt(0))}
	{set $query = concat("raw[submeta_topics___main_node_id____si] = ", $block.custom_attributes.topic_node_id, " and ", $query)}
{/if}
{if and(is_set($block.custom_attributes.tag_id), $block.custom_attributes.tag_id|int()|gt(0))}
	{set $query = concat("raw[ezf_df_tag_ids] = ", $block.custom_attributes.tag_id, " and ", $query)}
{/if}
{def $openpa = object_handler($block)}
{if $openpa.has_content}
	<div class="hide"
		 data-view="{$view}"
		 data-block_subtree_query="{$query}"
		 data-search_type="calendar"
		 data-day_limit="180"
		 data-limit="{$max_events}"
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

		{if and(is_set($#node), $#node.object.remote_id|ne('all-events'))}
		{def $calendar = fetch(content, object, hash('remote_id', 'all-events'))}
		{if $calendar}
		<div class="d-flex justify-content-end mt-4">
			<button type="button"
					href="{$calendar.main_node.url_alias|ezurl(no)}"
					onclick="location.href = '{$calendar.main_node.url_alias|ezurl(no)}';"
					data-element="{object_handler($calendar).data_element.value|wash()}"
					class="btn btn-primary px-5 py-3 full-mb text-button">
            <span>{'Go to event calendar'|i18n('bootstrapitalia')}</span>
			</button>
		</div>
		{/if}
		{undef $calendar}
		{/if}
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
				<a href="{{:baseUrl}}openpa/object/{{:metadata.id}}" class="card card-teaser rounded shadow" style="text-decoration:none !important">
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
</script>
{/literal}
{/run-once}


{undef $openpa}