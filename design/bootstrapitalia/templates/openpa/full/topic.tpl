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
                <div class="it-hero-card it-hero-bottom-overlapping px-2 px-lg-5 py-2 py-lg-5 rounded shadow">
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
    {attribute_view_gui attribute=$node|attribute('layout')}
{else}
    {def $blocks = array(
        page_block(
            "In evidenza", 
            "ListaAutomatica", 
            "lista_card_alt",
            hash(
                "limite", "3",
                "elementi_per_riga", "3",
                "includi_classi", "event,public_service",
                "escludi_classi", "",
                "ordinamento", "priority",
                "livello_profondita", "3",
                "state_id", "3",
                "color_style", "section section-muted section-inset-shadow pb-5",
                "container_style", "",
                "topic_node_id", $node.node_id
            )
        ),
        page_block(
            "Amministrazione", 
            "ListaPaginata", 
            "lista_paginata",
            hash(
                "limite", "3",
                "elementi_per_riga", "auto",
                "includi_classi", "employee,private_organization,public_organization,public_service,office",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", "",
                "container_style", "",
                "node_id", "2"
            )
        ),
        page_block(
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
                "color_style", "",
                "container_style", "",
                "node_id", "2"
            )
        ),
        page_block(
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
                "color_style", "",
                "container_style", "",
                "node_id", "2"
            )
        ),
        page_block(
            "Novità", 
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
                "color_style", "",
                "container_style", "",
                "node_id", "2"
            )
        )          
    )}

    {include uri='design:zone/default.tpl' zones=array(hash('blocks', $blocks))}
    
{/if}