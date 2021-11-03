{set_defaults( hash('dates_container_class', 'mt-5 mb-4'))}
{def $main_attributes = class_extra_parameters($node.object.class_identifier, 'table_view').in_overview}
{def $datetime_attributes = array()}
{foreach $main_attributes as $identifier}
	{if and(or($identifier|eq('alternative_name'), $identifier|eq('alt_name')), is_set($openpa[$identifier].contentobject_attribute))}
		<p class="lead"><strong>{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute image_class=reference alignment=center}</strong></p>
	{/if}
	{if array('alternative_name','alt_name','content_show_published','content_show_modified','reading_time')|contains($identifier)}{skip}{/if}
	{if is_set($openpa[$identifier].contentobject_attribute)}
		{if $openpa[$identifier].contentobject_attribute.has_content}
			{if array('ezdate', 'ezdatetime')|contains($openpa[$identifier].contentobject_attribute.data_type_string)}
				{set $datetime_attributes = $datetime_attributes|append($openpa[$identifier].contentobject_attribute)}
			{else}
				{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute image_class=reference alignment=center}
			{/if}
		{/if}
	{else}
	    {include uri=$openpa[$identifier].template}
	{/if}
{/foreach}
{if or($main_attributes|contains('content_show_published'),$main_attributes|contains('content_show_modified'),$main_attributes|contains('reading_time'),count($datetime_attributes)|gt(0))}
	<div class="row {$dates_container_class}">
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
			    <span class="d-block text-nowrap text-sans-serif">{'Reading time'|i18n('bootstrapitalia')}:</span>
			    <strong class="text-nowrap">{$node|attribute('reading_time').content|wash()} min</strong>
			</p>
		</div>
	{/if}
	{foreach $datetime_attributes as $attribute}
		<div class="col">
			<p class="info-date my-3">
				<span class="d-block text-nowrap">{$attribute.contentclass_attribute_name|wash()}:</span>
				<strong class="text-nowrap">{$attribute.content.timestamp|datetime( 'custom', '%j %F %Y' )}</strong>
			</p>
		</div>
	{/foreach}
	</div>
{/if}
{undef $main_attributes $datetime_attributes}
{unset_defaults(array('dates_container_class'))}
