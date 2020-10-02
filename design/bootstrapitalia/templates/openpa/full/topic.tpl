{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'show_path',false() )}
{def $homepage = fetch('openpa', 'homepage')}

<div class="it-hero-wrapper it-wrapped-container">
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
            <div class="col-12 px-lg-5">
                <div class="it-hero-card it-hero-bottom-overlapping px-2 px-lg-5 py-2 py-lg-5 rounded" style="box-shadow: 0 -1rem 1rem rgba(0,0,0,0.15) !important">
                    <div class="container">
                        <div class="row">
                            <div class="col">
                                <nav class="breadcrumb-container" aria-label="breadcrumb">
                                    <ol class="breadcrumb">
                                        <li class="breadcrumb-item">
                                            <a href="{'/'|ezurl(no)}">{$homepage.name|wash()}</a>
                                        </li>
                                        <li class="breadcrumb-item">
                                            <a href="{$node.parent.url_alias|ezurl(no)}">{$node.parent.name|wash()}</a>
                                        </li>
                                        <li class="breadcrumb-item active" aria-current="page">
                                            {$node.name|wash()}
                                        </li>
                                    </ol>
                                </nav>   
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-6">
                                <h1>{$node.name|wash()}</h1>
                                {include uri='design:openpa/full/parts/main_attributes.tpl'}
                            </div>         
                            <div class="col-lg-4 offset-lg-2">
                            </div>
                        </div>                    
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
{else}
    {def $blocks = array()}
    {def $has_first_block = false()}
    {if api_search(concat('classes [employee,private_organization,public_organization,office] and raw[submeta_topics___main_node_id____si] = ', $node.node_id, ' limit 1')).totalCount|gt(0)}
        {set $has_first_block = true()}
        {set $blocks = $blocks|append(page_block(
            "Amministrazione",
            "ListaPaginata",
            "lista_paginata",
            hash(
                "limite", "3",
                "elementi_per_riga", "auto",
                "includi_classi", "employee,private_organization,public_organization,office",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", cond($has_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "node_id", "2"
            )
        ))}
    {/if}

    {if api_search(concat('classes [public_service] and raw[submeta_topics___main_node_id____si] = ', $node.node_id, ' limit 1')).totalCount|gt(0)}
        {set $has_first_block = true()}
        {set $blocks = $blocks|append(page_block(
            "Servizi",
            "ListaPaginata",
            "lista_paginata",
            hash(
                "limite", "3",
                "elementi_per_riga", "auto",
                "includi_classi", "public_service",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", cond($has_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "node_id", "2"
            )
        ))}
    {/if}

    {if api_search(concat('classes [event,article] and raw[submeta_topics___main_node_id____si] = ', $node.node_id, ' limit 1')).totalCount|gt(0)}
        {set $has_first_block = true()}
        {set $blocks = $blocks|append(page_block(
            "Novità",
            "ListaPaginata",
            "lista_paginata",
            hash(
                "limite", "3",
                "elementi_per_riga", "auto",
                "includi_classi", "event,article",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", cond($has_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "node_id", "2"
            )
        ))}
    {/if}

    {if api_search(concat('classes [event,public_service] and raw[submeta_topics___main_node_id____si] = ', $node.node_id, ' limit 1')).totalCount|gt(0)}
        {set $has_first_block = true()}
        {set $blocks = $blocks|append(page_block(
            "Documenti",
            "ListaPaginata",
            "lista_paginata",
            hash(
                "limite", "3",
                "elementi_per_riga", "auto",
                "includi_classi", "document",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", cond($has_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "node_id", "2"
            )
        ))}
    {/if}
    {if fetch( content, 'list_count', hash( 'parent_node_id', $node.node_id, 'class_filter_type', 'include', 'class_filter_array', array('topic') ) )|gt(0)}
        {set $has_first_block = true()}
        {set $blocks = $blocks|append(page_block(
            "",
            "ListaAutomatica",
            "lista_card",
            hash(
                "limite", "30",
                "elementi_per_riga", "3",
                "includi_classi", "topic",
                "escludi_classi", "",
                "ordinamento", "name",
                "state_id", "",
                "topic_node_id", "",
                "color_style", cond($has_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "livello_profondita", 1,
                "node_id", $node.node_id
            )
        ))}
    {/if}

    {if $blocks|count()}
        {include uri='design:zone/default.tpl' zones=array(hash('blocks', $blocks))}
    {else}
        <section class="page-topic section section-muted section-inset-shadow pb-5" id=""></section>
    {/if}

{/if}
