{if $attribute.has_content}
{if $in_accordion}
<ul class="link-list">
  {foreach $attribute.content as $file}
    <li>
      <div class="cmp-icon-link mb-2">
        <a class="list-item icon-left d-inline-block font-sans-serif mb-0"
           href="{concat( 'ocmultibinary/download/', $attribute.contentobject_id, '/', $attribute.id,'/', $attribute.version , '/', $file.filename ,'/file/', $file.original_filename|urlencode )|ezurl(no)}"
           aria-label="{'Download file'|i18n('bootstrapitalia')} {if $file.display_name|ne('')}{$file.display_name|clean_filename()|wash( xhtml )}{else}{$file.original_filename|clean_filename()|wash( xhtml )}{/if}"
           data-focus-mouse="false">{*
                *}<span class="list-item-title-icon-wrapper">{*
                *}{display_icon('it-clip', 'svg', 'icon icon-primary icon-sm me-1')}{*
                *}<span class="list-item">{*
                *}{if $file.display_name|ne('')}{$file.display_name|clean_filename()|wash( xhtml )}{else}{$file.original_filename|clean_filename()|wash( xhtml )}{/if}{*
                *}</span>{*
                *}</span>{*
                *}</a>
        <small class="d-block mt-2 mb-4" style="margin-left: 28px !important;">(File {$file.mime_type|explode('application/')|implode('')} {*<em>{$file.original_filename|wash()}</em>*} {$file.filesize|si( byte )})</small>
      </div>
    </li>
  {/foreach}
</ul>
{else}
  <div class="row row-cols-2 mx-0">
  {foreach $attribute.content as $file}
    <div class="col font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3">
      {display_icon('it-clip', 'svg', 'icon')}		
      <div class="card-body">
        <h5 class="card-title">
          <a class="stretched-link"
            href={concat( 'ocmultibinary/download/', $attribute.contentobject_id, '/', $attribute.id,'/', $attribute.version , '/', $file.filename ,'/file/', $file.original_filename|urlencode )|ezurl}
            aria-label="{'Download file'|i18n('bootstrapitalia')} {$file.original_filename|clean_filename()|wash( xhtml )}">	    
            {$file.original_filename|clean_filename()|wash( xhtml )}
          </a>
          <small class="d-block">(File {$file.mime_type|explode('application/')|implode('')} {*<em>{$file.original_filename|wash()}</em>*} {$file.filesize|si( byte )})</small>
        </h5>
      </div>
    </div>
  {/foreach}
  </div>
{/if}
{/if}
