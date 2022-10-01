{set_defaults(hash('show_icon', true()))}
{def $attribute = $node|attribute('file')}
<div data-object_id="{$node.contentobject_id}" class="card card-teaser shadow {$node|access_style} rounded {$view_variation}">
    {if $show_icon}
        {display_icon('it-clip', 'svg', 'icon')}
    {/if}
    <div class="card-body">
        <h5 class="card-title">
            <a class="stretched-link"
               href="{concat("content/download/",$attribute.contentobject_id,"/",$attribute.id,"/file/",$attribute.content.original_filename|explode(' ')|implode('_'))|ezurl(no)}"
               title="Scarica il file {$attribute.content.original_filename|wash( xhtml )}">
                {$attribute.content.original_filename|clean_filename()|wash( xhtml )}
            </a>
            <small class="d-block">(File {$attribute.content.mime_type|explode('application/')|implode('')}{$attribute.content.filesize|si( byte )})</small>
        </h5>
    </div>
</div>
{undef $attribute}
{unset_defaults(array('show_icon'))}
