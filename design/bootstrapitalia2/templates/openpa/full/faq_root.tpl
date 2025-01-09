{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}
{ezpagedata_set( 'built_in_app', 'faq' )}

<div class="container">
    <div class="row justify-content-center">
        <div class="col-12 col-lg-10">
            <div class="cmp-hero">
                <section class="it-hero-wrapper bg-white align-items-start">
                    <div class="it-hero-text-wrapper pt-0 ps-0 pb-4 pb-lg-60">
                        <h1 class="text-black hero-title" data-element="page-name">{$node.name|wash()}</h1>
                        <div class="hero-text">
                            {include uri='design:openpa/full/parts/main_attributes.tpl'}
                            {if $node|has_attribute('description')}
                                {attribute_view_gui attribute=$node|attribute('description')}
                            {/if}
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>
</div>

{if openpaini('ViewSettings', 'FaqTreeView', 'disabled')|eq('disabled')}
    <div class="container mb-5">
        <div class="row">
            <div class="col-12 col-lg-8 offset-lg-2 px-sm-3 my-2 mb-5">
                {include uri='design:parts/faq_accordion.tpl'}
            </div>
        </div>
    </div>
{else}
    {def $page_limit = 6
         $items_per_row = 3
         $children_count = fetch( content, 'list_count', hash( 'parent_node_id', $node.node_id, 'class_filter_type', 'include', 'class_filter_array', array('faq_section','faq_group') ) )}
    {if $children_count}
        {if $children_count|eq(2)}{set $items_per_row = 2}{/if}
        {def $children = fetch( content, list, hash( 'parent_node_id', $node.node_id, 'class_filter_type', 'include', 'class_filter_array', array('faq_section','faq_group'), 'offset', $view_parameters.offset, 'sort_by', $sort_array, 'limit', $page_limit ) )}
        <section>
            <div class="container">
                {include uri='design:atoms/grid.tpl'
                         items_per_row=$items_per_row
                         i_view=card
                         image_class='imagelargeoverlay'
                         view_variation='w-100'
                         grid_wrapper_class='row g-4'
                         show_icon = false()
                         show_category = false()
                         items=$children}

                {include name=navigator
                         uri='design:navigator/google.tpl'
                         page_uri=$node.url_alias
                         item_count=$children_count
                         view_parameters=$view_parameters
                         item_limit=$page_limit}
            </div>
        </section>
        {undef $children}
    {/if}
    {undef $page_limit $items_per_row $children_count}
{/if}