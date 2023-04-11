{set_defaults( hash(
    'i_view', 'carousel',
    'items', array(),
    'autoplay', 0,
    'items_per_row', 1,
    'view_variation', false(),
    'loop', 0,
    'image_class', 'agid_carousel',
    'navigation', true(),
    'pagination', false(),
    'control_buttons', false(),
    'auto_height', true(),
    'top_pagination_position', true(),
    'show_items_preview', false(),
    'wide_items_preview', false(),
    'navigation_text', concat( "['", '<span class="u-alignMiddle Icon Icon-arrow-left" role="presentation"></span>', "','", '<span class="u-alignMiddle Icon Icon-arrow-right" role="presentation"></span>', "']"),
    'css_id', $root_node.node_id
))}

{if and( $root_node, $items )}

    <div id="carousel_{$css_id}" class="owl-carousel owl-theme clearfix">
        {foreach $items as $item}
            {if $i_view|ne('carousel')}<div class="p-2">{/if}
            {node_view_gui content_node=$item view=$i_view image_class=$image_class items_per_row=$items_per_row view_variation=$view_variation}
            {if $i_view|ne('carousel')}</div>{/if}
        {/foreach}
    </div>

    {ezcss_require(array('owl.carousel.min.css'))}

    <script>
        $(document).ready(function(){ldelim}
            $("#carousel_{$css_id}").initOwlCarousel(
                {ldelim}
                    responsive:{ldelim}
                        0: {ldelim}
                            items: 1
                            {rdelim},
                        480: {ldelim}
                            items: 1
                            {rdelim},
                        768: {ldelim}
                            items: {$items_per_row}
                            {rdelim},
                        900: {ldelim}
                            items: {$items_per_row}
                            {rdelim},
                        1200: {ldelim}
                            items: {$items_per_row}
                            {rdelim},
                        {rdelim},
                    nav: {cond( $navigation|gt(0), 'true', 'false')},
                    dots: {cond( $pagination|gt(0), 'true', 'false')},
                    autoHeight : false,
                    loop:{cond( $loop|gt(0), 'true', 'false')},
                    autoplaySpeed: 1000,
                    autoplay: {cond( $autoplay|gt(0), 'true', 'false')},
                    navText: {cond( $navigation_text|ne(false()), $navigation_text, false )}
                    {if $top_pagination_position}, onInitialized: function(e){ldelim}
                      var owl = $(e.target);
                      owl.find('.owl-nav').prependTo(owl);
                      {if $show_items_preview}
                      owl.find('.owl-dots').addClass('d-block d-md-none d-lg-none');
                      {/if}
                      {rdelim}
                    {/if}
                {rdelim},
                {if and($show_items_preview,count($items)|gt(1))}true{else}false{/if},
                {if $wide_items_preview}true{else}false{/if},
                {if $control_buttons}true{else}false{/if}
            );
        {rdelim});
    </script>
{/if}

{unset_defaults( array('i_view','items','autoplay','items_per_row', 'image_class','navigation','pagination','navigation_text','css_id'))}
