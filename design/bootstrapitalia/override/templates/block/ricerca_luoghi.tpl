{ezscript_require(array(
	'leaflet.js',
	'leaflet.markercluster.js',
	'leaflet.makimarkers.js',
	'jsrender.js',
	'jquery.opendata_remote_gui.js'
))}

{def $tag_tree = cond($block.custom_attributes.root_tag, api_tagtree($block.custom_attributes.root_tag), false())
	 $searchPlaceholder = 'Search'|i18n('openpa/search')
	 $hide_empty_facets = $block.custom_attributes.hide_empty_facets}

{def $query = concat("classes [place] subtree [", $block.custom_attributes.node_id, "] and state in [", privacy_states()['privacy.public'].id, "] sort [name=>asc]")}


<div class="row" id="remote-gui-{$block.id}">
	<div class="col-12 col-sm-8 col-md-9 col-lg-10 mb-3 search-form">
		<div class="row">
			<div class="col-sm mb-3 mb-sm-0">
				<div class="input-group chosen-border">
					<label class="hidden" for="{$block.id}-search-input">{$searchPlaceholder|wash()}</label>
					<input id="{$block.id}-search-input" autocomplete="off" type="text" class="form-control border-0" placeholder="{$searchPlaceholder|wash()}" />
					<div class="input-group-append">
						<button class="btn btn-outline-secondary border-0" type="button"><i aria-hidden="true" class="fa fa-search" aria-hidden="true"></i></button>
					</div>
				</div>
			</div>
			{if and($tag_tree, is_set($tag_tree.children))}
				<div class="col-sm mb-3 mb-sm-0">
					<label class="hidden" for="{$block.id}-search-facets">{$tag_tree.keyword|wash()}</label>
					<select id="{$block.id}-search-facets"
							style="display:none"
							class="form-control border-0"
							data-placeholder="{$searchPlaceholder|wash()} {$tag_tree.keyword|downcase()|wash()}"
							data-facets_select="facet-0"
							multiple>
						{foreach $tag_tree.children as $tag}
							{if $block.custom_attributes.hide_first_level|not}<option value="{$tag.id|wash()}" class="pl-1">{$tag.keyword|wash()}</option>{/if}
							{if $tag.hasChildren}
								{foreach $tag.children as $childTag}
									<option value="{$childTag.id|wash()}" class="{if $block.custom_attributes.hide_first_level|not}pl-3{else}pl-1{/if}">{$childTag.keyword|wash()}</option>
									{if $childTag.hasChildren}
										{foreach $childTag.children as $subChildTag}
											<option value="{$subChildTag.id|wash()}" class="{if $block.custom_attributes.hide_first_level|not}pl-5{else}pl-3{/if}">{$subChildTag.keyword|wash()}</option>
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
				<a data-toggle="tab"
				   class="nav-link active rounded-0 view-selector"
				   href="#remote-gui-{$block.id}-geo">
					<i aria-hidden="true" class="fa fa-map" aria-hidden="true"></i> <span class="sr-only">{'Map'|i18n('extension/ezgmaplocation/datatype')}</span>
				</a>
			</li><li class="nav-item pr-1 text-center d-inline-block">
				<a data-toggle="tab"
				   class="nav-link rounded-0 view-selector"
				   href="#remote-gui-{$block.id}-list">
					<i aria-hidden="true" class="fa fa-th" aria-hidden="true"></i> <span class="sr-only"> {'List'|i18n('editorialstuff/dashboard')}</span>
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

	{include uri='design:parts/opendata_remote_gui_templates.tpl' block=$block}
</div>

{undef $tag_tree $searchPlaceholder $hide_empty_facets}