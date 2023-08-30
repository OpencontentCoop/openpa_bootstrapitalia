{if $attribute.has_content}

	{def $context = false()
		 $module_params = module_params()}
	{if and($module_params.module_name|eq('content'),$module_params.function_name|eq('view'),$module_params.parameters.ViewMode|eq('full'))}
		{set $context = fetch(content, node, hash('node_id', $module_params.parameters.NodeID))}
	{/if}


	{switch match=$attribute.class_content.view}

		{case match=1} {* Lista Persone: per i ruoli afferenti a una struttura*}
			<ul class="list-unstyled ">
				{foreach $attribute.content.people as $person}
					{def $openpa_person = object_handler($person)}
						<li>
							<a href="{$openpa_person.content_link.full_link}" title="Link {$person.name|wash()}">{$person.name|wash()}</a>
							{foreach $attribute.content.roles_per_person[$person.id] as $role}{*
								*}{foreach $role|attribute('role').content.tags as $tag}{$tag.keyword|wash|trim}{delimiter}, {/delimiter}{/foreach}{*
								*}{if $role|has_attribute('delegations')}
									<small>({$role|attribute('delegations').contentclass_attribute_name|downcase|wash()}: {$role|attribute('delegations').content.cells|implode(', ')|wash})</small>
								{/if}{*
								*}{delimiter}, {/delimiter}{*
							*}{/foreach}
						</li>
					{undef $openpa_person}
				{/foreach}
			</ul>
		{/case}

		{case match=3} {* Persone: per i ruoli afferenti a una struttura *}
			{def $total = fetch('bootstrapitalia', 'openparole_people_count', hash('attribute', $attribute))}
			{def $items_per_page = 2}
			{def $people = fetch('bootstrapitalia', 'openparole_people', hash('attribute', $attribute, 'limit', $items_per_page, 'offset', cond(is_set($#view_parameters[$attribute.contentclass_attribute_identifier]), $#view_parameters[$attribute.contentclass_attribute_identifier], 0)))}
			<div>
				<div class="card-wrapper card-teaser-wrapper" style="min-width:49%">
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
		{/case}

		{case match=2} {* Lista Strutture: per i ruoli afferenti a una persona *}

			{* versione estesa per il full *}
			{if and(is_set($view_context), $view_context|eq('full_attributes'))}
				{def $roles = $attribute.content.roles}
				<ul>
					{foreach $roles as $role}
					<li class="mb-2">
						{def $entity = $attribute.content.entities[$role|attribute('for_entity').content.relation_list[0].contentobject_id]}
						{if $role|has_attribute('label')}
							<a href="{object_handler($entity).content_link.full_link}" title="Link {$entity.name|wash()}">{$role|attribute('label').content|wash()}</a>
						{else}
							{foreach $role|attribute('role').content.tags as $tag}{$tag.keyword|wash|trim}{delimiter}, {/delimiter}{/foreach} {'at'|i18n('bootstrapitalia')} <a href="{object_handler($entity).content_link.full_link}" title="Link {$entity.name|wash()}">{$entity.name|wash()}</a>
						{/if}
						{if or($role|has_attribute('competences'), $role|has_attribute('delegations'))}
							{if $role|has_attribute('competences')}
								<ul class="list-unstyled" style="font-size: .8em">
									<li><strong>{$role|attribute('competences').contentclass_attribute_name}:</strong></li>
								</ul>
								<ul style="font-size: .8em">
									<li>{$role|attribute('competences').content.cells|implode('</li><li>')}</li>
								</ul>

							{/if}
							{if $role|has_attribute('delegations')}
								<ul class="list-unstyled" style="font-size: .8em">
									<li><strong>{$role|attribute('delegations').contentclass_attribute_name}:</strong></li>
								</ul>
								<ul style="font-size: .8em">
									<li>{$role|attribute('delegations').content.cells|implode('</li><li>')}</li>
								</ul>
							{/if}
						{/if}
						{undef $entity}
					</li>
					{/foreach}
				</ul>
				{undef $roles}

			{* versione compatta per abstract *}
			{else}

				{* contestualizzato alla struttura del full corrente *}
				{if and($context, is_set($attribute.content.roles_per_entity[$context.contentobject_id]))}
					<ul class="list-unstyled">
						<li>
							{foreach $attribute.content.roles_per_entity[$context.contentobject_id] as $role}{*
								*}{foreach $role|attribute('role').content.tags as $tag}{$tag.keyword|wash|trim}{delimiter}, {/delimiter}{/foreach}{*
								mostra il dettaglio delegations dei ruoli legati all'entità di cui si sta visualizzando il content/view/full
								*}{if $role|has_attribute('delegations')}
									<small>({$role|attribute('delegations').content.cells|implode(', ')|wash})</small>
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
								{$type} {foreach $entities as $id => $name}<a href="{concat('openpa/object/', $id)|ezurl(no)}">{$name|wash()}</a>{delimiter}, {/delimiter}{/foreach}
							{/if}
						</li>
					{/foreach}
					</ul>
				{/if}
			{/if}
		{/case}

		{case match=4} {* Strutture: per i ruoli afferenti a una persona *}
			<div class="card-wrapper card-teaser-wrapper" style="min-width:49%">
				{foreach $attribute.content.entities as $child }
					{node_view_gui content_node=$child.main_node view=card_teaser show_icon=true() image_class=widemedium}
				{/foreach}
			</div>
		{/case}

		{case}{/case}
	{/switch}

	{undef $context $module_params}
{/if}
