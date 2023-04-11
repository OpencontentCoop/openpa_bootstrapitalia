{set_defaults( hash(
    'thumbnail_class', 'squaremedium',
    'wide_class', 'reference',
    'items', array()
))}
{if count($items)}
<div class="it-carousel-wrapper it-carousel-landscape-abstract-three-cols">
    <div class="it-carousel-all owl-carousel it-card-bg">
        {foreach $items as $item}
            {def $caption = $item.name}
            {if $item|attribute( 'image' ).content.alternative_text}
                {set $caption = $item|attribute( 'image' ).content.alternative_text}
            {elseif $item|has_attribute( 'caption' )}
                {set $caption = $item.data_map.caption.data_text|oc_shorten(200)|wash()}
            {/if}
            <a class="text-decoration-none it-single-slide-wrapper mb-0" href={$item|attribute('image').content[$wide_class].url|ezroot} title="{$caption}" data-gallery>
                {if fetch(user,current_user).is_logged_in}
                    <div style="position: absolute; display: inline; white-space: nowrap; left: 0; top: 0; background: rgba(255, 255, 255, 0.7);">
                        {include uri="design:parts/toolbar/node_edit.tpl" current_node=$item}
                        {include uri="design:parts/toolbar/node_trash.tpl" current_node=$item}
                    </div>
                {/if}
                <figure class="mb-0">
                    {attribute_view_gui attribute=$item|attribute( 'image' )
                                image_class=$thumbnail_class
                                image_css_class=''
                                fluid=false()}
                    <figcaption class="figure-caption mt-2 text-truncate text-muted">
                        {$caption}
                    </figcaption>
                </figure>
            </a>
            {undef $caption}
        {/foreach}
    </div>
</div>
{/if}