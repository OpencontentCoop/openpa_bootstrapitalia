{if $attribute.has_content}
<div class="row mx-lg-n3">
{foreach $attribute.content as $file}
 <div class="col-md-6 px-lg-3 pb-lg-3">
	<div class="card card-teaser shadow p-4 mt-3 rounded border">
		{display_icon('it-clip', 'svg', 'icon')}		
		<div class="card-body">
		  <h5 class="card-title">
		  	<a class="stretched-link" href={concat( 'ocmultibinary/download/', $attribute.contentobject_id, '/', $attribute.id,'/', $attribute.version , '/', $file.filename ,'/file/', $file.original_filename|urlencode )|ezurl}>			    
		    	{$file.original_filename|clean_filename()|wash( xhtml )} 		    	
		    </a>
		    <small class="d-block">(File {$file.mime_type|explode('application/')|implode('')} {*<em>{$file.original_filename|wash()}</em>*} {$file.filesize|si( byte )})</small>
		  </h5>
		</div>
	</div>
</div>	
{/foreach}
</div>
{/if}