{set_defaults( hash('image_class', 'reference'))}
{if is_set($node)}
<img {if openpaini('InstanceSettings', 'LazyLoadImages', 'disabled')|eq('enabled')}data-{/if}src="{node_image($node,$image_class).full_path|ezroot(no)|preload_image()}"
    title="{include uri='design:atoms/image_alt.tpl' node=$node}"
    alt="{include uri='design:atoms/image_alt.tpl' node=$node}"
    style="{if is_set($style)}{$style}{/if}"
     width="{node_image($node,$image_class).width}"
     height="{node_image($node,$image_class).height}"
    class="lazyload{if is_set($classes)} {$classes}{/if}" />
{/if}
{unset_defaults(array('image_class'))}