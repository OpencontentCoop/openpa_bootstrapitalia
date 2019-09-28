{include uri="design:content/mediaplayer/audio_player.tpl" attribute=$attribute}
<p>
    <a href="{concat("content/download/",$attribute.contentobject_id,"/",$attribute.id,"/file/",$attribute.content.original_filename)|ezurl(no)}"
       title="{'Download file'|i18n('bootstrapitalia')} {$attribute.content.original_filename|wash( xhtml )}">
        {'Download'|i18n('bootstrapitalia')} "{$attribute.object.name|wash( xhtml )}"
        <br /><small>({'File type'|i18n('bootstrapitalia')} {$attribute.content.mime_type_part} {$attribute.content.filesize|si( byte )})</small>
    </a>
</p>