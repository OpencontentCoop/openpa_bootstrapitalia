{set_defaults( hash(    
    'icon',true(),
	'wide', false()
))}

{if $attribute.has_content}
	{if $attribute.content}
	<div class="card-wrapper card-column my-3">
			<div class="font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3">
				{if $icon}
				{display_icon('it-clip', 'svg', 'icon')}		
				{/if}
				<div class="card-body">
				  <h5 class="card-title">
				    <a class="stretched-link"
              href={concat("content/download/",$attribute.contentobject_id,"/",$attribute.id,"/file/",$attribute.content.original_filename|explode(' ')|implode('_'))|ezurl}
              title="{'Download file'|i18n('bootstrapitalia')} {$attribute.content.original_filename|clean_filename()|wash( xhtml )}">
				    	{$attribute.content.original_filename|clean_filename()|wash( xhtml )} 				    	
				    </a>
				    <small class="d-block">(File {$attribute.content.mime_type|explode('application/')|implode('')} {*<em>{$attribute.content.original_filename|wash()}</em> *}{$attribute.content.filesize|si( byte )})</small>
				  </h5>
				</div>
			</div>
	</div>
	{else}
		{editor_warning('The file could not be found.'|i18n( 'design/ezwebin/view/ezbinaryfile' ) )}
	{/if}
	
{/if}