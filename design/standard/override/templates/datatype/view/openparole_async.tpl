
{def $context = false()
	 $module_params = module_params()}
{if and($module_params.module_name|eq('content'),$module_params.function_name|eq('view'),$module_params.parameters.ViewMode|eq('full'))}
	{set $context = fetch(content, node, hash('node_id', $module_params.parameters.NodeID))}
{/if}


{switch match=$attribute.class_content.view}

	{case match=1} {* Lista Persone: per i ruoli afferenti a una struttura*}
		{if $attribute.has_content}
			<ul class="list-unstyled">
				{foreach $attribute.content.people as $person}
					{def $openpa_person = object_handler($person)}
						<li>
							<a class="d-inline" href="{$openpa_person.content_link.full_link}" title="Link {$person.name|wash()}">{$person.name|wash()}</a>
							{foreach $attribute.content.roles_per_person[$person.id] as $role}{*
								*}{foreach $role|attribute('role').content.tags as $tag}{$tag.keyword|wash|trim}{delimiter}, {/delimiter}{/foreach}{*
								*}{if $role|has_attribute('delegations')}
									<small class="ms-1"> ({$role|attribute('delegations').contentclass_attribute_name|downcase|wash()}: {$role|attribute('delegations').content.cells|implode(', ')|wash})</small>
								{/if}{*
								*}{delimiter}, {/delimiter}{*
							*}{/foreach}
						</li>
					{undef $openpa_person}
				{/foreach}
			</ul>
		{/if}
	{/case}

	{case match=3} {* Persone: per i ruoli afferenti a una struttura *}
		{if $attribute.has_content}
			{def $items_per_page = cond(is_set($attribute.content.settings.pagination), $attribute.content.settings.pagination, 6)}
			{block_view_gui
				items_per_row=2
				wrapper_class=''
				container_class=''
				show_name=false()
				block=page_block(
					"",
					"OpendataRemoteContents",
					"default",
					hash(
						"query_builder", concat('a-', $attribute.id, '-', $attribute.version),
						"remote_url", "",
						"query", "",
						"show_grid", "1",
						"show_map", "0",
						"show_search", "0",
						"limit", $items_per_page,
						"items_per_row", "2",
						"facets", "",
						"view_api", "card_teaser",
						"color_style", "",
						"fields", "",
						"template", "",
						"simple_geo_api", "0",
						"input_search_placeholder", ""
					)
			)}
			{undef $items_per_page}
			{*
			{def $total = fetch('bootstrapitalia', 'openparole_people_count', hash('attribute', $attribute))}
			{def $items_per_page = cond(is_set($attribute.content.settings.pagination), $attribute.content.settings.pagination, 6)}
			{def $people = fetch('bootstrapitalia', 'openparole_people', hash('attribute', $attribute, 'limit', $items_per_page, 'offset', cond(is_set($#view_parameters[$attribute.contentclass_attribute_identifier]), $#view_parameters[$attribute.contentclass_attribute_identifier], 0)))}
			<div>
				<div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-2" style="min-width:49%">
					{foreach $people as $child }
						{node_view_gui content_node=$child view=card_teaser show_icon=false() show_category=false() image_class=widemedium}
					{/foreach}
				</div>
				{include name=navigator
					   uri='design:navigator/google.tpl'
					   page_uri=$attribute.object.main_node.url_alias
					   item_count=$total
					   variable_name=$attribute.contentclass_attribute_identifier
					   view_parameters=$#view_parameters
					   item_limit=$items_per_page}
			</div>
			{undef $people $items_per_page $total}
			*}
		{/if}
	{/case}

	{case match=2} {* Lista Strutture e dettagli: per i ruoli afferenti a una persona *}

		{* versione estesa per il full *}
		{if and(is_set($view_context), $view_context|eq('full_attributes'))}
			{def $roles_history = $attribute.content.roles_history}
			{def $roles = $roles_history.roles}

			<ul{if $attribute_group.slug|ne('content')} class="d-none"{/if}>
				{def $current_entities = array()}
				{def $expired_items = array()}
				{def $valid_items = array()}
				{foreach $roles as $role}
					{def $is_expired = cond(and($role|has_attribute('end_time'), $role|attribute('end_time').data_int|le(currentdate())), true(), false())}
					{if $role|has_attribute('for_entity')}
						{def $entity = $roles_history.entities[$role|attribute('for_entity').content.relation_list[0].contentobject_id]}
					{else}
						{def $entity = hash('name', '?')}
					{/if}
					{if $is_expired|not()}
						{set $current_entities = $current_entities|append($entity)}
						{set $valid_items = $valid_items|append(hash(
							'role', $role,
							'entity', $entity
						))}
					{else}
						{set $expired_items = $expired_items|append(hash(
							'role', $role,
							'entity', $entity
						))}
					{/if}
					{undef $entity $is_expired}
				{/foreach}
				{if count($valid_items)}
					{foreach $valid_items as $item}
						{include uri='design:content/datatype/view/openparole_item.tpl' role=$item.role entity=$item.entity is_expired=false()}
					{/foreach}
				{/if}
				{if count($expired_items)}
					<h3 class="my-4 h4 text-500">{'Previous assignments'|i18n("bootstrapitalia")}</h3>
					{foreach $expired_items as $item}
						{include uri='design:content/datatype/view/openparole_item.tpl' role=$item.role entity=$item.entity is_expired=true()}
					{/foreach}
				{/if}
			</ul>
			{if and($attribute_group.slug|eq('details'), count($current_entities)|gt(0))}
				<div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-2" style="min-width:49%">
					{foreach $current_entities as $child }
						{node_view_gui content_node=$child.main_node view=card_teaser show_icon=false() show_category=false() image_class=widemedium}
					{/foreach}
				</div>
			{/if}
			{undef $roles $roles_history $current_entities $expired_items $valid_items}

		{* versione compatta per abstract *}
		{elseif $attribute.has_content}

			{* contestualizzato alla struttura del full corrente *}
			{if and($context, is_set($attribute.content.roles_per_entity[$context.contentobject_id]))}
				<ul class="list-unstyled">
					<li>
						{foreach $attribute.content.roles_per_entity[$context.contentobject_id] as $role}{*
							*}{if $role|has_attribute('label')}{$role|attribute('label').content|wash()}{else}{foreach $role|attribute('role').content.tags as $tag}{$tag.keyword|wash|trim}{delimiter}, {/delimiter}{/foreach}{/if}{*
							mostra il dettaglio delegations dei ruoli legati all'entità di cui si sta visualizzando il content/view/full
							*}{if and($role|has_attribute('delegations'), openpaini('ViewSettings', 'ShowDelegationsInRoleList', 'disabled')|eq('enabled'))}
								<small> ({$role|attribute('delegations').content.cells|implode(', ')|wash})</small>
							{/if}{*
							*}{delimiter}, {/delimiter}{*
					  *}{/foreach}
					</li>
				</ul>

			{* in generale per abstract *}
			{else}
				<ul class="list-unstyled">
				{foreach $attribute.content.main_type_per_entities as $type => $entities}
					<li>
						{if $type|begins_with('#')}
							{$type|extract(1)|wash()}
						{else}
							{$type} {foreach $entities as $id => $name}<a class="d-inline" href="{concat('openpa/object/', $id)|ezurl(no)}">{$name|wash()}</a>{delimiter}, {/delimiter}{/foreach}
						{/if}
					</li>
				{/foreach}
				</ul>
			{/if}
		{/if}
	{/case}

	{case match=4} {* Strutture: per i ruoli afferenti a una persona *}
		{if $attribute.has_content}
		<div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-2" style="min-width:49%">
			{foreach $attribute.content.entities as $child }
				{node_view_gui content_node=$child.main_node view=card_teaser show_icon=false() show_category=false() image_class=widemedium}
			{/foreach}
		</div>
		{/if}
	{/case}

	{case}{/case}
{/switch}

{undef $context $module_params}

