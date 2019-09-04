{set_defaults( hash(
    'thumbnail_class', 'squarethumb',
    'wide_class', 'reference',
    'items', array()
))}

<div class="it-carousel-wrapper it-carousel-landscape-abstract-three-cols">
    <div class="it-carousel-all owl-carousel it-card-bg">
        {foreach $items as $item}
            {def $caption = $item.name}
            {if $item|attribute( 'image' ).content.alternative_text}
                {set $caption = $item|attribute( 'image' ).content.alternative_text}
            {elseif $item|has_attribute( 'caption' )}
                {set $caption = $item.data_map.caption.data_text|oc_shorten(200)|wash()}
            {/if}
            <a class="it-single-slide-wrapper mb-0" href={$item|attribute('image').content[$wide_class].url|ezroot} title="{$caption}" data-gallery>
                <figure class="mb-0">
                    {attribute_view_gui attribute=$item|attribute( 'image' )
                                image_class=$thumbnail_class
                                image_css_class='img-fluid'
                                fluid=true()}
                    <figcaption class="figure-caption mt-2 text-truncate">
                        {$caption}
                    </figcaption>
                </figure>
            </a>
            {undef $caption}
        {/foreach}
    </div>
</div>
