{def $class_attribute_content = $class_attribute.content}

<div class="block float-break" style="margin-top:20px;padding-bottom:0">
	<label for="RelationClassAttribute_{$class_attribute.id}">{'Add attribute'|i18n('design/admin/class/edit')}:</label>
	<div class="element">
		<select id="RelationClassAttribute_{$class_attribute.id}" name="RelationClassAttribute_{$class_attribute.id}" style="max-width: 300px">
		<option></option>
		{foreach $class_attribute_content.available_class_attributes as $class_name => $relation_attributes}
			{foreach $relation_attributes as $relation_attribute}
			<option value="{$relation_attribute.id}">{$class_name|wash()}/{$relation_attribute.name|wash()}</option>
			{/foreach}
		{/foreach}
		</select>
	</div>
	<div class="element">
		<input type="number" name="RelationClassAttributeSubtree_{$class_attribute.id}" class="halfbox" placeholder="{'Subtree'|i18n( 'design/admin/role/createpolicystep3' )}"/>
	</div>
	<div class="element">
		<input class="button" type="submit"
			   name="CustomActionButton[{$class_attribute.id}_add_attribute]"
			   value="{'Select item'|i18n('design/standard/class/datatype')}" />
	</div>
</div>

{if count($class_attribute_content.attribute_list)}
<div class="block" style="padding:0">
	<table class="list">
		<tr>
			<th class="tight"></th>
			<th>{'Class'|i18n('design/standard/class/datatype')}</th>
			<th>{'Attribute'|i18n('design/standard/class/datatype')}</th>
			<th>{'Subtree'|i18n( 'design/admin/role/createpolicystep3' )}</th>
		</tr>
		{foreach $class_attribute_content.attribute_list as $class_name => $relation_attributes}
			{foreach $relation_attributes as $relation_attribute}
			<tr>
				<td><input type="checkbox" name="RemoveRelationClassAttribute_{$class_attribute.id}[]" value="{$relation_attribute.id}" /></td>
				<td>{$class_name|wash()}</td>
				<td>{$relation_attribute.name|wash()}</td>
				<td>{if and(is_set($class_attribute_content.attribute_id_subtree[$relation_attribute.id]), $class_attribute_content.attribute_id_subtree[$relation_attribute.id]|gt(0))}{$class_attribute_content.attribute_id_subtree[$relation_attribute.id]|wash()}{/if}</td>
			</tr>
			{/foreach}
		{/foreach}
		<tr>
			<td colspan="3">
				<input class="button" type="submit" 
					   name="CustomActionButton[{$class_attribute.id}_remove_attribute]" 
					   value="{'Remove selected'|i18n('design/standard/class/datatype')}" />
			</td>
		</tr>
	</table>
</div>
{/if}


{def $sort_fields = hash( 
	'name', 'Name'|i18n( 'design/admin/node/view/full' ),
	'raw[meta_class_name_ms]', 'Class name'|i18n( 'design/admin/node/view/full' ),
	'modified', 'Modified'|i18n( 'design/admin/node/view/full' ),
	'published', 'Published'|i18n( 'design/admin/node/view/full' )
)}
<div class="float-break">
	<div class="block" style="margin-right:20px; float:left; clear:none">
		<label for="ContentClass_openpareverserelationlist_sort_{$class_attribute.id}">{'Ordering'|i18n( 'design/admin/node/view/full' )}:</label>
		<div class="element">
			<select class="box"
					id="ContentClass_openpareverserelationlist_sort_{$class_attribute.id}"
					name="ContentClass_openpareverserelationlist_sort_{$class_attribute.id}">
				{foreach $sort_fields as $key => $value}
				<option value="{$key}" {if $class_attribute_content.sort|eq($key)}selected="selected"{/if}>{$value|wash()}</option>
				{/foreach}
			</select>
		</div>
		<div class="element">
			<select name="ContentClass_openpareverserelationlist_order_{$class_attribute.id}">
				<option value="desc"{if eq($class_attribute_content.order, 'desc')} selected="selected"{/if}>{'Descending'|i18n( 'design/admin/node/view/full' )}</option>
				<option value="asc"{if eq($class_attribute_content.order, 'asc')} selected="selected"{/if}>{'Ascending'|i18n( 'design/admin/node/view/full' )}</option>
			</select>
		</div>
	</div>


	<div class="block" style="float:left; clear:none">
		<div class="element">
			<label>{'Numero elementi per pagina:'|i18n( 'design/admin/node/view/full' )}</label>
			<input type="number" name="ContentClass_openpareverserelationlist_limit_{$class_attribute.id}" value="{$class_attribute_content.limit|wash()}">
		</div>
	</div>
</div>

<div class="block">
	<label for="ContentClass_openpareverserelationlist_customquery_{$class_attribute.id}">Custom query:</label>
	<input type="text"
		   class="box"
		   placeholder="{$class_attribute_content.query|wash()}"
		   value="{$class_attribute_content.custom_query|wash()}"
		   id="ContentClass_openpareverserelationlist_customquery_{$class_attribute.id}"
		   name="ContentClass_openpareverserelationlist_customquery_{$class_attribute.id}" />
</div>
{undef $sort_fields}
{undef $class_attribute_content}