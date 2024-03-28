{set_defaults( hash('image_class', 'reference', 'alias', false(), 'preload', true(), 'height', false(), 'set_max_dimensions', false()))}
{if is_set($node)}
    <img src="{render_image(node_image($node), hash('alias', $image_class, 'preload', $preload)).src}"
            title="{include uri='design:atoms/image_alt.tpl' node=$node}"
            alt="{include uri='design:atoms/image_alt.tpl' node=$node}"
            {if $height}height="{$height}"{/if}
            style="{if is_set($style)}{$style}{/if}{if $set_max_dimensions}max-height:{node_image($node)[$image_class].height}px;max-width:{node_image($node)[$image_class].width}px{/if}"
            {if is_set($classes)} class="{$classes}"{/if}/>
{/if}
{unset_defaults(array('image_class', 'alias', 'preload', 'height'))}