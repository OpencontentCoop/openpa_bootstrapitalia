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

{include uri='design:openpa/full/parts/main_image.tpl'}

<div class="container">
    <div class="row">
        <div class="col-12 col-lg-8 offset-lg-2 px-sm-3 my-2">
            {include uri='design:parts/faq_accordion.tpl'}
        </div>
    </div>
</div>

{*
{def $faq_sections = fetch(content, list, hash('parent_node_id', $node.node_id, 'sort_by', $node.sort_array, 'class_filter_type', 'include', 'class_filter_array', array('faq_section')))}
{foreach $faq_sections as $faq_section}
    {def $faq_groups = fetch(content, list, hash('parent_node_id', $faq_section.node_id, 'sort_by', $node.sort_array, 'class_filter_type', 'include', 'class_filter_array', array('faq_group')))}
    {if count($faq_groups)|gt(0)}
        <section class="container mb-4">
            <div class="row border-top row-column-border row-column-menu-left attribute-list">
                <aside class="col-lg-4">
                    <div class="d-block d-lg-none d-xl-none text-center mb-2">
                        <a href="#toogle-sidemenu" role="button" class="btn btn-primary btn-md collapsed" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="toogle-sidemenu"><i class="fa fa-bars" aria-hidden="true"></i> {$faq_groups.name|wash()}</a>
                    </div>
                    <div class="d-lg-block d-xl-block collapse" id="toogle-sidemenu">
                        {foreach $faq_groups as $index => $faq_group}
                            {node_view_gui content_node=$faq_group view=banner_color image_class=medium view_variation=cond($index|ne(0), 'bg-white', '')}
                        {/foreach}
                    </div>
                </aside>
                <section class="col-lg-8 p-4">
                    <h4>{$faq_groups[0].name|wash()}</h4>
                    {include uri='design:openpa/full/parts/main_attributes.tpl' node=$faq_groups[0] openpa=object_handler($faq_groups[0])}
                    {include uri='design:parts/faq_accordion.tpl' node=$faq_groups[0]}
                </section>
            </div>
        </section>
    {/if}
    {undef $faq_groups}
{/foreach}
*}