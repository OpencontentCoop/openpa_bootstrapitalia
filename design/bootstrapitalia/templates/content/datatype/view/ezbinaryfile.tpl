{set_defaults( hash(    
    'icon',true(),
	'wide', false()
))}

{if $attribute.has_content}
	{if $attribute.content}
	<div class="row mx-lg-n3">
		<div class="col{if $wide|not()}-md-6{/if} px-lg-3 pb-lg-3">
			<div class="card card-teaser shadow p-4 mt-3 rounded border">
				{if $icon}
				{display_icon('it-clip', 'svg', 'icon')}		
				{/if}
				<div class="card-body">
				  <h5 class="card-title">
				    <a class="stretched-link" href={concat("content/download/",$attribute.contentobject_id,"/",$attribute.id,"/file/",$attribute.content.original_filename|explode(' ')|implode('_'))|ezurl} title="Scarica il file {$attribute.content.original_filename|wash( xhtml )}">
				    	{$attribute.content.original_filename|clean_filename()|wash( xhtml )} 				    	
				    </a>
				    <small class="d-block">(File {$attribute.content.mime_type|explode('application/')|implode('')} {*<em>{$attribute.content.original_filename|wash()}</em> *}{$attribute.content.filesize|si( byte )})</small>
				  </h5>
				</div>
			</div>
		</div>
	</div>
	{else}
		{editor_warning('The file could not be found.'|i18n( 'design/ezwebin/view/ezbinaryfile' ) )}
	{/if}
	
{/if}