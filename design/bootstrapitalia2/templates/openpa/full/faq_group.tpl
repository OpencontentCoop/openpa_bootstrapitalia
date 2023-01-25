{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'built_in_app', 'faq' )}

{def $parent = $node.parent}
{if $parent.class_identifier|ne('faq_section')}
    {set $parent = $node}
{/if}
{def $siblings = array()}
{if $parent.node_id|ne($node.node_id)}
    {set $siblings = fetch(content, list, hash('parent_node_id', $parent.node_id, 'sort_by', $parent.sort_array, 'class_filter_type', 'include', 'class_filter_array', array('faq_group')))}
{/if}
{if count($siblings)|eq(1)}
    {set $siblings = array()}
    {set $parent = $node}
{/if}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$parent.name|wash()}</h1>

            {if $parent|has_attribute('short_title')}
                <h2 class="h4 py-2">{$parent|attribute('short_title').content|wash()}</h2>
            {/if}

            {include uri='design:openpa/full/parts/main_attributes.tpl' node=$parent openpa=object_handler($parent)}

            {include uri='design:openpa/full/parts/info.tpl'}

        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>


{if count($siblings)}
<section class="container mb-4">
    <div class="row border-top row-column-border row-column-menu-left attribute-list">
        <aside class="col-lg-4">
            <div class="d-block d-lg-none d-xl-none text-center mb-2">
                <a href="#toogle-sidemenu" role="button" class="btn btn-primary btn-md collapsed" data-toggle="collapse" data-bs-toggle="collapse" aria-expanded="false" aria-controls="toogle-sidemenu"><i class="fa fa-bars" aria-hidden="true"></i> {$parent.name|wash()}</a>
            </div>
            <div class="d-lg-block d-xl-block collapse" id="toogle-sidemenu">
                {foreach $siblings as $sibling}
                    {node_view_gui content_node=$sibling view=banner_color image_class=medium view_variation=cond($sibling.node_id|ne($node.node_id), 'bg-white', '')}
                {/foreach}
            </div>
        </aside>
        <section class="col-lg-8 p-4">
            <h4>{$node.name|wash()}</h4>
            {include uri='design:openpa/full/parts/main_attributes.tpl'}
            {include uri='design:parts/faq_accordion.tpl' node=$node}
        </section>
    </div>
</section>
{else}
<section class="container mb-4">
    {include uri='design:parts/faq_accordion.tpl' node=$node}
</section>
{/if}

