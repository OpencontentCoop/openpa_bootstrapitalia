{ezscript_require(array(
	'leaflet.js',
	'leaflet.markercluster.js',
	'leaflet.makimarkers.js',
	'jsrender.js',
	'accessible-autocomplete.min.js',
	'jquery.opendata_remote_gui.js'
))}
{ezcss_require(array('accessible-autocomplete.min.css'))}
{def $tag_tree = cond($block.custom_attributes.root_tag, api_tagtree($block.custom_attributes.root_tag), false())
	 $searchPlaceholder = 'Search'|i18n('bootstrapitalia/places')
	 $hide_empty_facets = $block.custom_attributes.hide_empty_facets}
{def $tag_tree_query = cond($tag_tree, concat(" and raw[ezf_df_tag_ids] = ", $tag_tree.id, " "), '')}
{def $query = concat("classes [place] subtree [", $block.custom_attributes.node_id, "] ", $tag_tree_query, " and state in [", privacy_states()['privacy.public'].id, "] sort [name=>asc]")}
{undef $tag_tree_query}

{include uri='design:parts/block_name.tpl'}

<div class="row place-search-block" id="remote-gui-{$block.id}">
	<div class="col-12 col-sm-8 col-md-9 col-lg-10 mb-3 search-form">
		<div class="row">
			<div class="col-sm mb-3 mb-sm-0">
				<div class="input-group">
					<span class="input-group-text h-auto">{display_icon('it-search', 'svg', 'icon icon-sm')}</span>
					<label for="search-input-{$block.id}" class="visually-hidden">{$placeHolder|wash()}</label>
					<input type="text" class="form-control" id="search-input-{$block.id}" data-search="q" placeholder="{$placeHolder|wash()}" name="search-input-{$block.id}">
					<div class="input-group-append">
						<button class="btn btn-primary" type="button" id="button-3">{'Search'|i18n('design/plain/layout')}</button>
					</div>
				</div>
			</div>
			{if and($tag_tree, is_set($tag_tree.children))}
				<div class="col-sm mb-3 mb-sm-0 {if count($tag_tree.children)|eq(0)}d-none{/if}">
					<label class="hidden" for="{$block.id}-search-facets">{$tag_tree.keyword|wash()}</label>
					<select id="{$block.id}-search-facets"
							style="display:none"
							class="d-none"
							data-placeholder="{'Filter by type'|i18n('bootstrapitalia/places')}"
							data-facets_select="facet-0"
							multiple>
						{foreach $tag_tree.children as $tag}
							{if $block.custom_attributes.hide_first_level|not}<option value="{$tag.id|wash()}" class="pl-1 ps-1">{$tag.keyword|wash()}</option>{/if}
							{if $tag.hasChildren}
								{foreach $tag.children as $childTag}
									<option value="{$childTag.id|wash()}" class="{if $block.custom_attributes.hide_first_level|not}pl-3 ps-3{else}pl-1 ps-1{/if}">{$childTag.keyword|wash()}</option>
									{if $childTag.hasChildren}
										{foreach $childTag.children as $subChildTag}
											<option value="{$subChildTag.id|wash()}" class="{if $block.custom_attributes.hide_first_level|not}pl-5 ps-5 ps-5{else}pl-3 ps-3{/if}">{$subChildTag.keyword|wash()}</option>
										{/foreach}
									{/if}
								{/foreach}
							{/if}
						{/foreach}
					</select>
				</div>
			{/if}
		</div>
	</div>
	<div class="col-12 col-sm-4 col-md-3 col-lg-2 mb-3">
		<ul class="nav d-block nav-pills text-center text-sm-right">
			<li class="nav-item text-center d-inline-block">
				<a data-toggle="tab" data-bs-toggle="tab"
				   class="nav-link active rounded-0 view-selector"
				   href="#remote-gui-{$block.id}-geo">
					<i aria-hidden="true" class="fa fa-map"></i> <span class="sr-only">{'Map'|i18n('bootstrapitalia')}</span>
				</a>
			</li><li class="nav-item pr-1 pe-1 text-center d-inline-block">
				<a data-toggle="tab" data-bs-toggle="tab"
				   class="nav-link rounded-0 view-selector"
				   href="#remote-gui-{$block.id}-list">
					<i aria-hidden="true" class="fa fa-th"></i> <span class="sr-only"> {'List'|i18n('editorialstuff/dashboard')}</span>
				</a>
			</li>
		</ul>
	</div>

	<div class="col-12">
		<div class="items tab-content">
			<section id="remote-gui-{$block.id}-geo" class="tab-pane active">
				<div id="remote-gui-{$block.id}-map" style="width: 100%; height: 700px"></div>
			</section>
			<section id="remote-gui-{$block.id}-list" class="tab-pane"></section>
		</div>
	</div>

	<script>
		$(document).ready(function () {ldelim}
			moment.locale($.opendataTools.settings('locale'));
			$.views.helpers($.extend({ldelim}{rdelim}, $.opendataTools.helpers, {ldelim}
				'remoteUrl': function (remoteUrl, id) {ldelim}
					return remoteUrl+'/openpa/object/' + id;
					{rdelim}
				{rdelim}));
			$("#remote-gui-{$block.id}").remoteContentsGui({ldelim}
				'remoteUrl': "",
				'localAccessPrefix': {'/'|ezurl()},
				'geoSearchApi': "{'/opendata/api/geo/search/'|ezurl(no)}/",
				'searchApi': "{'/opendata/api/content/search/'|ezurl(no)}/",
				'spinnerTpl': '#tpl-remote-gui-spinner',
				'listTpl': '#tpl-remote-gui-list',
				'popupTpl': '#tpl-remote-gui-item',
				'itemsPerRow': 'auto',
				'limitPagination': 9,
				'query': "{$query|wash(javascript)}",
				'facets': ['raw[subattr_type___tag_ids____si]'],
				'removeExistingEmptyFacets': {cond($hide_empty_facets, 'true', 'false')}
			{rdelim});
		{rdelim});
	</script>

	{include uri='design:parts/opendata_remote_gui_templates.tpl' block=$block show_search=true()}
</div>

{undef $tag_tree $searchPlaceholder $hide_empty_facets}
