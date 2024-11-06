<div class="container">
    <div class="row justify-content-center">
        <div class="col-12">
            <div class="cmp-hero">
                <section class="it-hero-wrapper bg-white d-block">
                    <div class="it-hero-text-wrapper pt-0 ps-0 pb-0">
                        <h1 class="text-black hero-title" data-element="page-name">
                            {$node.name|wash()}
                        </h1>
                        <div class="hero-text">
                            {include uri='design:openpa/full/parts/main_attributes.tpl'}
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>
</div>

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
        "view_api", "card",
        "color_style", "",
        "fields", "",
        "template", "",
        "simple_geo_api", "1",
        "input_search_placeholder", ""
        )
    )
)))}