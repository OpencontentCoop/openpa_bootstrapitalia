{let image_variation="false"
     attribute_parameters=$object_parameters}
{if is_set($attribute_parameters.size)}
{set size=$attribute_parameters.size}
{else}
{set size=ezini( 'ImageSettings', 'DefaultEmbedAlias', 'content.ini' )}
{/if}
{set image_variation=$object.data_map.image.content[$size]}
<img src="{render_image($object.data_map.image.content, hash('alias', $size)).src}" alt="{$object.data_map.image.content.alternative_text|wash(xhtml)}"
    {cond( $attribute_parameters.align, concat( ' class="embed-inline-', $attribute_parameters.align, '"' ), '' )} />
{/let}
