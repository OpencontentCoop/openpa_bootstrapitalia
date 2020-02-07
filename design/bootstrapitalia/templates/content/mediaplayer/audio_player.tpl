 <audio controls>  
	<source src="{concat( "content/download/", $attribute.contentobject_id, "/", $attribute.content.contentobject_attribute_id, "/", $attribute.content.original_filename)|ezurl( 'no' )}"
			type="{$attribute.content.mime_type}">
	{'Your browser does not support the audio element.'|i18n("bootstrapitalia)}
</audio> 