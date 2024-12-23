{def $class_attribute_content = $class_attribute.content}

<div class="block"></div>
{if count($class_attribute_content.attribute_list)}
<div class="block">
	<table class="list">
		<tr>
			<th>{'Class'|i18n('design/standard/class/datatype')}</th>
			<th>{'Attribute'|i18n('design/standard/class/datatype')}</th>
			<th>{'Subtree'|i18n( 'design/admin/role/createpolicystep3' )}</th>
		</tr>
		{foreach $class_attribute_content.attribute_list as $class_name => $relation_attributes}
			{foreach $relation_attributes as $relation_attribute}
			<tr>
				<td>{$class_name|wash()}</td>
				<td>{$relation_attribute.name|wash()}</td>
				<td>{if and(is_set($class_attribute_content.attribute_id_subtree[$relation_attribute.id]), $class_attribute_content.attribute_id_subtree[$relation_attribute.id]|gt(0))}{$class_attribute_content.attribute_id_subtree[$relation_attribute.id]|wash()}{/if}</td>
			</tr>
			{/foreach}
		{/foreach}
		<tr>
			<td colspan="3">
				{def $sort_fields = hash( 
					'name', 'Name'|i18n( 'design/admin/node/view/full' ),
					'raw[meta_class_name_ms]', 'Class name'|i18n( 'design/admin/node/view/full' ),
					'modified', 'Modified'|i18n( 'design/admin/node/view/full' ),
					'published', 'Published'|i18n( 'design/admin/node/view/full' )
				)}
				<strong>{'Ordering'|i18n( 'design/admin/node/view/full' )}:</strong>
				{$sort_fields[$class_attribute_content.sort]|wash} {if eq($class_attribute_content.order, 'desc')}{'Descending'|i18n( 'design/admin/node/view/full' )}{else}{'Ascending'|i18n( 'design/admin/node/view/full' )}{/if}	
				{undef $sort_fields}

				<strong>{'Numero elementi per pagina:'|i18n( 'design/admin/node/view/full' )}</strong>
				{$class_attribute_content.limit|wash()}
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<strong>Query:</strong><br />
				<code style="margin:0">{$class_attribute_content.query|wash()}</code>
			</td>
	</table>
</div>

{/if}

{undef $class_attribute_content}