{set_defaults( hash(
    'thumbnail_class', 'medium',
    'wide_class', 'reference',
    'items', array()
))}
{if count($items)}
<div class="it-carousel-wrapper it-carousel-landscape-abstract-three-cols splide mb-4" data-bs-carousel-splide>
    <div class="splide__track">
        <ul class="splide__list">
            {foreach $items as $item}
                {def $caption = $item.name}
                {if $item|attribute( 'image' ).content.alternative_text}
                    {set $caption = $item|attribute( 'image' ).content.alternative_text}
                {elseif $item|has_attribute( 'caption' )}
                    {set $caption = $item.data_map.caption.data_text|oc_shorten(200)|wash()}
                {/if}
                <li class="splide__slide">
                    <div class="it-single-slide-wrapper">
                        <div class="card-wrapper pb-0">
                            <a class="card card-img no-after" title="{$caption}" data-gallery href={$item|attribute('image').content[$wide_class].url|ezroot}>
                                <div class="img-responsive-wrapper">
                                    <div class="img-responsive">
                                        <div class="img-wrapper">
                                            {attribute_view_gui attribute=$item|attribute( 'image' )
                                                                image_class=$thumbnail_class
                                                                image_css_class='img-fluid of-contain bg-light'}
                                        </div>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <p class="h5 fw-normal card-title mb-0">{$caption}</p>
                                </div>
                            </a>
                        </div>
                    </div>
                </li>
                {undef $caption}
            {/foreach}
        </ul>
    </div>
</div>
{/if}