{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}

<div class="container">
    <div class="row justify-content-center row-shadow">
        {if fetch('openpa', 'homepage').node_id|eq($node.node_id)}
            <div class="warning my-5">
                {'Opencity non è installato. Contatta il supporto tecnico'|i18n('bootstrapitalia')}
            </div>
        {else}
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
        {/if}
    </div>
</div>

{if $node.object.remote_id|eq('e7ff633c6b8e0fd3531e74c6e712bead')}
    {include uri='design:zone/default.tpl' zones=array(hash('blocks', array(page_block(
        "",
        "OpendataRemoteContents",
        "default",
        hash(
            "remote_url", "",
            "query", concat("raw[meta_main_parent_node_id_si] = '",$node.node_id,"' and sort [name=>asc]"),
            "show_grid", "1",
            "show_map", "0",
            "show_search", "1",
            "limit", "9",
            "items_per_row", "3",
            "facets", "",
            "view_api", "card_image",
            "color_style", "",
            "fields", "",
            "template", "",
            "simple_geo_api", "1",
            "input_search_placeholder", ""
            )
        )
    )))}
{else}
    {include uri='design:parts/children/default.tpl' view_variation='py-5' view_parameters=$view_parameters}
{/if}