<li class="mb-2 lora{if $is_expired} text-500{/if}">
	<h3 class="h5 mt-4">
		{if $role|has_attribute('label')}
			{$role|attribute('label').content|wash()}
		{else}
			{foreach $role|attribute('role').content.tags as $tag}{$tag.keyword|wash|trim}{delimiter}, {/delimiter}{/foreach} {'at'|i18n('bootstrapitalia')} {$entity.name|wash()}
		{/if}
		{if $role|has_attribute('start_time')}
			<small> {'from'|i18n("openpa/search")} {attribute_view_gui attribute=$role|attribute('start_time')}
				{if $is_expired} {'to'|i18n("openpa/search")} {attribute_view_gui attribute=$role|attribute('end_time')}{/if}
			</small>
		{/if}
	</h3>
	{if and($role|has_attribute('competences'), $role|attribute('competences').content.cells|implode('')|trim()|ne(''))}
		<h4 class="h6 mt-4 font-sans-serif">{$role|attribute('competences').contentclass_attribute_name}:</h4>
		<ul class="list-unstyled">
			<li>{$role|attribute('competences').content.cells|implode('</li><li>')}</li>
		</ul>
	{/if}
	{if and($role|has_attribute('delegations'), $role|attribute('delegations').content.cells|implode('')|trim()|ne(''))}
		<h4 class="h6 mt-4 font-sans-serif">{$role|attribute('delegations').contentclass_attribute_name}:</h4>
		<ul class="list-unstyled">
			<li>{$role|attribute('delegations').content.cells|implode('</li><li>')}</li>
		</ul>
	{/if}
	{foreach array('compensi', 'importi', 'atto_nomina', 'notes') as $attribute_identifier}
		{if $role|has_attribute($attribute_identifier)}
			<h4 class="h6 mt-4 font-sans-serif">{$role|attribute($attribute_identifier).contentclass_attribute_name}:</h4>
			<ul class="list-unstyled">
				<li>{attribute_view_gui attribute=$role|attribute($attribute_identifier)}</li>
			</ul>
		{/if}
	{/foreach}
</li>