{if $attribute.has_content}
  <div class="card-wrapper card-column my-3">
  {foreach $attribute.content as $file}
    <div class="font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3">
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
  {/foreach}
  </div>
{/if}