{def $main_attributes = class_extra_parameters($node.object.class_identifier, 'table_view').in_overview}
{foreach $main_attributes as $identifier}
	{if $identifier|eq('alternative_name')}
		<p class="lead"><strong>{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute image_class=reference alignment=center}</strong></p>
	{/if}
	{if array('alternative_name','content_show_published','content_show_modified','reading_time')|contains($identifier)}{skip}{/if}
	{if is_set($openpa[$identifier].contentobject_attribute)}
		{if $openpa[$identifier].contentobject_attribute.has_content}
			{*if class_extra_parameters($node.object.class_identifier, 'table_view').show_label|contains($identifier)}
				<span class="d-block text-nowrap text-sans-serif">{$openpa[$identifier].contentobject_attribute.contentclass_attribute_name}:</span>
			{/if*}
			{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute image_class=reference alignment=center}
		{/if}
	{else}
	    {include uri=$openpa[$identifier].template}
	{/if}
{/foreach}
{if or($main_attributes|contains('content_show_published'),$main_attributes|contains('content_show_modified'),$main_attributes|contains('reading_time'))}
	<div class="row mt-5 mb-4">
	{if $main_attributes|contains('content_show_published')}
		<div class="col">
			{include uri=$openpa['content_show_published'].template}
		</div>
	{/if}
	{if $main_attributes|contains('content_show_modified')}
		<div class="col">
			{include uri=$openpa['content_show_modified'].template}
		</div>
	{/if}
	{if and($node|has_attribute('reading_time'), $main_attributes|contains('reading_time'), $node|attribute('reading_time').content|ne('0'))}
		<div class="col">
			<p class="info-date my-3">
			    <span class="d-block text-nowrap">{'Reading time'|i18n('bootstrapitalia')}:</span>
			    <strong class="text-nowrap">{$node|attribute('reading_time').content|wash()} min</strong>
			</p>
		</div>
	{/if}
	</div>
{/if}
{undef $main_attributes}