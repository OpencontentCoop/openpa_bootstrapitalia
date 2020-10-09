{def $defaults = ezini( 'DefaultSettings', 'Settings', 'ocmediaplayer.ini' )}
{if $attribute.content.width|gt( 0 )}
    {def $width = $attribute.content.width}
{else}
    {def $width = $defaults.width}
{/if}

{if $attribute.content.height|gt( 0 )}
    {def $height = $attribute.content.height}
{else}
    {def $height = $defaults.height}
{/if}

{if $attribute.content.is_autoplay}
    {def $is_autoplay = true()}
{else}
    {def $is_autoplay = $defaults.is_autoplay|eq( 'enabled' )}
{/if}

<video width="{$width}" height="{$height}" controls{if $is_autoplay} autoplay{/if}>
  	<source src="{concat("content/download/",$attribute.contentobject_id,"/",$attribute.content.contentobject_attribute_id,"/",$attribute.content.original_filename)|ezurl(no)}"
  		    type="{$attribute.content.mime_type}">
	{'Your browser does not support the video element.'|i18n("bootstrapitalia")}
</video>

{undef}