{def $openpa = object_handler($node)}
{if $openpa.control_cache.no_cache}
    {set-block scope=root variable=cache_ttl}0{/set-block}
{/if}

{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'show_path',false() )}
{def $homepage = fetch('openpa', 'homepage')}
{def $has_managed = cond(or($node|has_attribute('managed_by_area'), $node|has_attribute('managed_by_political_body'), $node|has_attribute('help')), true(), false())}

<div class="it-hero-wrapper it-wrapped-container" id="main-container">

    {if $node|has_attribute('image')}
        <div class="img-responsive-wrapper">
            <div class="img-responsive">
                <div class="img-wrapper">
                    {attribute_view_gui attribute=$node|attribute('image') image_class=reference}
                </div>
            </div>
        </div>
    {/if}
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="it-hero-card drop-shadow it-hero-bottom-overlapping rounded px-lg-5 py-4 py-lg-5">
                    <div class="row justify-content-center">
                        <div class="col-12">
                            <div class="cmp-breadcrumbs mt-0" role="navigation">
                                <nav class="breadcrumb-container" aria-label="breadcrumb">
                                    <ol class="breadcrumb p-0" data-element="breadcrumb">
                                        {foreach $node.path as $item}
                                            <li class="breadcrumb-item">
                                                <a href="{$item.url_alias|ezurl(no)}">{$item.name|wash()}</a>
                                                <span class="separator">/</span>
                                            </li>
                                        {/foreach}
                                        <li class="breadcrumb-item active" aria-current="page">
                                            {$node.name|wash()}
                                        </li>
                                    </ol>
                                </nav>
                            </div>
                        </div>
                    </div>
                    <div class="row sport-wrapper justify-content-between mt-lg-2">
                        <div class="col-12{if $has_managed} col-lg-5 pl-lg-5{else} col-lg-10 pl-lg-10{/if}">
                            <h1 class="mb-3">{$node.name|wash()}</h1>
                            <div class="u-main-black text-secondary mb-5">
                                {include uri='design:openpa/full/parts/main_attributes.tpl'}
                            </div>
                            {if and( $node.children_count, $node|has_attribute('show_topic_children'), $node|attribute('show_topic_children').data_int|eq(1) )}
                                <div class="mt-4">
                                    {foreach $node.children as $child}
                                        {if topic_has_contents($child.contentobject_id)}
                                        <a class="text-decoration-none text-nowrap d-inline-block mb-1" href="{$child.url_alias|ezurl(no)}"><div class="chip chip-simple chip-primary {if $child.object.section_id|ne(1)}no-sezioni_per_tutti{/if}"><span class="chip-label">{$child.name|wash()}</span></div></a>
                                        {/if}
                                    {/foreach}
                                </div>
                            {/if}
                        </div>
                        {if $has_managed}
                        <div class="col-12 col-lg-5">
                            <div class="card-wrapper card-column">
                                <h3 class="title-xsmall-semi-bold text-secondary">Questo argomento è gestito da:</h3>
                                {if $node|has_attribute('managed_by_area')}
                                    {foreach $node|attribute('managed_by_area').content.relation_list as $item}
                                        {def $object = fetch(content, object, hash('object_id', $item.contentobject_id))}
                                        {if $object.can_read}
                                            {content_view_gui content_object=$object view=embed show_icon=false()}
                                        {/if}
                                        {undef $object}
                                    {/foreach}
                                {/if}
                                {if $node|has_attribute('managed_by_political_body')}
                                    {foreach $node|attribute('managed_by_political_body').content.relation_list as $item}
                                        {def $object = fetch(content, object, hash('object_id', $item.contentobject_id))}
                                        {if $object.can_read}
                                            {content_view_gui content_object=$object view=embed show_icon=false()}
                                        {/if}
                                        {undef $object}
                                    {/foreach}
                                {/if}
                                {if $node|has_attribute('help')}
                                    {foreach $node|attribute('help').content.relation_list as $item}
                                        {def $object = fetch(content, object, hash('object_id', $item.contentobject_id))}
                                        {if $object.can_read}
                                            {content_view_gui content_object=$object view=embed show_icon=false()}
                                        {/if}
                                        {undef $object}
                                    {/foreach}
                                {/if}
                            </div>
                        </div>
                        {/if}
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

{if $node|has_attribute('layout')}
    <div style="min-height: 80px">
        {attribute_view_gui attribute=$node|attribute('layout')}
    </div>
{/if}
{def $blocks = array()}
{def $banner = fetch(content, object, hash(remote_id, 'banner-pnrr'))}
{if and($banner, $banner.can_read)}
    {set $blocks = $blocks|append(page_block(
        '',
        "Singolo",
        "simple",
        hash(
            "container_style", "",
            ),
        array($banner.main_node)
        )
    )}
{/if}
{undef $banner}

{def $projects = fetch(content, object, hash(remote_id, 'all-projects'))}
{if $projects}
    {def $missions = hash(
        "Missione 1 - Digitalizzazione innovazione competitività cultura e turismo", "Digitalizzazione innovazione competitività cultura e turismo (M1)",
        "Missione 2 - Rivoluzione verde e Transizione ecologica", "Rivoluzione verde e Transizione ecologica (M2)",
        "Missione 3 - Infrastrutture per una mobilità sostenibile", "Infrastrutture per una mobilità sostenibile (M3)",
        "Missione 4 - Istruzione e Ricerca", "Istruzione e Ricerca (M4)",
        "Missione 5 - Inclusione e Coesione", "Inclusione e Coesione (M5)",
        "Missione 6 - Salute", "Salute (M6)"
    )}
    {def $has_intro = false()}
    {foreach $missions as $tag => $name}
    {if api_search(concat("classes [public_project] and mission = '", $tag, "' limit 1")).totalCount|gt(0)}
        {if $has_intro|not()}
            {set $blocks = $blocks|append(page_block(
                "",
                "HTML",
                "html",
                hash(
                    "html", '<div class="col-12"><h2 class="mt-5 card-title big-heading">Progetti finanziati dal PNRR</h3></div>'
                )
            ))}
            {set $has_intro = true()}
        {/if}
        {set $blocks = $blocks|append(page_block(
            "",
            "ListaAutomatica",
            "lista",
            hash(
                "limite", "300",
                "elementi_per_riga", "1",
                "includi_classi", "public_project",
                "escludi_classi", "",
                "ordinamento", "name",
                "state_id", "",
                "topic_node_id", "",
                "color_style", "",
                "container_style", "my-5",
                "livello_profondita", 1,
                "node_id", $projects.main_node_id,
                "tags", concat('/Progetti pubblici/Strumento di programmazione/PNRR/',$tag),
                "intro_text", concat('<strong>', $name|wash(), '</strong>')
            )
        ))}
    {/if}
    {/foreach}
{/if}

{if $blocks|count()}
    {include uri='design:zone/default.tpl' zones=array(hash('blocks', $blocks))}
{else}
    <section class="page-topic section section-muted section-inset-shadow pb-5" id=""></section>
{/if}



{if and($openpa.content_tools.editor_tools, module_params().function_name|ne('versionview'))}
    {include uri=$openpa.content_tools.template}
{/if}

{if $homepage.node_id|eq($node.node_id)}
    {ezpagedata_set('is_homepage', true())}
{/if}
{if and(openpaini('GeneralSettings','Valuation', 1), $node.class_identifier|ne('valuation'))}
    {ezpagedata_set('show_valuation', true())}
{/if}
{ezpagedata_set('opengraph', $openpa.opengraph.generate_data)}

{def $easyontology = class_extra_parameters($node.object.class_identifier, 'easyontology')}
{if and($easyontology, $easyontology.enabled, $easyontology.easyontology|ne(''))}
    {def $jsonld = $node.contentobject_id|easyontology_to_json($easyontology.easyontology)}
    {if $jsonld}<script data-element="metatag" type="application/ld+json">{$jsonld}</script>{/if}
{/if}

{if $node.object.state_identifier_array|contains('opencity_lock/locked')}
    {ezpagedata_set('is_opencity_locked', true())}
{/if}

{undef $openpa}