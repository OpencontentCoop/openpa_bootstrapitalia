{if and(ezmodule('flip','enqueue'), ezini('FlipConvertAll','Classes','ezflip.ini')|contains($content_object.class_identifier))}
{foreach $content_object.data_map as $identifier => $attribute}
    {if and( ezini('FlipConvertAll','Attributes','ezflip.ini')|contains($identifier),
             $attribute.data_type_string|eq( 'ezbinaryfile' ),
             $attribute.has_content, $attribute.content.mime_type|eq( 'application/pdf' ) )}
        <li>
            <a class="list-item left-icon"
               href="{concat("/flip/enqueue/", $attribute.id, '/', $attribute.version, '/', cond( flip_exists( $attribute.id, $attribute.version  ), 1, 0 ))|ezurl(no)}"
               title='Flip file "{$attribute.content.original_filename}"'>
                <i aria-hidden="true" class="fa fa-book"></i>
                Rendi sfogliabile il file
            </a>
        </li>
    {/if}
{/foreach}
{/if}
