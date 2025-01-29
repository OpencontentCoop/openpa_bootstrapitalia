{set_defaults( hash('dates_container_class', 'mt-5 mb-4'))}
{def $main_attributes = class_extra_parameters($node.object.class_identifier, 'table_view').in_overview}
{def $main_labels = class_extra_parameters($node.object.class_identifier, 'table_view').show_label}

{def $custom_datetime_attributes = array('content_show_published','content_show_modified','reading_time', 'protocollo')}
{def $datetime_attributes = array()}
{def $alt_name_identifier = array('alternative_name', 'alt_name')}
{def $skip_identifiers = array('topics', 'has_public_event_typology', 'type', 'content_type', 'document_type', 'announcement_type')}
{def $show_date_attributes = false()}

{foreach $alt_name_identifier as $identifier}
	{if and($main_attributes|contains($identifier), is_set($openpa[$identifier].contentobject_attribute), $openpa[$identifier].contentobject_attribute.has_content)}
		<h2 class="h5 mb-1">{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute image_class=reference alignment=center}</h2>
	{/if}
{/foreach}

{foreach $main_attributes as $identifier}
	{if $alt_name_identifier|contains($identifier)}
		{skip}
	{/if}
	{if $skip_identifiers|contains($identifier)}
		{skip}
	{/if}
	{if $custom_datetime_attributes|contains($identifier)}
		{set $datetime_attributes = $datetime_attributes|append($identifier)}
		{set $show_date_attributes = true()}
		{skip}
	{/if}
	{if is_set($openpa[$identifier].contentobject_attribute)}
		{if $openpa[$identifier].contentobject_attribute.has_content}
			{if array('ezdate', 'ezdatetime')|contains($openpa[$identifier].contentobject_attribute.data_type_string)}
				{set $datetime_attributes = $datetime_attributes|append($identifier)}
				{set $show_date_attributes = true()}
			{elseif array('ezstring')|contains($openpa[$identifier].contentobject_attribute.data_type_string)}
				<p class="mb-2">
					{if $main_labels|contains($identifier)}
						<small class="text-nowrap font-sans-serif">{$openpa[$identifier].contentclass_attribute.name|wash()}:</small>
					{/if}
					{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute image_class=reference alignment=center}
				</p>
			{else}
				{if $main_labels|contains($identifier)}
				<div class="d-flex align-items-baseline">
					<small class="d-block text-nowrap font-sans-serif me-3">{$openpa[$identifier].contentclass_attribute.name|wash()}:</small>
					<div>
				{/if}
        {if array('ezstring')|contains($openpa[$identifier].contentobject_attribute.data_type_string)}<p>{/if}
				{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute image_class=reference alignment=center}
        {if array('ezstring')|contains($openpa[$identifier].contentobject_attribute.data_type_string)}</p>{/if}
				{if $main_labels|contains($identifier)}
					</div>
				</div>
				{/if}
			{/if}
		{/if}
	{else}
	    {include uri=$openpa[$identifier].template}
	{/if}
{/foreach}

{if $show_date_attributes}
<div class="row {$dates_container_class}">
{foreach $datetime_attributes as $identifier}
	{if and(is_set($openpa[$identifier].contentobject_attribute), $openpa[$identifier].has_content)}
		<div class="col">
			<small class="d-block text-nowrap font-sans-serif">{$openpa[$identifier].contentclass_attribute.name|wash()}:</small>
			<p class="fw-semibold font-monospace text-{if $identifier|ne('protocollo')}nowrap{else}truncate" style="max-width: 300px;" title="{$openpa[$identifier].contentobject_attribute.content|wash()}{/if}">
				{if $identifier|eq('protocollo')}
					{$openpa[$identifier].contentobject_attribute.content|wash()}
				{elseif $identifier|eq('reading_time')}
					{$openpa[$identifier].contentobject_attribute.content|wash()} min
				{else}
					{$openpa[$identifier].contentobject_attribute.content.timestamp|l10n( 'shortdate' )}
				{/if}
			</p>
		</div>
	{elseif is_set($openpa[$identifier].template)}
		<div class="col">
			{include uri=$openpa[$identifier].template}
		</div>
	{/if}
{/foreach}
</div>
{/if}

{undef $main_labels $main_attributes $datetime_attributes $alt_name_identifier $show_date_attributes}
{unset_defaults(array('dates_container_class'))}
