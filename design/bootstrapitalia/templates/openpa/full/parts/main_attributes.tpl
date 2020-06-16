{def $main_attributes = class_extra_parameters($node.object.class_identifier, 'table_view').in_overview}
{foreach $main_attributes as $identifier}
	{if array('content_show_published','content_show_modified','reading_time')|contains($identifier)}{skip}{/if}
	{if is_set($openpa[$identifier].contentobject_attribute)}
		{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute image_class=reference alignment=center}
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