{def $class_attribute_content = $attribute.class_content}
{if count($class_attribute_content.attribute_list)}
<ul>
	{foreach $class_attribute_content.attribute_list as $class_name => $relation_attributes}
		{foreach $relation_attributes as $relation_attribute}
		<li>{$class_name|wash()}/{$relation_attribute.name|wash()}</li>
		{/foreach}
	{/foreach}
</ul>		
{/if}
{undef $class_attribute_content}