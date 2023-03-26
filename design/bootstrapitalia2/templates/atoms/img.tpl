{set_defaults( hash('image_class', 'reference', 'alias', false(), 'preload', true()))}
{if is_set($node)}
    <img {image_src(node_image($node,$image_class).full_path|ezroot(no,full), $alias, $preload)}
            title="{include uri='design:atoms/image_alt.tpl' node=$node}"
            alt="{include uri='design:atoms/image_alt.tpl' node=$node}"
            style="{if is_set($style)}{$style}{/if}"
            class="lazyload{if is_set($classes)} {$classes}{/if}"/>
{/if}
{unset_defaults(array('image_class', 'alias', 'preload'))}