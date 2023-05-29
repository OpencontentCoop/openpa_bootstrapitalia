{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'show_path',false() )}
{def $homepage = fetch('openpa', 'homepage')}

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
            <div class="col-12 px-0 px-lg-2 drop-shadow">
                <div class="it-hero-card it-hero-bottom-overlapping rounded hero-p">
                    <div class="row justify-content-center">
                        <div class="col-12 col-lg-10">
                            <div class="cmp-breadcrumbs mt-0" role="navigation">
                                <nav class="breadcrumb-container">
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
                    <div class="row justify-content-between mt-lg-2">
                        {def $has_managed = cond(or($node|has_attribute('managed_by_area'), $node|has_attribute('managed_by_political_body'), $node|has_attribute('help')), true(), false())}
                        <div class="col-12 col-lg-{if $has_managed}5{else}10{/if} offset-lg-1">
                            <h1 class="mb-3 mb-lg-4 title-xxlarge">{$node.name|wash()}</h1>
                            <div class="u-main-black text-paragraph-regular-medium mb-60">
                                {include uri='design:openpa/full/parts/main_attributes.tpl'}
                            </div>
                            {if and( $node.children_count, $node|has_attribute('show_topic_children'), $node|attribute('show_topic_children').data_int|eq(1) )}
                            <div class="mt-4">
                                {foreach $node.children as $child}
                                    <a class="text-decoration-none text-nowrap d-inline-block " href="{$child.url_alias|ezurl(no)}"><div class="chip chip-simple chip-{if $child.object.section_id|eq(1)}primary{else}danger{/if}"><span class="chip-label">{$child.name|wash()}</span></div></a>
                                {/foreach}
                            </div>
                            {/if}
                        </div>
                        {if $has_managed}
                        <div class="col-12 col-lg-5 me-lg-5 contact-section">
                            <h2 class="h3 title-xsmall-semi-bold">Questo argomento è gestito da:</h2>
                            <div class="card-wrapper card-column">
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
                        {undef $has_managed}
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
    {if api_search(concat('classes [public_person,private_organization,organization] and raw[submeta_topics___main_node_id____si] = ', $node.node_id, ' limit 1')).totalCount|gt(0)}
        {set $has_first_block = true()}
        {set $blocks = $blocks|append(page_block(
            'Amministrazione'|i18n('bootstrapitalia/menu'),
            "ListaAutomatica",
            "lista_card_teaser",
            hash(
                "limite", "9",
                "elementi_per_riga", "3",
                "includi_classi", "employee,private_organization,organization",
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
        {def $is_first_block = false()}
        {if $has_first_block|not()}{set $has_first_block = true()}{set $is_first_block = true()}{/if}
        {set $blocks = $blocks|append(page_block(
            'Servizi'|i18n('bootstrapitalia/menu'),
            "ListaAutomatica",
            "lista_card_teaser",
            hash(
                "limite", "9",
                "elementi_per_riga", "3",
                "includi_classi", "public_service",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", cond($is_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "node_id", "2"
            )
        ))}
        {undef $is_first_block}
    {/if}

    {if api_search(concat('classes [event,article] and raw[submeta_topics___main_node_id____si] = ', $node.node_id, ' limit 1')).totalCount|gt(0)}
        {def $is_first_block = false()}
        {if $has_first_block|not()}{set $has_first_block = true()}{set $is_first_block = true()}{/if}
        {set $blocks = $blocks|append(page_block(
            'Novità'|i18n('bootstrapitalia/menu'),
            "ListaAutomatica",
            "lista_card_teaser",
            hash(
                "limite", "9",
                "elementi_per_riga", "3",
                "includi_classi", "event,article",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", cond($is_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "node_id", "2"
            )
        ))}
        {undef $is_first_block}
    {/if}

    {if api_search(concat('classes [document] and raw[submeta_topics___main_node_id____si] = ', $node.node_id, ' limit 1')).totalCount|gt(0)}
        {def $is_first_block = false()}
        {if $has_first_block|not()}{set $has_first_block = true()}{set $is_first_block = true()}{/if}
        {set $blocks = $blocks|append(page_block(
            'Documenti'|i18n('bootstrapitalia/menu'),
            "ListaAutomatica",
            "lista_card_teaser",
            hash(
                "limite", "9",
                "elementi_per_riga", "3",
                "includi_classi", "document",
                "escludi_classi", "",
                "ordinamento", "modificato",
                "state_id", "",
                "topic_node_id", $node.node_id,
                "color_style", cond($is_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "node_id", "2"
            )
        ))}
        {undef $is_first_block}
    {/if}

    {if and($node|has_attribute('show_topic_children'), $node|attribute('show_topic_children').data_int|eq(1), fetch( content, 'list_count', hash( 'parent_node_id', $node.node_id, 'class_filter_type', 'include', 'class_filter_array', array('topic') ) ))|gt(0)}
        {def $is_first_block = false()}
        {if $has_first_block|not()}{set $has_first_block = true()}{set $is_first_block = true()}{/if}
        {set $blocks = $blocks|append(page_block(
            "",
            "ListaAutomatica",
            "lista_card_alt",
            hash(
                "limite", "30",
                "elementi_per_riga", "3",
                "includi_classi", "topic",
                "escludi_classi", "",
                "ordinamento", "name",
                "state_id", "",
                "topic_node_id", "",
                "color_style", cond($is_first_block, 'section section-muted section-inset-shadow pb-5', ''),
                "container_style", "",
                "livello_profondita", 1,
                "node_id", $node.node_id
            )
        ))}
        {undef $is_first_block}
    {/if}

    {if $blocks|count()}
        {include uri='design:zone/default.tpl' zones=array(hash('blocks', $blocks))}
    {else}
        <section class="page-topic section section-muted section-inset-shadow pb-5" id=""></section>
    {/if}

{/if}
