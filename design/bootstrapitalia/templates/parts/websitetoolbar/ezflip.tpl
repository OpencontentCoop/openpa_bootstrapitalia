{if ezini('FlipConvertAll','Classes','ezflip.ini')|contains($content_object.class_identifier)}
{foreach $content_object.data_map as $identifier => $attribute}
    {if and( ezini('FlipConvertAll','Attributes','ezflip.ini')|contains($identifier),
             $attribute.data_type_string|eq( 'ezbinaryfile' ),
             $attribute.has_content, $attribute.content.mime_type|eq( 'application/pdf' ) )}
        <a href={concat("/flip/enqueue/", $attribute.id, '/', $attribute.version, '/', cond( flip_exists( $attribute.id, $attribute.version  ), 1, 0 ))|ezurl} title='Flip file "{$attribute.content.original_filename}"'><img width="16" height="16" src={"ezwt-icon-pdf-upload.gif"|ezimage} alt="Flip file {$attribute.content.original_filename}" /></a>
    {/if}
{/foreach}
{/if}
