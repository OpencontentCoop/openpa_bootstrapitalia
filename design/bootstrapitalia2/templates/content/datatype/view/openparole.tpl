
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
		{/if}
	{/case}

	{case match=2} {* Lista Strutture e dettagli: per i ruoli afferenti a una persona *}

		{* versione estesa per il full *}
		{if and(is_set($view_context), $view_context|eq('full_attributes'))}
			{def $roles_history = $attribute.content.roles_history}
			{def $roles = $roles_history.roles}
			{* OpenPARoles::getEntities() (PHP) omits the key entirely for an entity
			   the current user can't read, rather than setting it to null - so a
			   direct $roles_history.entities[id] lookup on a filtered-out id raises
			   a template error ("No such attribute for array...") instead of
			   resolving to null. Collecting the actually-present ids up front and
			   checking with contains() avoids ever doing that lookup on a missing
			   key. *}
			{def $available_entity_ids = array()}
			{foreach $roles_history.entities as $available_entity_id => $available_entity}
				{set $available_entity_ids = $available_entity_ids|append($available_entity_id)}
			{/foreach}

			<ul{if $attribute_group.slug|ne('content')} class="d-none"{/if}>
				{def $current_entities = array()}
				{def $expired_items = array()}
				{def $valid_items = array()}
				{def $avoid_duplication = array()}
				{foreach $roles as $role}
					{def $is_expired = cond(and($role|has_attribute('end_time'), $role|attribute('end_time').data_int|le(currentdate())), true(), false())}
					{* has_attribute() is not reliable for distinguishing a real eZContentObject
					   from the plain hash('name', '?') fallback below (verified empirically: it
					   reports false for every key, even on real objects/attributes in this
					   context) - so the "is this real" flag is tracked explicitly here, at the
					   point where the two cases are already an explicit if/else, rather than
					   guessed at later from the value alone. Nested {if}s (not and()) on
					   purpose: and()/or() aren't guaranteed short-circuit here, and
					   evaluating attribute('for_entity') when it's absent is unsafe. *}
					{if $role|has_attribute('for_entity')}
						{if $available_entity_ids|contains($role|attribute('for_entity').content.relation_list[0].contentobject_id)}
							{def $entity = $roles_history.entities[$role|attribute('for_entity').content.relation_list[0].contentobject_id]}
							{def $entity_is_real = true()}
						{else}
							{def $entity = hash('name', '?')}
							{def $entity_is_real = false()}
						{/if}
					{else}
						{def $entity = hash('name', '?')}
						{def $entity_is_real = false()}
					{/if}
					{if $is_expired|not()}
						{if $avoid_duplication|contains($entity.name)|not()}
							{set $current_entities = $current_entities|append(hash('entity', $entity, 'is_real', $entity_is_real))}
							{set $avoid_duplication = $avoid_duplication|append($entity.name)}
						{/if}
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
						{* $current_entities is built from a raw, permission-unaware fetch
						   (OpenPABase::fetchObjects() in openparoles.php): an entity that's
						   been made private still ends up here, and a role with no linked
						   entity at all falls back to hash('name', '?') (see above). Both
						   cases lack a usable main_node, so both are skipped here rather than
						   rendering an empty/broken card shell for them - $child.is_real tells
						   the fallback hash apart from a real eZContentObject (has_attribute()
						   is unreliable for this in the current context, verified empirically). *}
						{if $child.is_real}
							{if $child.entity.can_read}
								{node_view_gui content_node=$child.entity.main_node view=card_teaser show_icon=false() show_category=false() image_class=widemedium}
							{/if}
						{/if}
					{/foreach}
				</div>
			{/if}
			{undef $roles $roles_history $current_entities $expired_items $valid_items $avoid_duplication}

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

