{if $attribute.has_content}

	{def $context = false()
		 $module_params = module_params()}
	{if and($module_params.module_name|eq('content'),$module_params.function_name|eq('view'),$module_params.parameters.ViewMode|eq('full'))}
		{set $context = fetch(content, node, hash('node_id', $module_params.parameters.NodeID))}
	{/if}


	{switch match=$attribute.class_content.view}

		{case match=1} {* Lista Persone per i ruoli afferenti a una struttura*}
			<ul class="list-unstyled ">
				{foreach $attribute.content.people as $person}
					{def $openpa_person = object_handler($person)}
						<li class="text-sans-serif">
							<a class="text-sans-serif" href="{$openpa_person.content_link.full_link}" title="Link {$person.name|wash()}">{$person.name|wash()}</a>
							{foreach $attribute.content.roles_per_person[$person.id] as $role}{*
								*}{$role|attribute('role').content.keyword_string|trim}{*
								*}{if $role|has_attribute('delegations')}
									<small class="text-sans-serif">({$role|attribute('delegations').contentclass_attribute_name|downcase|wash()}: {$role|attribute('delegations').content.cells|implode(', ')|wash})</small>
								{/if}{*
								*}{delimiter}, {/delimiter}{*
							*}{/foreach}
						</li>
					{undef $openpa_person}
				{/foreach}
			</ul>
		{/case}

		{case match=3} {* Persone per i ruoli afferenti a una struttura *}
			<div class="card-wrapper card-teaser-wrapper" style="min-width:49%">
				{foreach $attribute.content.people as $child }
					{node_view_gui content_node=$child.main_node view=card_teaser show_icon=true() image_class=widemedium}
				{/foreach}
			</div>
		{/case}

		{case match=2} {* Lista Strutture per i ruoli afferenti a una persona *}

			{* versione estesa per il full *}
			{if and(is_set($view_context), $view_context|eq('full_attributes'))}
				<ul class="list-unstyled text-sans-serif">
					{foreach $attribute.content.entities as $entity}
						{def $openpa_entity = object_handler($entity)}
							{foreach $attribute.content.roles_per_entity[$entity.id] as $role}
							<li class="text-sans-serif">
								{$role|attribute('role').content.keyword_string|trim} presso <a class="text-sans-serif" href="{$openpa_entity.content_link.full_link}" title="Link {$entity.name|wash()}">{$entity.name|wash()}</a>
								{if or($role|has_attribute('competences'), $role|has_attribute('delegations'))}
								<ul class="list-unstyled mb-3">
									{if $role|has_attribute('competences')}
										<small class="d-block text-sans-serif">
											<strong class="text-sans-serif">{$role|attribute('competences').contentclass_attribute_name}:</strong>
											{$role|attribute('competences').content.cells|implode(', ')}
										</small>
									{/if}
									{if $role|has_attribute('delegations')}
										<small class="d-block text-sans-serif">
											<strong class="text-sans-serif">{$role|attribute('delegations').contentclass_attribute_name}:</strong>
											{$role|attribute('delegations').content.cells|implode(', ')}
										</small>
									{/if}
								</ul>
									{/if}
							</li>
							{/foreach}
						{undef $openpa_entity}
					{/foreach}
				</ul>

			{* versione compatta per abstract *}
			{else}

				{* contestualizzato alla struttura del full corrente *}
				{if and($context, is_set($attribute.content.roles_per_entity[$context.contentobject_id]))}
					<ul class="list-unstyled text-sans-serif">
						<li class="text-sans-serif">
							{foreach $attribute.content.roles_per_entity[$context.contentobject_id] as $role}{*
								*}{$role|attribute('role').content.keyword_string|trim}{*
								mostra il dettaglio delegations dei ruoli legati all'entità di cui si sta visualizzando il content/view/full
								*}{if $role|has_attribute('delegations')}
									<small class="text-sans-serif">({$role|attribute('delegations').content.cells|implode(', ')|wash})</small>
								{/if}{*
								*}{delimiter}, {/delimiter}{*
						  *}{/foreach}
						</li>
					</ul>

				{* in generale per abstract *}
				{else}
                    <ul class="list-unstyled text-sans-serif">
					{foreach $attribute.content.main_type_per_entities as $type => $entities}
						<li class="text-sans-serif">{$type} presso {foreach $entities as $id => $name}<a class="text-sans-serif" href="{concat('openpa/object/', $id)|ezurl(no)}">{$name|wash()}</a>{delimiter}, {/delimiter}{/foreach}</li>
					{/foreach}
					</ul>
				{/if}
			{/if}
		{/case}

		{case match=4} {* Strutture per i ruoli afferenti a una persona *}
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
