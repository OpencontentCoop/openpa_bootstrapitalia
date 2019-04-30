<section class="container">
    <div class="row">
    <h1>{"New content since last visit"|i18n("design/standard/content/newcontent")}</h1>
    <p>{"Your last visit to this site was"|i18n("design/standard/content/newcontent")}:
        {$last_visit_timestamp|l10n(datetime)}
    </p>
    </div>
</section>

{let page_limit=21
     time_filter=array( array( 'published', '>=', $last_visit_timestamp ) )
     list_count=fetch( content, tree_count, hash( parent_node_id, 2,
                                                  offset, first_set( $view_parameters.offset, 0),
                                                  attribute_filter, $time_filter ) )}

        <div class="container mt-2">
            {if $list_count}                                
                {include uri='design:atoms/grid.tpl'
                         items_per_row=3
                         i_view=card
                         view_variation='big'
                         image_class=large
                         items=fetch( content, tree, hash( parent_node_id, 2,
                                                     offset, first_set( $view_parameters.offset, 0),
                                                     attribute_filter, $time_filter,
                                                     sort_by, array( array( 'modified', false() ) ),
                                                     limit, $page_limit ) )}
            {else}
                <p>{"There is no new content since your last visit."|i18n("design/standard/content/newcontent")}</p>
            {/if}
        </div>

        {include name=navigator
                 uri='design:navigator/google.tpl'
                 page_uri='/content/new'
                 item_count=$list_count
                 view_parameters=$view_parameters
                 item_limit=$page_limit}
    {/let}
