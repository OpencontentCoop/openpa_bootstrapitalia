{set_defaults( hash(
    'i_view', 'card',
    'items', array(),
    'autoplay', 0,
    'items_per_row', 1,
    'image_class', 'carousel',
    'view_variation', 'alt',
    'navigation', true(),
    'pagination', false(),
    'auto_height', false(),
    'top_pagination_position', false(),
    'navigation_text', concat( "['", '<i class="fa fa-angle-left"></i>', "','", '<i class="fa fa-angle-right"></i>', "']"),
    'css_id', $root_node.node_id
))}

{if and( $root_node, $items )}
{if $root_node}
    <div id="carousel_{$css_id}" class="owl-carousel">
        {foreach $items as $item}
            <div class="item">
                {if $i_view|ne('carousel')}<div class="p-2">{/if}
                {node_view_gui content_node=$item.node view=$i_view image_class=$image_class event=$item view_variation=$view_variation}
                {if $i_view|ne('carousel')}</div>{/if}
            </div>
        {/foreach}
    </div>

    <script type="text/javascript">
        $(document).ready(function() {ldelim}
            $("#carousel_{$css_id}").owlCarousel({ldelim}
                items : {$items_per_row},
                itemsDesktop : [1000,{$items_per_row}], // items between 1000px and 901px
                itemsDesktopSmall : [900,{$items_per_row}], // betweem 900px and 601px
                itemsTablet: [600,{$items_per_row}], // items between 600 and 0
                itemsMobile : [400,1],
                autoPlay: {cond( $autoplay|gt(0), $autoplay, 'false')},
                navigation: {cond( $navigation|gt(0), 'true', 'false')},
                pagination: {cond( $pagination|gt(0), 'true', 'false')},
                {if $auto_height}autoHeight : true,{/if}
                navigationText: {cond( $navigation_text|ne(false()), $navigation_text, false )}
                {if $top_pagination_position},afterInit : function(elem){ldelim}var that = this;that.owlControls.prependTo(elem){rdelim}{/if}
                {rdelim});
            {rdelim});
    </script>


{/if}

{unset_defaults( array('i_view','items','autoplay','items_per_row', 'image_class','navigation','pagination','navigation_text','css_id'))}
