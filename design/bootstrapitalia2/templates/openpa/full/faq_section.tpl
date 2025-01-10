{ezpagedata_set( 'has_container', true() )}

<section class="container cmp-heading">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {if $node|has_attribute('short_title')}
                <h2 class="h4 py-2">{$node|attribute('short_title').content|wash()}</h2>
            {/if}

            {include uri='design:openpa/full/parts/main_attributes.tpl'}

            {include uri='design:openpa/full/parts/info.tpl'}

        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>

{include uri='design:openpa/full/parts/main_image.tpl'}

{def $faq_groups = fetch(content, list, hash('parent_node_id', $node.node_id, 'sort_by', $node.sort_array, 'class_filter_type', 'include', 'class_filter_array', array('faq_group')))}
{if count($faq_groups)|gt(0)}
<section class="container mb-4">
    <div class="row border-top row-column-border row-column-menu-left attribute-list">
        <aside class="col-lg-4">
            <div class="d-block d-lg-none d-xl-none text-center mb-2">
                <a href="#toogle-sidemenu" role="button" class="btn btn-primary btn-md collapsed" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="toogle-sidemenu"><i class="fa fa-bars" aria-hidden="true"></i> {$faq_groups.name|wash()}</a>
            </div>
            <div class="d-lg-block d-xl-block collapse" id="toogle-sidemenu">
                {foreach $faq_groups as $index => $faq_group}
                    {node_view_gui content_node=$faq_group view=banner_color image_class=large view_variation=cond($index|ne(0), 'bg-white', '')}
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
