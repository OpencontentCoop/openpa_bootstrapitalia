<section class="bg-100">
    <div class="container">
        <div class="row">
            <div class="col mb-3">
                {if $openpa.content_gallery.has_images}
                    {if $openpa.content_gallery.has_single_images}
                        <div class="widget">
                            <div class="widget_content">
                                {include uri='design:atoms/gallery.tpl' items=$openpa.content_gallery.images title=false()}
                            </div>
                        </div>
                    {/if}
                    {if $openpa.content_gallery.has_galleries}
                        {foreach $openpa.content_gallery.galleries as $gallery}
                            <div class="widget">
                                <div class="widget_content">
                                    {include uri='design:atoms/gallery.tpl' items=fetch( content, list, hash( 'parent_node_id', $gallery.node_id, 'class_filter_type', 'include', 'class_filter_array', array( 'image' ))) title=false()}
                                </div>
                            </div>
                            {undef $add_link}
                        {/foreach}
                    {/if}
                {/if}
            </div>
        </div>
    </div>
</section>